//Killing Floor Turbo CardGameRules
//Used to apply a variety of gameplay effects. Moved handling of modifying spawned actors here as well out of the Mutator.
//Distributed under the terms of the MIT License.
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
var(Turbo) float MeleeDamageMultiplier;
var(Turbo) float FireDamageMultiplier;
var(Turbo) float BerserkerMeleeDamageMultiplier;
var(Turbo) float TrashHeadshotDamageMultiplier;
var(Turbo) float TrashDamageMultiplier;
var(Turbo) float BossDamageMultiplier;
var(Turbo) float MonsterFullHealthDamageMultiplier;
var(Turbo) bool bPlayerHeadshotsIncreaseHeadshotDamage;

var(Turbo) float DamageTakenMultiplier;
var(Turbo) float ExplosiveDamageTakenMultiplier;
var(Turbo) float FallDamageTakenMultiplier;
var(Turbo) float PlayerBurnDamageModifier;

var(Turbo) float OnPerkDamageMultiplier;
var(Turbo) float OffPerkDamageMultiplier;

var(Turbo) float HeadshotDamageMultiplier;
var(Turbo) float NonHeadshotDamageMultiplier;

var(Turbo) float LowHealthDamageMultiplier;

var(Turbo) float CriticalHitDamageMultiplier;
var(Turbo) float BaseCriticalHitChance;
var(Turbo) float CriticalHitChance;
var(Turbo) bool bCriticalHitChanceForEachNonCriticalHit;
var(Turbo) bool bBonusCriticalHitChanceAfterCriticalHit;
var bool bHasPerformedCriticalHitEffect;

var(Turbo) bool bCheatDeathEnabled;

var(Turbo) bool bRussianRouletteEnabled;
var(Turbo) Sound RussianRoulettePlayerKilledSound, RussianRouletteMonsterKilledSound;

var(Turbo) bool bDisableSyringe;
var(Turbo) bool bNoDropOrSellItems;
var(Turbo) float PlayerJumpZMultiplier;
var(Turbo) float PlayerAirControlMultiplier;

var(Turbo) bool bSuperGrenades;
var(Turbo) bool bOversizedPipebombs;

//Monster
var array<KFMonster> MonsterPawnList;

var(Turbo) float ClotMovementSpeedModifier;
var array<P_Clot> ClotPawnList;

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
var(Turbo) float MonsterRangedDamageMultiplier;
var(Turbo) float MonsterMeleeDamageMomentumMultiplier;
var(Turbo) float MonsterStalkerDamageMultiplier;

//Chance damage to monster can stun them.
var(Turbo) float MonsterStunChance;

var Pawn MarkedForDeathPawn;

var(Turbo) bool bNegateFirstPlayerDamage;

var bool bMassDetonationEnabled;
struct MassDetonationEntry
{
    var float ExplodeTime; //When to trigger.
    var vector Location;
    var int MaxHealth;
    var PlayerController Controller; //Instigator of the entry.
};
var array<MassDetonationEntry> MassDetonationList;

var bool bKillsGiveShield;

var bool bZedDamageDropsWeapon;

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

static final function TurboPlayerCardCustomInfo FindCustomInfo(TurboPlayerReplicationInfo TPRI)
{
    return TurboPlayerCardCustomInfo(class'TurboPlayerCardCustomInfo'.static.FindCustomInfo(TPRI));
}

final static function class<CoreMonsterClassification> GetMonsterClassification(class<CoreMonster> MonsterClass)
{
    if (MonsterClass != None)
    {
        return MonsterClass.default.MonsterClassification;
    }

    return class'MonsterClassificationSpecial';
}

final static function class<CoreMonster> GetMonsterArchetype(class<CoreMonster> MonsterClass)
{
    if (MonsterClass != None)
    {
        return MonsterClass.default.MonsterArchetypeClass;
    }

    return None;
}


function Tick(float DeltaTime)
{
	local int Index;

	Super.Tick(DeltaTime);

    bHasPerformedCriticalHitEffect = false;

	for(Index = MonsterPawnList.Length - 1; Index > -1; Index--)
	{
		if(MonsterPawnList[Index] == None)
		{
			continue;
		}

        InitializeMonster(MonsterPawnList[Index]);
	}

    MonsterPawnList.Length = 0;

	for(Index = ClotPawnList.Length - 1; Index > -1; Index--)
	{
		if(ClotPawnList[Index] == None)
		{
			continue;
		}

		ClotPawnList[Index].OriginalGroundSpeed *= ClotMovementSpeedModifier;
	}

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

    ProcessMassDetonationList();
}

