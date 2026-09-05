//Killing Floor Turbo VinylAugmentBasic
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentBasic extends VinylAugmentReplicationInfo;

enum EAugmentType
{
    Invalid,
    //Damage
    Damage,
    HeadshotDamage,
    //Fire Rate
    FireRate,
    FireRateMelee,
    //
    ReloadRate,
    MagazineAmmo,
    MaxAmmo,
    Penetration,
    SpreadRecoil,
    MovementSpeed,
    MovementAccel,
    MaxHealth,
    CarryWeight,
    HealPotency,
    HealRecharge,
    //Trader Cost
    TraderWeaponCost,
    TraderAmmoCost,
    TraderArmorCost,
    TraderGrenadeCost,
    //Damage Resistance
    DamageReceived,
    DamageReceivedFire,
    DamageReceivedBloat,
    DamageReceivedSiren
};

struct AugmentEntry
{
    var EAugmentType Type;
    var float Multiplier;
};

var AugmentEntry AugmentList[3];

var float DamageMultiplier, DamageHeadshotMultiplier;
var float FireRateMultiplier, FireRateMeleeMultiplier;
var float ReloadRateMultiplier, MagazineAmmoMultiplier, MaxAmmoMultiplier, PenetrationMultiplier, SpreadRecoilMultiplier;
var float MovementSpeedMultiplier, MaxHealthMultiplier, HealPotencyMultiplier, HealRechargeMultiplier;
var float DamageResistanceMultiplier, DamageResistanceFireMultiplier, DamageResistanceBloatMultiplier, DamageResistanceSirenMultiplier;
var float TraderWeaponCostMultiplier, TraderAmmoCostMultiplier, TraderArmorCostMultiplier, TraderGrenadeCostMultiplier;
var float MovementAccelMultiplier;
var int CarryWeightModifier;

replication
{
	reliable if (Role == ROLE_Authority)
		AugmentList;
}

final function ResetAugmentMultipliers()
{
    DamageMultiplier = 1.f;
    DamageHeadshotMultiplier = 1.f;
    FireRateMultiplier = 1.f;
    FireRateMeleeMultiplier = 1.f;
    ReloadRateMultiplier = 1.f;
    MagazineAmmoMultiplier = 1.f;
    MaxAmmoMultiplier = 1.f;
    PenetrationMultiplier = 1.f;
    SpreadRecoilMultiplier = 1.f;
    MovementSpeedMultiplier = 1.f;
    MovementAccelMultiplier = 1.f;
    MaxHealthMultiplier = 1.f;
    CarryWeightModifier = 0;
    HealPotencyMultiplier = 1.f;
    HealRechargeMultiplier = 1.f;
    DamageResistanceMultiplier = 1.f;
    DamageResistanceFireMultiplier = 1.f;
    DamageResistanceBloatMultiplier = 1.f;
    DamageResistanceSirenMultiplier = 1.f;
    TraderWeaponCostMultiplier = 1.f;
    TraderAmmoCostMultiplier = 1.f;
    TraderArmorCostMultiplier = 1.f;
    TraderGrenadeCostMultiplier = 1.f;
}

