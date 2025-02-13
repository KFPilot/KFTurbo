//Killing Floor Turbo W_M32_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M32_Weap extends M32GrenadeLauncher;

var int AddReloadCount;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
     if (Role == ROLE_Authority && ++AddReloadCount >= MagCapacity) { class'WeaponHelper'.static.OnWeaponReload(Self); AddReloadCount = 0; }
}

defaultproperties
{
     FireModeClass(0)=Class'KFTurbo.W_M32_Fire'
     PickupClass=Class'KFTurbo.W_M32_Pickup'
}