function InitializeMonster(KFMonster Monster)
{
    local float HeadScaleModifier, ExtCollisionHeightScale, ExtCollisionRadiusScale;
    HeadScaleModifier = MutatorOwner.TurboCardClientModifier.MonsterHeadSizeModifier;

    Monster.HeadScale *= HeadScaleModifier;

    if (HeadScaleModifier > 1.f && Monster.MyExtCollision != None)
    {
        ExtCollisionHeightScale = ((HeadScaleModifier - 1.f) * 0.5f) + 1.f;
        ExtCollisionRadiusScale = ((HeadScaleModifier - 1.f) * 0.25f) + 1.f;
        Monster.MyExtCollision.SetCollisionSize(Monster.MyExtCollision.CollisionRadius * ExtCollisionRadiusScale, Monster.MyExtCollision.CollisionHeight * ExtCollisionHeightScale);
    }
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
    local TurboPlayerCardCustomInfo PlayerCardInfo;

	if (Super.PreventDeath(Killed, Killer, DamageType, HitLocation))
    {
        return true;
    }

    if (bCheatDeathEnabled && Killed != None && Killed.PlayerReplicationInfo != None && PlayerController(Killed.Controller) != None)
    {
        PlayerCardInfo = FindCustomInfo(TurboPlayerReplicationInfo(Killed.PlayerReplicationInfo));
        if (PlayerCardInfo != None && IsInCheatDeathGracePeriod(PlayerCardInfo) || AttemptCheatDeath(PlayerCardInfo, Killed, DamageType))
        {
            return true;
        }
    }
		
	return false;
}

final function bool AttemptCheatDeath(TurboPlayerCardCustomInfo PlayerCardInfo, Pawn KilledPawn, class<DamageType> DamageType)
{
    //Do not block suicides or kills caused by the world (unless it's normal fall damage).
    if (class<Suicided>(DamageType) != None || (DamageType.default.bCausedByWorld && class<TurboHumanFall_DT>(DamageType) == None))
    {
        return false;
    }

    if (PlayerCardInfo == None || (PlayerCardInfo.CheatDeathWave > 0 && PlayerCardInfo.CheatDeathWave < (Level.Game.GetCurrentWaveNum() + 2)))
    {
        return false;
    }

    PlayerCardInfo.CheatDeathWave = Level.Game.GetCurrentWaveNum();
    PlayerCardInfo.CheatDeathTime = Level.TimeSeconds + 3.f;

    KilledPawn.Health = KilledPawn.HealthMax;
    Level.BroadcastLocalizedMessage(class'CheatDeathLocalMessage', 0, PlayerCardInfo.PlayerTPRI);
    Spawn(class'CheatDeathEffect', KilledPawn,, KilledPawn.Location + (vect(0, 0, 0.8f) * KilledPawn.CollisionHeight));
    return true;
}

final function bool IsInCheatDeathGracePeriod(TurboPlayerCardCustomInfo PlayerCardInfo)
{
    return PlayerCardInfo != None && PlayerCardInfo.IsInCheatDeathGracePeriod();
}