final function ApplyAugmentEntry(int Index)
{
    switch(AugmentList[Index].Type)
    {
    //Damage
    case Damage:
        DamageMultiplier = AugmentList[Index].Multiplier;
        bWantsDamageMultiplier = true;
        return;
    case HeadshotDamage:
        DamageHeadshotMultiplier = AugmentList[Index].Multiplier;
        bWantsHeadshotDamageMultiplier = true;
        return;
    //Fire Rate
    case FireRate:
        FireRateMultiplier = AugmentList[Index].Multiplier;
        bWantsFireRateMultiplier = true;
        return;
    case FireRateMelee:
        FireRateMeleeMultiplier = AugmentList[Index].Multiplier;
        bWantsFireRateMultiplier = true;
        bHasMeleeFireRateMultiplier = true;
        return;
    //
    case ReloadRate:
        ReloadRateMultiplier = AugmentList[Index].Multiplier;
        bWantsReloadRateMultiplier = true;
        return;
    case MagazineAmmo:
        MagazineAmmoMultiplier = AugmentList[Index].Multiplier;
        bWantsMagazineAmmoMultiplier = true;
        return;
    case MaxAmmo:
        MaxAmmoMultiplier = AugmentList[Index].Multiplier;
        bWantsMaxAmmoMultiplier = true;
        return;
    case Penetration:
        PenetrationMultiplier = AugmentList[Index].Multiplier;
        bWantsWeaponPenetrationMultiplier = true;
        return;
    case SpreadRecoil:
        SpreadRecoilMultiplier = AugmentList[Index].Multiplier;
        bWantsWeaponSpreadRecoilMultiplier = true;
        return;
    case MovementSpeed:
        MovementSpeedMultiplier = AugmentList[Index].Multiplier;
        bWantsPlayerMovementSpeedMultiplier = true;
        return;
    case MovementAccel:
        MovementAccelMultiplier = AugmentList[Index].Multiplier;
        bWantsPlayerMovementAccelMultiplier = true;
        return;
    case CarryWeight:
        CarryWeightModifier = int(AugmentList[Index].Multiplier);
        bWantsPlayerCarryWeightModifier = true;
        return;
    case MaxHealth:
        MaxHealthMultiplier = AugmentList[Index].Multiplier;
        TurboGameReplicationInfo(Level.GRI).NotifyPlayerMaxHealthChanged();
        bWantsPlayerMaxHealthMultiplier = true;
        return;
    case HealPotency:
        HealPotencyMultiplier = AugmentList[Index].Multiplier;
        bWantsHealPotencyMultiplier = true;
        return;
    case HealRecharge:
        HealRechargeMultiplier = AugmentList[Index].Multiplier;
        bWantsHealRechargeMultiplier = true;
        return;
    //Trader Cost
    case TraderWeaponCost:
        TraderWeaponCostMultiplier = AugmentList[Index].Multiplier;
        bWantsTraderCostMultiplier = true;
        return;
    case TraderAmmoCost:
        TraderAmmoCostMultiplier = AugmentList[Index].Multiplier;
        bWantsTraderCostMultiplier = true;
        return;
    case TraderArmorCost:
        TraderArmorCostMultiplier = AugmentList[Index].Multiplier;
        bWantsTraderCostMultiplier = true;
        return;
    case TraderGrenadeCost:
        TraderGrenadeCostMultiplier = AugmentList[Index].Multiplier;
        bWantsTraderGrenadeCostMultiplier = true;
        return;
    //Damage Resistance
    case DamageReceived:
        DamageResistanceMultiplier = AugmentList[Index].Multiplier;
        bWantsModifyDamage = true;
        return;
    case DamageReceivedFire:
        DamageResistanceFireMultiplier = AugmentList[Index].Multiplier;
        bWantsModifyDamage = true;
        return;
    case DamageReceivedBloat:
        DamageResistanceBloatMultiplier = AugmentList[Index].Multiplier;
        bWantsModifyDamage = true;
        return;
    case DamageReceivedSiren:
        DamageResistanceSirenMultiplier = AugmentList[Index].Multiplier;
        bWantsModifyDamage = true;
        return;
    }
}

simulated function PostNetReceive()
{
    local int Index;

    Super.PostNetReceive();

    for (Index = 0; Index < ArrayCount(AugmentList); Index++)
    {
        if (AugmentList[Index].Type == Invalid)
        {
            return;
        }

        ApplyAugmentEntry(Index);
    }
}

simulated final function bool IsMeleeWeapon(KFWeapon Weapon)
{
    return Weapon != None && Weapon.bMeleeWeapon;
}

function float GetDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageInstigator, int InDamage, class<DamageType> DamageType) { return DamageMultiplier; }
function float GetHeadshotDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType) { return DamageHeadshotMultiplier; }

