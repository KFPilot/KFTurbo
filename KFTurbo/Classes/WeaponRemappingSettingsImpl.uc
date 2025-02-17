//Killing Floor Turbo WeaponRemappingSettingsImpl
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class WeaponRemappingSettingsImpl extends WeaponRemappingSettings;

static function class<Weapon> GetRemappedWeapon(PlayerController PlayerController, class<Weapon> NewWeaponClass)
{
	local Inventory Inv;

	if (PlayerController == None || PlayerController.Pawn == None)
	{
		return NewWeaponClass;
	}

	for ( Inv = PlayerController.Pawn.Inventory; Inv != None; Inv = Inv.Inventory )
	{
		//Attempt adjustment automatically. Most KFTurbo weapons inherit from their KFMod counterparts.
		if (ClassIsChildOf(Inv.Class, NewWeaponClass))
		{
			return class<Weapon>(Inv.Class);
		}
	}
	
	return NewWeaponClass;
}

defaultproperties
{
	
}
