//Killing Floor Turbo W_Trenchgun_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Trenchgun_Weap extends WeaponTrenchgun;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

defaultproperties
{
     Weight=7.000000
     FireModeClass(0)=Class'KFTurbo.W_Trenchgun_Fire'
     PickupClass=Class'KFTurbo.W_Trenchgun_Pickup'
}