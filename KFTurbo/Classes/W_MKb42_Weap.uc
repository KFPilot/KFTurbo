//Killing Floor Turbo W_MKb42_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_MKb42_Weap extends MKb42AssaultRifle;

exec function ReloadMeNow()
{
     Super(KFWeapon).ReloadMeNow();
}

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

defaultproperties
{
     Weight=4.000000
     MagCapacity=26
     ReloadRate=2.70000
     ReloadAnimRate=1.100000
     FireModeClass(0)=Class'KFTurbo.W_MKb42_Fire'
     PickupClass=Class'KFTurbo.W_MKb42_Pickup'
}