simulated function float GetFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { if (bHasMeleeFireRateMultiplier && IsMeleeWeapon(KFWeapon(Other))) { return FireRateMultiplier * FireRateMeleeMultiplier; } return FireRateMultiplier; }
simulated function float GetReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return ReloadRateMultiplier; }
simulated function float GetMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { return MagazineAmmoMultiplier; }
simulated function float GetMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { return MaxAmmoMultiplier; }
simulated function float GetWeaponPenetrationMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { return PenetrationMultiplier; }
simulated function float GetWeaponSpreadRecoilMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { return SpreadRecoilMultiplier; }
simulated function float GetPlayerMovementSpeedMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { return MovementSpeedMultiplier; }
simulated function float GetPlayerMovementAccelMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { return MovementAccelMultiplier; }
simulated function float GetPlayerMaxHealthMultiplier(Pawn Pawn) { return MaxHealthMultiplier; }
function GetPlayerCarryWeightModifier(KFPlayerReplicationInfo KFPRI, out int OutCarryWeightModifier) { OutCarryWeightModifier += CarryWeightModifier; }
function float GetHealPotencyMultiplier(KFPlayerReplicationInfo KFPRI) { return HealPotencyMultiplier; }
simulated function float GetHealRechargeMultiplier(KFPlayerReplicationInfo KFPRI) { return HealRechargeMultiplier; }
simulated function float GetTraderGrenadeCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item) { return TraderGrenadeCostMultiplier; }

simulated function GetTraderCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item, out float Multiplier)
{
    if (class<Vest>(Item) != None)
    {
        Multiplier *= TraderArmorCostMultiplier;
        return;
    }

    if (class<KFAmmoPickup>(Item) != None)
    {
        Multiplier *= TraderAmmoCostMultiplier;
        return;
    }

    if (class<KFWeaponPickup>(Item) != None)
    {
        Multiplier *= TraderWeaponCostMultiplier;
    }
}

function float ModifyDamage(int Damage, Pawn Injured, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
    local float Multiplier;
    local class<KFWeaponDamageType> WeaponDamageType;

    Multiplier = DamageResistanceMultiplier;

    WeaponDamageType = class<KFWeaponDamageType>(DamageType);

    if (WeaponDamageType == None)
    {
        return Multiplier;
    }

    if (DamageResistanceFireMultiplier != 1.f && WeaponDamageType.default.bDealBurningDamage)
    {
        Multiplier *= DamageResistanceFireMultiplier;
    }
    else if (DamageResistanceBloatMultiplier != 1.f && class<DamTypeVomit>(WeaponDamageType) != None)
    {
        Multiplier *= DamageResistanceBloatMultiplier;
    }
    else if (DamageResistanceSirenMultiplier != 1.f && class<SirenScreamDamage>(WeaponDamageType) != None)
    {
        Multiplier *= DamageResistanceSirenMultiplier;
    }

	return Multiplier;
}

defaultproperties
{
    bNetNotify=true

    DamageMultiplier=1.f
    DamageHeadshotMultiplier=1.f
    FireRateMultiplier=1.f
    FireRateMeleeMultiplier=1.f
    ReloadRateMultiplier=1.f
    MagazineAmmoMultiplier=1.f
    MaxAmmoMultiplier=1.f
    PenetrationMultiplier=1.f
    SpreadRecoilMultiplier=1.f
    MovementSpeedMultiplier=1.f
    MaxHealthMultiplier=1.f
    HealPotencyMultiplier=1.f
    HealRechargeMultiplier=1.f
    DamageResistanceMultiplier=1.f
    DamageResistanceFireMultiplier=1.f
    DamageResistanceBloatMultiplier=1.f
    DamageResistanceSirenMultiplier=1.f
    TraderWeaponCostMultiplier=1.f
    TraderAmmoCostMultiplier=1.f
    TraderArmorCostMultiplier=1.f
    TraderGrenadeCostMultiplier=1.f
    MovementAccelMultiplier=1.f
}
