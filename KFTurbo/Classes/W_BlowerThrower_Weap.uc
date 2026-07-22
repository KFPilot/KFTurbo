//Killing Floor Turbo W_BlowerThrower_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_BlowerThrower_Weap extends BlowerThrower;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
     if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

defaultproperties
{
     MagCapacity=100
     PickupClass=Class'KFTurbo.W_BlowerThrower_Pickup'
     InventoryGroup=4
     FireModeClass(0)=class'KFTurbo.W_BlowerThrower_Fire'
     FireModeClass(1)=class'KFTurbo.W_BlowerThrower_Fire_Alt'
}
