//Killing Floor Turbo TurboCardGameplayManager
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardGameplayManager extends TurboCardGameplayManagerBase;

////////////////////
//GAME MODIFIERS

//WAVE
var CardModifierStack GameWaveSpeedModifier; //Distinct from the modifier that cards apply. Used to increase difficulty throughout card game.
var CardModifierStack WaveSpeedModifier;

var CardModifierStack MaxMonstersModifier;
var CardModifierStack TotalMonstersModifier;

var CardModifierStack TraderTimeModifier;
var CardFlag ShortTermRewardFlag;
var CardFlag FreeArmorFlag;

var CardModifierStack CashBonusModifier;
var CardModifierStack AmmoPickupRespawnModifier;

var CardFlag BorrowedTimeFlag;
var PlayerBorrowedTimeActor BorrowedTimeManager;
var CardFlag PlainSightSpawnFlag;
var PlainSightSpawningActor PlainSightManager;
var CardFlag RandomTraderChangeFlag;
var RandomTraderManager RandomTraderManager;
var CardFlag MarkedForDeathFlag;

var CardFlag LockPerkSelectionFlag;

var CardFlag ExplodeDoorFlag;
var ExplodeDoorsActor ExplodeDoorsActor;

var CardFlag BankRunFlag;

//CARD GAME
var CardDeltaStack CardSelectionCountDelta;
var CardDeltaStack GoodCardSelectionCountDelta;
var CardDeltaStack ProConCardSelectionCountDelta;
var CardFlag CurseOfRaFlag;
var CurseOfRaManager CurseOfRaManager;

//FRIENDLY FIRE
var CardModifierStack FriendlyFireModifier;

//DAMAGE
var CardFlag BleedDamageFlag;
var PlayerBleedActor BleedManager;
var CardFlag NoRestForTheWickedFlag;
var PlayerNoRestForTheWickedActor NoRestForTheWickedManager;

//DEATH
var CardFlag SuddenDeathFlag;
var CardFlag CheatDeathFlag;
var CardFlag RussianRouletteFlag;

//INVENTORY
var CardFlag NoSyringeFlag;
var CardFlag SuperGrenadesFlag;
var CardFlag NoArmorFlag;
var CardFlag NoDropOrSellItemsFlag;
var CardFlag OversizedPipebombFlag;

////////////////////
//PLAYER MODIFIERS

//HEALTH
var CardModifierStack PlayerMaxHealthModifier;
var CardDeltaStack PlayerHealthRegenDelta;
var PlayerRegenActor PlayerRegenActor;

//CARRY CAPACITY
var CardDeltaStack PlayerCarryCapacityDelta;

//TRADER
var CardModifierStack TraderPriceModifier;
var CardModifierStack TraderGrenadePriceModifier;

//DAMAGE
var CardModifierStack PlayerDamageModifier;
var CardModifierStack PlayerRangedDamageModifier;
var CardModifierStack PlayerMeleeDamageModifier;
var CardModifierStack PlayerShotgunDamageModifier;
var CardModifierStack PlayerFireDamageModifier;
var CardModifierStack PlayerExplosiveDamageModifier;
var CardModifierStack PlayerExplosiveRadiusModifier;
var CardModifierStack PlayerOnPerkDamageModifier;
var CardModifierStack PlayerOffPerkDamageModifier;

var CardModifierStack PlayerMedicGrenadeDamageModifier;
var CardModifierStack PlayerBerserkerMeleeDamageModifier;

var CardModifierStack PlayerNonEliteDamageModifier;
var CardModifierStack PlayerNonEliteHeadshotDamageModifier;
var CardModifierStack PlayerBossDamageModifier;
var CardModifierStack PlayerMonsterFullHealthDamageModifier;

var CardModifierStack PlayerSlomoDamageModifier;
var CardModifierStack PlayerLowHealthDamageModifier;

var CardModifierStack PlayerFleshpoundDamageModifier;
var CardModifierStack PlayerScrakeDamageModifier;

var CardFlag PlayerMassDetonationFlag;

var CardModifierStack WeldStrengthModifier;

var CardFlag CriticalShotFlag;

//DAMAGE RECEIVED
var CardModifierStack PlayerArmorStrengthModifier;
var CardModifierStack PlayerDamageTakenModifier;
var CardModifierStack PlayerExplosiveDamageTakenModifier;
var CardModifierStack PlayerFallDamageModifier;

var CardFlag PlayerDamageSubstituteFlag;

//FIRE RATE
var CardModifierStack PlayerFireRateModifier;
var CardModifierStack PlayerBerserkerFireRateModifier;
var CardModifierStack PlayerFirebugFireRateModifier;
var CardModifierStack PlayerZedTimeDualWeaponFireRateModifier;

//MAGAZINE AMMO
var CardModifierStack PlayerMagazineAmmoModifier;
var CardModifierStack PlayerCommandoMagazineAmmoModifier;
var CardModifierStack PlayerMedicMagazineAmmoModifier;
var CardModifierStack PlayerDualWeaponMagazineAmmoModifier;

//RELOAD RATE
var CardModifierStack PlayerReloadRateModifier;
var CardModifierStack PlayerCommandoReloadRateModifier;
var CardModifierStack PlayerZedTimeDualWeaponReloadRateModifier;

//EQUIP RATE
var CardModifierStack PlayerEquipRateModifier;
var CardModifierStack PlayerZedTimeDualWeaponEquipRateModifier;

//MAX AMMO
var CardModifierStack PlayerMaxAmmoModifier;
var CardModifierStack PlayerCommandoMaxAmmoModifier;
var CardModifierStack PlayerMedicMaxAmmoModifier;
var CardModifierStack PlayerGrenadeMaxAmmoModifier;

//SPREAD AND RECOIL
var CardModifierStack PlayerSpreadRecoilModifier;
var CardModifierStack PlayerShotgunSpreadRecoilModifier;

//PENETRATION
var CardModifierStack PlayerPenetrationModifier;

//SHOTGUN
var CardModifierStack PlayerShotgunPelletModifier;
var CardModifierStack PlayerShotgunKickbackModifier;

//ZED TIME EXTENSIONS
var CardDeltaStack PlayerZedTimeExtensionDelta;
var CardDeltaStack PlayerDualWeaponZedTimeExtensionDelta;

//HEALING
var CardModifierStack PlayerNonMedicHealPotencyModifier;
var CardModifierStack PlayerMedicHealPotencyModifier;
var CardModifierStack PlayerHealRechargeModifier;

//MOVEMENT
var CardModifierStack PlayerMovementSpeedModifier;
var CardModifierStack PlayerMovementAccelModifier;
var CardModifierStack PlayerMovementFrictionModifier;
var CardModifierStack PlayerJumpModifier;
var CardModifierStack PlayerAirControlModifier;
var CardFlag PlayerFreezeTagFlag;
var CardFlag PlayerGreedSlowsFlag;
var CardFlag PlayerLowHealthSlowsFlag;

//THORNS
var CardModifierStack PlayerThornsModifier;

////////////////////
//MONSTER MODIFIERS

//REPLACEMENT/SPAWNING
var CardFlag WeakMonsterReplacementFlag;
var CardFlag ScrakeMonsterReplacementFlag;
var CardFlag HuskAmountBoostFlag;
var CardFlag MonsterUpgradeFlag;

//DAMAGE
var CardModifierStack MonsterDamageModifier;
var CardModifierStack MonsterDamageMomentumModifier;
var CardModifierStack MonsterMeleeDamageModifier;
var CardModifierStack MonsterRangedDamageModifier;
var CardModifierStack MonsterStalkerMeleeDamageModifier;
var CardModifierStack MonsterSirenScreamDamageModifier;
var CardModifierStack MonsterSirenScreamRangeModifier;

//SCALING
var CardModifierStack MonsterHeadSizeModifier;
var CardModifierStack MonsterStalkerDistractionModifier;

//MOVEMENT
var CardModifierStack MonsterBloatMovementSpeedModifier;

//AI
var CardModifierStack MonsterFleshpoundRageThresholdModifier;
var CardModifierStack MonsterScrakeRageThresholdModifier;
var CardModifierStack MonsterHuskRefireTimeModifier;

function ModifyPlayer(Pawn Pawn)
{
    if (LockPerkSelectionFlag.IsFlagSet() && TurboPlayerController(Pawn.Controller) != None)
    {
        TurboPlayerController(Pawn.Controller).AddPerkChangeLock(class'LockedInTurboLocalMessage');
    }
}

