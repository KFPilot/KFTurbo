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

var(Turbo) float ReloadRateMultiplier;
var(Turbo) float ZedTimeDualWeaponReloadRateMultiplier;
var(Turbo) float CommandoReloadRateMultiplier;

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

var(Turbo) float ShotgunPelletCountMultiplier;
var(Turbo) float ShotgunSpreadRecoilMultiplier;
var(Turbo) float ShotgunKickBackMultiplier;

var(Turbo) float TraderCostMultiplier;
var(Turbo) float TraderGrenadeCostMultiplier;
var(Turbo) bool bDisableArmorPurchase;

//Modify this variable via ApplyPlayerMovementSpeedModifier since it needs to notify pawns to update movement speed.
var(Turbo) float PlayerMovementSpeedMultiplier;
var(Turbo) float PlayerMovementAccelMultiplier;
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

replication
{
    reliable if(bNetDirty && Role == ROLE_Authority)
        FireRateMultiplier, MeleeFireRateMultiplier, ZedTimeDualPistolFireRateMultiplier, BerserkerFireRateMultiplier, FirebugFireRateMultiplier,
        ReloadRateMultiplier, ZedTimeDualWeaponReloadRateMultiplier, CommandoReloadRateMultiplier,
        MagazineAmmoMultiplier, CommandoMagazineAmmoMultiplier, MedicMagazineAmmoMultiplier,
        MaxAmmoMultiplier, CommandoMaxAmmoMultiplier, MedicMaxAmmoMultiplier, GrenadeMaxAmmoMultiplier,
        WeaponPenetrationMultiplier,
        WeaponSpreadRecoilMultiplier, ShotgunSpreadRecoilMultiplier,
        TraderCostMultiplier, TraderGrenadeCostMultiplier, bDisableArmorPurchase,
        PlayerMovementSpeedMultiplier, PlayerMovementAccelMultiplier, bFreezePlayersDuringWave, bMoneySlowsPlayers, bMissingHealthStronglySlows,
        PlayerMaxHealthMultiplier,
        HealRechargeMultiplier,
        bOversizedPipebombs,
        bBurnSpeedsUpPlayers;
}

static simulated final function TurboPlayerCardCustomInfo GetPlayerCustomInfo(KFPlayerReplicationInfo KFPRI)
{
    return TurboPlayerCardCustomInfo(class'TurboPlayerCardCustomInfo'.static.FindCustomInfo(TurboPlayerReplicationInfo(KFPRI)));
}

simulated function float GetFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
    local float Multiplier;
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

    return Multiplier * GetCardCustomInfoFireRateMultiplier(GetPlayerCustomInfo(KFPRI));
}

final simulated function float GetCardCustomInfoFireRateMultiplier(TurboPlayerCardCustomInfo CardCustomInfo)
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

simulated function float GetReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
    local float Multiplier;
    Multiplier = Super.GetReloadRateMultiplier(KFPRI, Other) * ReloadRateMultiplier;

    if (Level.TimeDilation < 0.8f && IsDualWeapon(KFWeapon(Other)))
    {
        Multiplier *= ZedTimeDualWeaponReloadRateMultiplier;
    }
    
    return Multiplier * GetCardCustomInfoReloadRateMultiplier(GetPlayerCustomInfo(KFPRI));
}

final simulated function float GetCardCustomInfoReloadRateMultiplier(TurboPlayerCardCustomInfo CardCustomInfo)
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

simulated function float GetCommandoReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return Super.GetCommandoReloadRateMultiplier(KFPRI, Other) * CommandoReloadRateMultiplier; }

simulated function float GetMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
    local float Multiplier;
    Multiplier = MagazineAmmoMultiplier;

    if (IsDualWeapon(Other))
    {
        Multiplier *= DualWeaponMagazineAmmoMultiplier;
    }

    return Super.GetMagazineAmmoMultiplier(KFPRI, Other) * Multiplier;
}

simulated function float GetCommandoMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { return Super.GetCommandoMagazineAmmoMultiplier(KFPRI, Other) * CommandoMagazineAmmoMultiplier; }
simulated function float GetMedicMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { return Super.GetMedicMagazineAmmoMultiplier(KFPRI, Other) * MedicMagazineAmmoMultiplier; }

simulated function float GetMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType)
{
    local float Multiplier;
    Multiplier = MaxAmmoMultiplier;
    if (GrenadeMaxAmmoMultiplier != 1.f && class<FragAmmo>(AmmoType) != None)
    {
        Multiplier *= GrenadeMaxAmmoMultiplier;
    }

    if (bOversizedPipebombs && class<PipeBombAmmo>(AmmoType) != None)
    {
        Multiplier *= 0.5f;
    }

    return Super.GetMaxAmmoMultiplier(KFPRI, AmmoType) * Multiplier;
}

simulated function float GetCommandoMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { return Super.GetCommandoMaxAmmoMultiplier(KFPRI, AmmoType) * CommandoMagazineAmmoMultiplier; }
simulated function float GetMedicMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { return Super.GetMedicMaxAmmoMultiplier(KFPRI, AmmoType) * MedicMaxAmmoMultiplier; }

