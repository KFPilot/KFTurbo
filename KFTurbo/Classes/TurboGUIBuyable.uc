//Killing Floor Turbo TurboGUIBuyable
//Adds variant selection to GUIBuyable.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGUIBuyable extends GUIBuyable;

var array<TurboRepLink.VariantWeapon> VariantList;
var int VariantSelection;

final function class<Pickup> GetPickup()
{
	if (VariantSelection == -1 || VariantList.Length <= VariantSelection)
	{
		return ItemPickupClass;
	}

	return VariantList[VariantSelection].VariantClass;
}

final function class<KFWeapon> GetWeapon()
{
	if (GetPickup() == None || class<KFWeapon>(GetPickup().default.InventoryType) == None)
	{
		return ItemWeaponClass;
	}

	return class<KFWeapon>(GetPickup().default.InventoryType);
}

defaultproperties
{
    VariantSelection=-1
}
