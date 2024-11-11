//Killing Floor Turbo CardGameRules
//Used to apply a variety of gameplay effects. Moved handling of modifying spawned actors here as well out of the Mutator.
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardGameRules extends TurboGameRules
    hidecategories(Advanced,Display,Events,Object,Sound);
	
var KFTurboCardGameMut MutatorOwner;

//Player
var(Turbo) float BonusCashMultiplier;

var(Turbo) bool bSuddenDeathEnabled, bPerformingSuddenDeath;
var(Turbo) float PlayerThornsDamageMultiplier;

var(Turbo) float FleshpoundDamageMultiplier;
var(Turbo) float ScrakeDamageMultiplier;
var(Turbo) float SlomoDamageMultiplier;
var(Turbo) float PlayerDamageMultiplier;
var(Turbo) float PlayerRangedDamageMultiplier;
var(Turbo) float ExplosiveDamageMultiplier;
var(Turbo) float ExplosiveRadiusMultiplier;
var(Turbo) float ShotgunDamageMultiplier;
var(Turbo) float MedicGrenadeDamageMultiplier;
var(Turbo) float FireDamageMultiplier;
var(Turbo) float BerserkerMeleeDamageMultiplier;
var(Turbo) float TrashHeadshotDamageMultiplier;

var(Turbo) float ExplosiveDamageTakenMultiplier;
var(Turbo) float FallDamageTakenMultiplier;

var(Turbo) float OnPerkDamageMultiplier;
var(Turbo) float OffPerkDamageMultiplier;

var(Turbo) float HeadshotDamageMultiplier;
var(Turbo) float NonHeadshotDamageMultiplier;

var(Turbo) float LowHealthDamageMultiplier;

var (Turbo) bool bCheatDeathEnabled;
struct CheatDeathEntry
{
    var PlayerController Player;
    var float DeathTime;
};
var (Turbo) array<CheatDeathEntry> CheatedDeathPlayerList;

//Monster
var array<KFMonster> MonsterPawnList;

struct HeadshotData
{
    var KFMonster Monster;
    var float HeadHealth;
};
var array<HeadshotData> MonsterHeadshotCheckList;

var(Turbo) float BloatMovementSpeedModifier;
var array<P_Bloat> BloatPawnList;

var(Turbo) float FleshpoundRageThresholdModifier;
var array<P_Fleshpound> FleshpoundPawnList;

var(Turbo) float HuskRefireTimeModifier;
var array<P_Husk> HuskPawnList;

var(Turbo) float SirenScreamDamageMultiplier;
var(Turbo) float SirenScreamRangeModifier;
var array<P_Siren> SirenPawnList;

var(Turbo) float ScrakeRageThresholdModifier;
var array<P_Scrake> ScrakePawnList;

var(Turbo) float MonsterDamageMultiplier;
var(Turbo) float MonsterMeleeDamageMultiplier;
var(Turbo) float MonsterMeleeDamageMomentumMultiplier;
var(Turbo) float MonsterStalkerDamageMultiplier;

static final function bool IsBerserker(Pawn Pawn)
{
    if (Pawn == None || KFPlayerReplicationInfo(Pawn.PlayerReplicationInfo) == None)
    {
        return false;
    }

    if (class<V_Berserker>(KFPlayerReplicationInfo(Pawn.PlayerReplicationInfo).ClientVeteranSkill) != None)
    {
        return true;
    }

    return false;
}

