class W_SealSqueal_Proj extends SealSquealProjectile;

// Stick this explosive to the wall or zed it hit
simulated function Stick(actor HitActor, vector HitLocation)
{
	local vector HitDirection;
	local Pawn HitPawn;

	if(Role == ROLE_Authority)
	{
		bTearOff = true;
	}

	HitDirection = Normal(Velocity);

	if(Velocity == vect(0,0,0))
	{
		HitDirection = Vector(Rotation);
	}

	SetRotation(Rotator(HitDirection));

	bStuck=true;
	Velocity = vect(0,0,0);
	SetPhysics(PHYS_None);

	HitPawn = ResolveBaseActor(HitActor);

	if(HitPawn != None)
	{
		StickToPawn(HitPawn, HitLocation, HitDirection);
	}
	else
	{
		StickToActor(HitActor, HitLocation, HitDirection);
	}

	if( Trail!=None )
	{
		Trail.mRegen = False;
	}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if( HitPawn != none )
		{
            PlaySound(ImpactPawnSound, SLOT_Misc );
        }
        else
        {
            PlaySound(ImpactSound, SLOT_Misc );
        }
	}

	// Make light radius smaller once it impacts
    LightRadius=2.0;
}

simulated function Pawn ResolveBaseActor(Actor HitActor)
{
	if(HitActor.IsA('ExtendedZCollision') && HitActor.Base != None && Pawn(HitActor.Base) != None)
	{
		return Pawn(HitActor.Base);
	}
	else
	{
		return Pawn(HitActor);
	}
}

simulated function StickToActor(Actor HitActor, Vector HitLocation, Vector HitDirection)
{
	//Maybe we'll do something else here sometime...
	SetBase(HitActor);
}

simulated function StickToPawn(Pawn HitPawn, Vector HitLocation, Vector HitDirection)
{
	local Name NearestBone;
	local float Distance;
	local KFMonster KFM;

	//We'll give players a little helping hand when trying to stick headshots.
	if(VSizeSquared(HitPawn.GetBoneCoords(HitPawn.HeadBone).Origin - HitLocation) < 1024.f)
	{
		NearestBone = HitPawn.HeadBone;
	}
	else
	{
		NearestBone = HitPawn.GetClosestBone(HitLocation, HitDirection, Distance);
	}

	bBlockActors = false;
	bBlockPlayers = false;

	//Ok so dedicated servers don't seem to play nice with skeletal meshes (optimization?) so we do an aprox attachment on dedicated servers. Better than nothing.	
	if(Level.NetMode == NM_DedicatedServer)
	{
		bHardAttach = true;
		SetLocation(HitPawn.GetBoneCoords(NearestBone).Origin);
		SetBase(HitPawn);
	}
	else
	{
		SetLocation(HitPawn.GetBoneCoords(NearestBone).Origin);
		HitPawn.AttachToBone(self, NearestBone);
		SetRelativeLocation(-4.f * (HitDirection >> HitPawn.GetBoneRotation( NearestBone, 0 )));
		SetRelativeRotation(Rotator(HitDirection >> HitPawn.GetBoneRotation( NearestBone, 0 )));
	}

	if(NearestBone == HitPawn.HeadBone)
	{
		bAttachedToHead = true;
	}

	KFM = KFMonster(HitPawn);

	if(KFM != none && Role == ROLE_Authority)
	{
		if( KFM.bHarpoonToBodyStuns || KFM.bHarpoonToHeadStuns && bAttachedToHead )
		{
			KFM.bHarpoonStunned = true;
		}

		KFM.NumHarpoonsAttached++;
		
		class'TurboEventHandler'.static.BroadcastPawnHarpooned(Instigator, KFM, KFM.NumHarpoonsAttached);
	}
}

event TornOff()
{
	Super.TornOff();

	if(Pawn(Base) != None)
	{
		StickToPawn(Pawn(Base), Location, vector(Rotation));
	}
}

