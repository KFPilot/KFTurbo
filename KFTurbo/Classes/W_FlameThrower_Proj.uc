//Killing Floor Turbo W_FlameThrower_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_FlameThrower_Proj extends FlameTendril;

var int BaseTime;
var array<Pawn> HitPawnList;
var int PenetrationCount;

var float NextExplodeEffectTime;

simulated function PreBeginPlay()
{
	NextExplodeEffectTime = Level.TimeSeconds + 0.25f + (FRand() * 0.25f);
	Super.PreBeginPlay();
}

simulated function Timer()
{
	Velocity = Default.Speed * Normal(Velocity);

	if (Trail != None)
	{
		Trail.mSizeRange[0] *= 1.8;
		Trail.mSizeRange[1] *= 1.8;
	}

	if (FlameTrail != None)
	{
		FlameTrail.SetDrawScale(FlameTrail.DrawScale * 1.5);
	}

	TimerRunCount++;

	if (KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != None && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != None)
	{
		if (TimerRunCount >= BaseTime + KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.ExtraRange(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo)))
		{
			PerformImpactEffect(VRand(), true);
			Explode(Location,VRand());
		}
	}
	else if (TimerRunCount >= BaseTime)
	{
		PerformImpactEffect(VRand(), true);
		Explode(Location,VRand());
	}
}

final function bool HasAlreadyHitPawn(Actor Other)
{
	local int Index;
	local Pawn Pawn;

	Pawn = Pawn(Other);

	if (Pawn == None)
	{
		Pawn = Pawn(Other.Base);
	}

	//Ignore non-pawns.
	if (Pawn == None)
	{
		return true;
	}

	for (Index = 0; Index < HitPawnList.Length; Index++)
	{
		if (HitPawnList[Index] == Other)
		{
			return true;
		}
	}

	HitPawnList.Length = HitPawnList.Length + 1;
	HitPawnList[HitPawnList.Length - 1] = Pawn;

	return false;
}

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
	local TurboPlayerEventHandler.MonsterHitData HitData;
	local Actor ProjectileOwner;
	local int Index;

	if (Other == None || Other == Instigator || Other.Base == Instigator)
	{
		return;
	}

	if (Level.NetMode != NM_DedicatedServer)
	{
		PerformImpactEffect(-vector(Rotation));
	}

	if (Role != ROLE_Authority)
	{
		return;
	}

	if (Pawn(Other) == None)
	{
		return;
	}

	for (Index = 0; Index < HitPawnList.Length; Index++)
	{
		if (HitPawnList[Index] == Other)
		{
			return;
		}
	}

	//Ignore all projectiles.
	ProjectileOwner = Owner;
	class'TurboPlayerEventHandler'.static.CollectMonsterHitData(Other, HitLocation, Normal(Velocity), HitData);

	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);

	if (HitData.DamageDealt > 0 && Weapon(ProjectileOwner) != None && ProjectileOwner.Instigator != None)
	{
		class'TurboPlayerEventHandler'.static.BroadcastPlayerFireHit(ProjectileOwner.Instigator.Controller, Weapon(ProjectileOwner).GetFireMode(0), HitData);	
	}

	PenetrationCount++;
	if (PenetrationCount >= MaxPenetrations)
	{
		Explode(Location, -vector(Rotation));
	}
}

simulated singular function HitWall(vector HitNormal, actor Wall)
{
	PerformImpactEffect(HitNormal, true);
	Explode(Location + ExploWallOut * HitNormal, HitNormal);
}

simulated function Landed(vector HitNormal)
{
	PerformImpactEffect(HitNormal, true);
	Explode(Location,HitNormal);
}

simulated function Explode(vector HitLocation,vector HitNormal)
{
	SetCollisionSize(0.0, 0.0);
	Destroy();
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local Pawn Pawn;
	local float DamageScale, Distance;
	local vector Direction;

	if (bHurtEntry)
	{
		return;
	}

	bHurtEntry = true;

	foreach VisibleCollidingActors(class'Pawn', Pawn, DamageRadius, HitLocation)
	{
		if (Pawn.Role != ROLE_Authority || Pawn == Instigator || Pawn.Health <= 0)
		{
			continue;
		}

		if (HasAlreadyHitPawn(Pawn))
		{
			continue;
		}

		Direction = Pawn.Location - HitLocation;
		Distance = FMax(1,VSize(Direction));
		Direction = Direction / Distance;
		DamageScale = 1.f - FMax(0.f, (Distance - Pawn.CollisionRadius) / DamageRadius);

		if (Instigator == None || Instigator.Controller == None)
		{
			Pawn.SetDelayedDamageInstigatorController(InstigatorController);
		}

		Pawn.TakeDamage(DamageScale * DamageAmount, Instigator, Pawn.Location - 0.5 * (Pawn.CollisionHeight + Pawn.CollisionRadius) * Direction, (DamageScale * Momentum * Direction), DamageType);

		if (Vehicle(Pawn) != None)
		{
			Vehicle(Pawn).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
		}
	}

	bHurtEntry = false;
}

simulated function PerformImpactEffect(vector HitNormal, optional bool bFinalImpact)
{
	if (!bFinalImpact && Level.TimeSeconds < NextExplodeEffectTime)
	{
		return;
	}

	NextExplodeEffectTime = Level.TimeSeconds + 0.125f + (FRand() * 0.125f);

	if (!EffectIsRelevant(Location,false))
	{
		return;
	}

	Spawn(class'FuelFlame',self,,Location);
	Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
}

defaultproperties
{
	MyDamageType=Class'W_FlameThrower_DT'
	ExplosionDecal=Class'W_FlameThrower_BurnMark'
	BaseTime=2
	Damage=11.000000
	DamageRadius=100
	MaxPenetrations=10
}
