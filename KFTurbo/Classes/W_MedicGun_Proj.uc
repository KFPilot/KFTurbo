class W_MedicGun_Proj extends HealingProjectile;

var KFHumanPawn HitHumanPawn;
//Used by KFSteamStats
var bool bIsMP7Projectile, bIsMP5Projectile;

simulated function PostNetReceive()
{
     if( bHidden && !bHitHealTarget && HealLocation != vect(0,0,0))
     {
          HitHealTarget(HealLocation,vector(HealRotation));
     }
}

simulated function Destroyed()
{
	if (SmokeTrail != None)
	{
		SmokeTrail.HandleOwnerDestroyed();
	}

	if(!bHitHealTarget && HealLocation != vect(0,0,0))
	{
          HitHealTarget(Location,-vector(Rotation));
     }
	else if(!bHasExploded)
     {
		Explode(Location,-vector(Rotation));
     }

    Super(ROBallisticProjectile).Destroyed();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
     local ROBulletHitEffect ExplosionEffect;
     bHasExploded = True;

     // Don't do the regular effect if we healed someone
     if( bHitHealTarget )
     {
          return;
     }

     SetPhysics(PHYS_None);

     if(Level.NetMode != NM_DedicatedServer)
     {
          ExplosionEffect = Spawn(class'ROBulletHitEffect',,, Location, rotator(-HitNormal));
          ExplosionEffect.SetDrawScale(0.15f);
     }

     BlowUp(HitLocation);
     Destroy();
}

state WaitForServerHeal
{
Begin:
     Sleep(1.f);
     Destroy();
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local KFHumanPawn Healed;
	local KFPlayerReplicationInfo PRI;
	local float MedicReward;
	local float HealSum; // for modifying based on perks

     if (bHasExploded)
     {
          return;
     }

	if ( Other == None || Other == Instigator || Other.Base == Instigator )
     {
          return;
     }

    	Healed = KFHumanPawn(Other);

     if (Healed == None)
     {
          Healed = KFHumanPawn(Other.Base);
     }
	
     if (Role != ROLE_Authority)
     {
          bHidden = true;
          SetPhysics(PHYS_None);

          if (Healed == None)
          {
               Explode(HitLocation,-vector(Rotation));
          }
          else
          {
               GotoState('WaitForServerHeal');
          }
          return;
     }

     if (Instigator == none || Healed == None || Healed.Health <= 0 || Healed.Health >= Healed.HealthMax || !Healed.bCanBeHealed)
     {
          bHidden = true;
          SetPhysics(PHYS_None);
	     Explode(HitLocation, -vector(Rotation));
          return;
     }
     
     HitHealTarget(HitLocation, -vector(Rotation));
     
     MedicReward = HealBoostAmount;
    	
     PRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);

     if ( PRI != none && PRI.ClientVeteranSkill != none )
     {
          MedicReward *= PRI.ClientVeteranSkill.Static.GetHealPotency(PRI);
     }
     
     HealSum = MedicReward;
     MedicReward = Min(MedicReward, FMax((Healed.HealthMax - float(Healed.Health)) - Healed.HealthToGive, 0.f)); //How much we actually gave as health to heal.

     Healed.GiveHealth(HealSum, Healed.HealthMax);

     if (MedicReward <= 0)
     {
	     Explode(HitLocation, -vector(Rotation));
          return;
     }

     if ( KFHumanPawn(Instigator) != none )
     {
          KFHumanPawn(Instigator).AlphaAmount = 255;
     }

     if( KFMedicGun(Instigator.Weapon) != none )
     {
          KFMedicGun(Instigator.Weapon).ClientSuccessfulHeal(Healed.GetPlayerName());
     }

     if ( PRI == None )
     {
	     Explode(HitLocation, -vector(Rotation));
          return;
     }

     HitHumanPawn = Healed;
     AddDamagedHealStats( MedicReward );

     MedicReward = int((MedicReward / Healed.HealthMax) * 60);

     PRI.ReceiveRewardForHealing( MedicReward, Healed );

     Explode(HitLocation, -vector(Rotation));
}


function AddDamagedHealStats( int MedicReward )
{
    local KFSteamStatsAndAchievements KFSteamStats;

	if ( Instigator == none || Instigator.PlayerReplicationInfo == none )
	{
		return;
	}

	KFSteamStats = KFSteamStatsAndAchievements( Instigator.PlayerReplicationInfo.SteamStatsAndAchievements );

	if ( KFSteamStats != none )
	{
	 	KFSteamStats.AddDamageHealed(MedicReward, bIsMP7Projectile, bIsMP5Projectile);
	}

     class'TurboHealEventHandler'.static.BroadcastPawnDartHealed(Instigator, HitHumanPawn, MedicReward, Self);
}

defaultproperties
{
     bIsMP7Projectile=false
     bIsMP5Projectile=false
}