simulated function float GetWeaponPenetrationMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { return Super.GetWeaponPenetrationMultiplier(KFPRI, Other) * WeaponPenetrationMultiplier; }
simulated function float GetWeaponSpreadRecoilMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other)
{
    local float Multiplier;
    Multiplier = Super.GetWeaponSpreadRecoilMultiplier(KFPRI, Other) * WeaponSpreadRecoilMultiplier;
    
    if (ShotgunSpreadRecoilMultiplier != 1.f && ShotgunFire(Other) != None && ShotgunFire(Other).default.ProjPerFire > 1)
    {
        Multiplier *= ShotgunSpreadRecoilMultiplier;
    }

    return Multiplier;
}

simulated function GetTraderCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item, out float Multiplier)
{
    Super.GetTraderCostMultiplier(KFPRI, Item, Multiplier);

    if (bDisableArmorPurchase && class<Vest>(Item) != None)
    {
        Multiplier = -1.f;
    }
    else
    {
        Multiplier *= TraderCostMultiplier;
    }
}
simulated function float GetTraderGrenadeCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item) { return Super.GetTraderGrenadeCostMultiplier(KFPRI, Item) * TraderGrenadeCostMultiplier; }

simulated function float GetPlayerMovementSpeedMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) 
{
    local float Multiplier;
    local KFPawn Pawn;

    Pawn = KFPawn(Controller(KFPRI.Owner).Pawn);

    if (bFreezePlayersDuringWave && KFGRI != None && KFGRI.bWaveInProgress)
    {
        if (KFMeleeGun(Pawn.Weapon) == None)
        {
            return 0.0001f;
        }
    }

    Multiplier = PlayerMovementSpeedMultiplier;

    if (bMoneySlowsPlayers)
    {
        Multiplier *= FClamp(Lerp((KFPRI.Score - 800.f) / 5200.f, 1.f, 0.01f), 0.01f, 1.f);
    }

    if (bMissingHealthStronglySlows && Pawn != None && (float(Pawn.Health) / Pawn.HealthMax) < 0.75f)
    {
        Multiplier *= 0.75f;
    }

    if (bBurnSpeedsUpPlayers && Pawn != None && Pawn.bBurnified)
    {
        Multiplier *= 1.15f;
    }
    
    return Super.GetPlayerMovementSpeedMultiplier(KFPRI, KFGRI) * Multiplier * GetCardCustomInfoSpeedMultiplier(GetPlayerCustomInfo(KFPRI));
}

final simulated function float GetCardCustomInfoSpeedMultiplier(TurboPlayerCardCustomInfo CardCustomInfo)
{
    if (CardCustomInfo == None)
    {
        return 1.f;
    }

    if (CardCustomInfo.IsInHealBoostTime())
    {
        return 2.f;
    }

    return 1.f;
}

simulated function float GetPlayerMovementAccelMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
    return Super.GetPlayerMovementAccelMultiplier(KFPRI, KFGRI) * PlayerMovementAccelMultiplier;
}

simulated function float GetPlayerMaxHealthMultiplier(Pawn Pawn)
{
    return Super.GetPlayerMaxHealthMultiplier(Pawn) * PlayerMaxHealthMultiplier;
}

simulated function float GetHealRechargeMultiplier(KFPlayerReplicationInfo KFPRI)
{
    return Super.GetHealRechargeMultiplier(KFPRI) * HealRechargeMultiplier;
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

function float GetHealPotencyMultiplier(KFPlayerReplicationInfo KFPRI)
{
    local float Multiplier;
    Multiplier = Super.GetHealPotencyMultiplier(KFPRI);

    if (KFPRI != None && class<V_FieldMedic>(KFPRI.ClientVeteranSkill) != None)
    {
        Multiplier *= MedicHealPotencyMultiplier;
    }
    else
    {
        Multiplier *= NonMedicHealPotencyMultiplier;
    }

    return Multiplier;
}

function GetBodyArmorDamageModifier(KFPlayerReplicationInfo KFPRI, out float Multiplier)
{
    Super.GetBodyArmorDamageModifier(KFPRI, Multiplier);
    Multiplier *= BodyArmorDamageModifier;
}

function OnShotgunFire(CoreShotgunFire ShotgunFire)
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

    ReloadRateMultiplier=1.f
    ZedTimeDualWeaponReloadRateMultiplier=1.f
    CommandoReloadRateMultiplier=1.f

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
    ShotgunPelletCountMultiplier=1.f
    ShotgunSpreadRecoilMultiplier=1.f
    ShotgunKickBackMultiplier=1.f

    TraderCostMultiplier=1.f
    TraderGrenadeCostMultiplier=1.f
    bDisableArmorPurchase=false

    PlayerMovementSpeedMultiplier=1.f
    PlayerMovementAccelMultiplier=1.f
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
}