function int NetDamage(int OriginalDamage, int Damage, Pawn Injured, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType )
{
    local class<KFWeaponDamageType> WeaponDamageType;
    local TurboPlayerCardCustomInfo InjuredCardInfo, InstigatorCardInfo;
    local float DamageMultiplier;

    //I hate how much we cast these so I'm just going to do them all once.
    local TurboHumanPawn InjuredHumanPawn, InstigatorHumanPawn;
    local KFMonster InjuredMonster, InstigatorMonster;

    Damage = Super.NetDamage(OriginalDamage, Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);

    if (Damage <= 0)
    {
        return Damage;
    }

    DamageMultiplier = 1.f;

    InjuredHumanPawn = TurboHumanPawn(Injured);
    if (InjuredHumanPawn == None)
    {
        InjuredMonster = KFMonster(Injured);
    }

    InstigatorHumanPawn = TurboHumanPawn(InstigatedBy);
    if (InstigatorHumanPawn == None)
    {
        InstigatorMonster = KFMonster(InstigatedBy);
    }
    else
    {
        if (InstigatedBy.Controller != None && InstigatedBy.Controller.PlayerReplicationInfo != None && InstigatedBy.Controller.bIsPlayer)
        {
            InstigatorCardInfo = FindCustomInfo(TurboPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo));
        }
    }

    //Check for outright damage blocking effects first.
    if (InjuredHumanPawn != None)
    {
        InjuredCardInfo = FindCustomInfo(TurboPlayerReplicationInfo(Injured.PlayerReplicationInfo));
        if (bCheatDeathEnabled && IsInCheatDeathGracePeriod(InjuredCardInfo))
        {
            return 0;
        }

        if (bNegateFirstPlayerDamage && AttemptNegateDamage(InjuredCardInfo))
        {
            return 0;
        }

        if (IsInHealingBoostTime(InjuredCardInfo))
        {
            DamageMultiplier *= 0.5f;
        }
        
        DamageMultiplier *= DamageTakenMultiplier;
    }

    if (MarkedForDeathPawn == Injured)
    {
        DamageMultiplier *= 3.f;
    }

    if (class<SirenScreamDamage>(DamageType) != None)
    {   
        DamageMultiplier *= SirenScreamDamageMultiplier;
    }

    WeaponDamageType = class<KFWeaponDamageType>(DamageType);
    if (WeaponDamageType != None)
    {
        if (InstigatorHumanPawn != None)
        {
            if (LowHealthDamageMultiplier != 1.f && ((float(InstigatedBy.Health) / InstigatedBy.HealthMax) < 0.75f))
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
                DamageMultiplier *= MeleeDamageMultiplier;

                if (BerserkerMeleeDamageMultiplier != 1.f && IsBerserker(InstigatedBy))
                {
                    DamageMultiplier *= BerserkerMeleeDamageMultiplier;
                }
            }
            else
            { 
                DamageMultiplier *= PlayerRangedDamageMultiplier;
            }

            if ((OnPerkDamageMultiplier != 1.f || OffPerkDamageMultiplier != 1.f) && KFPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo) != None)
            {
                ApplyPerkDamageModifiers(DamageMultiplier, InstigatorHumanPawn, KFPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo), WeaponDamageType);
            }
        }

        if (InjuredHumanPawn != None && WeaponDamageType.default.bIsExplosive)
        {
            DamageMultiplier *= ExplosiveDamageTakenMultiplier;
        }
    }
    
    if (InstigatorMonster != None)
    {
        DamageMultiplier *= MonsterDamageMultiplier;

        if (P_Stalker(InstigatedBy) != None)
        {
            DamageMultiplier *= MonsterStalkerDamageMultiplier;
        }

        if (class<ZombieMeleeDamage>(DamageType) != None)
        {
            DamageMultiplier *= MonsterMeleeDamageMultiplier;
            Momentum *= MonsterMeleeDamageMomentumMultiplier;
        }
        else
        {
            DamageMultiplier *= MonsterRangedDamageMultiplier;
        }
    }

    if (InstigatorHumanPawn != None)
    {
        if (Level.TimeDilation < 0.75f)
        {
            DamageMultiplier *= SlomoDamageMultiplier;
        }
    
        if (InjuredMonster != None && P_Fleshpound(Injured) != None)
        {
            DamageMultiplier *= FleshpoundDamageMultiplier;
        }

        if (InjuredMonster != None && P_Scrake(Injured) != None)
        {
            DamageMultiplier *= ScrakeDamageMultiplier;
        }
    }

    if (InjuredHumanPawn != None)
    {
        if (PlayerBurnDamageModifier != 1.f && class<TurboHumanBurned_DT>(DamageType) != None)
        {
            DamageMultiplier *= PlayerBurnDamageModifier;
        }
        else if (FallDamageTakenMultiplier != 1.f && class<TurboHumanFall_DT>(DamageType) != None)
        {
            DamageMultiplier *= FallDamageTakenMultiplier;
        }
    }

    //Apply damage multipliers all at once.
    Damage = float(Damage) * DamageMultiplier;

    if (Damage <= 0.f)
    {
        return 0.f;
    }

    
    if (InstigatorCardInfo != None && InjuredMonster != None)
    {
        AttemptCriticalHit(DamageMultiplier, InstigatedBy, InstigatorCardInfo, HitLocation);

        MonsterNetDamage(DamageMultiplier, InjuredMonster, InstigatedBy, InstigatorCardInfo, HitLocation, Momentum, WeaponDamageType);
    }


    if (InstigatorMonster != None && InjuredHumanPawn != None)
    {
        ApplyThornsDamage(Damage, InjuredHumanPawn, InstigatorMonster);
        
        if (MutatorOwner.TurboCardGameplayManagerInfo.BleedManager != None && class<ZombieMeleeDamage>(DamageType) != None && class<TurboHumanBleed_DT>(DamageType) == None)
        {
            MutatorOwner.TurboCardGameplayManagerInfo.BleedManager.ApplyBleedToPlayer(InjuredHumanPawn);
        }
    }
    
    //If resulting damage was more than 1, check russian roulette if it's enabled.
    if (bRussianRouletteEnabled && FRand() < 0.001 && class<TurboHumanBurned_DT>(DamageType) == None)
    {
        PerformRussianRouletteEffect(Injured, InjuredHumanPawn != None);

        if (InstigatedBy == None)
        {
            Injured.Died(None, class'RussianRoulette_DT', Injured.Location);
        }
        else
        {
            Injured.Died(InstigatedBy.Controller, class'RussianRoulette_DT', Injured.Location);
        }
    }

    if (bZedDamageDropsWeapon)
    {
        PlayerDropWeapon(InjuredHumanPawn, InjuredCardInfo);
    }

	return Damage;
}

