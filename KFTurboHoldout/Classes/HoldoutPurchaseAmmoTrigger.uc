//Killing Floor Turbo HoldoutPurchaseAmmoTrigger
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class HoldoutPurchaseAmmoTrigger extends HoldoutPurchaseTrigger
	placeable;

var(Purchase) int AmmoPrice;
var localized string MarkerName;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		AmmoPrice;
}

simulated function Object GetBroadcastMessageOptionalObject()
{
	return class'KFAmmoPickup';
}

simulated function int GetPurchasePrice()
{
	return AmmoPrice;
}

simulated function string GetMarkerName()
{
	return MarkerName;
}

simulated function Touch(Actor Other)
{
	if (Pawn(Other) == None || !Pawn(Other).IsLocallyControlled() || !NeedsAmmo(Pawn(Other)))
	{
		return;
	}

	Super.Touch(Other);
}

function PerformPurchase(Pawn EventInstigator)
{
	if (EventInstigator == None)
	{
		return;
	}

	if (EventInstigator.PlayerReplicationInfo.Score < AmmoPrice)
	{
		return;
	}

	if (!GrantAmmo(EventInstigator))
	{
		return;
	}
	
	EventInstigator.PlayerReplicationInfo.Score -= AmmoPrice;
	PlayerController(EventInstigator.Controller).ClientPlaySound(Sound'KF_InventorySnd.Ammo_GenericPickup');

	Super.PerformPurchase(EventInstigator);
}

simulated function Timer()
{
	if (TargetPawn == None || !NeedsAmmo(TargetPawn))
	{
		SetTimer(0.5f, false);
		return;
	}

	Super.Timer();
}

simulated function bool NeedsAmmo(Pawn Pawn)
{
	local KFPlayerReplicationInfo KFPRI;
	local Inventory Inv;
	local KFAmmunition Ammo;
	local float MaxAmmo;

	KFPRI = KFPlayerReplicationInfo(Pawn.PlayerReplicationInfo);
	Inv = Pawn.Inventory;
	
	while (Inv != None)
	{
		Ammo = KFAmmunition(Inv);

		if (Ammo == None || !Ammo.bAcceptsAmmoPickups)
		{
			Inv = Inv.Inventory;
			continue;
		}

		MaxAmmo = Ammo.default.MaxAmmo;
		
		if (KFPRI != None && KFPRI.ClientVeteranSkill != None)
		{
			MaxAmmo = MaxAmmo * KFPRI.ClientVeteranSkill.static.AddExtraAmmoFor(KFPRI, Ammo.Class);
		}
	
		if (Ammo.AmmoAmount < MaxAmmo)
		{
			return true;
		}

		Inv = Inv.Inventory;
	}
	
	return false;
}

function bool GrantAmmo(Pawn Pawn)
{
	local KFPlayerReplicationInfo KFPRI;
	local Inventory Inv;
	local KFAmmunition Ammo;

	local float MaxAmmo;
	local bool bGrantedAmmo;

	local Boomstick HuntingShotgun;

	KFPRI = KFPlayerReplicationInfo(Pawn.PlayerReplicationInfo);
	Inv = Pawn.Inventory;
	
	while (Inv != None)
	{
		if (BoomStick(Inv) != None)
		{
			HuntingShotgun = BoomStick(Inv);
		}

		Ammo = KFAmmunition(Inv);

		if (Ammo == None || !Ammo.bAcceptsAmmoPickups)
		{
			Inv = Inv.Inventory;
			continue;
		}

		MaxAmmo = Ammo.default.MaxAmmo;
		
		if (KFPRI != None && KFPRI.ClientVeteranSkill != None)
		{
			MaxAmmo = MaxAmmo * KFPRI.ClientVeteranSkill.static.AddExtraAmmoFor(KFPRI, Ammo.Class);
		}
	
		if (Ammo.AmmoAmount < MaxAmmo)
		{
			Ammo.AmmoAmount = MaxAmmo;
			bGrantedAmmo = true;
		}

		Inv = Inv.Inventory;
	}
	
	if (bGrantedAmmo)
	{
		if (HuntingShotgun != None)
		{
			HuntingShotgun.AmmoPickedUp();
		}
	}

	return bGrantedAmmo;
}

defaultproperties
{
	AmmoPrice=250
	MarkerName="Ammo Restock"
	PurchaseMessageClass=class'KFTurboHoldout.PurchaseAmmoMessage'
	PurchaseNotificationMessageClass=class'KFTurboHoldout.PurchaseAmmoNotificationMessage'
	Texture=Texture'Engine.S_Ammo'
}