function Tick(float DeltaTime)
{
	local int Index;

	Super.Tick(DeltaTime);

	for(Index = MonsterPawnList.Length - 1; Index > -1; Index--)
	{
		if(MonsterPawnList[Index] == None)
		{
			continue;
		}

        InitializeMonster(MonsterPawnList[Index]);
	}

    MonsterPawnList.Length = 0;

	for(Index = BloatPawnList.Length - 1; Index > -1; Index--)
	{
		if(BloatPawnList[Index] == None)
		{
			continue;
		}

		BloatPawnList[Index].OriginalGroundSpeed *= BloatMovementSpeedModifier;
	}

	BloatPawnList.Length = 0;

	for(Index = FleshpoundPawnList.Length - 1; Index > -1; Index--)
	{
		if(FleshpoundPawnList[Index] == None)
		{
			continue;
		}

		FleshpoundPawnList[Index].RageDamageThreshold = Max(1, float(FleshpoundPawnList[Index].RageDamageThreshold) * FleshpoundRageThresholdModifier);
	}

	FleshpoundPawnList.Length = 0;

	for(Index = HuskPawnList.Length - 1; Index > -1; Index--)
	{
		if(HuskPawnList[Index] == None)
		{
			continue;
		}

		HuskPawnList[Index].ProjectileFireInterval *= HuskRefireTimeModifier;
	}

	HuskPawnList.Length = 0;

	for(Index = SirenPawnList.Length - 1; Index > -1; Index--)
	{
		if(SirenPawnList[Index] == None)
		{
			continue;
		}

		SirenPawnList[Index].ScreamRadius *= SirenScreamRangeModifier;
	}

	SirenPawnList.Length = 0;

	for(Index = ScrakePawnList.Length - 1; Index > -1; Index--)
	{
		if(ScrakePawnList[Index] == None)
		{
			continue;
		}

		ScrakePawnList[Index].HealthRageThreshold *= ScrakeRageThresholdModifier;

        if (ScrakePawnList[Index].ShouldRage())
        {
            ScrakePawnList[Index].RangedAttack(None);
        }
	}


	ScrakePawnList.Length = 0;
}

function InitializeMonster(KFMonster Monster)
{
    local float HeadScaleModifier, ExtCollisionHeightScale, ExtCollisionRadiusScale;
    HeadScaleModifier = MutatorOwner.TurboCardClientModifier.MonsterHeadSizeModifier;

    Monster.HeadScale *= HeadScaleModifier;

    MonsterHeadshotCheckList.Length = MonsterHeadshotCheckList.Length + 1;
    MonsterHeadshotCheckList[MonsterHeadshotCheckList.Length - 1].Monster = Monster;
    MonsterHeadshotCheckList[MonsterHeadshotCheckList.Length - 1].HeadHealth = Monster.HeadHealth;

    if (HeadScaleModifier > 1.f && Monster.MyExtCollision != None)
    {
        ExtCollisionHeightScale = ((HeadScaleModifier - 1.f) * 0.5f) + 1.f;
        ExtCollisionRadiusScale = ((HeadScaleModifier - 1.f) * 0.25f) + 1.f;
        Monster.MyExtCollision.SetCollisionSize(Monster.MyExtCollision.CollisionRadius * ExtCollisionRadiusScale, Monster.MyExtCollision.CollisionHeight * ExtCollisionHeightScale);
    }
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	if (Super.PreventDeath(Killed, Killer, DamageType, HitLocation))
    {
        return true;
    }

    if (bCheatDeathEnabled && Killed != None && PlayerController(Killed.Controller) != None)
    {
        if (AttemptCheatDeath(PlayerController(Killed.Controller), Killed, DamageType))
        {
            return true;
        }
    }
		
	return false;
}

function bool AttemptCheatDeath(PlayerController Killed, Pawn KilledPawn, class<DamageType> DamageType)
{
    local int Index;

    //Do not block suicides or kills caused by the world (unless it's normal fall damage).
    if (class<Suicided>(DamageType) != None || (DamageType.default.bCausedByWorld && class<TurboHumanFall_DT>(DamageType) == None))
    {
        return false;
    }

    for(Index = CheatedDeathPlayerList.Length - 1; Index > -1; Index--)
    {
        if (CheatedDeathPlayerList[Index].Player == Killed)
        {
            return false;
        }
    }

    CheatedDeathPlayerList.Length = CheatedDeathPlayerList.Length + 1;
    CheatedDeathPlayerList[CheatedDeathPlayerList.Length - 1].Player = Killed;
    CheatedDeathPlayerList[CheatedDeathPlayerList.Length - 1].DeathTime = Level.TimeSeconds;
    KilledPawn.Health = Max(KilledPawn.HealthMax * 0.5f, Max(KilledPawn.Health, 1));

    Level.BroadcastLocalizedMessage(class'CheatDeathLocalMessage', 0, Killed.PlayerReplicationInfo);
    
    return true;
}

