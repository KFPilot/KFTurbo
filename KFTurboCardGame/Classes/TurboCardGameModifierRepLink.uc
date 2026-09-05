//Killing Floor Turbo TurboCardGameModifierRepLink
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardGameModifierRepLink extends TurboGameModifierReplicationLink
    hidecategories(Advanced,Display,Events,Object,Sound);

//Higher means faster.
var(Turbo) float FireRateMultiplier;
var(Turbo) float MeleeFireRateMultiplier;
var(Turbo) float ZedTimeDualPistolFireRateMultiplier;
var(Turbo) float BerserkerFireRateMultiplier;
var(Turbo) float FirebugFireRateMultiplier;
var(Turbo) float HighAmmoFireRateMultiplier;

var(Turbo) float ReloadRateMultiplier;
var(Turbo) float ZedTimeDualWeaponReloadRateMultiplier;
var(Turbo) float CommandoReloadRateMultiplier;
var(Turbo) float LowAmmoReloadRateMultiplier;

var(Turbo) float MagazineAmmoMultiplier;
var(Turbo) float DualWeaponMagazineAmmoMultiplier;
var(Turbo) float CommandoMagazineAmmoMultiplier;
var(Turbo) float MedicMagazineAmmoMultiplier;

var(Turbo) float MaxAmmoMultiplier;
var(Turbo) float CommandoMaxAmmoMultiplier;
var(Turbo) float MedicMaxAmmoMultiplier;
var(Turbo) float GrenadeMaxAmmoMultiplier;

var(Turbo) float WeaponPenetrationMultiplier;
var(Turbo) float WeaponSpreadRecoilMultiplier;
var(Turbo) float BracedSpreadRecoilMultiplier; //Applied on top of WeaponSpreadRecoilMultiplier while the player is standing still.

var(Turbo) float ShotgunPelletCountMultiplier;
var(Turbo) float ShotgunSpreadRecoilMultiplier;
var(Turbo) float ShotgunKickBackMultiplier;

var(Turbo) float TraderCostMultiplier;
var(Turbo) float TraderVinylCostMultiplier;
var(Turbo) float TraderGrenadeCostMultiplier;
var(Turbo) bool bDisableArmorPurchase;

var(Turbo) bool bPlayerHeadshotsIncreaseHeadshotDamage;
var(Turbo) float HeadshotDamageMultiplier;

//Modify this variable via ApplyPlayerMovementSpeedModifier since it needs to notify pawns to update movement speed.
var(Turbo) float PlayerMovementSpeedMultiplier;
var(Turbo) float PlayerMovementAccelMultiplier;
var(Turbo) float PlayerMovementLowWeightMultiplier;
var(Turbo) bool bFreezePlayersDuringWave;
var(Turbo) bool bMoneySlowsPlayers;
var(Turbo) bool bMissingHealthStronglySlows;

//Same as above but for max health.
var(Turbo) float PlayerMaxHealthMultiplier;
var(Turbo) int PlayerMaxCarryWeightModifier;

var(Turbo) int PlayerZedTimeExtensionsModifier;
var(Turbo) int PlayerDualPistolZedTimeExtensionsModifier;

var(Turbo) float MedicHealPotencyMultiplier, NonMedicHealPotencyMultiplier;
var(Turbo) float BodyArmorDamageModifier;
var(Turbo) float HealRechargeMultiplier;

var(Turbo) float WeldStrengthMultiplier;

var(Turbo) bool bOversizedPipebombs;

var(Turbo) bool bBurnSpeedsUpPlayers;

var(Turbo) float PerfectionistMultiplier;

