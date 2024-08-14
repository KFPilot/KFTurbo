//========
//Anti redundancy class.
//Handles logic for zeds.
//========
class PawnHelper extends Object;

//Master container for all afflictions.
struct AfflictionData
{
	var AfflictionBurn Burn;
	var AfflictionZap Zap;
	var AfflictionHarpoon Harpoon;
	
	var Pawn LastBurnDamageInstigator; //Stored here instead of within AfflictionBurn because this pointer can become garbage when in an object.
};

static final simulated function bool IsPawnBurning(Pawn Pawn)
{
	local KFMonster Monster;
	local KFPawn PlayerPawn;

	if (Pawn == None)
	{
		return false;
	}

	Monster = KFMonster(Pawn);

	if (Monster != None)
	{
		return Monster.bBurnified;
	}
	
	PlayerPawn = KFPawn(Pawn);

	if (PlayerPawn != None)
	{
		return PlayerPawn.bBurnified;
	}

	return false;
}

static final simulated function bool IsPawnZapped(Pawn Pawn)
{
	local KFMonster Monster;

	Monster = KFMonster(Pawn);

	if (Monster != None)
	{
		return Monster.bZapped;
	}

	return false;
}

static final simulated function bool IsPawnHarpoonStunned(Pawn Pawn)
{
	local KFMonster Monster;

	Monster = KFMonster(Pawn);

	if (Monster != None)
	{
		return Monster.bHarpoonStunned;
	}

	return false;
}

static final simulated function InitializePawnHelper(KFMonster Monster, out AfflictionData Data)
{
	if (Data.Burn != None)
	{
		Data.Burn.Initialize(Monster);
	}

	if (Data.Zap != None)
	{
		Data.Zap.Initialize(Monster);
	}

	if (Data.Harpoon != None)
	{
		Data.Harpoon.Initialize(Monster);
	}

	SpawnClientExtendedZCollision(Monster);
}

//NOTE: No special destroy code is needed. EZCollision is already destroyed on any zed that has it (not role-dependent).
static final simulated function SpawnClientExtendedZCollision(KFMonster KFM)
{
	local vector AttachPos;

	//Auth has already created this hitbox.
	if(KFM.Role == ROLE_Authority)
	{
		return;
	}

	if (KFM.bUseExtendedCollision && KFM.MyExtCollision == none )
	{
		KFM.MyExtCollision = KFM.Spawn(class'ClientExtendedZCollision', KFM);
		//Slightly smaller version for non auth clients
		KFM.MyExtCollision.SetCollisionSize(KFM.ColRadius * 0.9f, KFM.ColHeight * 0.9f);

		KFM.MyExtCollision.bHardAttach = true;

		AttachPos = KFM.Location + (KFM.ColOffset >> KFM.Rotation);
		
		KFM.MyExtCollision.SetLocation(AttachPos);
		KFM.MyExtCollision.SetPhysics(PHYS_None);
		KFM.MyExtCollision.SetBase(KFM);
		KFM.SavedExtCollision = KFM.MyExtCollision.bCollideActors;
	}
}

static final simulated function ZombieCrispUp(KFMonster KFM)
{
	KFM.bAshen = true;
	KFM.bCrispified = true;

	KFM.SetBurningBehavior();

	if ( KFM.Level.NetMode == NM_DedicatedServer || class'GameInfo'.static.UseLowGore() )
	{
		Return;
	}

	KFM.Skins[0]=Combiner'PatchTex.Common.BurnSkinEmbers_cmb';
	KFM.Skins[1]=Combiner'PatchTex.Common.BurnSkinEmbers_cmb';
	KFM.Skins[2]=Combiner'PatchTex.Common.BurnSkinEmbers_cmb';
	KFM.Skins[3]=Combiner'PatchTex.Common.BurnSkinEmbers_cmb';
}

//Handles both Burning and Harpooned (I don't know why TWI did this...)
static final simulated function SetBurningBehavior(KFMonster KFM, AfflictionData AD)
{
	if(KFM == None)
	{
		return;
	}

	if(KFM.bHarpoonStunned)
	{
		KFM.Intelligence = BRAINS_Retarded;

		if (KFM.MovementAnims[1] != KFM.BurningWalkAnims[0])
		{
			KFM.MovementAnims[0] = KFM.BurningWalkFAnims[Rand(3)];
			KFM.WalkAnims[0]     = KFM.BurningWalkFAnims[Rand(3)];

			KFM.MovementAnims[1] = KFM.BurningWalkAnims[0];
			KFM.WalkAnims[1]     = KFM.BurningWalkAnims[0];
			KFM.MovementAnims[2] = KFM.BurningWalkAnims[1];
			KFM.WalkAnims[2]     = KFM.BurningWalkAnims[1];
			KFM.MovementAnims[3] = KFM.BurningWalkAnims[2];
			KFM.WalkAnims[3]     = KFM.BurningWalkAnims[2];
		}
	}

	if(KFM.Role == Role_Authority)
	{
		KFM.SetGroundSpeed(KFM.GetOriginalGroundSpeed());
		KFM.AirSpeed = KFM.default.AirSpeed * GetSpeedMultiplier(AD);
		KFM.WaterSpeed = KFM.default.WaterSpeed * GetSpeedMultiplier(AD);

		if(KFM.bHarpoonStunned && KFM.Controller != none )
		{
			MonsterController(KFM.Controller).Accuracy = -20;
		}
	}
}