function OnWaveStart(int StartedWave)
{
    Super.OnWaveStart(StartedWave);

    //Start stacking modifiers to this.
    if (StartedWave >= 7)
    {
        GameWaveSpeedModifier.AddModifier(1.1f, None);
    }

    if (PlayerDamageSubstituteFlag.IsFlagSet())
    {
        CardGameRules.ResetNegateDamageList();
    }

    if (BankRunFlag.IsFlagSet())
    {
        MultiplyPlayerCash(0.5f);
    }

    if (MarkedForDeathFlag.IsFlagSet())
    {
        MarkPlayerForDeath();
    }

    if (ExplodeDoorsActor != None)
    {
        ExplodeDoorsActor.ExplodeDoors();
    }
}

function OnWaveEnd(int EndedWave)
{
    Super.OnWaveEnd(EndedWave);

    if (TurboGameType.FinalWave <= EndedWave)
    {
        return;
    }

    if (ShortTermRewardFlag.IsFlagSet())
    {
        GrantAllPlayersDosh(500);
    }

    if (FreeArmorFlag.IsFlagSet())
    {
        GrantAllPlayersArmor();
    }
}

function OnNextSpawnSquadGenerated(out array < class<KFMonster> > NextSpawnSquad)
{
    local int SquadIndex;

    if (!WeakMonsterReplacementFlag.IsFlagSet() && !ScrakeMonsterReplacementFlag.IsFlagSet() && !MonsterUpgradeFlag.IsFlagSet())
    {
        return;
    }
    
    for (SquadIndex = 0; SquadIndex < NextSpawnSquad.Length; SquadIndex++)
    {
        if (MonsterUpgradeFlag.IsFlagSet() && FRand() < 0.05f)
        {
            AttemptUpgradeMonster(NextSpawnSquad[SquadIndex]);
        }
        else if (WeakMonsterReplacementFlag.IsFlagSet() && FRand() < 0.15f)
        {
            AttemptReplaceWeakMonster(NextSpawnSquad[SquadIndex]);
        }
        else if (ScrakeMonsterReplacementFlag.IsFlagSet() && FRand() < 0.05f)
        {
            NextSpawnSquad[SquadIndex] = class'P_Scrake_STA';
        }
    }

    if (HuskAmountBoostFlag.IsFlagSet())
    {
        PotentiallyDoubleHuskSpawn(NextSpawnSquad);
    }
}

function OnBossSpawned()
{
    if (CurseOfRaFlag.IsFlagSet() && CurseOfRaManager != None)
    {
        CurseOfRaManager.OnBossSpawned();
    }
}

function WaveSpeedModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    TurboGameType.GameWaveSpawnRateModifier = GameWaveSpeedModifier.GetModifier() * WaveSpeedModifier.GetModifier();
}

function MaxMonstersModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    local float OriginalModifier;
    OriginalModifier = TurboGameType.GameMaxMonstersModifier;
    TurboGameType.GameMaxMonstersModifier = MaxMonstersModifier.GetModifier();

    //If the change occurs while the wave is in progress, we need to apply this to it.
    if (!TurboGameType.bWaveInProgress)
    {
        return;
    }
    
    TurboGameType.MaxMonsters = float(TurboGameType.MaxMonsters) * (TurboGameType.GameMaxMonstersModifier / OriginalModifier);
}

function TotalMonstersModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    local float OriginalModifier;
    OriginalModifier = TurboGameType.GameTotalMonstersModifier;
    TurboGameType.GameTotalMonstersModifier = TotalMonstersModifier.GetModifier();

    if (!TurboGameType.bWaveInProgress)
    {
        return;
    }
    
    TurboGameType.TotalMaxMonsters = float(TurboGameType.TotalMaxMonsters) * (TurboGameType.GameTotalMonstersModifier / OriginalModifier);
}

function ShortTermRewardCardFlagChanged(CardFlag Flag, bool bIsEnabled) {}

function FreeArmorCardFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    if (!TurboGameType.bWaveInProgress)
    {
        return;
    }

    GrantAllPlayersArmor();
}

function TraderTimeModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    local float OriginalModifier;
    OriginalModifier = TurboGameType.GameTraderTimeModifier;
    TurboGameType.GameTraderTimeModifier = TraderTimeModifier.GetModifier();

    if (TurboGameType.bWaveInProgress)
    {
        return;
    }
    
    TurboGameType.WaveCountDown = float(TurboGameType.WaveCountDown) * (TurboGameType.GameTraderTimeModifier / OriginalModifier);
    KFGameReplicationInfo(TurboGameType.GameReplicationInfo).TimeToNextWave = TurboGameType.WaveCountDown;
}

function CashBonusModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.BonusCashMultiplier = CashBonusModifier.GetModifier();
}

function AmmoPickupRespawnModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    local KFAmmoPickup AmmoPickup;
    foreach AllActors(class'KFAmmoPickup', AmmoPickup)
    {
        AmmoPickup.RespawnTime = AmmoPickup.default.RespawnTime * Modifier;
    }
}

function BorrowedTimeCardFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    if (bIsEnabled)
    {
        if (BorrowedTimeManager == None)
        {
            BorrowedTimeManager = Spawn(class'PlayerBorrowedTimeActor', Self);
        }
    }
    else
    {
        if (BorrowedTimeManager != None)
        {
            BorrowedTimeManager.Destroy();
        }
    }
}

function PlainSightSpawnCardFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    if (bIsEnabled)
    {
        if (PlainSightManager == None)
        {
            PlainSightManager = Spawn(class'PlainSightSpawningActor', Self);
        }
    }
    else
    {
        if (PlainSightManager != None)
        {
            PlainSightManager.Revert();
            PlainSightManager.Destroy();
        }
    }
}

function RandomTraderChangeFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    if (bIsEnabled)
    {
        if (RandomTraderManager == None)
        {
            RandomTraderManager = Spawn(class'RandomTraderManager', Self);
        }
    }
    else
    {
        if (RandomTraderManager != None)
        {
            RandomTraderManager.Destroy();
        }
    }
}

function MarkedForDeathFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    if (!bIsEnabled)
    {
        CardGameRules.MarkedForDeathPawn = None;
    }
}

function LockPerkSelectionFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    local array<TurboPlayerController> PlayerList;
    local int Index;
    PlayerList = class'TurboGameplayHelper'.static.GetPlayerControllerList(Level);
    
    for (Index = 0; Index < PlayerList.Length; Index++)
    {
        if (!bIsEnabled)
        {
            PlayerList[Index].RemovePerkChangeLock(class'LockedInTurboLocalMessage');
            continue;
        }

        if (PlayerList[Index].Pawn == None)
        {
            continue;
        }

        PlayerList[Index].AddPerkChangeLock(class'LockedInTurboLocalMessage');
    }
}

function ExplodeDoorFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    if (bIsEnabled)
    {
        if (ExplodeDoorsActor == None)
        {
            ExplodeDoorsActor = Spawn(class'ExplodeDoorsActor', Self);
        }
    }
    else
    {
        if (ExplodeDoorsActor != None)
        {
            ExplodeDoorsActor.Destroy();
        }
    }
}

function BankRunFlagChanged(CardFlag Flag, bool bIsEnabled) {}

//CARD GAME
function CardSelectionCountDeltaChanged(CardDeltaStack ChangedDelta, int Delta)
{
    CardReplicationInfo.SelectionCount = CardReplicationInfo.default.SelectionCount + Delta;
    CardReplicationInfo.SelectionCount = Max(1, CardReplicationInfo.SelectionCount);
}

function GoodCardSelectionCountDeltaChanged(CardDeltaStack ChangedDelta, int Delta)
{
    CardReplicationInfo.GoodSelectionDelta = Delta;
}

function ProConCardSelectionCountDeltaChanged(CardDeltaStack ChangedDelta, int Delta)
{
    CardReplicationInfo.ProConSelectionDelta = Delta;
}

function CurseOfRaFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    if (bIsEnabled)
    {
        if (CurseOfRaManager == None)
        {
            CurseOfRaManager = Spawn(class'CurseOfRaManager', Self);
        }
    }
    else
    {
        if (CurseOfRaManager != None)
        {
            CurseOfRaManager.Destroy();
        }
    }
}

//FRIENDLY FIRE
function FriendlyFireModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    if (Modifier <= 1.f)
    {
        TeamGame(Level.Game).FriendlyFireScale = 0.0001f;
        return;
    }

    TeamGame(Level.Game).FriendlyFireScale = (Modifier - 1.f);
}

//DAMAGE
function BleedDamageFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    if (bIsEnabled)
    {
        if (BleedManager == None)
        {
            BleedManager = Spawn(class'PlayerBleedActor', Self);
        }
    }
    else
    {
        if (BleedManager != None)
        {
            BleedManager.Destroy();
        }
    }
}

function NoRestForTheWickedFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    if (bIsEnabled)
    {
        if (NoRestForTheWickedManager == None)
        {
            NoRestForTheWickedManager = Spawn(class'PlayerNoRestForTheWickedActor', Self);
        }
    }
    else
    {
        if (NoRestForTheWickedManager != None)
        {
            NoRestForTheWickedManager.Destroy();
        }
    }
}

function SuddenDeathFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    CardGameRules.bSuddenDeathEnabled = bIsEnabled;
}

function CheatDeathFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    CardGameRules.bCheatDeathEnabled = bIsEnabled;

    if (!bIsEnabled)
    {
        CardGameRules.CheatedDeathPlayerList.Length = 0;
    }
}

function RussianRouletteFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    CardGameRules.bRussianRouletteEnabled = bIsEnabled;
}

//INVENTORY
function NoSyringeFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    local array<TurboHumanPawn> HumanPawnList;
    local int Index;

    CardGameRules.bDisableSyringe = bIsEnabled;

    HumanPawnList = class'TurboGameplayHelper'.static.GetPlayerPawnList(Level);
    
    if (bIsEnabled)
    {
        for (Index = HumanPawnList.Length - 1; Index >= 0; Index--)
        {
            CardGameRules.DestorySyringe(HumanPawnList[Index]);
        }
    }
    else
    {
        for (Index = HumanPawnList.Length - 1; Index >= 0; Index--)
        {
            HumanPawnList[Index].CreateInventory(string(class'W_Syringe_Weap'));
        }
    }
}

function SuperGrenadesFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    CardGameRules.bSuperGrenades = bIsEnabled;
}

function NoArmorFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    CardGameModifier.bDisableArmorPurchase = bIsEnabled;
    CardGameModifier.ForceNetUpdate();
}

function NoDropOrSellItemsFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    CardGameRules.bNoDropOrSellItems = bIsEnabled;
    CardGameRules.UpdateCanThrowWeapons();
}

function OversizedPipebombFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    CardGameModifier.bOversizedPipebombs = bIsEnabled;
    CardGameModifier.ForceNetUpdate();
    CardGameRules.bOversizedPipebombs = bIsEnabled;
}

////////////////////
//PLAYER MODIFIERS

//HEALTH
function PlayerMaxHealthModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.PlayerMaxHealthMultiplier = Modifier;
    TurboGameReplicationInfo(Level.GRI).NotifyPlayerMaxHealthChanged();
    CardGameModifier.ForceNetUpdate();
}

function PlayerHealthRegenDeltaChanged(CardDeltaStack ChangedDelta, int Delta)
{
    Delta = Max(Delta, 0);
    if (Delta != 0)
    {
        if (PlayerRegenActor == None)
        {
            PlayerRegenActor = Spawn(class'PlayerRegenActor', Self);
        }

        PlayerRegenActor.SetRegenAmount(Delta);
    }
    else
    {
        if (PlayerRegenActor != None)
        {
            PlayerRegenActor.Destroy();
        }
    }
}

//CARRY CAPACITY
function PlayerCarryCapacityDeltaChanged(CardDeltaStack ChangedDelta, int Delta)
{
    CardGameModifier.PlayerMaxCarryWeightModifier = Delta;
    TurboGameReplicationInfo(Level.GRI).NotifyPlayerCarryWeightChanged();
}

//TRADER
function TraderPriceModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.TraderCostMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function TraderGrenadePriceModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.TraderGrenadeCostMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

//DAMAGE
function PlayerDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.PlayerDamageMultiplier = Modifier;
}

function PlayerRangedDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.PlayerRangedDamageMultiplier = Modifier;
}

function PlayerMeleeDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.MeleeDamageMultiplier = Modifier;
}

function PlayerShotgunDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.ShotgunDamageMultiplier = Modifier;
}

function PlayerFireDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.FireDamageMultiplier = Modifier;
}

function PlayerExplosiveDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.ExplosiveDamageMultiplier = Modifier;
}

function PlayerExplosiveRadiusModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.ExplosiveRadiusMultiplier = Modifier;
}

function PlayerOnPerkDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.OnPerkDamageMultiplier = Modifier;
}

function PlayerOffPerkDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.OffPerkDamageMultiplier = Modifier;
}

function PlayerMedicGrenadeDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.MedicGrenadeDamageMultiplier = Modifier;
}

function PlayerBerserkerMeleeDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.BerserkerMeleeDamageMultiplier = Modifier;
}

function PlayerNonEliteDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.TrashDamageMultiplier = Modifier;
}

function PlayerNonEliteHeadshotDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.TrashHeadshotDamageMultiplier = Modifier;
}

function PlayerBossDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.BossDamageMultiplier = Modifier;
}

function PlayerMonsterFullHealthDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.MonsterFullHealthDamageMultiplier = Modifier;
}

function PlayerSlomoDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.SlomoDamageMultiplier = Modifier;
}

function PlayerLowHealthDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.LowHealthDamageMultiplier = Modifier;
}

function PlayerFleshpoundDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.FleshpoundDamageMultiplier = Modifier;
}

function PlayerScrakeDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.ScrakeDamageMultiplier = Modifier;
}

function PlayerMassDetonationCardFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    CardGameRules.bMassDetonationEnabled = bIsEnabled;
}

function WeldStrengthModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.WeldStrengthMultiplier = Modifier;
}

function CriticalShotCardFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    CardGameRules.bCriticalHitEnabled = bIsEnabled;
}

//DAMAGE RECEIVED
function PlayerArmorStrengthModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.BodyArmorDamageModifier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerDamageTakenModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.DamageTakenMultiplier = Modifier;
}

function PlayerExplosiveDamageTakenModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.ExplosiveDamageTakenMultiplier = Modifier;
}

function PlayerFallDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.FallDamageTakenMultiplier = Modifier;
}

function PlayerDamageSubstituteCardFlagChanged(CardFlag Flag, bool bIsEnabled)
{
    if (bIsEnabled)
    {
        CardGameRules.ResetNegateDamageList();
    }
    else
    {
        CardGameRules.ClearNegateDamageList();
    }
}

//FIRERATE
function PlayerFireRateModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.FireRateMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerBerserkerFireRateModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.BerserkerFireRateMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerFirebugFireRateModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.FirebugFireRateMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerZedTimeDualWeaponFireRateModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.ZedTimeDualPistolFireRateMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

//MAGAZINE AMMO
function PlayerMagazineAmmoModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.MagazineAmmoMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerCommandoMagazineAmmoModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.CommandoMagazineAmmoMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerMedicMagazineAmmoModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.MedicMagazineAmmoMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerDualWeaponMagazineAmmoModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.DualWeaponMagazineAmmoMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

//RELOAD RATE
function PlayerReloadRateModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.ReloadRateMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerCommandoReloadRateModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.CommandoReloadRateMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerZedTimeDualWeaponReloadRateModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.ZedTimeDualWeaponReloadRateMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

//EQUIP RATE
function PlayerEquipRateModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardClientModifier.WeaponBringUpSpeedModifier = Modifier;
    CardClientModifier.WeaponPutDownSpeedModifier = Modifier;
    CardClientModifier.ForceNetUpdate();
}

function PlayerZedTimeDualWeaponEquipRateModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardClientModifier.ZedTimeWeaponBringUpSpeedModifier = Modifier;
    CardClientModifier.ZedTimeWeaponPutDownSpeedModifier = Modifier;
    CardClientModifier.ForceNetUpdate();
}

//MAX AMMO
function PlayerMaxAmmoModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.MaxAmmoMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerCommandoMaxAmmoModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.CommandoMaxAmmoMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerMedicMaxAmmoModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.MedicMaxAmmoMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerGrenadeMaxAmmoModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.GrenadeMaxAmmoMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

//SPREAD AND RECOIL
function PlayerSpreadRecoilModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.WeaponSpreadRecoilMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerShotgunSpreadRecoilModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.ShotgunSpreadRecoilMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

//PENETRATION
function PlayerPenetrationModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.WeaponPenetrationMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

//SHOTGUN
function PlayerShotgunPelletModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.ShotgunPelletCountMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerShotgunKickbackModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.ShotgunKickBackMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

//ZED TIME EXTENSIONS
function PlayerZedTimeExtensionDeltaChanged(CardDeltaStack DeltaStack, int Delta)
{
    CardGameModifier.PlayerZedTimeExtensionsModifier = CardGameModifier.default.PlayerZedTimeExtensionsModifier + Delta;
    CardGameModifier.ForceNetUpdate();
}

