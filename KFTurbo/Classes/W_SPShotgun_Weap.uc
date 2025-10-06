//Killing Floor Turbo W_SPShotgun_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SPShotgun_Weap extends WeaponSPAutoShotgun;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

defaultproperties
{
     MagCapacity=20
     ReloadRate=3.750000
     ReloadAnimRate=0.880000
     Weight=8.000000
     FireModeClass(0)=Class'KFTurbo.W_SPShotgun_Fire'
     FireModeClass(1)=Class'KFTurbo.W_SPShotgun_Fire_Alt'
     PickupClass=Class'KFTurbo.W_SPShotgun_Pickup'
     AttachmentClass=Class'KFTurbo.W_SPShotgun_Attachment'
}