//Handles both Burning and Harpooned (I don't know why TWI did this...)
static final simulated function UnSetBurningBehavior(KFMonster KFM, AfflictionData AD)
{
	local int i;

	if(KFM == None)
	{
		return;
	}

    if(!KFM.bHarpoonStunned)
    {
		KFM.Intelligence = KFM.default.Intelligence;

    	for ( i = 0; i < 4; i++ )
		{
			KFM.MovementAnims[i] = KFM.default.MovementAnims[i];
			KFM.WalkAnims[i] = KFM.default.WalkAnims[i];
		}
    }

	if (KFM.Role == Role_Authority )
	{
		KFM.SetGroundSpeed(KFM.GetOriginalGroundSpeed());
		KFM.AirSpeed = KFM.default.AirSpeed * GetSpeedMultiplier(AD);
		KFM.WaterSpeed = KFM.default.WaterSpeed * GetSpeedMultiplier(AD);

		if (!KFM.bHarpoonStunned && KFM.Controller != none )
		{
		   MonsterController(KFM.Controller).Accuracy = MonsterController(KFM.Controller).default.Accuracy;
		}
	}

	KFM.bAshen = False;
}

static final simulated function SetZappedBehavior(KFMonster KFM, AfflictionData AD)
{
	if( KFM.Role == Role_Authority )
	{
		KFM.SetGroundSpeed(KFM.GetOriginalGroundSpeed());
		KFM.AirSpeed = KFM.default.AirSpeed * GetSpeedMultiplier(AD);
		KFM.WaterSpeed = KFM.default.WaterSpeed * GetSpeedMultiplier(AD);
	}
}

static final simulated function UnSetZappedBehavior(KFMonster KFM, AfflictionData AD)
{
	if( KFM.Role == Role_Authority )
	{
		KFM.SetGroundSpeed(KFM.GetOriginalGroundSpeed());
		KFM.AirSpeed = KFM.default.AirSpeed * GetSpeedMultiplier(AD);
		KFM.WaterSpeed = KFM.default.WaterSpeed * GetSpeedMultiplier(AD);
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

static final function float GetOriginalGroundSpeed(KFMonster KFM, AfflictionData AD)
{
	return KFM.OriginalGroundSpeed * GetSpeedMultiplier(AD);
}

static final function float GetSpeedMultiplier(AfflictionData AD)
{
	local float Multiplier;
	Multiplier = 1.f;

	if (AD.Burn != None)
	{
		Multiplier *= AD.Burn.GetMovementSpeedModifier();
	}

	if (AD.Harpoon != None)
	{
		Multiplier *= AD.Harpoon.GetMovementSpeedModifier();
	}

	if (AD.Zap != None)
	{
		Multiplier *= AD.Zap.GetMovementSpeedModifier();
	}

	return Multiplier;
}

static simulated function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, int HitIndex, out AfflictionData AD)
{
	if (AD.Burn != None)
	{
		AD.Burn.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex);
	}
}

static simulated function PostTakeDamage(KFMonster Monster, int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, int HitIndex, out AfflictionData AD)
{
	if (AD.Burn != None)
	{
		//Inform the Burn affliction about who did this and with what damage type.
		if (Monster.FireDamageClass != AD.Burn.LastBurnDamageType)
		{
			AD.Burn.LastBurnDamageType = Monster.FireDamageClass;
			AD.LastBurnDamageInstigator = InstigatedBy;
		}

		if (Monster.bBurnified && AD.Burn.BurnRatio <= 0.f)
		{
			class'TurboEventHandler'.static.BroadcastPawnIgnited(AD.LastBurnDamageInstigator, Monster, class<KFWeaponDamageType>(AD.Burn.LastBurnDamageType), Monster.LastBurnDamage);
		}
	}
}

static final function TakeFireDamage(KFMonster Monster, int Damage, Pawn Instigator, out AfflictionData AD)
{
	if (AD.Burn != None && AD.LastBurnDamageInstigator != None)
	{
		Instigator = AD.LastBurnDamageInstigator;
	}

   	BlockPlayHit(AD);
	Monster.TakeDamage(Damage, Instigator, vect(0,0,0), vect(0,0,0), Monster.FireDamageClass);
   	UnblockPlayHit(AD);

	//Someone called this function but nulled this out. Their goal was likely to apply damage without a hit reaction. 
	if (Monster.FireDamageClass == None)
	{
		return;
	}

	if ( Monster.BurnDown > 0 )
	{
		Monster.BurnDown--;
	}

	if ( Monster.BurnDown < Monster.CrispUpThreshhold )
	{
		Monster.ZombieCrispUp();
	}

	if ( Monster.BurnDown <= 0 )
	{
		Monster.bBurnified = false;
        
		Monster.SetGroundSpeed(Monster.GetOriginalGroundSpeed());
	}
}

