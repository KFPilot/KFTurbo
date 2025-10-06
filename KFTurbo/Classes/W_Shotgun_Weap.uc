//Killing Floor Turbo W_Shotgun_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Shotgun_Weap extends WeaponShotgun;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

simulated function BringUp(optional Weapon PrevWeapon)
{
     class'WeaponHelper'.static.WeaponCheckForHint(Self, 14);

     Super.BringUp(PrevWeapon);
}

defaultproperties
{
     ReloadRate=0.550000
     ReloadAnimRate=1.212121
     Weight=7.000000
     FireModeClass(0)=Class'KFTurbo.W_Shotgun_Fire'
     PickupClass=Class'KFTurbo.W_Shotgun_Pickup'

     HudImageRef="KillingFloorHUD.WeaponSelect.combat_shotgun_unselected"
     SelectedHudImageRef="KillingFloorHUD.WeaponSelect.combat_shotgun"

     Skins(0)=None
     SkinRefs(0)="KF_Weapons_Trip_T.Shotguns.shotgun_cmb"

     Mesh=None
     MeshRef="KF_Weapons_Trip.Shotgun_Trip"
}