function int NetDamage(int OriginalDamage, int Damage, Pawn Injured, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType )
{
    local class<KFWeaponDamageType> WeaponDamageType;
    local float DamageMultiplier;
    Damage = Super.NetDamage(OriginalDamage, Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);

    if (Damage <= 0)
    {
        return Damage;
    }

    DamageMultiplier = 1.f;

    WeaponDamageType = class<KFWeaponDamageType>(DamageType);
    if (WeaponDamageType != None)
    {
        if (KFHumanPawn(InstigatedBy) != None)
        {
            if (LowHealthDamageMultiplier != 1.f && ((float(InstigatedBy.Health) / InstigatedBy.HealthMax) < 0.5f))
            {
                DamageMultiplier *= LowHealthDamageMultiplier;
            }

            DamageMultiplier *= PlayerDamageMultiplier;
            
            if (WeaponDamageType.default.bIsExplosive)
            {
                DamageMultiplier *= ExplosiveDamageMultiplier;
            }

            if (WeaponDamageType.default.bDealBurningDamage)
            {
                DamageMultiplier *= FireDamageMultiplier;
            }

            if (ShotgunDamageMultiplier != 1.f && (class'V_SupportSpec'.static.IsPerkDamageType(WeaponDamageType) || class<DamTypeTrenchgun>(DamageType) != None))
            {
                DamageMultiplier *= ShotgunDamageMultiplier;
            }

            if (WeaponDamageType.default.bIsMeleeDamage)
            {
                if (BerserkerMeleeDamageMultiplier != 1.f && IsBerserker(InstigatedBy))
                {
                    DamageMultiplier *= BerserkerMeleeDamageMultiplier;
                }
            }
            else
            { 
                DamageMultiplier *= PlayerRangedDamageMultiplier;
            }

            if ((OnPerkDamageMultiplier != 1.f || OffPerkDamageMultiplier != 1.f) && KFHumanPawn(InstigatedBy) != None && KFPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo) != None)
            {
                ApplyPerkDamageModifiers(DamageMultiplier, KFHumanPawn(InstigatedBy), KFPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo), WeaponDamageType);
            }

            if (KFMonster(Injured) != None)
            {
                MonsterNetDamage(DamageMultiplier, KFMonster(Injured), InstigatedBy, HitLocation, Momentum, WeaponDamageType);
            }
        }

        if (KFHumanPawn(Injured) != None && WeaponDamageType.default.bIsExplosive)
        {
            DamageMultiplier *= ExplosiveDamageTakenMultiplier;
        }
    }
    else if (KFMonster(InstigatedBy) != None)
    {
        DamageMultiplier *= MonsterDamageMultiplier;

        if (P_Stalker(InstigatedBy) != None)
        {
            DamageMultiplier *= MonsterStalkerDamageMultiplier;
        }

        if (class<SirenScreamDamage>(DamageType) != None)
        {   
            DamageMultiplier *= SirenScreamDamageMultiplier;
        }
        else if (class<ZombieMeleeDamage>(DamageType) != None)
        {
            DamageMultiplier *= MonsterMeleeDamageMultiplier;
            Momentum *= MonsterMeleeDamageMomentumMultiplier;
        }
    }

    if (KFHumanPawn(InstigatedBy) != None)
    {
        if (Level.TimeDilation < 1.f)
        {
            DamageMultiplier *= SlomoDamageMultiplier;
        }
    
        if (P_Fleshpound(Injured) != None)
        {
            DamageMultiplier *= FleshpoundDamageMultiplier;
        }

        if (P_Scrake(Injured) != None)
        {
            DamageMultiplier *= ScrakeDamageMultiplier;
        }
    }

    if (KFHumanPawn(Injured) != None)
    {
        if (FallDamageTakenMultiplier != 1.f && class<TurboHumanFall_DT>(DamageType) != None)
        {
            DamageMultiplier *= FallDamageTakenMultiplier;
        }
    }

    //Apply damage multipliers all at once.
    Damage = float(Damage) * DamageMultiplier;

    if (KFMonster(InstigatedBy) != None && KFHumanPawn(Injured) != None)
    {
        ApplyThornsDamage(Damage, KFHumanPawn(Injured), KFMonster(InstigatedBy));
    }

	return Damage;
}

function ApplyPerkDamageModifiers(out float DamageMultiplier, KFHumanPawn InstigatedBy, KFPlayerReplicationInfo InstigatedByPRI, class<KFWeaponDamageType> WeaponDamageType)
{
    if (class<TurboVeterancyTypes>(InstigatedByPRI.ClientVeteranSkill) == None)
    { 
        return;
    }

    if (class<TurboVeterancyTypes>(InstigatedByPRI.ClientVeteranSkill).static.IsPerkDamageType(WeaponDamageType))
    {
        DamageMultiplier *= OnPerkDamageMultiplier;
    }
    else
    {
        DamageMultiplier *= OffPerkDamageMultiplier;
    }
}

