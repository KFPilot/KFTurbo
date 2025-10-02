//Killing Floor Turbo PawnHelper
//Anti redundancy class. Handles logic for zeds.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PawnHelper extends Object;

//Master container for all afflictions.
struct AfflictionData
{
	var AfflictionBurn Burn;
	var AfflictionZap Zap;
	var AfflictionHarpoon Harpoon;
	
	var Pawn LastBurnDamageInstigator; //Stored here instead of within AfflictionBurn because this pointer can become garbage when in an object.
};

enum EMonsterTier
{
	Trash,
	Special,
	Elite,
	Boss
};

//NOTE: THESE ENUMS MUST LINE UP WITH THE MC_TURBO MONSTERCLASSES LIST.
enum EMonster
{
	Clot,
	Crawler,
	Gorefast,
	Stalker,
	Scrake,
	Fleshpound,
	Bloat,
	Siren,
	Husk,
	Boss,

	//"Custom" zeds.
	Crawler_Jumper,
	Gorefast_Classy,
	Gorefast_Assassin,
	Bloat_Fathead,
	Siren_Caroler,
	Husk_Shotgun,

	//Failed to resolve.
	Unknown
};


static final simulated function InitializePawnHelper(KFMonster Monster, out AfflictionData Data)
{
	if (Monster.Level.NetMode != NM_DedicatedServer && TurboGameReplicationInfo(Monster.Level.GRI) != None)
	{
		TurboGameReplicationInfo(Monster.Level.GRI).ModifyMonster(Monster);
	}
}

static final function bool UpdateStunProperties(KFMonster KFM, float LastStunCount, out float UnstunTime, bool bUnstunTimeReady)
{
	if (LastStunCount == KFM.StunsRemaining)
	{
		return bUnstunTimeReady;
	}

	UnstunTime = KFM.Level.TimeSeconds + KFM.StunTime;
	bUnstunTimeReady = true;

	if (KFM.BurnDown <= 0)
	{
		//Don't uncomment this - is responsible for flinch slow raging.
		//KFM.SetTimer(-1.f, false);
	}
	else
	{
		//Need to avoid a case where SetTimer() resets itself instead of just starting a new timer.
		if ((1.f - KFM.TimerCounter) < 0.0001f)
		{
			KFM.Timer();
		}
		else
		{
			//AActor::TimerCounter is the amount of time that the current timer has elapsed.
			KFM.SetTimer(1.f - KFM.TimerCounter, false); //burn timer is not a var and always 1 second.
		}
	}

	return bUnstunTimeReady;
}

static final function BlockPlayHit(out AfflictionData AD)
{
	if (AD.Burn != None)
	{
		AD.Burn.bBlockPlayHit = true;
	}
}

static final function UnblockPlayHit(out AfflictionData AD)
{
	if (AD.Burn != None)
	{
		AD.Burn.bBlockPlayHit = false;
	}
}

static final function bool ShouldPlayHit(KFMonster KFM, AfflictionData AD)
{
	if (AD.Burn != None && AD.Burn.bBlockPlayHit)
	{
		return false;
	}

	return true;
}


static final function MonsterDied(KFMonster Monster, out AfflictionData AD)
{
	if (Monster == None)
	{
		return;
	}

	DisablePawnCollision(Monster);

	if (AD.Burn != None)
	{
		AD.Burn.OnDeath(Monster);
		AD.Burn = None;
	}

	if (AD.Zap != None)
	{
		AD.Zap.OnDeath(Monster);
		AD.Zap = None;
	}

	if (AD.Harpoon != None)
	{
		AD.Harpoon.OnDeath(Monster);
		AD.Harpoon = None;
	}
}

static final function bool MeleeDamageTarget(KFMonster Monster, int HitDamage, vector PushDirection, out AfflictionData AD)
{
	local vector HitLocation, HitNormal;
	local Actor ControllerTarget, HitActor;
	local KFHumanPawn HumanPawn;
	local Name TearBone;
	local float dummy;
	local Emitter BloodHit;
	local int OriginalDamage;

	if(Monster.Role != ROLE_Authority || Monster.Controller == None)
	{
		return false; 
	}

	ControllerTarget = Monster.Controller.Target;

	if (ControllerTarget == None)
	{
		return false;
	}

	if (ControllerTarget != none && ControllerTarget.IsA('KFDoorMover'))
	{
		Monster.Controller.Target.TakeDamage(HitDamage, Monster, HitLocation, PushDirection, Monster.CurrentDamType);
		Return true;
	}

	if (Monster.bSTUNNED || Monster.DECAP)
	{
		return false;
	}

	if (VSizeSquared(ControllerTarget.Location - Monster.Location) > Square((Monster.MeleeRange * 1.4) + ControllerTarget.CollisionRadius + Monster.CollisionRadius))
	{
		return false;
	}

	if ((Monster.Physics != PHYS_Flying) && (Monster.Physics != PHYS_Swimming) && (Abs(Monster.Location.Z - ControllerTarget.Location.Z) > FMax(Monster.CollisionHeight, ControllerTarget.CollisionHeight) + (0.5 * FMin(Monster.CollisionHeight, ControllerTarget.CollisionHeight))))
	{
		return false;
	}
	
	Monster.bBlockHitPointTraces = false;
	HitActor = Monster.Trace(HitLocation, HitNormal, ControllerTarget.Location , Monster.Location + Monster.EyePosition(), true);
	Monster.bBlockHitPointTraces = true;

	if (Pawn(HitActor) == None)
	{
		Monster.bBlockHitPointTraces = false;
		HitActor = Monster.Trace(HitLocation, HitNormal, ControllerTarget.Location, Monster.Location, false);
		Monster.bBlockHitPointTraces = true;

		if (HitActor != None)
		{
			return false;
		}
	}

	HumanPawn = KFHumanPawn(ControllerTarget);
	OriginalDamage = HitDamage;

	if (HumanPawn != None)
	{
		if (IsPawnBurning(Monster) && AD.Burn != None)
		{
			HitDamage = float(OriginalDamage) * AD.Burn.BurnMonsterDamageModifier;
			class'TurboGameplayEventHandler'.static.BroadcastBurnMitigatedDamage(AD.LastBurnDamageInstigator, HumanPawn, HitDamage, OriginalDamage - HitDamage);
		}

		HumanPawn.TakeDamage(HitDamage, Monster, HitLocation, PushDirection, Monster.CurrentDamType);

		if (HumanPawn.Health <= 0.f)
		{
			if ( !class'GameInfo'.static.UseLowGore() )
			{
				BloodHit = Monster.Spawn(class'KFMod.FeedingSpray', Monster,, ControllerTarget.Location,rotator(PushDirection));
				HumanPawn.SpawnGibs(rotator(PushDirection), 1);
				TearBone = HumanPawn.GetClosestBone(HitLocation, Monster.Velocity, dummy);
				HumanPawn.HideBone(TearBone);
			}

			if (Monster.Health <= (1.0 - Monster.FeedThreshold) * Monster.HealthMax)
			{
				Monster.Health += (Monster.FeedThreshold * Monster.HealthMax) * (Monster.Health / Monster.HealthMax);
			}
		}
	}
	else if (ControllerTarget != None)
	{
		if (KFMonster(ControllerTarget) != None)
		{
			HitDamage *= Monster.DamageToMonsterScale;
		}

		ControllerTarget.TakeDamage(hitdamage, Monster, HitLocation, PushDirection, Monster.CurrentDamType);
	}

	return true;
}

defaultproperties
{

}
