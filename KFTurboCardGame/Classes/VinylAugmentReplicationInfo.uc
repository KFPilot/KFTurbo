//Killing Floor Turbo VinylAugmentReplicationInfo
//Replicated state actor for vinyl augments. Spawned by TurboPlayerCardCustomInfo while its vinyl is
//possessed and registers itself to that custom info via the SparseReplicationInfo pattern.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentReplicationInfo extends KFTurbo.SparseReplicationInfo;

var TurboPlayerCardCustomInfo OwningCardInfo;

//Flags are const - they do not replicate, so flipping them at runtime would desync the simulated.
var const bool bWantsHeadshotDamageMultiplier;
var const bool bWantsPlayerHeadshotEvents;
var const bool bHasStatusIcon; //If true, this augment draws a status icon alongside the active cards' icons.
var const bool bWantsStatusIconTick; //If true, TickStatusIcon is called alongside the active cards' status icon ticks.

//Set these to have TurboCardGameModifierRepLink forward the matching function to this augment.
var const bool bWantsFireRateMultiplier;
var const bool bWantsReloadRateMultiplier;
var const bool bWantsMagazineAmmoMultiplier;
var const bool bWantsMaxAmmoMultiplier;
var const bool bWantsWeaponPenetrationMultiplier;
var const bool bWantsWeaponSpreadRecoilMultiplier;
var const bool bWantsPlayerMovementSpeedMultiplier;
var const bool bWantsPlayerMaxHealthMultiplier;
var const bool bWantsHealPotencyMultiplier;
var const bool bWantsHealRechargeMultiplier;

//Signature matches TurboGameModifierRepLink.GetHeadshotDamageMultiplier.
function float GetHeadshotDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType)
{
	return 1.f;
}

simulated function float GetFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return 1.f; }
simulated function float GetReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return 1.f; }
simulated function float GetMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { return 1.f; }
simulated function float GetMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { return 1.f; }
simulated function float GetWeaponPenetrationMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { return 1.f; }
simulated function float GetWeaponSpreadRecoilMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { return 1.f; }
simulated function float GetPlayerMovementSpeedMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { return 1.f; }
simulated function float GetPlayerMaxHealthMultiplier(Pawn Pawn) { return 1.f; }
function float GetHealPotencyMultiplier(KFPlayerReplicationInfo KFPRI) { return 1.f; }
simulated function float GetHealRechargeMultiplier(KFPlayerReplicationInfo KFPRI) { return 1.f; }

//Matches the shape of TurboCard.OnStatusIconTick.
simulated function TickStatusIcon(TurboCardOverlay CardOverlay, TurboPlayerCardCustomInfo PlayerCustomInfo, float DeltaTime)
{
}

//Matches the shape of TurboCard.OnStatusIconDraw. Return true if an icon was drawn.
simulated function bool DrawStatusIcon(TurboCardOverlay CardOverlay, TurboPlayerCardCustomInfo PlayerCustomInfo, Canvas Canvas, float DrawX, float DrawY, float DrawHeight)
{
	return false;
}

function NotifyPlayerHeadshot(TurboPlayerController Player, KFMonster HitMonster, class<DamageType> DamageType)
{
}

static function SparseReplicationInfo Find(Actor InSparseOwningActor)
{
	local TurboPlayerCardCustomInfo CardInfo;

	if (InSparseOwningActor == None)
	{
		return None;
	}

	CardInfo = TurboPlayerCardCustomInfo(InSparseOwningActor);
	if (CardInfo == None)
	{
		Warn("Find: " $ default.Class $ " was subclassed from VinylAugmentReplicationInfo but InSparseOwningActor is not a TurboPlayerCardCustomInfo (was a " $ InSparseOwningActor $ ").");
		return None;
	}

	return CardInfo.GetAugmentInfo(default.Class);
}

protected simulated function bool AttemptRegister()
{
	if (SparseOwningActor == None)
	{
		return false;
	}

	OwningCardInfo = TurboPlayerCardCustomInfo(SparseOwningActor);
	if (OwningCardInfo == None)
	{
		Warn("AttemptRegister: " $ Class $ " was subclassed from VinylAugmentReplicationInfo but SparseOwningActor is not a TurboPlayerCardCustomInfo (was a " $ SparseOwningActor $ ").");
		return false;
	}

	OwningCardInfo.RegisterAugmentInfo(Self);
	return true;
}

protected simulated function Unregister()
{
	Super.Unregister();

	if (OwningCardInfo == None)
	{
		return;
	}

	OwningCardInfo.UnregisterAugmentInfo(Self);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bOnlyRelevantToOwner=true
}
