class V_FieldMedic_Grenade extends KFMod.MedicNade;

simulated function Explode(vector HitLocation, vector HitNormal)
{
    Super.Explode(HitLocation, HitNormal);

    LightType = LT_None;
    bDynamicLight = false;
}

simulated function HitWall( vector HitNormal, actor Wall )
{
    local Vector VNorm;
	local PlayerController PC;

	if ( (Pawn(Wall) != None) || (GameObjective(Wall) != None) )
	{
		Explode(Location, HitNormal);
		return;
	}

    if (!bTimerSet)
    {
        SetTimer(ExplodeTimer, false);
        bTimerSet = true;
    }

    // Reflect off Wall w/damping
    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

    RandSpin(100000);
    Speed = VSize(Velocity);

    if ( Speed < 10 )
    {
        bBounce = False;
        Timer();
        SetTimer(0.0,False);

		class'WeaponHelper'.static.BeginGrenadeSmoothRotation(self, 20);

		if( Fear == none )
		{
		    //(jc) Changed to use MedicNade-specific grenade that's overridden to not make the ringmaster fear it
		    Fear = Spawn(class'AvoidMarker_MedicNade');
    		Fear.SetCollisionSize(DamageRadius,DamageRadius);
    		Fear.StartleBots();
		}

        if ( Trail != None )
            Trail.mRegen = false; // stop the emitter from regenerating
    }
    else
    {
		if ( (Level.NetMode != NM_DedicatedServer) && (Speed > 50) )
		{
			PlaySound(ImpactSound, SLOT_Misc );
		}

        if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && (Level.TimeSeconds - LastSparkTime > 0.5) && EffectIsRelevant(Location,false) )
        {
			PC = Level.GetLocalPlayerController();
			if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 6000 )
				Spawn(HitEffectClass,,, Location, Rotator(HitNormal));
            LastSparkTime = Level.TimeSeconds;
        }
    }
}


function HealOrHurt(float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation)
{
	local Actor Target;
	local Pawn PawnTarget;
	local KFMonster MonsterTarget;
	local KFPawn KFPawnTarget;

	local float DamageScale;
    
	local int NumKilled;
	local array<Pawn> CheckedPawns;
	local int i;
	local bool bAlreadyChecked;
	// Healing
	local KFPlayerReplicationInfo PRI;
	local int MedicReward;
	local float HealSum; // for modifying based on perks
	local int PlayersHealed;

	if ( bHurtEntry )
    {
		return;
    }

    NextHealTime = Level.TimeSeconds + HealInterval;

	bHurtEntry = true;

	if( Fear != none )
	{
		Fear.StartleBots();
	}

    if( Instigator == None || Instigator.Health <= 0 )
    {
        return;
    }

    PRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);

	foreach CollidingActors (class 'Actor', Target, DamageRadius, HitLocation)
	{
        if (Target == Self || Target == Hurtwall || Target.Role != ROLE_Authority || Target.IsA('FluidSurfaceInfo') )
        {
            continue;
        }
			
        DamageScale = 1.0;

        if ( Instigator == None || Instigator.Controller == None )
        {
            Target.SetDelayedDamageInstigatorController( InstigatorController );
        }

		PawnTarget = Pawn(Target);

        if (PawnTarget == None || PawnTarget.Health <= 0)
        {
            continue;
        }

        for (i = 0; i < CheckedPawns.Length; i++)
        {
            if (CheckedPawns[i] == PawnTarget)
            {
                bAlreadyChecked = true;
                break;
            }
        }

        if( bAlreadyChecked )
        {
            bAlreadyChecked = false;
            PawnTarget = none;
            continue;
        }

        MonsterTarget = KFMonster(Target);
        KFPawnTarget = KFPawn(Target);

        if( MonsterTarget != none )
        {
            DamageScale *= MonsterTarget.GetExposureTo(Location + 15 * -Normal(PhysicsVolume.Gravity));
        }
        else if( KFPawnTarget != none )
        {
            DamageScale *= KFPawnTarget.GetExposureTo(Location + 15 * -Normal(PhysicsVolume.Gravity));
        }

        CheckedPawns[CheckedPawns.Length] = PawnTarget;

        PawnTarget = none;

        if ( DamageScale <= 0 )
        {
            continue;
        }

        if( MonsterTarget != None )
        {
            MonsterTarget.TakeDamage(DamageScale * DamageAmount, Instigator, Target.Location, vect(0,0,0), DamageType);

            if( MonsterTarget.Health <= 0 )
            {
                NumKilled++;
            }
            
            continue;
        }

        if( KFPawnTarget.Health >= KFPawnTarget.HealthMax || !KFPawnTarget.bCanBeHealed )
        {
            continue;
        }
        
        PlayersHealed += 1;
        MedicReward = HealBoostAmount;

        if ( PRI != none && PRI.ClientVeteranSkill != none )
        {
            MedicReward *= PRI.ClientVeteranSkill.Static.GetHealPotency(PRI);
        }

        HealSum = MedicReward;
        MedicReward = Min(MedicReward, FMax((KFPawnTarget.HealthMax - float(KFPawnTarget.Health)) - KFPawnTarget.HealthToGive, 0.f)); 
        
        KFPawnTarget.GiveHealth(HealSum, KFPawnTarget.HealthMax);

        class'TurboEventHandler'.static.BroadcastPawnGrenadeHealed(Instigator, KFPawnTarget, MedicReward);

        if ( PRI == None || MedicReward <= 0 )
        {
            continue;
        }

        if ( KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements) != none )
        {
            KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements).AddDamageHealed(MedicReward, false, false);
        }

        // Give the medic reward money as a percentage of how much of the person's health they healed
        MedicReward = int((float(MedicReward) / KFPawnTarget.HealthMax) * 60.f);

        PRI.ReceiveRewardForHealing( MedicReward, KFPawnTarget );

        if ( KFHumanPawn(Instigator) != none )
        {
            KFHumanPawn(Instigator).AlphaAmount = 255;
        }

        if( PlayerController(Instigator.Controller) != none )
        {
            PlayerController(Instigator.Controller).ClientMessage(SuccessfulHealMessage$KFPawnTarget.GetPlayerName(), 'CriticalEvent');
        }
	}

    if (PRI != none && PlayersHealed >= MaxNumberOfPlayers)
    {
        KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements).HealedTeamWithMedicGrenade();
    }

	bHurtEntry = false;
}

defaultproperties
{
	LightType=LT_Pulse
    LightBrightness=64
	LightPeriod=16
    LightRadius=0.500000
    LightHue=62
    LightSaturation=150
    bDynamicLight=True

    DampenFactor=0.250000
    DampenFactorParallel=0.35

    StaticMesh=StaticMesh'KFTurbo.T10.T10Projectile'
	Skins(0)=Texture'KFTurbo.G28.G28MedicGrenade'
    DrawScale=0.2
	
	Physics=PHYS_Falling
	bUseCollisionStaticMesh = false
	bUseCylinderCollision = false
	bFixedRotationDir = true

	CollisionRadius=6
    CollisionHeight=6
    RotationRate=(Roll=0)
}