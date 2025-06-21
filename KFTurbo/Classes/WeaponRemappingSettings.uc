//Killing Floor Turbo WeaponRemappingSettings
//Called by PlayerController exec function GetWeapon. Allows for modular weapon remapping.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class WeaponRemappingSettings extends Object;

static function class<Weapon> GetRemappedWeapon(PlayerController PlayerController, class<Weapon> NewWeaponClass)
{
	return NewWeaponClass;
}

defaultproperties
{

}