simulated function HurtRadius(float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation)
{
	local actor HitActor;
	local Pawn HitPawn;

	local Vector Direction;
	local float Distance;
	local float DamageScale;

	local int i;
	local array<Pawn> CheckedPawns;

	local int NumKilled;

	local Vector MomentumVector;

	if (bHurtEntry)
	{
		return;
	}

	bHurtEntry = true;

	foreach CollidingActors(class'Actor', HitActor, DamageRadius, HitLocation)
	{
		if(!CanDamageTarget(HitActor))
		{
			continue;
		}

		Direction = HitActor.Location - HitLocation;

		if(VSizeSquared(Direction) > 0.0001f)
		{
			Direction = Normal(Direction);
		}
		else
		{
			Direction = vect(0, 0, 1);
		}

		if(HitActor == Base)
		{
			Distance = 0.f;
		}
		else
		{
			Distance = class'WeaponHelper'.static.GetDistanceToClosestPointOnActor(HitLocation, HitActor);
		}

		DamageScale = 1.f - FMax(Distance / DamageRadius, 0.f);

		if (DamageScale <= 0.f)
		{
			continue;
		}

		if (Instigator == None || Instigator.Controller == None)
		{
			HitActor.SetDelayedDamageInstigatorController(InstigatorController);
		}

		if (HitActor == LastTouched)
		{
			LastTouched = None;
		}

		HitPawn = Pawn(HitActor);

		if(HitPawn == None)
		{
			MomentumVector = (Momentum * Direction * DamageScale);

			HitActor.TakeDamage(DamageAmount * DamageScale, Instigator, HitActor.Location, MomentumVector, DamageType);

			if (Vehicle(HitActor) != None && Vehicle(HitActor).Health > 0)
			{
				Vehicle(HitActor).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
			}

			continue;
		}

		for (i = 0; i < CheckedPawns.Length; i++)
		{
			if (CheckedPawns[i] == HitPawn)
			{
				continue;
			}
		}

		//Immediately add this actor to list of checked pawns.
		CheckedPawns[CheckedPawns.Length] = HitPawn;

		if(HitPawn.Health <= 0.f)
		{
			continue;
		}

		DamageScale *= GetDamageMultiplier(HitPawn, HitLocation);

		if(DamageScale <= 0.f)
		{
			continue;
		}

		MomentumVector = (Momentum * Direction * DamageScale);
		HitActor.TakeDamage(DamageAmount * DamageScale, Instigator, HitActor.Location, MomentumVector, DamageType);

		if(Role == ROLE_Authority && HitPawn.Health <= 0 )
		{
			NumKilled++;
		}
	}

	CheckForDrama(NumKilled);
	bHurtEntry = false;
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

	if(ExtendedZCollision(Target) != None)
	{
		return false;
	}

	return true;
}

simulated function float GetDamageMultiplier(Pawn HitPawn, Vector HitLocation)
{
	if(HitPawn == Base)
	{
		if(bAttachedToHead)
		{
			return 1.85f;
		}

		return 1.5f;
	}

	if(KFPawn(HitPawn) != None)
	{
		return KFPawn(HitPawn).GetExposureTo(HitLocation);
	}
	else if(KFMonster(HitPawn) != None)
	{
		return KFMonster(HitPawn).GetExposureTo(HitLocation);
	}

	return 1.f;
}

function CheckForDrama(int NumKilled)
{
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
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if(Level.NetMode != NM_DedicatedServer && !bHasExploded)
	{
		CheckPawnBase(Pawn(Base));
	}
}

//Dedicated servers will detonate this projectile instantly on death. We need to copy this behaviour.
simulated function CheckPawnBase(Pawn PawnBase)
{
	if(PawnBase == None)
	{
		return;
	}

	if(PawnBase.Health > 0)
	{
		return;
	}

	Explode(Location, vect(0,0,1));
}

defaultproperties
{
     ImpactDamage=0
     Damage=400.000000
     DamageRadius=350.000000
}
