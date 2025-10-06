//Killing Floor Turbo W_Bullpup_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Bullpup_Weap extends WeaponBullpup;

simulated function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
     if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

simulated function BringUp(optional Weapon PrevWeapon)
{
     class'WeaponHelper'.static.WeaponCheckForHint(Self, 13);

     Super.BringUp(PrevWeapon);
}

defaultproperties
{
     MagCapacity=30
     ReloadRate=1.966667
     Weight=5.000000
     FireModeClass(0)=Class'KFTurbo.W_Bullpup_Fire'
     PickupClass=Class'KFTurbo.W_Bullpup_Pickup'
}