//Killing Floor Turbo W_SeekerSix_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SeekerSix_Proj extends WeaponSeekerSixRocketProjectile
    dependson(TurboPlayerEventHandler);

var Actor LastTouchedOverride;
var bool bAlreadyDidHitRegister;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	class'WeaponHelper'.static.SeekerSixProjTakeDamage(self, Damage, InstigatedBy, Hitlocation, Momentum, DamageType, HitIndex);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local int Index;
	local W_SeekerSix_Proj SeekerSixProjectile;

	if ( Other == none || Other == Instigator || Other.Base == Instigator )
	{
		return;
	}

    if( KFBulletWhipAttachment(Other) != none )
    {
        return;
    }

    if( KFHumanPawn(Other) != none && Instigator != none
        && KFHumanPawn(Other).PlayerReplicationInfo.Team.TeamIndex == Instigator.PlayerReplicationInfo.Team.TeamIndex )
    {
        return;
    }

	//TODO: Check if this is necessary.
	//Tell our flock we just hit someone so if anyone else blows up during Super.ProcessTouch they know to apply impact damage to this actor.
	if (LastTouchedOverride == None)
	{
		LastTouchedOverride = Other;

		for(Index = 0; Index < 6; Index++)
		{
			SeekerSixProjectile = W_SeekerSix_Proj(Flock[Index]);
			if (SeekerSixProjectile != None)
			{
				SeekerSixProjectile.LastTouchedOverride = Other;

				if (SeekerSixProjectile != Self)
				{
					SeekerSixProjectile.bAlreadyDidHitRegister = true;
				}
			}
		}
	}

	Super.ProcessTouch(Other, HitLocation);

	//Untell our flock now that we've blown up.
	LastTouchedOverride = None;
	for(Index = 0; Index < 6; Index++)
	{
		SeekerSixProjectile = W_SeekerSix_Proj(Flock[Index]);
		if (SeekerSixProjectile != None)
		{
			SeekerSixProjectile.LastTouchedOverride = None;
		}
	}
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local Actor Target;
	local float Distance;
	local float DamageScale;
	local vector Direction;
	local float UsedMomentum;

	local Pawn Pawn;
	local array<Pawn> CheckedPawns;
	local bool bAlreadyChecked;
	
	local TurboPlayerEventHandler.MonsterHitData HitData;
	local bool bWasAltFire;

	local int Index, NumKilled;

	if ( bHurtEntry )
	{
		return;
	}

	bHurtEntry = true;
	
	if (LastTouchedOverride == None)
	{
		LastTouchedOverride = LastTouched;
	}
		
	if (ExtendedZCollision(LastTouchedOverride) != None)
	{
		LastTouchedOverride = LastTouchedOverride.Base;
	}

	if (!bAlreadyDidHitRegister && KFMonster(LastTouchedOverride) != None)
	{
		class'TurboPlayerEventHandler'.static.CollectMonsterHitData(LastTouchedOverride, HitLocation, Normal(Velocity), HitData);
	}

	foreach CollidingActors (class'Actor', Target, DamageRadius, HitLocation)
	{
		if (Target == self || Target == Hurtwall || Target == None || Target.Role != ROLE_Authority || FluidSurfaceInfo(Target) != None || ExtendedZCollision(Target) != None)
		{
			continue;
		}
		
		Direction = Target.Location - HitLocation;
		Distance = FMax(VSize(Direction), 1.f);
		Direction = Direction / Distance;

		Distance = class'WeaponHelper'.static.GetDistanceToClosestPointOnActor(HitLocation, Target);

		if ( Instigator == None || Instigator.Controller == None )
		{
			Target.SetDelayedDamageInstigatorController( InstigatorController );
		}

		if ( Target == LastTouchedOverride )
		{
			DamageScale = 1.f;
		}
		else
		{
			DamageScale = FMax(1.f - (Distance / DamageRadius), 0.f);
		}
		
		UsedMomentum = Momentum;
		UsedMomentum *= InterpCurveEval(AppliedMomentumCurve, Target.Mass);

		Pawn = Pawn(Target);

		if( Pawn == None )
		{
			UsedMomentum *= DamageScale;
			Target.TakeDamage(DamageScale * DamageAmount, Instigator, Location, Direction * UsedMomentum, DamageType);
			continue;
		}

		if( Pawn.Health <= 0 )
		{
			continue;
		}

		bAlreadyChecked = false;
		for (Index = 0; Index < CheckedPawns.Length; Index++)
		{
			if (CheckedPawns[Index] == Pawn)
			{
				bAlreadyChecked = true;
				break;
			}
		}

		CheckedPawns[CheckedPawns.Length] = Pawn;

		if( bAlreadyChecked )
		{
			continue;
		}

		if (KFMonster(Target) != None)
		{
			DamageScale *= KFMonster(Target).GetExposureTo(HitLocation);
		}
		else if (KFPawn(Target) != None)
		{
			DamageScale *= KFPawn(Target).GetExposureTo(HitLocation);
		}

		if ( DamageScale <= 0.f)
		{
			continue;
		}

		UsedMomentum *= DamageScale;

		Target.TakeDamage(DamageScale * DamageAmount, Instigator, Location, Direction * UsedMomentum, DamageType);

		if (Vehicle(Target) != None && Vehicle(Target).Health > 0)
		{
			Vehicle(Target).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, UsedMomentum, HitLocation);
		}

		if( Role == ROLE_Authority && KFMonster(Target) != None && Pawn.Health <= 0 )
		{
			NumKilled++;
		}
	}

	bWasAltFire = FlockIndex == 0;

	//Do impact damage.
	if (LastTouchedOverride != None)
	{
		//Somehow the above check is missing an explosive hit.
		bAlreadyChecked = false;
		for (Index = 0; Index < CheckedPawns.Length; Index++)
		{
			if (CheckedPawns[Index] == LastTouchedOverride)
			{
				bAlreadyChecked = true;
				break;
			}
		}

		Target = LastTouchedOverride;
		LastTouchedOverride = None;
		LastTouched = None;

		if (!bAlreadyChecked)
		{
			UsedMomentum = Momentum;
			UsedMomentum *= InterpCurveEval(AppliedMomentumCurve, Target.Mass);
			Target.TakeDamage(DamageAmount, Instigator, Location, Direction * UsedMomentum, DamageType);
		}

		Target.TakeDamage(ImpactDamage, Instigator, Location, Normal(Velocity), ImpactDamageType);
	}

	if (!bAlreadyDidHitRegister && HitData.DamageDealt > 0 && Weapon(Owner) != None && Owner.Instigator != None)
	{
		if (!bWasAltFire)
		{
			class'TurboPlayerEventHandler'.static.BroadcastPlayerFireHit(Owner.Instigator.Controller, Weapon(Owner).GetFireMode(0), HitData);
		}
		else
		{
			class'TurboPlayerEventHandler'.static.BroadcastPlayerFireHit(Owner.Instigator.Controller, Weapon(Owner).GetFireMode(1), HitData);
		}
	}

	if( Role == ROLE_Authority )
	{
		if( NumKilled >= 4 )
		{
			KFGameType(Level.Game).DramaticEvent(0.05);
		}
		else if( NumKilled >= 2 )
		{
			KFGameType(Level.Game).DramaticEvent(0.03);
		}
	}

	bHurtEntry = false;
}

defaultproperties
{
	SoundPitch=48

	AppliedMomentumCurve=(Points=((OutVal=0.500000),(InVal=100.000000,OutVal=0.500000),(InVal=350.000000,OutVal=1.000000),(InVal=600.000000,OutVal=1.000000)))
	ArmDistSquared=10000.000000
	Speed=2000.000000
	MaxSpeed=2000.000000
	DrawScale=3.000000
	RotationRate=(Roll=50000)
	
	FlockRadius=10.000000
	FlockStiffness=-100.000000
	FlockMaxForce=600.000000
	FlockCurlForce=450.000000

	ImpactDamage=50
	Damage=300.000000
	DamageRadius=150.000000
    bGameRelevant=false
}

