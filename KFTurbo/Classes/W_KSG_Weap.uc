//Killing Floor Turbo W_KSG_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_KSG_Weap extends KSGShotgun;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

defaultproperties
{
     MagCapacity=10
     ReloadRate=3.400000
     ReloadAnimRate=0.929000
     Weight=7.000000
     FireModeClass(0)=Class'KFTurbo.W_KSG_Fire'
     PickupClass=Class'KFTurbo.W_KSG_Pickup'
}