replication
{
    reliable if(bNetDirty && Role == ROLE_Authority)
        FireRateMultiplier, MeleeFireRateMultiplier, ZedTimeDualPistolFireRateMultiplier, BerserkerFireRateMultiplier, FirebugFireRateMultiplier, HighAmmoFireRateMultiplier,
        ReloadRateMultiplier, ZedTimeDualWeaponReloadRateMultiplier, CommandoReloadRateMultiplier, LowAmmoReloadRateMultiplier,
        MagazineAmmoMultiplier, DualWeaponMagazineAmmoMultiplier, CommandoMagazineAmmoMultiplier, MedicMagazineAmmoMultiplier,
        MaxAmmoMultiplier, CommandoMaxAmmoMultiplier, MedicMaxAmmoMultiplier, GrenadeMaxAmmoMultiplier,
        WeaponPenetrationMultiplier,
        WeaponSpreadRecoilMultiplier, BracedSpreadRecoilMultiplier, ShotgunSpreadRecoilMultiplier,
        TraderCostMultiplier, TraderVinylCostMultiplier, TraderGrenadeCostMultiplier, bDisableArmorPurchase,
        PlayerMovementSpeedMultiplier, PlayerMovementAccelMultiplier, PlayerMovementLowWeightMultiplier,
        bFreezePlayersDuringWave, bMoneySlowsPlayers, bMissingHealthStronglySlows,
        PlayerMaxHealthMultiplier,
        HealRechargeMultiplier,
        bOversizedPipebombs,
        bBurnSpeedsUpPlayers,
        PerfectionistMultiplier;
}

static simulated final function TurboPlayerCardCustomInfo GetPlayerCustomInfo(KFPlayerReplicationInfo KFPRI)
{
    return TurboPlayerCardCustomInfo(class'TurboPlayerCardCustomInfo'.static.FindCustomInfo(TurboPlayerReplicationInfo(KFPRI)));
}

simulated final function float GetHighAmmoFireRateMultiplier(KFWeapon Weapon)
{
    local float AmmoPercent;

    if (Weapon == None || Weapon.default.MagCapacity <= 2)
    {
        return 1.f;
    }

    AmmoPercent = FClamp(float(Weapon.MagAmmoRemaining) / float(Weapon.MagCapacity), 0.f, 1.f);

    if (AmmoPercent < 0.75f)
    {
        return 1.f;
    }

    return Lerp((AmmoPercent - 0.75f) / 0.25f, 1.f, HighAmmoFireRateMultiplier);
}

//Resolves the vinyl augment of a player (if they have one).
static simulated final function VinylAugmentReplicationInfo GetPlayerAugmentInfo(KFPlayerReplicationInfo KFPRI)
{
    local TurboPlayerCardCustomInfo CardCustomInfo;

    CardCustomInfo = GetPlayerCustomInfo(KFPRI);

    if (CardCustomInfo == None)
    {
        return None;
    }

    return CardCustomInfo.AugmentInfo;
}

simulated function float GetFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
    local float Multiplier;
    local TurboPlayerCardCustomInfo CardCustomInfo;

    Multiplier = Super.GetFireRateMultiplier(KFPRI, Other);
    Multiplier *= FireRateMultiplier;

    if (KFMeleeGun(Other) != None)
    {
        Multiplier *= MeleeFireRateMultiplier;
    }
    else if (Level.TimeDilation < 0.8f && IsDualWeapon(KFWeapon(Other)))
    {
        Multiplier *= ZedTimeDualPistolFireRateMultiplier;
    }

    if (HighAmmoFireRateMultiplier != 1.f)
    {
        Multiplier *= GetHighAmmoFireRateMultiplier(KFWeapon(Other));
    }

    CardCustomInfo = GetPlayerCustomInfo(KFPRI);
    Multiplier *= GetCardCustomInfoFireRateMultiplier(CardCustomInfo, KFWeapon(Other));

    if (CardCustomInfo != None && CardCustomInfo.AugmentInfo != None && CardCustomInfo.AugmentInfo.bWantsFireRateMultiplier)
    {
        Multiplier *= CardCustomInfo.AugmentInfo.GetFireRateMultiplier(KFPRI, Other);
    }

    return Multiplier;
}

