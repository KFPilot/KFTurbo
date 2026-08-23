//Killing Floor Turbo VinylAugmentReplicationInfo
//Replicated state actor for vinyl augments. Spawned by TurboPlayerCardCustomInfo while its vinyl is
//possessed and registers itself to that custom info via the SparseReplicationInfo pattern.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentReplicationInfo extends KFTurbo.SparseReplicationInfo;

var TurboPlayerCardCustomInfo OwningCardInfo;

var bool bWantsDamageMultiplier, bWantsHeadshotDamageMultiplier;
var bool bWantsPlayerHeadshotEvents;
var bool bWantsPlayerReceivedDamageEvents;
var bool bWantsModifyDamage;
var bool bHasStatusIcon;
var bool bWantsStatusIconTick;

//Set these to have TurboCardGameModifierRepLink forward the matching function to this augment.
var bool bWantsFireRateMultiplier, bHasMeleeFireRateMultiplier;
var bool bWantsReloadRateMultiplier;
var bool bWantsMagazineAmmoMultiplier;
var bool bWantsMaxAmmoMultiplier;
var bool bWantsWeaponPenetrationMultiplier;
var bool bWantsWeaponSpreadRecoilMultiplier;
var bool bWantsPlayerMovementSpeedMultiplier;
var bool bWantsPlayerMaxHealthMultiplier;
var bool bWantsHealPotencyMultiplier;
var bool bWantsHealRechargeMultiplier;

function float GetDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageInstigator, int InDamage, class<DamageType> DamageType) { return 1.f; }
function float GetHeadshotDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType) { return 1.f; }

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

simulated function TickStatusIcon(TurboCardOverlay CardOverlay, TurboPlayerCardCustomInfo PlayerCustomInfo, float DeltaTime)
{
}

//Returns true if an icon was drawn.
simulated function bool DrawStatusIcon(TurboCardOverlay CardOverlay, TurboPlayerCardCustomInfo PlayerCustomInfo, Canvas Canvas, float DrawX, float DrawY, float DrawHeight)
{
	return false;
}

function NotifyPlayerHeadshot(TurboPlayerController Player, KFMonster HitMonster, class<DamageType> DamageType)
{
}

function NotifyPlayerReceivedDamage(TurboPlayerController Player, KFMonster DamageInstigator, int Damage, class<DamageType> DamageType)
{
}

//Returns a multiplier folded into CardGameRules.NetDamage. Forwarded for the augment of the injured
//player and of the instigating player - compare OwningCardInfo.GetOwnerPawn() to tell which side this is.
function float ModifyDamage(int Damage, Pawn Injured, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	return 1.f;
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