static final function int GetFakedPlayerAdjustedCount(LevelInfo Level)
{
	local Controller C;
	local int FakedPlayers;
	local int PlayerCount;
	FakedPlayers = 0;
	PlayerCount = 0;

	if(KFTurboGameTypePlus(Level.Game) != None)
	{
		FakedPlayers = KFTurboGameTypePlus(Level.Game).FAKED_P_HEALTH;
	}

	for( C=Level.ControllerList; C!=None; C=C.NextController )
    {
        if( C.bIsPlayer && C.Pawn!=None && C.Pawn.Health > 0 )
        {
            PlayerCount++;
        }
    }

	return Max(FakedPlayers, PlayerCount);
}

static final function float GetBodyHealthModifier(KFMonster KFM, LevelInfo Level)
{
	local int AdjustedPlayerCount;
    local float AdjustedModifier;
	AdjustedPlayerCount = GetFakedPlayerAdjustedCount(Level);
    AdjustedModifier = 1.f;

    if( AdjustedPlayerCount > 1 )
    {
        AdjustedModifier += (AdjustedPlayerCount - 1) * KFM.PlayerCountHealthScale;
    }

    return AdjustedModifier;
}

static final function float GetHeadHealthModifier(KFMonster KFM, LevelInfo Level)
{
	local int AdjustedPlayerCount;
	local float AdjustedModifier;

	AdjustedPlayerCount = GetFakedPlayerAdjustedCount(Level);
    AdjustedModifier = 1.f;

    if( AdjustedPlayerCount > 1 )
    {
        AdjustedModifier += (AdjustedPlayerCount - 1) * KFM.PlayerNumHeadHealthScale;
    }

    return AdjustedModifier;
}

static final function PreTickAfflictionData(float DeltaTime, KFMonster KFM, out AfflictionData AD)
{
	if (KFM == None)
	{
		return;
	}

	if (AD.Burn != None)
	{
		AD.Burn.PreTick(DeltaTime);
	}

	if (AD.Zap != None)
	{
		AD.Zap.PreTick(DeltaTime);
	}

	if (AD.Harpoon != None)
	{
		AD.Harpoon.PreTick(DeltaTime);
	}
}

static final function TickAfflictionData(float DeltaTime, KFMonster KFM, out AfflictionData AD)
{
	if (KFM == None)
	{
		return;
	}

	if (AD.Burn != None)
	{
		AD.Burn.Tick(DeltaTime);
	}

	if (AD.Zap != None)
	{
		AD.Zap.Tick(DeltaTime);
	}

	if (AD.Harpoon != None)
	{
		AD.Harpoon.Tick(DeltaTime);
	}
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
		AD.Burn.OnDeath();
		AD.Burn = None;
	}

	if (AD.Zap != None)
	{
		AD.Zap.OnDeath();
		AD.Zap = None;
	}

	if (AD.Harpoon != None)
	{
		AD.Harpoon.OnDeath();
		AD.Harpoon = None;
	}
}

static final function DisablePawnCollision(Pawn P)
{
	if (P == None)
	{
		return;
	}

	P.bBlockActors = false;
	P.bBlockPlayers = false;
	P.bBlockProjectiles = false;
	P.bProjTarget = false;
	P.bBlockZeroExtentTraces = false;
	P.bBlockNonZeroExtentTraces = false;
	P.bBlockHitPointTraces = false;
}

static function bool MeleeDamageTarget(KFMonster Monster, int HitDamage, vector PushDirection, out AfflictionData AD)
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
		Return false; 
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

	if( Pawn(HitActor) == none )
	{
		Monster.bBlockHitPointTraces = false;
		HitActor = Monster.Trace(HitLocation, HitNormal, ControllerTarget.Location, Monster.Location, false);
		Monster.bBlockHitPointTraces = true;

		if ( HitActor != None )
		{
			return false;
		}
	}

	HumanPawn = KFHumanPawn(ControllerTarget);
	OriginalDamage = HitDamage;

	if ( HumanPawn != none )
	{
		if (IsPawnBurning(Monster) && AD.Burn != None)
		{
			HitDamage = float(OriginalDamage) * AD.Burn.BurnMonsterDamageModifier;
			class'TurboEventHandler'.static.BroadcastBurnMitigatedDamage(AD.LastBurnDamageInstigator, HumanPawn, HitDamage, OriginalDamage - HitDamage);
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
		if( KFMonster(ControllerTarget) != none )
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