final simulated function float GetCardCustomInfoFireRateMultiplier(TurboPlayerCardCustomInfo CardCustomInfo, KFWeapon Weapon)
{
    if (CardCustomInfo == None)
    {
        return 1.f;
    }

    if (CardCustomInfo.IsInGrenadeBuffTime())
    {
        return 2.f;
    }

    return 1.f;
}

simulated function float GetBerserkerFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return Super.GetBerserkerFireRateMultiplier(KFPRI, Other) * BerserkerFireRateMultiplier; }
simulated function float GetFirebugFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return Super.GetFirebugFireRateMultiplier(KFPRI, Other) * FirebugFireRateMultiplier; }

simulated final function bool IsLowAmmoWeapon(KFWeapon Weapon)
{
    return Weapon.default.MagCapacity > 2 && (float(Weapon.MagAmmoRemaining) / float(Weapon.MagCapacity)) <= class'TurboPlayerCardCustomInfo'.default.PanicReloadThreshold;
}

simulated function float GetReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
    local float Multiplier;
    local TurboPlayerCardCustomInfo CardCustomInfo;

    Multiplier = Super.GetReloadRateMultiplier(KFPRI, Other) * ReloadRateMultiplier;

    if (Level.TimeDilation < 0.8f && IsDualWeapon(KFWeapon(Other)))
    {
        Multiplier *= ZedTimeDualWeaponReloadRateMultiplier;
    }

    if (LowAmmoReloadRateMultiplier != 1.f && IsLowAmmoWeapon(KFWeapon(Other)))
    {
        Multiplier *= LowAmmoReloadRateMultiplier;
    }

    CardCustomInfo = GetPlayerCustomInfo(KFPRI);
    Multiplier *= GetCardCustomInfoReloadRateMultiplier(CardCustomInfo, KFWeapon(Other));

    if (CardCustomInfo != None && CardCustomInfo.AugmentInfo != None && CardCustomInfo.AugmentInfo.bWantsReloadRateMultiplier)
    {
        Multiplier *= CardCustomInfo.AugmentInfo.GetReloadRateMultiplier(KFPRI, Other);
    }

    return Multiplier;
}

final simulated function float GetCardCustomInfoReloadRateMultiplier(TurboPlayerCardCustomInfo CardCustomInfo, KFWeapon Weapon)
{
    local float Multiplier;

    if (CardCustomInfo == None)
    {
        return 1.f;
    }

    Multiplier = 1.f;
    if (CardCustomInfo.IsInGrenadeBuffTime())
    {
        Multiplier *= 2.f;
    }

    if (PerfectionistMultiplier != 1.f && CardCustomInfo.IsPerfectionistActive())
    {
        Multiplier *= PerfectionistMultiplier;
    }

    return Multiplier;
}

simulated function float GetCommandoReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return Super.GetCommandoReloadRateMultiplier(KFPRI, Other) * CommandoReloadRateMultiplier; }

simulated function float GetMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
    local float Multiplier;
    local VinylAugmentReplicationInfo AugmentInfo;

    Multiplier = MagazineAmmoMultiplier;

    if (IsDualWeapon(Other))
    {
        Multiplier *= DualWeaponMagazineAmmoMultiplier;
    }

    AugmentInfo = GetPlayerAugmentInfo(KFPRI);

    if (AugmentInfo != None && AugmentInfo.bWantsMagazineAmmoMultiplier)
    {
        Multiplier *= AugmentInfo.GetMagazineAmmoMultiplier(KFPRI, Other);
    }

    return Super.GetMagazineAmmoMultiplier(KFPRI, Other) * Multiplier;
}

simulated function float GetCommandoMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { return Super.GetCommandoMagazineAmmoMultiplier(KFPRI, Other) * CommandoMagazineAmmoMultiplier; }
simulated function float GetMedicMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { return Super.GetMedicMagazineAmmoMultiplier(KFPRI, Other) * MedicMagazineAmmoMultiplier; }