final function bool IsInHealingBoostTime(TurboPlayerCardCustomInfo PlayerCardInfo)
{
    return PlayerCardInfo != None && PlayerCardInfo.IsInHealBoostTime();
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

function MonsterNetDamage(out float DamageMultiplier, KFMonster Injured, Pawn InstigatedBy, TurboPlayerCardCustomInfo InsitgatorCardInfo, Vector HitLocation, out Vector Momentum, class<KFWeaponDamageType> WeaponDamageType)
{
    local bool bWasHeadshot;
    local class<CoreMonsterClassification> MonsterClassification;
    MonsterClassification = GetMonsterClassification(class<CoreMonster>(Injured.Class));

    if (MonsterClassification == class'MonsterClassificationBoss')
    {
        DamageMultiplier *= BossDamageMultiplier;
    }
    else if (MonsterClassification == class'MonsterClassificationTrash')
    {
        DamageMultiplier *= TrashDamageMultiplier;
    }

    if ((Injured.Health - Injured.HealthMax) > -1.f)
    {
        DamageMultiplier *= MonsterFullHealthDamageMultiplier;
    }

    if (WeaponDamageType.default.bCheckForHeadShots)
    {
        //It's fine to ask this again since we haven't run PlayHit yet or anything.
        if (class<DamTypeMelee>(WeaponDamageType) != None)
        {
            bWasHeadshot = Injured.IsHeadShot(HitLocation, Normal(Momentum), 1.25f); 
        }
        else
        {
            bWasHeadshot = Injured.IsHeadShot(HitLocation, Normal(Momentum), 1.f);
        }

        if (bWasHeadshot)
        {
            if(MonsterClassification == class'MonsterClassificationTrash')
            {
                DamageMultiplier *= TrashHeadshotDamageMultiplier;
            }

            DamageMultiplier *= HeadshotDamageMultiplier;

            if (bPlayerHeadshotsIncreaseHeadshotDamage && InsitgatorCardInfo != None)
            {
                DamageMultiplier *= InsitgatorCardInfo.GetPlayerHeadshotBonus();
            }
        }
        else
        {
            DamageMultiplier *= NonHeadshotDamageMultiplier;
        }
    }

    if (MonsterStunChance > 0.f && FRand() < MonsterStunChance)
    {
        ForceFlipOver(Injured);
    }
}

function AttemptCriticalHit(out float Damage, Pawn InstigatedBy, TurboPlayerCardCustomInfo PlayerCardInfo, vector HitLocation)
{
    local float CurrentCriticalHitChance;
    local int NumCriticalHits;

    NumCriticalHits = 0;
    CurrentCriticalHitChance = CriticalHitChance + BaseCriticalHitChance;

    if (bBonusCriticalHitChanceAfterCriticalHit && PlayerCardInfo != None && PlayerCardInfo.IsInPerpetualCriticalHitTime())
    {
        CurrentCriticalHitChance += 0.5f;
    }

    if (bCriticalHitChanceForEachNonCriticalHit && PlayerCardInfo != None && PlayerCardInfo.NonCriticalHitCount > 0)
    {
        CurrentCriticalHitChance += float(PlayerCardInfo.NonCriticalHitCount) * 0.02f;
    }
    
    while (CurrentCriticalHitChance >= 1.f)
    {
        NumCriticalHits++;
        CurrentCriticalHitChance -= 1.f;
    }

    if (CurrentCriticalHitChance > 0.f && FRand() < CurrentCriticalHitChance)
    {
        NumCriticalHits++;
    }

    if (NumCriticalHits <= 0)
    {
        if (bCriticalHitChanceForEachNonCriticalHit && PlayerCardInfo != None)
        {
            PlayerCardInfo.NonCriticalHitCount++;
        }
            
        return;
    }
    else
    {
        if (bCriticalHitChanceForEachNonCriticalHit && PlayerCardInfo != None)
        {
            PlayerCardInfo.NonCriticalHitCount = 0;
        }
    }
    
    if (bBonusCriticalHitChanceAfterCriticalHit && PlayerCardInfo != None)
    {
        PlayerCardInfo.AttemptGrantPerpetualCriticalHit();
    }

    if (!bHasPerformedCriticalHitEffect)
    {
        bHasPerformedCriticalHitEffect = true;
        PlayerCardInfo.ClientCriticalHit(HitLocation, NumCriticalHits);
    }
    
    Damage *= CriticalHitDamageMultiplier * float(NumCriticalHits);
}

function ApplyThornsDamage(int DamageTaken, KFHumanPawn Injured, KFMonster InstigatedBy)
{
    if (PlayerThornsDamageMultiplier <= 1.f)
    {
        return;
    }

    InstigatedBy.TakeDamage(float(DamageTaken) * (PlayerThornsDamageMultiplier - 1.f), Injured, Injured.Location, vect(0, 0, 0), class'PlayerThornsDamage_DT');
}

function PerformRussianRouletteEffect(Pawn KilledPawn, bool bWasPlayer)
{
    if (bWasPlayer)
    {
        Spawn(class'RoulettePlayerEffect', KilledPawn,, KilledPawn.Location + (vect(0, 0, 1) * KilledPawn.CollisionHeight));
    }
    else
    {
        Spawn(class'RouletteEffect', KilledPawn,, KilledPawn.Location + (vect(0, 0, 1) * KilledPawn.CollisionHeight));
    }
}

function PlayerDropWeapon(TurboHumanPawn Injured, TurboPlayerCardCustomInfo PlayerCardInfo)
{
    if (!PlayerCardInfo.CanPlayerDropWeapon() || FRand() > 0.05f)
    {
        return;
    }

    if (KFWeapon(Injured.Weapon) == None || KFWeapon(Injured.Weapon).bKFNeverThrow)
    {
        return;
    }

    Injured.TossWeapon(vect(0,0,0));
    PlayerCardInfo.PlayerDroppedWeapon();
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
}

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType)
{
    if (Killed == None)
    {
        Super.Killed(Killer, Killed, KilledPawn, DamageType);
        return;
    }

    if (bSuddenDeathEnabled && PlayerController(Killed) != None && KFHumanPawn(Killed.Pawn) != None && Killed.PlayerReplicationInfo != None)
    {
        if (ShouldTriggerSuddenDeath(Killed, DamageType))
        {
            PerformSuddenDeath();
        }
    }

    if (bMassDetonationEnabled && FRand() < 0.25f && KFMonster(KilledPawn) != None && PlayerController(Killer) != None)
    {
        if (class<KFWeaponDamageType>(DamageType) != None && class<KFWeaponDamageType>(DamageType).default.bIsExplosive)
        {
            AddMassDetonationEntry(KFMonster(KilledPawn), PlayerController(Killer));
        }
    }

    if (bKillsGiveShield && KFMonster(KilledPawn) != None && PlayerController(Killer) != None)
    {
        GrantShieldOnKill(CoreMonster(KilledPawn), PlayerController(Killer));
    }
    
    Super.Killed(Killer, Killed, KilledPawn, DamageType);
}

