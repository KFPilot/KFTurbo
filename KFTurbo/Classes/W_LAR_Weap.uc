//Killing Floor Turbo W_LAR_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_LAR_Weap extends WeaponWinchester;

var int AddReloadCount;

function AddReloadedAmmo()
{
    Super.AddReloadedAmmo();
    if (Role == ROLE_Authority && ++AddReloadCount >= MagCapacity) { class'WeaponHelper'.static.OnWeaponReload(Self); AddReloadCount = 0; }
}

simulated function BringUp(optional Weapon PrevWeapon)
{
     class'WeaponHelper'.static.WeaponCheckForHint(Self, 15);

     Super.BringUp(PrevWeapon);
}

defaultproperties
{
     FireModeClass(0)=Class'KFTurbo.W_LAR_Fire'
     PickupClass=Class'KFTurbo.W_LAR_Pickup'

	HudImage=None
	SelectedHudImage=None
	HudImageRef="KillingFloorHUD.WeaponSelect.winchester_unselected"
	SelectedHudImageRef="KillingFloorHUD.WeaponSelect.Winchester"
     
     Skins(0)=None
     Skins(1)=None
     SkinRefs(0)="KF_Weapons_Trip_T.Rifles.winchester_cmb"
     SkinRefs(1)="KF_Weapons_Trip_T.Rifles.winchester_cmb"

     Mesh=None
     MeshRef="KF_Weapons_Trip.Winchester_Trip"

     AddReloadCount=0
}