simulated function float GetMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType)
{
    local float Multiplier;
    local VinylAugmentReplicationInfo AugmentInfo;

    Multiplier = MaxAmmoMultiplier;
    if (GrenadeMaxAmmoMultiplier != 1.f && class<FragAmmo>(AmmoType) != None)
    {
        Multiplier *= GrenadeMaxAmmoMultiplier;
    }

    if (bOversizedPipebombs && class<PipeBombAmmo>(AmmoType) != None)
    {
        Multiplier *= 0.5f;
    }

    AugmentInfo = GetPlayerAugmentInfo(KFPRI);

    if (AugmentInfo != None && AugmentInfo.bWantsMaxAmmoMultiplier)
    {
        Multiplier *= AugmentInfo.GetMaxAmmoMultiplier(KFPRI, AmmoType);
    }

    return Super.GetMaxAmmoMultiplier(KFPRI, AmmoType) * Multiplier;
}

simulated function float GetCommandoMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { return Super.GetCommandoMaxAmmoMultiplier(KFPRI, AmmoType) * CommandoMaxAmmoMultiplier; }
simulated function float GetMedicMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { return Super.GetMedicMaxAmmoMultiplier(KFPRI, AmmoType) * MedicMaxAmmoMultiplier; }

simulated function float GetWeaponPenetrationMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other)
{
    local float Multiplier;
    local VinylAugmentReplicationInfo AugmentInfo;

    Multiplier = Super.GetWeaponPenetrationMultiplier(KFPRI, Other) * WeaponPenetrationMultiplier;

    AugmentInfo = GetPlayerAugmentInfo(KFPRI);

    if (AugmentInfo != None && AugmentInfo.bWantsWeaponPenetrationMultiplier)
    {
        Multiplier *= AugmentInfo.GetWeaponPenetrationMultiplier(KFPRI, Other);
    }

    return Multiplier;
}

simulated function float GetWeaponSpreadRecoilMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other)
{
    local float Multiplier;
    local VinylAugmentReplicationInfo AugmentInfo;

    Multiplier = Super.GetWeaponSpreadRecoilMultiplier(KFPRI, Other) * WeaponSpreadRecoilMultiplier;

    if (ShotgunSpreadRecoilMultiplier != 1.f && ShotgunFire(Other) != None && ShotgunFire(Other).default.ProjPerFire > 1)
    {
        Multiplier *= ShotgunSpreadRecoilMultiplier;
    }

    if (BracedSpreadRecoilMultiplier != 1.f && Other != None && Other.Instigator != None
        && Other.Instigator.Physics == PHYS_Walking && VSizeSquared(Other.Instigator.Velocity) < 100.f)
    {
        Multiplier *= BracedSpreadRecoilMultiplier;
    }

    AugmentInfo = GetPlayerAugmentInfo(KFPRI);

    if (AugmentInfo != None && AugmentInfo.bWantsWeaponSpreadRecoilMultiplier)
    {
        Multiplier *= AugmentInfo.GetWeaponSpreadRecoilMultiplier(KFPRI, Other);
    }

    return Multiplier;
}

simulated function GetTraderCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item, out float Multiplier)
{
    local VinylAugmentReplicationInfo AugmentInfo;

    Super.GetTraderCostMultiplier(KFPRI, Item, Multiplier);

    if (Item == class'CardGameVinylPickup')
    {
        Multiplier *= TraderVinylCostMultiplier;
        return;
    }

    if (bDisableArmorPurchase && class<Vest>(Item) != None)
    {
        Multiplier = -1.f;
        return;
    }

    Multiplier *= TraderCostMultiplier;

    AugmentInfo = GetPlayerAugmentInfo(KFPRI);

    if (AugmentInfo != None && AugmentInfo.bWantsTraderCostMultiplier)
    {
        AugmentInfo.GetTraderCostMultiplier(KFPRI, Item, Multiplier);
    }
}
simulated function float GetTraderGrenadeCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
    local float Multiplier;
    local VinylAugmentReplicationInfo AugmentInfo;

    Multiplier = Super.GetTraderGrenadeCostMultiplier(KFPRI, Item) * TraderGrenadeCostMultiplier;

    AugmentInfo = GetPlayerAugmentInfo(KFPRI);

    if (AugmentInfo != None && AugmentInfo.bWantsTraderGrenadeCostMultiplier)
    {
        Multiplier *= AugmentInfo.GetTraderGrenadeCostMultiplier(KFPRI, Item);
    }

    return Multiplier;
}

simulated function float GetPlayerMovementSpeedMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
    local float Multiplier;
    local TurboHumanPawn Pawn;
    local TurboPlayerCardCustomInfo CardCustomInfo;

    if (Controller(KFPRI.Owner) == None)
    {
        return 1.f;
    }

    Pawn = TurboHumanPawn(Controller(KFPRI.Owner).Pawn);
    CardCustomInfo = GetPlayerCustomInfo(KFPRI);

    Multiplier = PlayerMovementSpeedMultiplier;

    if (Pawn != None && Pawn.CurrentWeight < 5)
    {
        Multiplier *= PlayerMovementLowWeightMultiplier;
    }

    if (CardCustomInfo != None)
    {
        if (PerfectionistMultiplier != 1.f && CardCustomInfo.IsPerfectionistActive())
        {
            Multiplier *= PerfectionistMultiplier;
        }

        if (bFreezePlayersDuringWave)
        {
            if (KFGRI != None && KFGRI.bWaveInProgress && Pawn != None)
            {
                Multiplier *= CardCustomInfo.UpdateFreezeTagMoveSpeed(KFWeapon(Pawn.Weapon));
            }
            else
            {
                CardCustomInfo.MeleeWeaponHoldTime = Level.TimeSeconds; //Always report the weapon is being held.
            }

            if (Multiplier <= 0.0001f)
            {
                return Multiplier;
            }
        }

        if (CardCustomInfo.IsInHealBoostTime())
        {
            Multiplier *= 1.3f;
        }

        if (bMoneySlowsPlayers)
        {
            Multiplier *= CardCustomInfo.GetGreedBegetsSlowSpeedModifier();
        }
    }

    if (bMissingHealthStronglySlows && Pawn != None && (float(Pawn.Health) / Pawn.HealthMax) < 0.75f)
    {
        Multiplier *= 0.66f;
    }

    if (bBurnSpeedsUpPlayers && Pawn != None && Pawn.bBurnified)
    {
        Multiplier *= 1.15f;
    }

    if (CardCustomInfo != None && CardCustomInfo.AugmentInfo != None && CardCustomInfo.AugmentInfo.bWantsPlayerMovementSpeedMultiplier)
    {
        Multiplier *= CardCustomInfo.AugmentInfo.GetPlayerMovementSpeedMultiplier(KFPRI, KFGRI);
    }

    return Super.GetPlayerMovementSpeedMultiplier(KFPRI, KFGRI) * Multiplier;
}

simulated function float GetPlayerMovementAccelMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
    return Super.GetPlayerMovementAccelMultiplier(KFPRI, KFGRI) * PlayerMovementAccelMultiplier;
}

simulated function float GetPlayerMaxHealthMultiplier(Pawn Pawn)
{
    local float Multiplier;
    local VinylAugmentReplicationInfo AugmentInfo;

    Multiplier = Super.GetPlayerMaxHealthMultiplier(Pawn) * PlayerMaxHealthMultiplier;

    if (Pawn != None)
    {
        AugmentInfo = GetPlayerAugmentInfo(KFPlayerReplicationInfo(Pawn.PlayerReplicationInfo));

        if (AugmentInfo != None && AugmentInfo.bWantsPlayerMaxHealthMultiplier)
        {
            Multiplier *= AugmentInfo.GetPlayerMaxHealthMultiplier(Pawn);
        }
    }

    return Multiplier;
}

