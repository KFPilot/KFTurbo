//Killing Floor Turbo W_AA12_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_AA12_Weap extends WeaponAA12AutoShotgun;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
     if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

defaultproperties
{
     FireModeClass(0)=Class'KFTurbo.W_AA12_Fire'
     PickupClass=Class'KFTurbo.W_AA12_Pickup'
}