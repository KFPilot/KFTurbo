//Killing Floor Turbo W_MAC10_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_MAC10_Weap extends MAC10MP;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

defaultproperties
{
     Weight=3.000000
     PickupClass=Class'KFTurbo.W_MAC10_Pickup' 
     FireModeClass(0)=Class'KFTurbo.W_MAC10_Fire'
}