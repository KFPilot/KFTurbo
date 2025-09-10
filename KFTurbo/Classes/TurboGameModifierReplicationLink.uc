//Killing Floor Turbo TurboGameModifierReplicationLink
//Linked list of gameplay modifications. Forwards mutator-like events but for things networked gameplay cares about.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameModifierReplicationLink extends ReplicationInfo
    abstract;

var TurboGameModifierReplicationLink NextGameModifierLink;
var TurboGameReplicationInfo OwnerGRI;

replication
{
    reliable if(Role == ROLE_Authority)
        NextGameModifierLink, OwnerGRI;
}

//Reminder that if you override these simulated functions, they must return the same value on the client and server.
simulated function float GetFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetFireRateMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetBerserkerFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetBerserkerFireRateMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetFirebugFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetFirebugFireRateMultiplier(KFPRI, Other); } return 1.f; }

simulated function float GetReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetReloadRateMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetCommandoReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetCommandoReloadRateMultiplier(KFPRI, Other); } return 1.f; }

simulated function float GetMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetMagazineAmmoMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetCommandoMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetCommandoMagazineAmmoMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetMedicMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetMedicMagazineAmmoMultiplier(KFPRI, Other); } return 1.f; }

simulated function float GetMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetMaxAmmoMultiplier(KFPRI, AmmoType); } return 1.f; }
simulated function float GetCommandoMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetMaxAmmoMultiplier(KFPRI, AmmoType); } return 1.f; }
simulated function float GetMedicMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetMedicMaxAmmoMultiplier(KFPRI, AmmoType); } return 1.f; }

simulated function float GetWeaponPenetrationMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetWeaponPenetrationMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetWeaponSpreadRecoilMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetWeaponSpreadRecoilMultiplier(KFPRI, Other); } return 1.f; }

simulated function GetTraderCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item, out float Multiplier) { if (NextGameModifierLink != None) { NextGameModifierLink.GetTraderCostMultiplier(KFPRI, Item, Multiplier); } }
simulated function float GetTraderGrenadeCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetTraderGrenadeCostMultiplier(KFPRI, Item); } return 1.f; }

simulated function float GetPlayerMovementSpeedMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetPlayerMovementSpeedMultiplier(KFPRI, KFGRI); } return 1.f; }
simulated function float GetPlayerMovementAccelMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetPlayerMovementAccelMultiplier(KFPRI, KFGRI); } return 1.f; }
simulated function float GetPlayerMaxHealthMultiplier(Pawn Pawn) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetPlayerMaxHealthMultiplier(Pawn); } return 1.f; }

simulated function float GetHealRechargeMultiplier(KFPlayerReplicationInfo KFPRI) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetHealRechargeMultiplier(KFPRI); } return 1.f; }

//These functions are only called server-side so no need to replicate properties that are only used here.
function GetPlayerCarryWeightModifier(KFPlayerReplicationInfo KFPRI, out int OutCarryWeightModifier) { if (NextGameModifierLink != None) { NextGameModifierLink.GetPlayerCarryWeightModifier(KFPRI, OutCarryWeightModifier); } }
function GetPlayerZedExtensionModifier(KFPlayerReplicationInfo KFPRI, out int OutZedExtensions) { if (NextGameModifierLink != None) { NextGameModifierLink.GetPlayerZedExtensionModifier(KFPRI, OutZedExtensions); } }
function float GetHeadshotDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetHeadshotDamageMultiplier(KFPRI, Pawn, DamageType); } return 1.f; }
function float GetHealPotencyMultiplier(KFPlayerReplicationInfo KFPRI) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetHealPotencyMultiplier(KFPRI); } return 1.f; }
function float GetWeldSpeedModifier(KFPlayerReplicationInfo KFPRI) { if (NextGameModifierLink != None) { return NextGameModifierLink.GetWeldSpeedModifier(KFPRI); } return 1.f; }
function GetBodyArmorDamageModifier(KFPlayerReplicationInfo KFPRI, out float Multiplier) { if (NextGameModifierLink != None) { NextGameModifierLink.GetBodyArmorDamageModifier(KFPRI, Multiplier); } }
function OnWeaponFire(WeaponFire WeaponFire) { if (NextGameModifierLink != None) { NextGameModifierLink.OnWeaponFire(WeaponFire); } }
function OnShotgunFire(KFShotgunFire ShotgunFire) { if (NextGameModifierLink != None) { NextGameModifierLink.OnShotgunFire(ShotgunFire); } }
function OnMeleeFire(KFMeleeFire MeleeFire) { if (NextGameModifierLink != None) { NextGameModifierLink.OnMeleeFire(MeleeFire); } }
function OnMedicDartFire(WeaponFire MeleeFire) { if (NextGameModifierLink != None) { NextGameModifierLink.OnMedicDartFire(MeleeFire); } }

//Make NetUpdateTime want to update now.
simulated function ForceNetUpdate()
{
    NetUpdateTime = Max(Level.TimeSeconds - ((1.f / NetUpdateFrequency) + 1.f), 0.1f);
}

defaultproperties
{
    NetUpdateFrequency=0.1f
}