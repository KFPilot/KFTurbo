class W_Frag_Proj extends KFMod.Nade;

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	if (ExtendedZCollision(Other) != None)
	{
		return;
	}

	log(Other);

	Super.ProcessTouch(Other, HitLocation);
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
	local actor HitActor;
	local float DamageScale, Distance;
	local vector Direction, HitMomentum;

	local Pawn P;

	local array<Pawn> CheckedPawns;
	local int i;
	local bool bAlreadyChecked;

	local int NumKilled;


	if ( bHurtEntry )
	{
		return;
	}

	bHurtEntry = true;

	foreach CollidingActors (class 'Actor', HitActor, DamageRadius, HitLocation)
	{
		if (!CanDamageTarget(HitActor))
		{
			continue;
		}

		if((Instigator == None || Instigator.Health <= 0) && KFPawn(HitActor) != None)
		{
			continue;
		}

		Direction = Normal(HitActor.Location - HitLocation);
		Distance = class'WeaponHelper'.static.GetDistanceToClosestPointOnActor(Location, HitActor);
		DamageScale = 1.f - FMax(0.f, Distance / DamageRadius);

		if ( Instigator == None || Instigator.Controller == None )
		{
			HitActor.SetDelayedDamageInstigatorController( InstigatorController );
		}

		P = Pawn(HitActor);

		if (DamageScale <= 0.f)
		{
			continue;
		}

		if( P != none )
		{
			if (P.Health <= 0)
			{
				continue;
			}

			bAlreadyChecked = false;
			for (i = 0; i < CheckedPawns.Length; i++)
			{
				if (CheckedPawns[i] == P)
				{
					bAlreadyChecked = true;
					break;
				}
			}

			if (bAlreadyChecked)
			{
				continue;
			}

			CheckedPawns[CheckedPawns.Length] = P;

			DamageScale *= GetDamageMultiplier(P);

			if (DamageScale <= 0.f)
			{
				continue;
			}
		}

		HitMomentum = DamageScale * Momentum * Direction;
		HitActor.TakeDamage(DamageScale * DamageAmount, Instigator, Location, HitMomentum, DamageType);
		
		if( P != none && P.Health <= 0 )
		{
			NumKilled++;
		}

		if (Vehicle(HitActor) != None && Vehicle(HitActor).Health > 0)
		{
			Vehicle(HitActor).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
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
}