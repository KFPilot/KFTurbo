//Killing Floor Turbo W_BlowerThrower_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_BlowerThrower_Weap extends WeaponBlowerThrower;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
     if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

defaultproperties
{
     PickupClass=Class'KFTurbo.W_BlowerThrower_Pickup'
     InventoryGroup=4
}