simulated function float GetHealRechargeMultiplier(KFPlayerReplicationInfo KFPRI)
{
    local float Multiplier;
    local VinylAugmentReplicationInfo AugmentInfo;

    Multiplier = Super.GetHealRechargeMultiplier(KFPRI) * HealRechargeMultiplier;

    AugmentInfo = GetPlayerAugmentInfo(KFPRI);

    if (AugmentInfo != None && AugmentInfo.bWantsHealRechargeMultiplier)
    {
        Multiplier *= AugmentInfo.GetHealRechargeMultiplier(KFPRI);
    }

    return Multiplier;
}

function float GetWeldSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
    return Super.GetWeldSpeedModifier(KFPRI) * WeldStrengthMultiplier;
}

function GetPlayerCarryWeightModifier(KFPlayerReplicationInfo KFPRI, out int OutCarryWeightModifier)
{
    Super.GetPlayerCarryWeightModifier(KFPRI, OutCarryWeightModifier);

    OutCarryWeightModifier += PlayerMaxCarryWeightModifier;
}

function GetPlayerZedExtensionModifier(KFPlayerReplicationInfo KFPRI, out int OutZedExtensions)
{
    Super.GetPlayerZedExtensionModifier(KFPRI, OutZedExtensions);

    OutZedExtensions += PlayerZedTimeExtensionsModifier;

    if (PlayerDualPistolZedTimeExtensionsModifier != 0 && IsPlayerHoldingDualWeapon(KFPRI))
    {
        OutZedExtensions += PlayerDualPistolZedTimeExtensionsModifier;
    }
}

static final function bool IsPlayerHoldingDualWeapon(KFPlayerReplicationInfo KFPRI)
{
    local Controller Controller;
    local Pawn Pawn;

    Controller = Controller(KFPRI.Owner);
    if (Controller == None)
    {
        return false;
    }

    Pawn = Controller.Pawn;
    if (Pawn == None)
    {
        return false;
    }

    return IsDualWeapon(KFWeapon(Pawn.Weapon));
}

static final function bool IsDualWeapon(KFWeapon Weapon)
{
    return Weapon != None && Weapon.bDualWeapon;
}

function float GetDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageInstigator, int InDamage, class<DamageType> DamageType)
{
    local float Multiplier;
    local VinylAugmentReplicationInfo AugmentInfo;

    Multiplier = Super.GetDamageMultiplier(KFPRI, Injured, DamageInstigator, InDamage, DamageType);

    AugmentInfo = GetPlayerAugmentInfo(KFPRI);

    if (AugmentInfo != None && AugmentInfo.bWantsDamageMultiplier)
    {
        Multiplier *= AugmentInfo.GetDamageMultiplier(KFPRI, Injured, DamageInstigator, InDamage, DamageType);
    }

    return Multiplier;
}

function float GetHeadshotDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType)
{
    local float Multiplier;
    local TurboPlayerCardCustomInfo CardCustomInfo;

    Multiplier = Super.GetHeadshotDamageMultiplier(KFPRI, Pawn, DamageType);

    CardCustomInfo = GetPlayerCustomInfo(KFPRI);

    if (CardCustomInfo != None)
    {
        if (bPlayerHeadshotsIncreaseHeadshotDamage)
        {
            Multiplier *= CardCustomInfo.GetRackEmUpHeadshotBonus();
        }

        //Forward to a vinyl augment that wants to take part in headshot damage.
        if (CardCustomInfo.AugmentInfo != None && CardCustomInfo.AugmentInfo.bWantsHeadshotDamageMultiplier)
        {
            Multiplier *= CardCustomInfo.AugmentInfo.GetHeadshotDamageMultiplier(KFPRI, Pawn, DamageType);
        }
    }

    Multiplier *= HeadshotDamageMultiplier;

    return Multiplier;
}