function bool ShouldTriggerSuddenDeath(Controller Killed, class<DamageType> DamageType)
{
    if (class<Suicided>(DamageType) != None)
    {
        //Don't trigger sudden death on suicide during trader time.
        if (KFGameType(Level.Game) != None && !KFGameType(Level.Game).bWaveInProgress)
        {
            return false;
        }

        //Usually 255 or more is a player timing out.
        if (Killed.PlayerReplicationInfo.Ping < 255)
        {
            return false;
        }
    }

    //Don't trigger sudden death from sudden death.
    if (class<SuddenDeath_DT>(DamageType) != None)
    {
        return false;
    }

    return true;
}

function PerformSuddenDeath()
{
    local Controller C;
    local PlayerController PC;
    local TurboPlayerCardCustomInfo PlayerCardInfo;

    if (bPerformingSuddenDeath)
    {
        return;
    }

    bPerformingSuddenDeath = true;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        PC = PlayerController(C);

        if (PC != None && PC.Pawn != None && PC.PlayerReplicationInfo != None && !PC.Pawn.bDeleteMe && PC.Pawn.Health > 0)
        {
            if (bCheatDeathEnabled)
            {
                PlayerCardInfo = FindCustomInfo(TurboPlayerReplicationInfo(PC.PlayerReplicationInfo));
                if (IsInCheatDeathGracePeriod(PlayerCardInfo) || AttemptCheatDeath(PlayerCardInfo, PC.Pawn, class'SuddenDeath_DT'))
                {
                    continue;
                }
            }

            PlayerController(C).Pawn.Died(None, class'SuddenDeath_DT', PlayerController(C).Pawn.Location);
        }
    }

    bPerformingSuddenDeath = false;
}

function AddMassDetonationEntry(KFMonster KilledMonster, PlayerController Killer)
{
    MassDetonationList.Length = MassDetonationList.Length + 1;

    MassDetonationList.Insert(0, 1);
    MassDetonationList[0].ExplodeTime = Level.TimeSeconds + 0.25f;
    MassDetonationList[0].Location = KilledMonster.Location;
    MassDetonationList[0].MaxHealth = KilledMonster.HealthMax;
    MassDetonationList[0].Controller = Killer;
}

