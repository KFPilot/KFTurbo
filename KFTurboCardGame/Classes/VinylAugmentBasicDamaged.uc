//Killing Floor Turbo VinylAugmentBasicDamaged
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentBasicDamaged extends VinylAugmentBasic;

var float DamageTakenEndTime;

replication
{
	reliable if (Role == ROLE_Authority)
		DamageTakenEndTime;
}

function NotifyPlayerReceivedDamage(TurboPlayerController Player, KFMonster DamageInstigator, int Damage, class<DamageType> DamageType)
{
    DamageTakenEndTime = Level.TimeSeconds;
    ForceNetUpdate();
}

simulated final function bool WasRecentlyDamaged()
{
    return DamageTakenEndTime > Level.TimeSeconds;
}

function float GetHeadshotDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType) { if (WasRecentlyDamaged()) { return DamageHeadshotMultiplier; } return 1.f; }

simulated function float GetFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { if (WasRecentlyDamaged()) { return FireRateMultiplier; } return 1.f; }
simulated function float GetReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { if (WasRecentlyDamaged()) { return ReloadRateMultiplier; } return 1.f; }
simulated function float GetMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { if (WasRecentlyDamaged()) { return MagazineAmmoMultiplier; } return 1.f; }
simulated function float GetMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { if (WasRecentlyDamaged()) { return MaxAmmoMultiplier; } return 1.f; }
simulated function float GetWeaponPenetrationMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { if (WasRecentlyDamaged()) { return PenetrationMultiplier; } return 1.f; }
simulated function float GetWeaponSpreadRecoilMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { if (WasRecentlyDamaged()) { return SpreadRecoilMultiplier; } return 1.f; }
simulated function float GetPlayerMovementSpeedMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { if (WasRecentlyDamaged()) { return MovementSpeedMultiplier; } return 1.f; }
simulated function float GetPlayerMaxHealthMultiplier(Pawn Pawn) { if (WasRecentlyDamaged()) { return MaxHealthMultiplier; } return 1.f; }
function float GetHealPotencyMultiplier(KFPlayerReplicationInfo KFPRI) { if (WasRecentlyDamaged()) { return HealPotencyMultiplier; } return 1.f;}
simulated function float GetHealRechargeMultiplier(KFPlayerReplicationInfo KFPRI) { if (WasRecentlyDamaged()) { return HealRechargeMultiplier; } return 1.f; }

defaultproperties
{
    bWantsPlayerReceivedDamageEvents=true
}