function PlayerDualWeaponZedTimeExtensionDeltaChanged(CardDeltaStack DeltaStack, int Delta)
{
    CardGameModifier.PlayerDualPistolZedTimeExtensionsModifier = CardGameModifier.default.PlayerDualPistolZedTimeExtensionsModifier + Delta;
    CardGameModifier.ForceNetUpdate();
}

//HEALING
function PlayerNonMedicHealPotencyModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.NonMedicHealPotencyMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerMedicHealPotencyModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.MedicHealPotencyMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

function PlayerHealRechargeModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.HealRechargeMultiplier = Modifier;
    CardGameModifier.ForceNetUpdate();
}

//MOVEMENT
function PlayerMovementSpeedModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.PlayerMovementSpeedMultiplier = Modifier;
    TurboGameReplicationInfo(Level.GRI).NotifyPlayerMovementSpeedChanged();
    CardGameModifier.ForceNetUpdate();
}

function PlayerMovementAccelModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameModifier.PlayerMovementAccelMultiplier = Modifier;
    TurboGameReplicationInfo(Level.GRI).NotifyPlayerMovementSpeedChanged();
    CardGameModifier.ForceNetUpdate();
}

function PlayerMovementFrictionModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardClientModifier.GroundFrictionModifier = Modifier;
    CardClientModifier.UpdatePhysicsVolumes();
    CardClientModifier.ForceNetUpdate();
}

function PlayerJumpModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    local array<TurboHumanPawn> HumanPawnList;
    local TurboHumanPawn TurboHumanPawn;
    local int Index;

    CardGameRules.PlayerJumpZMultiplier = Modifier;
    
    HumanPawnList = class'TurboGameplayHelper'.static.GetPlayerPawnList(Level);
    for (Index = HumanPawnList.Length - 1; Index >= 0; Index--)
    {
        TurboHumanPawn = HumanPawnList[Index];
        TurboHumanPawn.JumpZMultiplier = Modifier;
        TurboHumanPawn.MaxFallSpeed = FMax(TurboHumanPawn.default.MaxFallSpeed * TurboHumanPawn.GetJumpZModifier(), TurboHumanPawn.default.MaxFallSpeed);
        TurboHumanPawn.JumpZ = TurboHumanPawn.default.JumpZ * TurboHumanPawn.GetJumpZModifier();
    }
}

function PlayerAirControlModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    local array<TurboHumanPawn> HumanPawnList;
    local int Index;

    CardGameRules.PlayerAirControlMultiplier = Modifier;
    
    HumanPawnList = class'TurboGameplayHelper'.static.GetPlayerPawnList(Level);
    for (Index = HumanPawnList.Length - 1; Index >= 0; Index--)
    {
        HumanPawnList[Index].AirControl = FMin(HumanPawnList[Index].default.AirControl * Modifier, 4.f);
    }
}

function PlayerFreezeTagFlagChanged(Cardflag Flag, bool bIsEnabled)
{
    CardGameModifier.bFreezePlayersDuringWave = bIsEnabled;
    CardGameModifier.ForceNetUpdate();
}

function PlayerGreedSlowsFlagChanged(Cardflag Flag, bool bIsEnabled)
{
    CardGameModifier.bMoneySlowsPlayers = bIsEnabled;
    CardGameModifier.ForceNetUpdate();
}

function PlayerLowHealthSlowsFlagChanged(Cardflag Flag, bool bIsEnabled)
{
    CardGameModifier.bMissingHealthStronglySlows = bIsEnabled;
    CardGameModifier.ForceNetUpdate();
}

//THORNS
function PlayerThornsModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.PlayerThornsDamageMultiplier = Modifier;
}

////////////////////
//MONSTER MODIFIERS

//REPLACEMENT
function WeakMonsterReplacementFlagChanged(Cardflag Flag, bool bIsEnabled) {}
function ScrakeMonsterReplacementFlagChanged(Cardflag Flag, bool bIsEnabled) {}
function HuskAmountBoostFlagChanged(Cardflag Flag, bool bIsEnabled) {}
function MonsterUpgradeFlagChanged(Cardflag Flag, bool bIsEnabled) {}

//DAMAGE
function MonsterDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.MonsterDamageMultiplier = Modifier;
}

function MonsterDamageMomentumModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.MonsterMeleeDamageMomentumMultiplier = Modifier;
}

function MonsterMeleeDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.MonsterMeleeDamageMultiplier = Modifier;
}

function MonsterRangedDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.MonsterRangedDamageMultiplier = Modifier;
}

function MonsterStalkerMeleeDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.MonsterStalkerDamageMultiplier = Modifier;
}

function MonsterSirenScreamDamageModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.SirenScreamDamageMultiplier = Modifier;
}

function MonsterSirenScreamRangeModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.SirenScreamRangeModifier = Modifier;
}

//SCALING
function MonsterHeadSizeModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardClientModifier.MonsterHeadSizeModifier = Modifier;
    CardClientModifier.ForceNetUpdate();
}

function MonsterStalkerDistractionModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardClientModifier.StalkerDistractionModifier = Modifier;
    CardClientModifier.ForceNetUpdate();
}

//MOVEMENT
function MonsterBloatMovementSpeedModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.BloatMovementSpeedModifier = Modifier;
}

//AI
function MonsterFleshpoundRageThresholdModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.FleshpoundRageThresholdModifier = Modifier;
}

function MonsterScrakeRageThresholdModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.ScrakeRageThresholdModifier = Modifier;
}

function MonsterHuskRefireTimeModifierChanged(CardModifierStack ModifiedStack, float Modifier)
{
    CardGameRules.HuskRefireTimeModifier = Modifier;
}