function bool WasHeadshot(KFMonster Injured)
{
    local int Index;
    local bool bResult;
    for (Index = 0; Index < MonsterHeadshotCheckList.Length; Index++)
    {
        if (MonsterHeadshotCheckList[Index].Monster == Injured)
        {
            bResult = MonsterHeadshotCheckList[Index].HeadHealth > Injured.HeadHealth;
            MonsterHeadshotCheckList[Index].HeadHealth = Injured.HeadHealth;
            return bResult;
        }
    }
    
    return false;
}

function MonsterNetDamage(out float DamageMultiplier, KFMonster Injured, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<KFWeaponDamageType> WeaponDamageType)
{
    local bool bWasHeadshot;
    bWasHeadshot = WasHeadshot(Injured);

    if (WeaponDamageType.default.bCheckForHeadShots)
    {
        if (bWasHeadshot)
        {
            //We use kill message rules to figure out if something is a trash zed.
            if(Class'HUDKillingFloor'.Default.MessageHealthLimit > Injured.Default.Health && Class'HUDKillingFloor'.Default.MessageMassLimit > Injured.Default.Mass)
            {
                DamageMultiplier *= TrashHeadshotDamageMultiplier;
            }

            DamageMultiplier *= HeadshotDamageMultiplier;
        }
        else
        {
            DamageMultiplier *= NonHeadshotDamageMultiplier;
        }
    }
}

function ApplyThornsDamage(int DamageTaken, KFHumanPawn Injured, KFMonster InstigatedBy)
{
    local class<DamageType> MonsterFireDamageClass;
    if (PlayerThornsDamageMultiplier <= 1.f)
    {
        return;
    }

    MonsterFireDamageClass = InstigatedBy.FireDamageClass;
    
    InstigatedBy.FireDamageClass = None;
    InstigatedBy.TakeFireDamage(float(DamageTaken) * (PlayerThornsDamageMultiplier - 1.f), Injured);

    InstigatedBy.FireDamageClass = MonsterFireDamageClass;
}

function ScoreKill(Controller Killer, Controller Killed)
{
    Super.ScoreKill(Killer, Killed);

    if (Killer != None && Killed != None)
    {
        if (BonusCashMultiplier > 1.f && Killer.PlayerReplicationInfo != None && KFMonster(Killed.Pawn) != None)
        {
            GiveBonusCash(Killer.PlayerReplicationInfo, KFMonster(Killed.Pawn));
        }
    }

    if (Killed != None)
    {
        if (bSuddenDeathEnabled && KFHumanPawn(Killed.Pawn) != None)
        {
            PerformSuddenDeath();
        }

        if (KFMonster(Killed.Pawn) != None)
        {
            RemoveMonsterFromHeadshotList(KFMonster(Killed.Pawn));
        }
    }
}

function bool ShouldTriggerSuddenDeath(Controller Killed, class<DamageType> DamageType)
{
    //Don't trigger sudden death on suicide during trader time.
    if (class<Suicided>(DamageType) != None && KFGameType(Level.Game) != None && !KFGameType(Level.Game).bWaveInProgress)
    {
        return false;
    }

    //Don't trigger sudden death from sudden death.
    if (class<SuddenDeath_DT>(DamageType) != None)
    {
        return false;
    }

    return true;
}

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType)
{
    if (Killed == None)
    {
        return;
    }

    if (bSuddenDeathEnabled && PlayerController(Killed) != None && KFHumanPawn(Killed.Pawn) != None
        && Killed.PlayerReplicationInfo != None && Killed.PlayerReplicationInfo.Ping < 255)
    {
        if (ShouldTriggerSuddenDeath(Killed, DamageType))
        {
            PerformSuddenDeath();
        }
    }
}

function RemoveMonsterFromHeadshotList(KFMonster Monster)
{
    local int Index;
    for(Index = MonsterHeadshotCheckList.Length - 1; Index > -1; Index--)
    {
        if (MonsterHeadshotCheckList[Index].Monster == None)
        {
            MonsterHeadshotCheckList.Remove(Index, 1);
            continue;
        }

        if (MonsterHeadshotCheckList[Index].Monster == Monster)
        {
            MonsterHeadshotCheckList.Remove(Index, 1);
            break;
        }
    }
}

