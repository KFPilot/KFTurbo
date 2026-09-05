//Killing Floor Turbo VinylAugmentBasicConditional
//Applies its augment list only while IsAugmentActive() is true. Subclasses define the condition.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentBasicConditional extends VinylAugmentBasic
	abstract;

simulated function bool IsAugmentActive()
{
    return true;
}

function float GetDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageInstigator, int InDamage, class<DamageType> DamageType) { if (IsAugmentActive()) { return Super.GetDamageMultiplier(KFPRI, Injured, DamageInstigator, InDamage, DamageType); } return 1.f; }
function float GetHeadshotDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType) { if (IsAugmentActive()) { return Super.GetHeadshotDamageMultiplier(KFPRI, Pawn, DamageType); } return 1.f; }

simulated function float GetFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { if (IsAugmentActive()) { return Super.GetFireRateMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { if (IsAugmentActive()) { return Super.GetReloadRateMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { if (IsAugmentActive()) { return Super.GetMagazineAmmoMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { if (IsAugmentActive()) { return Super.GetMaxAmmoMultiplier(KFPRI, AmmoType); } return 1.f; }
simulated function float GetWeaponPenetrationMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { if (IsAugmentActive()) { return Super.GetWeaponPenetrationMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetWeaponSpreadRecoilMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { if (IsAugmentActive()) { return Super.GetWeaponSpreadRecoilMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetPlayerMovementSpeedMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { if (IsAugmentActive()) { return Super.GetPlayerMovementSpeedMultiplier(KFPRI, KFGRI); } return 1.f; }
simulated function float GetPlayerMaxHealthMultiplier(Pawn Pawn) { if (IsAugmentActive()) { return Super.GetPlayerMaxHealthMultiplier(Pawn); } return 1.f; }
function float GetHealPotencyMultiplier(KFPlayerReplicationInfo KFPRI) { if (IsAugmentActive()) { return Super.GetHealPotencyMultiplier(KFPRI); } return 1.f; }
simulated function float GetHealRechargeMultiplier(KFPlayerReplicationInfo KFPRI) { if (IsAugmentActive()) { return Super.GetHealRechargeMultiplier(KFPRI); } return 1.f; }
simulated function float GetTraderGrenadeCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item) { if (IsAugmentActive()) { return Super.GetTraderGrenadeCostMultiplier(KFPRI, Item); } return 1.f; }

function float ModifyDamage(int Damage, Pawn Injured, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
    if (IsAugmentActive())
    {
        return Super.ModifyDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);
    }

    return 1.f;
}

simulated function GetTraderCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item, out float Multiplier)
{
    if (IsAugmentActive())
    {
        Super.GetTraderCostMultiplier(KFPRI, Item, Multiplier);
    }
}
