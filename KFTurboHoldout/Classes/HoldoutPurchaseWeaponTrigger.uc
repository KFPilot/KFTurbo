//Killing Floor Turbo HoldoutPurchaseWeaponTrigger
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class HoldoutPurchaseWeaponTrigger extends HoldoutPurchaseTrigger
	placeable;

var(Purchase) class<KFWeaponPickup> WeaponPickupClass;
var(Purchase) int WeaponPrice;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		WeaponPickupClass, WeaponPrice;
}

simulated function Object GetBroadcastMessageOptionalObject()
{
	return WeaponPickupClass;
}

simulated function int GetPurchasePrice()
{
	return WeaponPrice;
}

simulated function string GetMarkerName()
{
	local string WeaponName;
	WeaponName = class<KFWeaponPickup>(GetBroadcastMessageOptionalObject()).default.ItemShortName;
	if (WeaponName == "")
	{
		WeaponName = class<KFWeaponPickup>(GetBroadcastMessageOptionalObject()).default.ItemName;
	}
	
	return WeaponName;
}

simulated function Touch(Actor Other)
{
	if (Pawn(Other) == None || HasWeapon(Pawn(Other)) || !CanCarryWeapon(HoldoutHumanPawn(Other)))
	{
		return;
	}

	Super.Touch(Other);
}

function PerformPurchase(Pawn EventInstigator)
{
	local class<Inventory> WeaponClass;
	local Inventory NewInventory;
	local KFWeapon NewWeapon;
	if (EventInstigator == None || WeaponPickupClass == None)
	{
		return;
	}

	if (EventInstigator.PlayerReplicationInfo.Score < WeaponPrice)
	{
		return;
	}

	if (HasWeapon(EventInstigator))
	{
		return;
	}

	if (!CanCarryWeapon(HoldoutHumanPawn(EventInstigator)))
	{
		return;
	}

	WeaponClass = WeaponPickupClass.default.InventoryType;


	NewInventory = Spawn(WeaponClass);
	NewWeapon = KFWeapon(NewInventory);

	if (NewInventory == None)
	{
		return;
	}

	if (NewWeapon == None)
	{
		NewInventory.Destroy();
		return;
	}

	if (KFGameType(Level.Game) != None)
	{
		KFGameType(Level.Game).WeaponSpawned(NewInventory);
	}

	NewWeapon.UpdateMagCapacity(EventInstigator.PlayerReplicationInfo);
	NewWeapon.FillToInitialAmmo();
	NewWeapon.SellValue = 0;
	
	NewWeapon.GiveTo(EventInstigator);
	EventInstigator.PlayerReplicationInfo.Score -= WeaponPrice;

	Super.PerformPurchase(EventInstigator);
}

simulated function Timer()
{
	if (TargetPawn == None || HasWeapon(TargetPawn) || !CanCarryWeapon(TargetPawn))
	{
		return;
	}

	Super.Timer();
}

simulated function bool HasWeapon(Pawn Pawn)
{
	local Inventory Inv;
	local class<Inventory> WeaponClass;

	if (Pawn == None)
	{
		return false;
	}

	Inv = Pawn.Inventory;
	WeaponClass = WeaponPickupClass.default.InventoryType;
	
	while (Inv != None)
	{
		if (Inv.IsA(WeaponClass.Name))
		{
			return true;
		}

		Inv = Inv.Inventory;
	}

	return false;
}


simulated function bool CanCarryWeapon(HoldoutHumanPawn Pawn)
{
	if (Pawn == None || WeaponPickupClass == None)
	{
		return false;
	}

	return Pawn.CanCarry(WeaponPickupClass.default.Weight);
}

defaultproperties
{
	WeaponPrice=100
	PurchaseMessageClass=class'KFTurboHoldout.PurchaseWeaponMessage'
	PurchaseNotificationMessageClass=class'KFTurboHoldout.PurchaseWeaponNotificationMessage'
	Texture=Texture'Engine.S_Weapon'
}
