//Killing Floor Turbo W_SPGrenade_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SPGrenade_Weap extends WeaponSPGrenadeLauncher;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

defaultproperties
{
     FireModeClass(0)=Class'KFTurbo.W_SPGrenade_Fire'
     PickupClass=Class'KFTurbo.W_SPGrenade_Pickup'
}