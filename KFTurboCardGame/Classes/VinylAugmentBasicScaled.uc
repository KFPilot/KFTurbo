//Killing Floor Turbo VinylAugmentBasicScaled
//Scales its augment list by GetScaleRatio.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentBasicScaled extends VinylAugmentBasic
	abstract;

simulated function float GetScaleRatio()
{
    return 1.f;
}

simulated final function float ApplyScale(float Multiplier)
{
    return Lerp(GetScaleRatio(), BaseMultiplier, Multiplier);
}

function float GetDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageInstigator, int InDamage, class<DamageType> DamageType) { return ApplyScale(Super.GetDamageMultiplier(KFPRI, Injured, DamageInstigator, InDamage, DamageType)); }
function float GetHeadshotDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType) { return ApplyScale(Super.GetHeadshotDamageMultiplier(KFPRI, Pawn, DamageType)); }

simulated function float GetFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return ApplyScale(Super.GetFireRateMultiplier(KFPRI, Other)); }
simulated function float GetReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return ApplyScale(Super.GetReloadRateMultiplier(KFPRI, Other)); }
simulated function float GetMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { return ApplyScale(Super.GetMagazineAmmoMultiplier(KFPRI, Other)); }
simulated function float GetMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { return ApplyScale(Super.GetMaxAmmoMultiplier(KFPRI, AmmoType)); }
simulated function float GetWeaponPenetrationMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { return ApplyScale(Super.GetWeaponPenetrationMultiplier(KFPRI, Other)); }
simulated function float GetWeaponSpreadRecoilMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { return ApplyScale(Super.GetWeaponSpreadRecoilMultiplier(KFPRI, Other)); }
simulated function float GetPlayerMovementSpeedMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { return ApplyScale(Super.GetPlayerMovementSpeedMultiplier(KFPRI, KFGRI)); }
simulated function float GetPlayerMovementAccelMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { return ApplyScale(Super.GetPlayerMovementAccelMultiplier(KFPRI, KFGRI)); }
simulated function float GetPlayerMaxHealthMultiplier(Pawn Pawn) { return ApplyScale(Super.GetPlayerMaxHealthMultiplier(Pawn)); }
function float GetHealPotencyMultiplier(KFPlayerReplicationInfo KFPRI) { return ApplyScale(Super.GetHealPotencyMultiplier(KFPRI)); }
simulated function float GetHealRechargeMultiplier(KFPlayerReplicationInfo KFPRI) { return ApplyScale(Super.GetHealRechargeMultiplier(KFPRI)); }
simulated function float GetTraderGrenadeCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item) { return ApplyScale(Super.GetTraderGrenadeCostMultiplier(KFPRI, Item)); }

simulated function GetTraderCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item, out float Multiplier)
{
    local float ScaledMultiplier;
    ScaledMultiplier = 1.f;
    Super.GetTraderCostMultiplier(KFPRI, Item, ScaledMultiplier);
    Multiplier *= ApplyScale(ScaledMultiplier);
}

function GetPlayerCarryWeightModifier(KFPlayerReplicationInfo KFPRI, out int OutCarryWeightModifier)
{
    local int ScaledModifier;
    Super.GetPlayerCarryWeightModifier(KFPRI, ScaledModifier);
    OutCarryWeightModifier += int(float(ScaledModifier) * GetScaleRatio());
}

function float ModifyDamage(int Damage, Pawn Injured, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
    return ApplyScale(Super.ModifyDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType));
}