function ProcessMassDetonationList()
{
    local int Index;
    local bool bPerformedDetonation;

    bPerformedDetonation = false;

    for (Index = MassDetonationList.Length - 1; Index >= 0; Index--)
    {
        if (MassDetonationList[Index].ExplodeTime > Level.TimeSeconds)
        {
            break;
        }

        PerformMassDetonation(MassDetonationList[Index]);
        MassDetonationList.Remove(Index, 1);
        bPerformedDetonation = true;
    }

    if (!bPerformedDetonation)
    {
        return;
    }

    Index--;
    while (Index >= 0)
    {
        MassDetonationList[Index].ExplodeTime += 0.1f;
        Index--;
    }
}

final function PerformMassDetonation(MassDetonationEntry Detonation)
{
    local Pawn HitPawn;
    local float DamageRadius;
    local float Distance, DamageScale;
    local vector Direction;
    local vector HitMomentum;

    if (Detonation.Controller == None)
    {
        return;
    }

    DamageRadius = class'W_Frag_Proj'.default.DamageRadius;

    if (Detonation.MaxHealth < 600)
    {
        Spawn(class'MassDetonationExplosion_Small', Self,, Detonation.Location);
    }
    else if (Detonation.MaxHealth < 1000)
    {
        Spawn(class'MassDetonationExplosion_Medium', Self,, Detonation.Location);
    }
    else
    {
        Spawn(class'MassDetonationExplosion', Self,, Detonation.Location);
    }

    foreach CollidingActors(class'Pawn', HitPawn, DamageRadius, Detonation.Location)
    {
		Distance = class'WeaponHelper'.static.GetDistanceToClosestPointOnActor(Detonation.Location, HitPawn);
		DamageScale = 1.f - FMax(0.f, Distance / DamageRadius);

        if(KFPawn(HitPawn) != None)
        {
            DamageScale *= KFPawn(HitPawn).GetExposureTo(Detonation.Location);
        }
        else if(KFMonster(HitPawn) != None)
        {
            DamageScale *= KFMonster(HitPawn).GetExposureTo(Detonation.Location);
        }

		Direction = Normal(HitPawn.Location - Detonation.Location);
		HitMomentum = DamageScale * class'W_Frag_Proj'.default.MomentumTransfer * Direction * 0.125f;
        
		HitPawn.TakeDamage(DamageScale * float(Detonation.MaxHealth) * 0.25f, Detonation.Controller.Pawn, Detonation.Location, HitMomentum, class'MassDetonation_DT');
    }
}

function GrantShieldOnKill(CoreMonster KilledMonster, PlayerController Killer)
{
    local float ShieldAmount;

    if (Killer.Pawn == None)
    {
        return;
    }

    ShieldAmount = 0.5f;

    switch (KilledMonster.MonsterClassification)
    {
        case class'MonsterClassificationTrash':
            ShieldAmount = 0.5f;
            break;
        case class'MonsterClassificationSpecial':
            ShieldAmount = 2.f;
            break;
        case class'MonsterClassificationElite':
            ShieldAmount = 10.f;
            break;
        case class'MonsterClassificationBoss':
            ShieldAmount = 50.f;
            break;
    }

    switch (KilledMonster.MonsterArchetypeClass)
    {
        //Trash
        case class'MonsterClotBase':
            ShieldAmount *= 2.f;
            break;
        case class'MonsterGorefastBase':
            ShieldAmount *= 3.f;
            break;
        //Special
        case class'MonsterSirenBase':
        case class'MonsterHuskBase':
            ShieldAmount *= 1.5f;
            break;
        //Elite
        case class'MonsterFleshpoundBase':
            ShieldAmount *= 1.5f;
            break;
    }

    ShieldAmount = FMin(Killer.Pawn.ShieldStrength + ShieldAmount, FMax(Killer.Pawn.ShieldStrength, 100.f));
    if (ShieldAmount <= Killer.Pawn.ShieldStrength)
    {
        return;
    }

    Killer.Pawn.ShieldStrength = ShieldAmount;
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
    if (Projectile(Other) != None)
    {
        if (KFHumanPawn(Other.Instigator) != None)
        {
            Projectile(Other).DamageRadius *= ExplosiveRadiusMultiplier;
            
            if (bOversizedPipebombs && PipeBombProjectile(Other) != None)
            {
                Other.SetDrawScale(Other.DrawScale * 1.75f);
                Projectile(Other).Damage *= 1.5f;
                Projectile(Other).DamageRadius *= 1.25f;
            }

            if (Nade(Other) != None)
            {
                ModifyNade(Nade(Other));
            }
        }
    }

    else if (Pawn(Other) != None)
    {
        if (KFMonster(Other) != None)
        {
            MonsterPawnList[MonsterPawnList.Length] = KFMonster(Other);
            switch (GetMonsterArchetype(class<CoreMonster>(MonsterPawnList[MonsterPawnList.Length - 1].Class)))
            {
                case class'MonsterClotBase':
                    ClotPawnList[ClotPawnList.Length] = P_Clot(Other);
                    return;
                case class'MonsterBloatBase':
                    if (Other.Class != class'P_Bloat_Fathead')
                    {
                        BloatPawnList[BloatPawnList.Length] = P_Bloat(Other);
                    }
                    return;
                case class'MonsterHuskBase':
                    HuskPawnList[HuskPawnList.Length] = P_Husk(Other);
                    return;
                case class'MonsterSirenBase':
                    SirenPawnList[SirenPawnList.Length] = P_Siren(Other);
                    return;
                case class'MonsterScrakeBase':
                    ScrakePawnList[ScrakePawnList.Length] = P_Scrake(Other);
                    return;
                case class'MonsterFleshpoundBase':
                    FleshpoundPawnList[FleshpoundPawnList.Length] = P_Fleshpound(Other);
                    return;
            }
        }
    }

    else if (KFWeapon(Other) != None)
    {
        ModifyWeapon(KFWeapon(Other));
    }
}

