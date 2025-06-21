//Killing Floor Turbo W_Frag_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Frag_Proj extends KFMod.Nade;

var float SharpnelDamageAdjustment;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
    class'WeaponHelper'.static.GrenadeTakeDamage(self, Damage, InstigatedBy, Hitlocation, Momentum, DamageType, HitIndex);
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	if (ExtendedZCollision(Other) != None)
	{
		return;
	}

	Super.ProcessTouch(Other, HitLocation);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (bHasExploded)
	{
		return;
	}

	Super.Explode(HitLocation, HitNormal);
}

simulated function bool CanDamageTarget(Actor Target)
{
	if(Target == self)
	{
		return false;
	}

	if(Target == Hurtwall)
	{
		return false;
	}

	if(Target.Role < ROLE_Authority)
	{
		return false;
	}

	if(Target.IsA('FluidSurfaceInfo'))
	{
		return false;
	}

	if(ExtendedZCollision(Target) != None || KFBulletWhipAttachment(Target) != None)
	{
		return false;
	}

	return true;
}

simulated function float GetDamageMultiplier(Pawn HitPawn)
{
	if(KFPawn(HitPawn) != None)
	{
		return KFPawn(HitPawn).GetExposureTo(Location + 15.f * -Normal(PhysicsVolume.Gravity));
	}
	else if(KFMonster(HitPawn) != None)
	{
		return KFMonster(HitPawn).GetExposureTo(Location + 15.f * -Normal(PhysicsVolume.Gravity));
	}

	return 1.f;
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local Actor HitActor;
	local Pawn HitPawn;
	local float DamageScale, Distance;
	local vector Direction, HitMomentum;

	local bool bHasInstigator;

	local int NumKilled;

	if ( bHurtEntry )
	{
		return;
	}

	bHasInstigator = Instigator != None && Instigator.Health > 0;
	bHurtEntry = true;

	foreach CollidingActors (class 'Actor', HitActor, DamageRadius, HitLocation)
	{
		if (!CanDamageTarget(HitActor))
		{
			continue;
		}

		if (!bHasInstigator && KFPawn(HitActor) != None)
		{
			continue;
		}

		Direction = Normal(HitActor.Location - HitLocation);
		Distance = class'WeaponHelper'.static.GetDistanceToClosestPointOnActor(Location, HitActor);
		DamageScale = 1.f - FMax(0.f, Distance / DamageRadius);

		if (Instigator == None || Instigator.Controller == None)
		{
			HitActor.SetDelayedDamageInstigatorController( InstigatorController );
		}

		HitPawn = Pawn(HitActor);

		if (HitPawn != None)
		{
			if (HitPawn.Health <= 0)
			{
				continue;
			}

			DamageScale *= GetDamageMultiplier(HitPawn);
		}

		if (DamageScale <= 0.f)
		{
			continue;
		}

		HitMomentum = DamageScale * Momentum * Direction;
		HitActor.TakeDamage(DamageScale * DamageAmount, Instigator, Location, HitMomentum, DamageType);
		
		if (HitPawn != none && HitPawn.Health <= 0)
		{
			NumKilled++;
		}

		if (Vehicle(HitActor) != None && Vehicle(HitActor).Health > 0)
		{
			Vehicle(HitActor).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
		}
	}
	
	foreach CollidingActors (class'Pawn', HitPawn, DamageRadius * 0.5f, HitLocation)
	{
		if (HitPawn.Role < ROLE_Authority)
		{
			continue;
		}

		if (!bHasInstigator && KFPawn(HitPawn) != None)
		{
			continue;
		}

		Direction = Normal(HitPawn.Location - HitLocation);
		Distance = class'WeaponHelper'.static.GetDistanceToClosestPointOnActor(Location, HitPawn);
		DamageScale = 1.f - FMax(0.f, Distance / DamageRadius);

		if (Instigator == None || Instigator.Controller == None)
		{
			HitPawn.SetDelayedDamageInstigatorController( InstigatorController );
		}

		if (HitPawn.Health <= 0)
		{
			continue;
		}

		DamageScale *= GetDamageMultiplier(HitPawn);

		if (DamageScale <= 0.f)
		{
			continue;
		}
		
		HitPawn.TakeDamage(DamageScale * SharpnelDamageAdjustment, Instigator, Location, vect(0,0,0), DamageType);
		
		if (HitPawn != none && HitPawn.Health <= 0 )
		{
			NumKilled++;
		}
	}

	if( Role == ROLE_Authority )
    {
    	if ( NumKilled >= 8 && Instigator != none && Instigator.PlayerReplicationInfo != none &&
			 KFSteamStatsAndAchievements(Instigator.PlayerReplicationInfo.SteamStatsAndAchievements) != none )
    	{
    		KFSteamStatsAndAchievements(Instigator.PlayerReplicationInfo.SteamStatsAndAchievements).Killed8ZedsWithGrenade();
    	}

        if ( NumKilled >= 4 )
        {
            KFGameType(Level.Game).DramaticEvent(0.05);
        }
        else if ( NumKilled >= 2 )
        {
            KFGameType(Level.Game).DramaticEvent(0.03);
        }
    }

	bHurtEntry = false;
}

defaultproperties
{
	ShrapnelClass=class'W_Frag_Proj_Shrapnel'
	Damage=300.000000
	SharpnelDamageAdjustment=125.000000
}