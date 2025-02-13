//Killing Floor Turbo W_SCARMK17_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SCARMK17_Weap extends SCARMK17AssaultRifle;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

defaultproperties
{
     PickupClass=Class'KFTurbo.W_SCARMK17_Pickup'
     FireModeClass(0)=Class'KFTurbo.W_SCARMK17_Fire'
}