function PerformSuddenDeath()
{
    local Controller C;
    local PlayerController PC;
    if (bPerformingSuddenDeath)
    {
        return;
    }

    bPerformingSuddenDeath = true;
    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        PC = PlayerController(C);

        if (PC != None && PC.Pawn != None && !PC.Pawn.bDeleteMe && PC.Pawn.Health > 0)
        {
            //Allow Cheat Death to directly stop this.
            if (!AttemptCheatDeath(PC, PC.Pawn, class'SuddenDeath_DT'))
            {
                PlayerController(C).Pawn.Died(None, class'SuddenDeath_DT', PlayerController(C).Pawn.Location);
            }
        }
    }
    bPerformingSuddenDeath = false;
}

function float GetAdjustedScoreValue(float Score)
{
    if ( Level.Game.GameDifficulty >= 5.0 )
    {
        Score *= 0.65;
    }
    else if ( Level.Game.GameDifficulty >= 4.0 )
    {
        Score *= 0.85;
    }
    else if ( Level.Game.GameDifficulty >= 2.0 )
    {
        Score *= 1.0;
    }
    else
    {
        Score *= 2.0;
    }

    return Score;
}

function GiveBonusCash(PlayerReplicationInfo KillerPRI, KFMonster Monster)
{
    KillerPRI.Score += Max(int(((BonusCashMultiplier - 1.f) * GetAdjustedScoreValue(Monster.ScoringValue))), 0);
}

function ModifyActor(Actor Other)
{
    if (Projectile(Other) != None && KFHumanPawn(Other.Instigator) != None)
    {
        Projectile(Other).DamageRadius *= ExplosiveRadiusMultiplier;

        if (MedicNade(Other) != None)
        {
            MedicNade(Other).Damage *= MedicGrenadeDamageMultiplier;
        }
    }

    if (KFMonster(Other) != None)
    {
        MonsterPawnList[MonsterPawnList.Length] = KFMonster(Other);

        if (BloatMovementSpeedModifier != 1.f && P_Bloat(Other) != None)
        {
            BloatPawnList[BloatPawnList.Length] = P_Bloat(Other);
        }
        else if (FleshpoundRageThresholdModifier != 1.f && P_Fleshpound(Other) != None)
        {
            FleshpoundPawnList[FleshpoundPawnList.Length] = P_Fleshpound(Other);
        }
        else if (HuskRefireTimeModifier != 1.f && P_Husk(Other) != None)
        {
            HuskPawnList[HuskPawnList.Length] = P_Husk(Other);
        }
        else if (SirenScreamRangeModifier != 1.f && P_Siren(Other) != None)
        {
            SirenPawnList[SirenPawnList.Length] = P_Siren(Other);
        }
        else if (ScrakeRageThresholdModifier != 1.f && P_Scrake(Other) != None)
        {
            ScrakePawnList[ScrakePawnList.Length] = P_Scrake(Other);
        }
    }
}

defaultproperties
{
    BonusCashMultiplier=1.f

    bSuddenDeathEnabled=false
    bPerformingSuddenDeath=false
    PlayerThornsDamageMultiplier=1.f

    FleshpoundDamageMultiplier=1.f
    ScrakeDamageMultiplier=1.f
    PlayerDamageMultiplier=1.f
    SlomoDamageMultiplier=1.f
    PlayerRangedDamageMultiplier=1.f
    ExplosiveDamageMultiplier=1.f
    ExplosiveRadiusMultiplier=1.f
    ShotgunDamageMultiplier=1.f
    MedicGrenadeDamageMultiplier=1.f
    FireDamageMultiplier=1.f
    BerserkerMeleeDamageMultiplier=1.f
    TrashHeadshotDamageMultiplier=1.f

    ExplosiveDamageTakenMultiplier=1.f
    FallDamageTakenMultiplier=1.f

    OnPerkDamageMultiplier=1.f
    OffPerkDamageMultiplier=1.f

    HeadshotDamageMultiplier=1.f
    NonHeadshotDamageMultiplier=1.f

    LowHealthDamageMultiplier=1.f

    SirenScreamDamageMultiplier=1.f

    BloatMovementSpeedModifier=1.f

    FleshpoundRageThresholdModifier=1.f

    HuskRefireTimeModifier=1.f

    SirenScreamRangeModifier=1.f

    ScrakeRageThresholdModifier=1.f

    MonsterDamageMultiplier=1.f
    MonsterMeleeDamageMultiplier=1.f
    MonsterMeleeDamageMomentumMultiplier=1.f
    MonsterStalkerDamageMultiplier=1.f

}