function ModifyNade(Nade Nade)
{
    if (MedicNade(Nade) != None)
    {
        MedicNade(Nade).Damage *= MedicGrenadeDamageMultiplier;
    }

    if (bSuperGrenades)
    {
        Nade.Damage *= 2.f;

        if (FlameNade(Nade) != None)
        {
            Nade.Damage *= 2.f; //Even more powerful.
        }
        else if (V_Berserker_Grenade(Nade) != None)
        {
            V_Berserker_Grenade(Nade).ZapAmount *= 100.f; //Always zap.
        }
        else if (MedicNade(Nade) != None)
        {
            MedicNade(Nade).HealBoostAmount *= 2.f;
        }
    }
}

function ModifyWeapon(KFWeapon Weapon)
{
    if (bNoDropOrSellItems)
    {
        Weapon.bKFNeverThrow = true;
        Weapon.bCanThrow = false;
    }
}

function ModifyPlayer(Pawn Other)
{
    local TurboHumanPawn TurboHumanPawn;
    if (bDisableSyringe)
    {
        DestorySyringe(Other);
    }

    TurboHumanPawn = TurboHumanPawn(Other);
    if (TurboHumanPawn != None)
    {
        TurboHumanPawn.JumpZMultiplier = PlayerJumpZMultiplier;
        TurboHumanPawn.MaxFallSpeed = FMax(TurboHumanPawn.default.MaxFallSpeed * TurboHumanPawn.GetJumpZModifier(), TurboHumanPawn.default.MaxFallSpeed);
        TurboHumanPawn.JumpZ = TurboHumanPawn.default.JumpZ * TurboHumanPawn.GetJumpZModifier();
        TurboHumanPawn.AirControl = FMin(TurboHumanPawn.default.AirControl * PlayerAirControlMultiplier, 4.f);
    }
}

function DestorySyringe(Pawn Other)
{
    local Syringe Syringe;
    local bool bWasEquipped;

    if (Other == None || Other.bDeleteMe || Other.Health <= 0 || KFHumanPawn(Other) == None)
    {
        return;
    }

    Syringe = Syringe(Other.FindInventoryType(class'Syringe'));

    if (Syringe == None)
    {
        return;
    }

    bWasEquipped = Syringe == Other.Weapon;

    Syringe.Destroy();

    if (bWasEquipped && Other.Controller != None)
    {
        Other.Controller.ClientSwitchToBestWeapon();
    }
}

function UpdateCanThrowWeapons()
{
    local array<CoreHumanPawn> PawnList;
    local Inventory Inv;
    local KFWeapon Weapon;
    local int Index;

    PawnList = class'TurboGameplayHelper'.static.GetPlayerPawnList(Level);

    for (Index = 0; Index < PawnList.Length; Index++)
    {
        Inv = PawnList[Index].Inventory;
        while (Inv != None)
        {
            Weapon = KFWeapon(Inv);

            if (Weapon != None)
            {
                if (bNoDropOrSellItems)
                {
                    Weapon.bKFNeverThrow = true;
                    Weapon.bCanThrow = false;
                }
                else
                {
                    Weapon.bKFNeverThrow = Weapon.default.bKFNeverThrow;
                    Weapon.bCanThrow = Weapon.default.bCanThrow;
                }
            }

            Inv = Inv.Inventory;
        }
    }
}

