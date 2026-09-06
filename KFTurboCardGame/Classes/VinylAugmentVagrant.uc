//Killing Floor Turbo VinylAugmentVagrant
//Scales its augment list by how much of the player's carry weight is free.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentVagrant extends VinylAugmentBasic;

//Weight replicates to the owning client, so both sides agree on the ratio.
simulated final function float GetFreeWeightRatio()
{
    local KFHumanPawn Pawn;

    if (OwningCardInfo == None)
    {
        return 0.f;
    }

    Pawn = KFHumanPawn(OwningCardInfo.GetOwnerPawn());

    if (Pawn == None || Pawn.Health <= 0 || Pawn.MaxCarryWeight <= 0.f)
    {
        return 0.f;
    }

    return FClamp((Pawn.MaxCarryWeight - Pawn.CurrentWeight) / Pawn.MaxCarryWeight, 0.f, 1.f);
}

simulated final function float ApplyFreeWeightRatio(float Multiplier)
{
    return Lerp(GetFreeWeightRatio(), 1.f, Multiplier);
}

function float GetDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageInstigator, int InDamage, class<DamageType> DamageType) { return ApplyFreeWeightRatio(Super.GetDamageMultiplier(KFPRI, Injured, DamageInstigator, InDamage, DamageType)); }
function float GetHeadshotDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType) { return ApplyFreeWeightRatio(Super.GetHeadshotDamageMultiplier(KFPRI, Pawn, DamageType)); }

simulated function float GetFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return ApplyFreeWeightRatio(Super.GetFireRateMultiplier(KFPRI, Other)); }
simulated function float GetReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return ApplyFreeWeightRatio(Super.GetReloadRateMultiplier(KFPRI, Other)); }
simulated function float GetMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { return ApplyFreeWeightRatio(Super.GetMagazineAmmoMultiplier(KFPRI, Other)); }
simulated function float GetMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { return ApplyFreeWeightRatio(Super.GetMaxAmmoMultiplier(KFPRI, AmmoType)); }
simulated function float GetWeaponPenetrationMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { return ApplyFreeWeightRatio(Super.GetWeaponPenetrationMultiplier(KFPRI, Other)); }
simulated function float GetWeaponSpreadRecoilMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { return ApplyFreeWeightRatio(Super.GetWeaponSpreadRecoilMultiplier(KFPRI, Other)); }
simulated function float GetPlayerMovementSpeedMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { return ApplyFreeWeightRatio(Super.GetPlayerMovementSpeedMultiplier(KFPRI, KFGRI)); }
simulated function float GetPlayerMovementAccelMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { return ApplyFreeWeightRatio(Super.GetPlayerMovementAccelMultiplier(KFPRI, KFGRI)); }
simulated function float GetPlayerMaxHealthMultiplier(Pawn Pawn) { return ApplyFreeWeightRatio(Super.GetPlayerMaxHealthMultiplier(Pawn)); }
function float GetHealPotencyMultiplier(KFPlayerReplicationInfo KFPRI) { return ApplyFreeWeightRatio(Super.GetHealPotencyMultiplier(KFPRI)); }
simulated function float GetHealRechargeMultiplier(KFPlayerReplicationInfo KFPRI) { return ApplyFreeWeightRatio(Super.GetHealRechargeMultiplier(KFPRI)); }

function float ModifyDamage(int Damage, Pawn Injured, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
    return ApplyFreeWeightRatio(Super.ModifyDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType));
}
