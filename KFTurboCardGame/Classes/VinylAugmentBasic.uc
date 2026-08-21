//Killing Floor Turbo VinylAugmentBasic
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentBasic extends VinylAugmentReplicationInfo;

enum EAugmentType
{
    Invalid,
    Headshot,
    FireRate,
    ReloadRate,
    MagazineAmmo,
    MaxAmmo,
    Penetration,
    SpreadRecoil,
    MovementSpeed,
    MaxHealth,
    HealPotency,
    HealRecharge
};

struct AugmentEntry
{
    var EAugmentType Type;
    var float Multiplier;
};

var AugmentEntry AugmentList[3];

var float HeadshotMultiplier, FireRateMultiplier, ReloadRateMultiplier, MagazineAmmoMultiplier, MaxAmmoMultiplier, PenetrationMultiplier, SpreadRecoilMultiplier;
var float MovementSpeedMultiplier, MaxHealthMultiplier, HealPotencyMultiplier, HealRechargeMultiplier;

replication
{
	reliable if (Role == ROLE_Authority)
		AugmentList;
}

final function ApplyAugmentEntry(int Index)
{
    switch(AugmentList[Index].Type)
    {
    case Headshot:
        HeadshotMultiplier = AugmentList[Index].Multiplier;
        bWantsHeadshotDamageMultiplier = true;
        return;
    case FireRate:
        FireRateMultiplier = AugmentList[Index].Multiplier;
        bWantsFireRateMultiplier = true;
        return;
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

function float GetHeadshotDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType) { return HeadshotMultiplier; }

simulated function float GetFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return FireRateMultiplier; }
simulated function float GetReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return ReloadRateMultiplier; }
simulated function float GetMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { return MagazineAmmoMultiplier; }
simulated function float GetMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { return MaxAmmoMultiplier; }
simulated function float GetWeaponPenetrationMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { return PenetrationMultiplier; }
simulated function float GetWeaponSpreadRecoilMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { return SpreadRecoilMultiplier; }
simulated function float GetPlayerMovementSpeedMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { return MovementSpeedMultiplier; }
simulated function float GetPlayerMaxHealthMultiplier(Pawn Pawn) { return MaxHealthMultiplier; }
function float GetHealPotencyMultiplier(KFPlayerReplicationInfo KFPRI) { return HealPotencyMultiplier; }
simulated function float GetHealRechargeMultiplier(KFPlayerReplicationInfo KFPRI) { return HealRechargeMultiplier; }

defaultproperties
{
    bNetNotify=true

    HeadshotMultiplier=1.f
    FireRateMultiplier=1.f
    ReloadRateMultiplier=1.f
    MagazineAmmoMultiplier=1.f
    MaxAmmoMultiplier=1.f
    PenetrationMultiplier=1.f
    SpreadRecoilMultiplier=1.f
    MovementSpeedMultiplier=1.f
    MaxHealthMultiplier=1.f
    HealPotencyMultiplier=1.f
    HealRechargeMultiplier=1.f
}