function float GetHealPotencyMultiplier(KFPlayerReplicationInfo KFPRI)
{
    local float Multiplier;
    local VinylAugmentReplicationInfo AugmentInfo;

    Multiplier = Super.GetHealPotencyMultiplier(KFPRI);

    if (KFPRI != None && class<V_FieldMedic>(KFPRI.ClientVeteranSkill) != None)
    {
        Multiplier *= MedicHealPotencyMultiplier;
    }
    else
    {
        Multiplier *= NonMedicHealPotencyMultiplier;
    }

    AugmentInfo = GetPlayerAugmentInfo(KFPRI);

    if (AugmentInfo != None && AugmentInfo.bWantsHealPotencyMultiplier)
    {
        Multiplier *= AugmentInfo.GetHealPotencyMultiplier(KFPRI);
    }

    return Multiplier;
}

function GetBodyArmorDamageModifier(KFPlayerReplicationInfo KFPRI, out float Multiplier)
{
    Super.GetBodyArmorDamageModifier(KFPRI, Multiplier);
    Multiplier *= BodyArmorDamageModifier;
}

function OnShotgunFire(KFShotgunFire ShotgunFire)
{
    Super.OnShotgunFire(ShotgunFire);

    if (ShotgunFire.default.ProjPerFire > 1)
    {
        ShotgunFire.ProjPerFire = float(ShotgunFire.default.ProjPerFire) * ShotgunPelletCountMultiplier;
    }

    ShotgunFire.KickMomentum = ShotgunFire.default.KickMomentum * ShotgunKickBackMultiplier;
}

defaultproperties
{
    FireRateMultiplier=1.f
    MeleeFireRateMultiplier=1.f
    ZedTimeDualPistolFireRateMultiplier=1.f
    BerserkerFireRateMultiplier=1.f
    FirebugFireRateMultiplier=1.f
    HighAmmoFireRateMultiplier=1.f

    ReloadRateMultiplier=1.f
    ZedTimeDualWeaponReloadRateMultiplier=1.f
    CommandoReloadRateMultiplier=1.f
    LowAmmoReloadRateMultiplier=1.f

    MagazineAmmoMultiplier=1.f
    DualWeaponMagazineAmmoMultiplier=1.f
    CommandoMagazineAmmoMultiplier=1.f
    MedicMagazineAmmoMultiplier=1.f

    MaxAmmoMultiplier=1.f
    CommandoMaxAmmoMultiplier=1.f
    MedicMaxAmmoMultiplier=1.f
    GrenadeMaxAmmoMultiplier=1.f

    WeaponPenetrationMultiplier=1.f
    WeaponSpreadRecoilMultiplier=1.f
    BracedSpreadRecoilMultiplier=1.f
    ShotgunPelletCountMultiplier=1.f
    ShotgunSpreadRecoilMultiplier=1.f
    ShotgunKickBackMultiplier=1.f

    TraderCostMultiplier=1.f
    TraderVinylCostMultiplier=1.f
    TraderGrenadeCostMultiplier=1.f
    bDisableArmorPurchase=false

    PlayerMovementSpeedMultiplier=1.f
    PlayerMovementAccelMultiplier=1.f
    PlayerMovementLowWeightMultiplier=1.f
    PerfectionistMultiplier=1.f
    bFreezePlayersDuringWave=false
    bMoneySlowsPlayers=false
    bMissingHealthStronglySlows=false

    PlayerMaxHealthMultiplier=1.f

    PlayerMaxCarryWeightModifier=0

    MedicHealPotencyMultiplier=1.f
    NonMedicHealPotencyMultiplier=1.f
    BodyArmorDamageModifier=1.f
    HealRechargeMultiplier=1.f
    WeldStrengthMultiplier=1.f

    HeadshotDamageMultiplier=1.f
}