defaultproperties
{
    Begin Object Name=GameWaveSpeedModifierStack Class=CardModifierStack
        ModifierStackID="GameWaveSpeed"
        OnModifierChanged=WaveSpeedModifierChanged
    End Object
    GameWaveSpeedModifier=CardModifierStack'GameWaveSpeedModifierStack'

    Begin Object Name=WaveSpeedModifierStack Class=CardModifierStack
        ModifierStackID="WaveSpeed"
        OnModifierChanged=WaveSpeedModifierChanged
    End Object
    WaveSpeedModifier=CardModifierStack'WaveSpeedModifierStack'

    Begin Object Name=MaxMonstersModifierStack Class=CardModifierStack
        ModifierStackID="MaxMonsters"
        OnModifierChanged=MaxMonstersModifierChanged
    End Object
    MaxMonstersModifier=CardModifierStack'MaxMonstersModifierStack'

    Begin Object Name=TotalMonstersModifierStack Class=CardModifierStack
        ModifierStackID="TotalMonsters"
        OnModifierChanged=TotalMonstersModifierChanged
    End Object
    TotalMonstersModifier=CardModifierStack'TotalMonstersModifierStack'

    Begin Object Name=ShortTermRewardCardFlag Class=CardFlag
        FlagID="ShortTermReward"
        OnFlagSetChanged=ShortTermRewardCardFlagChanged
    End Object
    ShortTermRewardFlag=CardFlag'ShortTermRewardCardFlag'

    Begin Object Name=FreeArmorCardFlag Class=CardFlag
        FlagID="FreeArmor"
        OnFlagSetChanged=FreeArmorCardFlagChanged
    End Object
    FreeArmorFlag=CardFlag'FreeArmorCardFlag'

    Begin Object Name=TraderTimeModifierStack Class=CardModifierStack
        ModifierStackID="TraderTime"
        OnModifierChanged=TraderTimeModifierChanged
    End Object
    TraderTimeModifier=CardModifierStack'TraderTimeModifierStack'

    Begin Object Name=CashBonusModifierStack Class=CardModifierStack
        ModifierStackID="CashBonus"
        OnModifierChanged=CashBonusModifierChanged
    End Object
    CashBonusModifier=CardModifierStack'CashBonusModifierStack'

    Begin Object Name=AmmoPickupRespawnModifierStack Class=CardModifierStack
        ModifierStackID="AmmoPickupRespawn"
        OnModifierChanged=AmmoPickupRespawnModifierChanged
    End Object
    AmmoPickupRespawnModifier=CardModifierStack'AmmoPickupRespawnModifierStack'

    Begin Object Name=BorrowedTimeCardFlag Class=CardFlag
        FlagID="BorrowedTime"
        OnFlagSetChanged=BorrowedTimeCardFlagChanged
    End Object
    BorrowedTimeFlag=CardFlag'BorrowedTimeCardFlag'

    Begin Object Name=PlainSightSpawnCardFlag Class=CardFlag
        FlagID="PlainSightSpawn"
        OnFlagSetChanged=PlainSightSpawnCardFlagChanged
    End Object
    PlainSightSpawnFlag=CardFlag'PlainSightSpawnCardFlag'

    Begin Object Name=RandomTraderChangeCardFlag Class=CardFlag
        FlagID="RandomTraderChange"
        OnFlagSetChanged=RandomTraderChangeFlagChanged
    End Object
    RandomTraderChangeFlag=CardFlag'RandomTraderChangeCardFlag'

    Begin Object Name=MarkedForDeathCardFlag Class=CardFlag
        FlagID="MarkedForDeath"
        OnFlagSetChanged=MarkedForDeathFlagChanged
    End Object
    MarkedForDeathFlag=CardFlag'MarkedForDeathCardFlag'

    Begin Object Name=LockPerkSelectionCardFlag Class=CardFlag
        FlagID="LockPerkSelection"
        OnFlagSetChanged=LockPerkSelectionFlagChanged
    End Object
    LockPerkSelectionFlag=CardFlag'LockPerkSelectionCardFlag'

    Begin Object Name=ExplodeDoorCardFlag Class=CardFlag
        FlagID="ExplodeDoor"
        OnFlagSetChanged=ExplodeDoorFlagChanged
    End Object
    ExplodeDoorFlag=CardFlag'ExplodeDoorCardFlag'

    Begin Object Name=BankRunCardFlag Class=CardFlag
        FlagID="BankRun"
        OnFlagSetChanged=BankRunFlagChanged
    End Object
    BankRunFlag=CardFlag'BankRunCardFlag'

//CARD GAME
    Begin Object Name=CardSelectionCountDeltaStack Class=CardDeltaStack
        DeltaStackID="CardSelectionCount"
        OnDeltaChanged=CardSelectionCountDeltaChanged
    End Object
    CardSelectionCountDelta=CardDeltaStack'CardSelectionCountDeltaStack'
    
    Begin Object Name=GoodCardSelectionCountDeltaStack Class=CardDeltaStack
        DeltaStackID="GoodCardSelectionCount"
        OnDeltaChanged=GoodCardSelectionCountDeltaChanged
    End Object
    GoodCardSelectionCountDelta=CardDeltaStack'GoodCardSelectionCountDeltaStack'
    
    Begin Object Name=ProConCardSelectionCountDeltaStack Class=CardDeltaStack
        DeltaStackID="ProConCardSelectionCount"
        OnDeltaChanged=ProConCardSelectionCountDeltaChanged
    End Object
    ProConCardSelectionCountDelta=CardDeltaStack'ProConCardSelectionCountDeltaStack'
    
    Begin Object Name=CurseOfRaCardFlag Class=CardFlag
        FlagID="CurseOfRa"
        OnFlagSetChanged=CurseOfRaFlagChanged
    End Object
    CurseOfRaFlag=CardFlag'CurseOfRaCardFlag'

//FRIENDLY FIRE
    Begin Object Name=FriendlyFireModifierStack Class=CardModifierStack
        ModifierStackID="FriendlyFire"
        OnModifierChanged=FriendlyFireModifierChanged
    End Object
    FriendlyFireModifier=CardModifierStack'FriendlyFireModifierStack'
    
//DAMAGE
    Begin Object Name=BleedDamageCardFlag Class=CardFlag
        FlagID="BleedDamage"
        OnFlagSetChanged=BleedDamageFlagChanged
    End Object
    BleedDamageFlag=CardFlag'BleedDamageCardFlag'
    
    Begin Object Name=NoRestForTheWickedCardFlag Class=CardFlag
        FlagID="NoRestForTheWicked"
        OnFlagSetChanged=NoRestForTheWickedFlagChanged
    End Object
    NoRestForTheWickedFlag=CardFlag'NoRestForTheWickedCardFlag'

//DEATH
    Begin Object Name=SuddenDeathCardFlag Class=CardFlag
        FlagID="SuddenDeath"
        OnFlagSetChanged=SuddenDeathFlagChanged
    End Object
    SuddenDeathFlag=CardFlag'SuddenDeathCardFlag'

    Begin Object Name=CheatDeathCardFlag Class=CardFlag
        FlagID="CheatDeath"
        OnFlagSetChanged=CheatDeathFlagChanged
    End Object
    CheatDeathFlag=CardFlag'CheatDeathCardFlag'

    Begin Object Name=RussianRouletteCardFlag Class=CardFlag
        FlagID="RussianRoulette"
        OnFlagSetChanged=RussianRouletteFlagChanged
    End Object
    RussianRouletteFlag=CardFlag'RussianRouletteCardFlag'
    
//INVENTORY
    Begin Object Name=NoSyringeCardFlag Class=CardFlag
        FlagID="NoSyringe"
        OnFlagSetChanged=NoSyringeFlagChanged
    End Object
    NoSyringeFlag=CardFlag'NoSyringeCardFlag'

    Begin Object Name=SuperGrenadesCardFlag Class=CardFlag
        FlagID="SuperGrenades"
        OnFlagSetChanged=SuperGrenadesFlagChanged
    End Object
    SuperGrenadesFlag=CardFlag'SuperGrenadesCardFlag'

    Begin Object Name=NoArmorCardFlag Class=CardFlag
        FlagID="NoArmor"
        OnFlagSetChanged=NoArmorFlagChanged
    End Object
    NoArmorFlag=CardFlag'NoArmorCardFlag'
    
    Begin Object Name=NoDropOrSellItemsCardFlag Class=CardFlag
        FlagID="NoDropOrSellItems"
        OnFlagSetChanged=NoDropOrSellItemsFlagChanged
    End Object
    NoDropOrSellItemsFlag=CardFlag'NoDropOrSellItemsCardFlag'

    Begin Object Name=OversizedPipebombCardFlag Class=CardFlag
        FlagID="OversizedPipebomb"
        OnFlagSetChanged=OversizedPipebombFlagChanged
    End Object
    OversizedPipebombFlag=CardFlag'OversizedPipebombCardFlag'

////////////////////
//PLAYER MODIFIERS

//HEALTH
    Begin Object Name=PlayerMaxHealthModifierStack Class=CardModifierStack
        ModifierStackID="PlayerMaxHealth"
        OnModifierChanged=PlayerMaxHealthModifierChanged
    End Object
    PlayerMaxHealthModifier=CardModifierStack'PlayerMaxHealthModifierStack'

    Begin Object Name=PlayerHealthRegenDeltaStack Class=CardDeltaStack
        DeltaStackID="PlayerHealthRegen"
        OnDeltaChanged=PlayerHealthRegenDeltaChanged
    End Object
    PlayerHealthRegenDelta=CardDeltaStack'PlayerHealthRegenDeltaStack'

//CARRY CAPACITY
    Begin Object Name=PlayerCarryCapacityDeltaStack Class=CardDeltaStack
        DeltaStackID="PlayerCarryCapacity"
        OnDeltaChanged=PlayerCarryCapacityDeltaChanged
    End Object
    PlayerCarryCapacityDelta=CardDeltaStack'PlayerCarryCapacityDeltaStack'

//TRADER
    Begin Object Name=TraderPriceModifierStack Class=CardModifierStack
        ModifierStackID="TraderPrice"
        OnModifierChanged=TraderPriceModifierChanged
    End Object
    TraderPriceModifier=CardModifierStack'TraderPriceModifierStack'

    Begin Object Name=TraderGrenadePriceStack Class=CardModifierStack
        ModifierStackID="TraderGrenade"
        OnModifierChanged=TraderGrenadePriceModifierChanged
    End Object
    TraderGrenadePriceModifier=CardModifierStack'TraderGrenadePriceStack'

//DAMAGE
    Begin Object Name=PlayerDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerDamage"
        OnModifierChanged=PlayerDamageModifierChanged
    End Object
    PlayerDamageModifier=CardModifierStack'PlayerDamageModifierStack'

    Begin Object Name=PlayerRangedDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerRangedDamage"
        OnModifierChanged=PlayerRangedDamageModifierChanged
    End Object
    PlayerRangedDamageModifier=CardModifierStack'PlayerRangedDamageModifierStack'

    Begin Object Name=PlayerMeleeDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerMeleeDamage"
        OnModifierChanged=PlayerMeleeDamageModifierChanged
    End Object
    PlayerMeleeDamageModifier=CardModifierStack'PlayerMeleeDamageModifierStack'

    Begin Object Name=PlayerShotgunDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerShotgunDamage"
        OnModifierChanged=PlayerShotgunDamageModifierChanged
    End Object
    PlayerShotgunDamageModifier=CardModifierStack'PlayerShotgunDamageModifierStack'

    Begin Object Name=PlayerFireDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerFireDamage"
        OnModifierChanged=PlayerFireDamageModifierChanged
    End Object
    PlayerFireDamageModifier=CardModifierStack'PlayerFireDamageModifierStack'

    Begin Object Name=PlayerExplosiveDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerExplosiveDamage"
        OnModifierChanged=PlayerExplosiveDamageModifierChanged
    End Object
    PlayerExplosiveDamageModifier=CardModifierStack'PlayerExplosiveDamageModifierStack'

    Begin Object Name=PlayerExplosiveRadiusStack Class=CardModifierStack
        ModifierStackID="PlayerExplosiveRadius"
        OnModifierChanged=PlayerExplosiveRadiusModifierChanged
    End Object
    PlayerExplosiveRadiusModifier=CardModifierStack'PlayerExplosiveRadiusStack'

    Begin Object Name=PlayerOnPerkDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerOnPerkDamage"
        OnModifierChanged=PlayerOnPerkDamageModifierChanged
    End Object
    PlayerOnPerkDamageModifier=CardModifierStack'PlayerFireDamageModifierStack'

    Begin Object Name=PlayerOffPerkDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerOffPerkDamage"
        OnModifierChanged=PlayerOffPerkDamageModifierChanged
    End Object
    PlayerOffPerkDamageModifier=CardModifierStack'PlayerOffPerkDamageModifierStack'

    Begin Object Name=PlayerMedicGrenadeDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerMedicGrenadeDamage"
        OnModifierChanged=PlayerMedicGrenadeDamageModifierChanged
    End Object
    PlayerMedicGrenadeDamageModifier=CardModifierStack'PlayerMedicGrenadeDamageModifierStack'

    Begin Object Name=PlayerBerserkerMeleeDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerBerserkerMeleeDamage"
        OnModifierChanged=PlayerBerserkerMeleeDamageModifierChanged
    End Object
    PlayerBerserkerMeleeDamageModifier=CardModifierStack'PlayerBerserkerMeleeDamageModifierStack'

    Begin Object Name=PlayerNonEliteDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerNonEliteDamage"
        OnModifierChanged=PlayerNonEliteDamageModifierChanged
    End Object
    PlayerNonEliteDamageModifier=CardModifierStack'PlayerNonEliteDamageModifierStack'

    Begin Object Name=PlayerNonEliteHeadshotDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerNonEliteHeadshotDamage"
        OnModifierChanged=PlayerNonEliteHeadshotDamageModifierChanged
    End Object
    PlayerNonEliteHeadshotDamageModifier=CardModifierStack'PlayerNonEliteHeadshotDamageModifierStack'

    Begin Object Name=PlayerBossDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerBossDamage"
        OnModifierChanged=PlayerBossDamageModifierChanged
    End Object
    PlayerBossDamageModifier=CardModifierStack'PlayerBossDamageModifierStack'

    Begin Object Name=PlayerMonsterFullHealthDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerMonsterFullHealthDamage"
        OnModifierChanged=PlayerMonsterFullHealthDamageModifierChanged
    End Object
    PlayerMonsterFullHealthDamageModifier=CardModifierStack'PlayerMonsterFullHealthDamageModifierStack'

    Begin Object Name=PlayerSlomoDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerSlomoDamage"
        OnModifierChanged=PlayerSlomoDamageModifierChanged
    End Object
    PlayerSlomoDamageModifier=CardModifierStack'PlayerSlomoDamageModifierStack'

    Begin Object Name=PlayerLowHealthDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerLowHealthDamage"
        OnModifierChanged=PlayerLowHealthDamageModifierChanged
    End Object
    PlayerLowHealthDamageModifier=CardModifierStack'PlayerLowHealthDamageModifierStack'

    Begin Object Name=PlayerFleshpoundDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerFleshpoundDamage"
        OnModifierChanged=PlayerFleshpoundDamageModifierChanged
    End Object
    PlayerFleshpoundDamageModifier=CardModifierStack'PlayerFleshpoundDamageModifierStack'

    Begin Object Name=PlayerScrakeDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerScrakeDamage"
        OnModifierChanged=PlayerScrakeDamageModifierChanged
    End Object
    PlayerScrakeDamageModifier=CardModifierStack'PlayerScrakeDamageModifierStack'

    Begin Object Name=PlayerMassDetonationCardFlag Class=CardFlag
        FlagID="PlayerMassDetonation"
        OnFlagSetChanged=PlayerMassDetonationCardFlagChanged
    End Object
    PlayerMassDetonationFlag=CardFlag'PlayerMassDetonationCardFlag'

    Begin Object Name=WeldStrengthModifierStack Class=CardModifierStack
        ModifierStackID="WeldStrengthModifier"
        OnModifierChanged=WeldStrengthModifierChanged
    End Object
    WeldStrengthModifier=CardModifierStack'WeldStrengthModifierStack'

    Begin Object Name=CriticalShotCardFlag Class=CardFlag
        FlagID="CriticalShot"
        OnFlagSetChanged=CriticalShotCardFlagChanged
    End Object
    CriticalShotFlag=CardFlag'CriticalShotCardFlag'

//DAMAGE RECEIVED
    Begin Object Name=PlayerArmorStrengthModifierStack Class=CardModifierStack
        ModifierStackID="PlayerArmorStrength"
        OnModifierChanged=PlayerArmorStrengthModifierChanged
    End Object
    PlayerArmorStrengthModifier=CardModifierStack'PlayerArmorStrengthModifierStack'

    Begin Object Name=PlayerDamageTakenModifierStack Class=CardModifierStack
        ModifierStackID="PlayerDamageTaken"
        OnModifierChanged=PlayerDamageTakenModifierChanged
    End Object
    PlayerDamageTakenModifier=CardModifierStack'PlayerDamageTakenModifierStack'

    Begin Object Name=PlayerExplosiveDamageTakenModifierStack Class=CardModifierStack
        ModifierStackID="PlayerExplosiveDamageTaken"
        OnModifierChanged=PlayerExplosiveDamageTakenModifierChanged
    End Object
    PlayerExplosiveDamageTakenModifier=CardModifierStack'PlayerExplosiveDamageTakenModifierStack'

    Begin Object Name=PlayerFallDamageModifierStack Class=CardModifierStack
        ModifierStackID="PlayerFallDamage"
        OnModifierChanged=PlayerFallDamageModifierChanged
    End Object
    PlayerFallDamageModifier=CardModifierStack'PlayerFallDamageModifierStack'

    Begin Object Name=PlayerDamageSubstituteCardFlag Class=CardFlag
        FlagID="PlayerDamageSubstitute"
        OnFlagSetChanged=PlayerDamageSubstituteCardFlagChanged
    End Object
    PlayerDamageSubstituteFlag=CardFlag'PlayerDamageSubstituteCardFlag'

//FIRE RATE
    Begin Object Name=PlayerFireRateModifierStack Class=CardModifierStack
        ModifierStackID="PlayerFireRate"
        OnModifierChanged=PlayerFireRateModifierChanged
    End Object
    PlayerFireRateModifier=CardModifierStack'PlayerFireRateModifierStack'

    Begin Object Name=PlayerBerserkerFireRateModifierStack Class=CardModifierStack
        ModifierStackID="PlayerBerserkerFireRate"
        OnModifierChanged=PlayerBerserkerFireRateModifierChanged
    End Object
    PlayerBerserkerFireRateModifier=CardModifierStack'PlayerBerserkerFireRateModifierStack'

    Begin Object Name=PlayerFirebugFireRateModifierStack Class=CardModifierStack
        ModifierStackID="PlayerFirebugFireRate"
        OnModifierChanged=PlayerFirebugFireRateModifierChanged
    End Object
    PlayerFirebugFireRateModifier=CardModifierStack'PlayerFirebugFireRateModifierStack'

    Begin Object Name=PlayerZedTimeDualWeaponFireRateModifierStack Class=CardModifierStack
        ModifierStackID="PlayerZedTimeDualWeaponFireRate"
        OnModifierChanged=PlayerZedTimeDualWeaponFireRateModifierChanged
    End Object
    PlayerZedTimeDualWeaponFireRateModifier=CardModifierStack'PlayerZedTimeDualWeaponFireRateModifierStack'

//MAGAZINE AMMO
    Begin Object Name=PlayerMagazineAmmoModifierStack Class=CardModifierStack
        ModifierStackID="PlayerMagazineAmmo"
        OnModifierChanged=PlayerMagazineAmmoModifierChanged
    End Object
    PlayerMagazineAmmoModifier=CardModifierStack'PlayerMagazineAmmoModifierStack'
    
    Begin Object Name=PlayerCommandoMagazineAmmoModifierStack Class=CardModifierStack
        ModifierStackID="PlayerCommandoMagazineAmmo"
        OnModifierChanged=PlayerCommandoMagazineAmmoModifierChanged
    End Object
    PlayerCommandoMagazineAmmoModifier=CardModifierStack'PlayerCommandoMagazineAmmoModifierStack'
    
    Begin Object Name=PlayerMedicMagazineAmmoModifierStack Class=CardModifierStack
        ModifierStackID="PlayerMedicMagazineAmmo"
        OnModifierChanged=PlayerMedicMagazineAmmoModifierChanged
    End Object
    PlayerMedicMagazineAmmoModifier=CardModifierStack'PlayerMedicMagazineAmmoModifierStack'
    
    Begin Object Name=PlayerDualWeaponMagazineAmmoModifierStack Class=CardModifierStack
        ModifierStackID="PlayerDualWeaponMagazineAmmo"
        OnModifierChanged=PlayerDualWeaponMagazineAmmoModifierChanged
    End Object
    PlayerDualWeaponMagazineAmmoModifier=CardModifierStack'PlayerDualWeaponMagazineAmmoModifierStack'

//RELOAD RATE
    Begin Object Name=PlayerReloadRateModifierStack Class=CardModifierStack
        ModifierStackID="PlayerReloadRate"
        OnModifierChanged=PlayerReloadRateModifierChanged
    End Object
    PlayerReloadRateModifier=CardModifierStack'PlayerReloadRateModifierStack'
    
    Begin Object Name=PlayerCommandoReloadRateModifierStack Class=CardModifierStack
        ModifierStackID="PlayerCommandoReloadRate"
        OnModifierChanged=PlayerCommandoReloadRateModifierChanged
    End Object
    PlayerCommandoReloadRateModifier=CardModifierStack'PlayerCommandoReloadRateModifierStack'
    
    Begin Object Name=PlayerZedTimeDualWeaponReloadRateModifierStack Class=CardModifierStack
        ModifierStackID="PlayerZedTimeDualWeaponReloadRate"
        OnModifierChanged=PlayerZedTimeDualWeaponReloadRateModifierChanged
    End Object
    PlayerZedTimeDualWeaponReloadRateModifier=CardModifierStack'PlayerZedTimeDualWeaponReloadRateModifierStack'

//EQUIP RATE
    Begin Object Name=PlayerEquipRateModifierStack Class=CardModifierStack
        ModifierStackID="PlayerEquipRate"
        OnModifierChanged=PlayerEquipRateModifierChanged
    End Object
    PlayerEquipRateModifier=CardModifierStack'PlayerEquipRateModifierStack'
    
    Begin Object Name=PlayerZedTimeDualWeaponEquipRateModifierStack Class=CardModifierStack
        ModifierStackID="PlayerZedTimeDualWeaponEquipRate"
        OnModifierChanged=PlayerZedTimeDualWeaponEquipRateModifierChanged
    End Object
    PlayerZedTimeDualWeaponEquipRateModifier=CardModifierStack'PlayerZedTimeDualWeaponEquipRateModifierStack'

//MAX AMMO
    Begin Object Name=PlayerMaxAmmoModifierStack Class=CardModifierStack
        ModifierStackID="PlayerMaxAmmo"
        OnModifierChanged=PlayerMaxAmmoModifierChanged
    End Object
    PlayerMaxAmmoModifier=CardModifierStack'PlayerMaxAmmoModifierStack'
    
    Begin Object Name=PlayerCommandoMaxAmmoModifierStack Class=CardModifierStack
        ModifierStackID="PlayerCommandoMaxAmmo"
        OnModifierChanged=PlayerCommandoMaxAmmoModifierChanged
    End Object
    PlayerCommandoMaxAmmoModifier=CardModifierStack'PlayerCommandoMaxAmmoModifierStack'
    
    Begin Object Name=PlayerMedicMaxAmmoModifierStack Class=CardModifierStack
        ModifierStackID="PlayerMedicMaxAmmo"
        OnModifierChanged=PlayerMedicMaxAmmoModifierChanged
    End Object
    PlayerMedicMaxAmmoModifier=CardModifierStack'PlayerMedicMaxAmmoModifierStack'
    
    Begin Object Name=PlayerGrenadeMaxAmmoModifierStack Class=CardModifierStack
        ModifierStackID="PlayerGrenadeMaxAmmo"
        OnModifierChanged=PlayerGrenadeMaxAmmoModifierChanged
    End Object
    PlayerGrenadeMaxAmmoModifier=CardModifierStack'PlayerGrenadeMaxAmmoModifierStack'

//SPREAD AND RECOIL
    Begin Object Name=PlayerSpreadRecoilModifierStack Class=CardModifierStack
        ModifierStackID="PlayerSpreadRecoil"
        OnModifierChanged=PlayerSpreadRecoilModifierChanged
    End Object
    PlayerSpreadRecoilModifier=CardModifierStack'PlayerSpreadRecoilModifierStack'
    
    Begin Object Name=PlayerShotgunSpreadRecoilModifierStack Class=CardModifierStack
        ModifierStackID="PlayerShotgunSpreadRecoil"
        OnModifierChanged=PlayerShotgunSpreadRecoilModifierChanged
    End Object
    PlayerShotgunSpreadRecoilModifier=CardModifierStack'PlayerShotgunSpreadRecoilModifierStack'

//PENETRATION
    Begin Object Name=PlayerPenetrationModifierStack Class=CardModifierStack
        ModifierStackID="PlayerPenetration"
        OnModifierChanged=PlayerPenetrationModifierChanged
    End Object
    PlayerPenetrationModifier=CardModifierStack'PlayerPenetrationModifierStack'

//SHOTGUN
    Begin Object Name=PlayerShotgunPelletModifierStack Class=CardModifierStack
        ModifierStackID="PlayerShotgunPellet"
        OnModifierChanged=PlayerShotgunPelletModifierChanged
    End Object
    PlayerShotgunPelletModifier=CardModifierStack'PlayerShotgunPelletModifierStack'
    
    Begin Object Name=PlayerShotgunKickbackModifierStack Class=CardModifierStack
        ModifierStackID="PlayerShotgunKickback"
        OnModifierChanged=PlayerShotgunKickbackModifierChanged
    End Object
    PlayerShotgunKickbackModifier=CardModifierStack'PlayerShotgunKickbackModifierStack'

//ZED TIME EXTENSIONS
    Begin Object Name=PlayerZedTimeExtensionDeltaStack Class=CardDeltaStack
        DeltaStackID="PlayerZedTimeExtension"
        OnDeltaChanged=PlayerZedTimeExtensionDeltaChanged
    End Object
    PlayerZedTimeExtensionDelta=CardDeltaStack'PlayerZedTimeExtensionDeltaStack'
    
    Begin Object Name=PlayerDualWeaponZedTimeExtensionDeltaStack Class=CardDeltaStack
        DeltaStackID="PlayerDualWeaponZedTime"
        OnDeltaChanged=PlayerDualWeaponZedTimeExtensionDeltaChanged
    End Object
    PlayerDualWeaponZedTimeExtensionDelta=CardDeltaStack'PlayerDualWeaponZedTimeExtensionDeltaStack'

//HEALING
    Begin Object Name=PlayerNonMedicHealPotencyModifierStack Class=CardModifierStack
        ModifierStackID="PlayerNonMedicHealPotency"
        OnModifierChanged=PlayerNonMedicHealPotencyModifierChanged
    End Object
    PlayerNonMedicHealPotencyModifier=CardModifierStack'PlayerNonMedicHealPotencyModifierStack'
    
    Begin Object Name=PlayerMedicHealPotencyModifierStack Class=CardModifierStack
        ModifierStackID="PlayerMedicHealPotency"
        OnModifierChanged=PlayerMedicHealPotencyModifierChanged
    End Object
    PlayerMedicHealPotencyModifier=CardModifierStack'PlayerMedicHealPotencyModifierStack'
    
    Begin Object Name=PlayerHealRechargeModifierStack Class=CardModifierStack
        ModifierStackID="PlayerHealRecharge"
        OnModifierChanged=PlayerHealRechargeModifierChanged
    End Object
    PlayerHealRechargeModifier=CardModifierStack'PlayerHealRechargeModifierStack'

//MOVEMENT
    Begin Object Name=PlayerMovementSpeedModifierStack Class=CardModifierStack
        ModifierStackID="PlayerMovementSpeed"
        OnModifierChanged=PlayerMovementSpeedModifierChanged
    End Object
    PlayerMovementSpeedModifier=CardModifierStack'PlayerMovementSpeedModifierStack'

    Begin Object Name=PlayerMovementAccelModifierStack Class=CardModifierStack
        ModifierStackID="PlayerMovementAccel"
        OnModifierChanged=PlayerMovementAccelModifierChanged
    End Object
    PlayerMovementAccelModifier=CardModifierStack'PlayerMovementAccelModifierStack'

    Begin Object Name=PlayerMovementFrictionModifierStack Class=CardModifierStack
        ModifierStackID="PlayerMovementFriction"
        OnModifierChanged=PlayerMovementFrictionModifierChanged
    End Object
    PlayerMovementFrictionModifier=CardModifierStack'PlayerMovementFrictionModifierStack'

    Begin Object Name=PlayerJumpModifierStack Class=CardModifierStack
        ModifierStackID="PlayerJump"
        OnModifierChanged=PlayerJumpModifierChanged
    End Object
    PlayerJumpModifier=CardModifierStack'PlayerJumpModifierStack'

    Begin Object Name=PlayerAirControlModifierStack Class=CardModifierStack
        ModifierStackID="PlayerAirControl"
        OnModifierChanged=PlayerAirControlModifierChanged
    End Object
    PlayerAirControlModifier=CardModifierStack'PlayerAirControlModifierStack'
    
    Begin Object Name=PlayerFreezeTagCardFlag Class=CardFlag
        FlagID="PlayerFreezeTag"
        OnFlagSetChanged=PlayerFreezeTagFlagChanged
    End Object
    PlayerFreezeTagFlag=CardFlag'PlayerFreezeTagCardFlag'

    Begin Object Name=PlayerGreedSlowsCardFlag Class=CardFlag
        FlagID="PlayerGreedSlows"
        OnFlagSetChanged=PlayerGreedSlowsFlagChanged
    End Object
    PlayerGreedSlowsFlag=CardFlag'PlayerGreedSlowsCardFlag'

    Begin Object Name=PlayerLowHealthSlowsCardFlag Class=CardFlag
        FlagID="PlayerLowHealthSlows"
        OnFlagSetChanged=PlayerLowHealthSlowsFlagChanged
    End Object
    PlayerLowHealthSlowsFlag=CardFlag'PlayerLowHealthSlowsCardFlag'

//THORNS
    Begin Object Name=PlayerThornsModifierStack Class=CardModifierStack
        ModifierStackID="PlayerThorns"
        OnModifierChanged=PlayerThornsModifierChanged
    End Object
    PlayerThornsModifier=CardModifierStack'PlayerThornsModifierStack'

////////////////////
//MONSTER MODIFIERS

//REPLACEMENT
    Begin Object Name=WeakMonsterReplacementCardFlag Class=CardFlag
        FlagID="WeakMonsterReplacement"
        OnFlagSetChanged=WeakMonsterReplacementFlagChanged
    End Object
    WeakMonsterReplacementFlag=CardFlag'WeakMonsterReplacementCardFlag'

    Begin Object Name=ScrakeMonsterReplacementCardFlag Class=CardFlag
        FlagID="ScrakeMonsterReplacement"
        OnFlagSetChanged=ScrakeMonsterReplacementFlagChanged
    End Object
    ScrakeMonsterReplacementFlag=CardFlag'ScrakeMonsterReplacementCardFlag'

    Begin Object Name=HuskAmountBoostCardFlag Class=CardFlag
        FlagID="HuskAmountBoost"
        OnFlagSetChanged=HuskAmountBoostFlagChanged
    End Object
    HuskAmountBoostFlag=CardFlag'HuskAmountBoostCardFlag'
    
    Begin Object Name=MonsterUpgradeCardFlag Class=CardFlag
        FlagID="MonsterUpgrade"
        OnFlagSetChanged=MonsterUpgradeFlagChanged
    End Object
    MonsterUpgradeFlag=CardFlag'MonsterUpgradeCardFlag'

//DAMAGE

    Begin Object Name=MonsterDamageModifierStack Class=CardModifierStack
        ModifierStackID="MonsterDamage"
        OnModifierChanged=MonsterDamageModifierChanged
    End Object
    MonsterDamageModifier=CardModifierStack'MonsterDamageModifierStack'
    
    Begin Object Name=MonsterDamageMomentumModifierStack Class=CardModifierStack
        ModifierStackID="MonsterDamageMomentum"
        OnModifierChanged=MonsterDamageMomentumModifierChanged
    End Object
    MonsterDamageMomentumModifier=CardModifierStack'MonsterDamageMomentumModifierStack'
    
    Begin Object Name=MonsterMeleeDamageModifierStack Class=CardModifierStack
        ModifierStackID="MonsterMeleeDamage"
        OnModifierChanged=MonsterMeleeDamageModifierChanged
    End Object
    MonsterMeleeDamageModifier=CardModifierStack'MonsterMeleeDamageModifierStack'
    
    Begin Object Name=MonsterRangedDamageModifierStack Class=CardModifierStack
        ModifierStackID="MonsterRangedDamage"
        OnModifierChanged=MonsterRangedDamageModifierChanged
    End Object
    MonsterRangedDamageModifier=CardModifierStack'MonsterRangedDamageModifierStack'
    
    Begin Object Name=MonsterStalkerMeleeDamageModifierStack Class=CardModifierStack
        ModifierStackID="MonsterStalkerMeleeDamage"
        OnModifierChanged=MonsterStalkerMeleeDamageModifierChanged
    End Object
    MonsterStalkerMeleeDamageModifier=CardModifierStack'MonsterStalkerMeleeDamageModifierStack'
    
    Begin Object Name=MonsterSirenScreamDamageModifierStack Class=CardModifierStack
        ModifierStackID="MonsterSirenScreamDamage"
        OnModifierChanged=MonsterSirenScreamDamageModifierChanged
    End Object
    MonsterSirenScreamDamageModifier=CardModifierStack'MonsterSirenScreamDamageModifierStack'
    
    Begin Object Name=MonsterSirenScreamRangeModifierStack Class=CardModifierStack
        ModifierStackID="MonsterSirenScreamRange"
        OnModifierChanged=MonsterSirenScreamRangeModifierChanged
    End Object
    MonsterSirenScreamRangeModifier=CardModifierStack'MonsterSirenScreamRangeModifierStack'

//SCALING
    Begin Object Name=MonsterHeadSizeModifierStack Class=CardModifierStack
        ModifierStackID="MonsterHeadSize"
        OnModifierChanged=MonsterHeadSizeModifierChanged
    End Object
    MonsterHeadSizeModifier=CardModifierStack'MonsterHeadSizeModifierStack'
    
    Begin Object Name=MonsterStalkerDistractionModifierStack Class=CardModifierStack
        ModifierStackID="MonsterStalkerDistraction"
        OnModifierChanged=MonsterStalkerDistractionModifierChanged
    End Object
    MonsterStalkerDistractionModifier=CardModifierStack'MonsterStalkerDistractionModifierStack'

//MOVEMENT
    Begin Object Name=MonsterBloatMovementSpeedModifierStack Class=CardModifierStack
        ModifierStackID="MonsterBloatMovementSpeed"
        OnModifierChanged=MonsterBloatMovementSpeedModifierChanged
    End Object
    MonsterBloatMovementSpeedModifier=CardModifierStack'MonsterBloatMovementSpeedModifierStack'

//AI
    Begin Object Name=MonsterFleshpoundRageThresholdModifierStack Class=CardModifierStack
        ModifierStackID="MonsterFleshpoundRageThreshold"
        OnModifierChanged=MonsterFleshpoundRageThresholdModifierChanged
    End Object
    MonsterFleshpoundRageThresholdModifier=CardModifierStack'MonsterFleshpoundRageThresholdModifierStack'
    
    Begin Object Name=MonsterScrakeRageThresholdModifierStack Class=CardModifierStack
        ModifierStackID="MonsterScrakeRageThreshold"
        OnModifierChanged=MonsterScrakeRageThresholdModifierChanged
    End Object
    MonsterScrakeRageThresholdModifier=CardModifierStack'MonsterScrakeRageThresholdModifierStack'
    
    Begin Object Name=MonsterHuskRefireTimeModifierStack Class=CardModifierStack
        ModifierStackID="MonsterHuskRefireTime"
        OnModifierChanged=MonsterHuskRefireTimeModifierChanged
    End Object
    MonsterHuskRefireTimeModifier=CardModifierStack'MonsterHuskRefireTimeModifierStack'
}