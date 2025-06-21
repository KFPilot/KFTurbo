//Killing Floor Turbo W_M14_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M14_Weap extends M14EBRBattleRifle;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

defaultproperties
{
     FireModeClass(0)=Class'W_M14_Fire'
     PickupClass=Class'KFTurbo.W_M14_Pickup'
}
