class W_NailGun_Proj extends NailGunProjectile;

var array<Pawn> HitPawnList;

event PreBeginPlay()
{
	Super.PreBeginPlay();

	class'WeaponHelper'.static.NotifyPostProjectileSpawned(self);
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
     local vector X;
     local Vector TempHitLocation, HitNormal;
     local array<int>	HitPoints;
     local KFPawn HitPawn;
     local bool bWasDecapitated;
     local KFMonster KFM;

	if (Other == None || Other == Instigator || Other.Base == Instigator || !Other.bBlockHitPointTraces)
     {
		return;
     }

	if (bFinishedPenetrating)
	{
	   return;
	}

    X = Vector(Rotation);

 	if (ROBulletWhipAttachment(Other) != None)
	{
          if(!Other.Base.bDeleteMe)
          {
               Other = Instigator.HitPointTrace(TempHitLocation, HitNormal, HitLocation + (200 * X), HitPoints, HitLocation,, 1);

               if( Other == None || HitPoints.Length == 0 )
               {
                    return;
               }

               HitPawn = KFPawn(Other);

               if (Role == ROLE_Authority && HitPawn != None && !HitPawn.bDeleteMe)
               {
                    HitPawn.ProcessLocationalDamage(Damage, Instigator, TempHitLocation, MomentumTransfer * Normal(Velocity), MyDamageType,HitPoints);
               }
          }
	}
     else
     {
          if (class'WeaponHelper'.static.AlreadyHitPawn(Other, HitPawnList))
          {
               return;
          }

          KFM = KFMonster(Other);

          if (KFM != None)
          {
               bWasDecapitated = KFM.bDecapitated;
          }

          Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);

          if (Role == ROLE_Authority && Bounces > 0 && MonsterHeadAttached == None && KFM != None && !bWasDecapitated && KFM.Health < 0 && KFM.IsHeadShot(HitLocation, X, 1.0))
          {
               MonsterHeadAttached = KFM;

               if (Level.NetMode == NM_ListenServer || Level.NetMode == NM_StandAlone)
               {
                    PostNetReceive();
               }

               Bounces = 0;
          }
               
          //If damage was applied and we're doing less than our default, assume it's a penetrated hit.
          if (Monster(Other) != None && Damage < default.Damage)
          {
               class'WeaponHelper'.static.OnShotgunProjectileHit(Self, Other, Damage);
          }
     }

	if (KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != None && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != None)
	{
   		PenDamageReduction = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.static.GetShotgunPenetrationDamageMulti(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo),default.PenDamageReduction);
	}
	else
	{
   		PenDamageReduction = default.PenDamageReduction;
   	}

   	Damage *= PenDamageReduction;

     if (Damage / default.Damage <= PenDamageReduction / MaxPenetrations)
     {
          bFinishedPenetrating = true;
          Velocity = PhysicsVolume.Gravity;
          SetPhysics(PHYS_Falling);
          Bounces=0;
     }

     Speed = VSize(Velocity);

     if(Speed < (default.Speed * 0.25))
     {
          bFinishedPenetrating = true;
          Velocity = PhysicsVolume.Gravity;
          SetPhysics(PHYS_Falling);
          Bounces=0;
     }
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	HitPawnList.Length = 0;

	Super.HitWall(HitNormal, Wall);
}

defaultproperties
{
     //Property is UNUSED!!!
     HeadShotDamageMult=1.000000

     Bounces=1
     MaxPenetrations=4
     Speed=4000.000000
     MaxSpeed=4500.000000
     ExplosionDecal=Class'KFTurbo.W_NailGun_Decal'
     StaticMesh=StaticMesh'EffectsSM.Weapons.Vlad_9000_Nail'
     CullDistance=4000.000000
     DrawScale=3.000000
     PenDamageReduction=0.900000
     
     Damage=250.000000
     MyDamageType=Class'KFTurbo.W_NailGun_DT'
}