final function ResetNegateDamageList()
{
    local int Index;
    local TurboPlayerCardCustomInfo PlayerCardInfo;

    for (Index = Level.GRI.PRIArray.Length - 1; Index >= 0; Index--)
    {
        PlayerCardInfo = FindCustomInfo(TurboPlayerReplicationInfo(Level.GRI.PRIArray[Index]));

        if (PlayerCardInfo == None)
        {
            continue;
        }

        PlayerCardInfo.NegateDamageCount = 10;
    }
}

final function bool AttemptNegateDamage(TurboPlayerCardCustomInfo PlayerCardInfo)
{
    if (PlayerCardInfo == None || PlayerCardInfo.NegateDamageCount <= 0)
    {
        return false;
    }

    PlayerCardInfo.NegateDamageCount--;
    return true;
}

final function ForceFlipOver(KFMonster Monster)
{
    if (GetMonsterClassification(class<CoreMonster>(Monster.Class)) == class'MonsterClassificationBoss')
    {
        return;
    }

    if (KFMonsterController(Monster.Controller) == None)
    {
        return;
    }

	if (Physics == PHYS_Falling)
	{
		Monster.SetPhysics(PHYS_Walking);
	}
    
    if (Monster.IsInState('BeginRaging'))
    {
        if (ZombieFleshPound(Monster) != None)
        {
            UnrageFleshpound(ZombieFleshPound(Monster));
        }

        Monster.GotoState('');
    }

    Monster.LastPainAnim = Level.TimeSeconds + FMax(Monster.GetAnimDuration('KnockDown'), 2.f);

    Monster.StopAnimating(true);
	Monster.bShotAnim = true;
	Monster.SetAnimAction('KnockDown');
	Monster.Acceleration = vect(0, 0, 0);
	Monster.Velocity.X = 0;
	Monster.Velocity.Y = 0;
	Monster.Controller.GoToState('WaitForAnim');
	KFMonsterController(Monster.Controller).bUseFreezeHack = true;
}

final function UnrageFleshpound(ZombieFleshPound Fleshpound)
{
    Fleshpound.TwoSecondDamageTotal = 0;
    Fleshpound.bFrustrated = false;
    Fleshpound.bChargingPlayer = false;
    Fleshpound.ClientChargingAnims();

    if (FleshpoundZombieController(Fleshpound.Controller) != None)
    {
        FleshpoundZombieController(Fleshpound.Controller).SetPoundRageTimout(0);
    }
}

defaultproperties
{
    BonusCashMultiplier=1.f
    bRussianRouletteEnabled=false

    bSuddenDeathEnabled=false
    bPerformingSuddenDeath=false
    bMassDetonationEnabled=false
    bKillsGiveShield=false
    bZedDamageDropsWeapon=false
    bCheatDeathEnabled=false
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
    MeleeDamageMultiplier=1.f
    FireDamageMultiplier=1.f
    BerserkerMeleeDamageMultiplier=1.f
    TrashHeadshotDamageMultiplier=1.f
    TrashDamageMultiplier=1.f
    BossDamageMultiplier=1.f
    MonsterFullHealthDamageMultiplier=1.f

    DamageTakenMultiplier=1.f
    ExplosiveDamageTakenMultiplier=1.f
    FallDamageTakenMultiplier=1.f
    PlayerBurnDamageModifier=1.f

    OnPerkDamageMultiplier=1.f
    OffPerkDamageMultiplier=1.f

    HeadshotDamageMultiplier=1.f
    NonHeadshotDamageMultiplier=1.f

    LowHealthDamageMultiplier=1.f

    CriticalHitDamageMultiplier=1.5f
    BaseCriticalHitChance=0.02f
    CriticalHitChance=0.f
    bCriticalHitChanceForEachNonCriticalHit=false
    bBonusCriticalHitChanceAfterCriticalHit=false

    PlayerJumpZMultiplier=1.f
    PlayerAirControlMultiplier=1.f  

    SirenScreamDamageMultiplier=1.f

    ClotMovementSpeedModifier=1.f

    BloatMovementSpeedModifier=1.f

    FleshpoundRageThresholdModifier=1.f

    HuskRefireTimeModifier=1.f

    SirenScreamRangeModifier=1.f

    ScrakeRageThresholdModifier=1.f

    MonsterDamageMultiplier=1.f
    MonsterMeleeDamageMultiplier=1.f
    MonsterRangedDamageMultiplier=1.f
    MonsterMeleeDamageMomentumMultiplier=1.f
    MonsterStalkerDamageMultiplier=1.f
    MonsterStunChance=0.f
}