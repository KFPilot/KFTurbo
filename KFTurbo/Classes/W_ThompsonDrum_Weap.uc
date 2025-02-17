//Killing Floor Turbo W_ThompsonDrum_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_ThompsonDrum_Weap extends ThompsonDrumSMG;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

defaultproperties
{
     MagCapacity=50
     ReloadRate=4.210000
     ReloadAnimRate=0.900000
     Weight=6.000000
     AppID=0
     FireModeClass(0)=Class'KFTurbo.W_ThompsonDrum_Fire'
     PickupClass=Class'KFTurbo.W_ThompsonDrum_Pickup'
}
