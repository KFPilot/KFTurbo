//Killing Floor Turbo TurboGUIBuyWeaponInfoPanel
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGUIBuyWeaponInfoPanel extends SRGUIBuyWeaponInfoPanel;

function Display(GUIBuyable NewBuyable)
{
	local TurboGUIBuyable TurboBuyable;
	local class<KFWeaponPickup> PickupClass;
	
	Super.Display(NewBuyable);

	if (NewBuyable == None)
	{
		return;
	}

	if (NewBuyable.bSaleList)
	{
		TurboBuyable = TurboGUIBuyable(NewBuyable);

		if (TurboBuyable != None)
		{
			PickupClass = class<KFWeaponPickup>(TurboBuyable.GetPickup());
		}
		else
		{
			PickupClass = NewBuyable.ItemPickupClass;
		}
	}
	else
	{
		if (NewBuyable.ItemWeaponClass != None)
		{
			PickupClass = class<KFWeaponPickup>(NewBuyable.ItemWeaponClass.default.PickupClass);
		}
	}

	if (PickupClass == None)
	{
		return;
	}

	ItemName.Caption = PickupClass.default.ItemName;
	ItemImage.Image = class<KFWeapon>(PickupClass.default.InventoryType).default.TraderInfoTexture;
}

defaultproperties
{
}
