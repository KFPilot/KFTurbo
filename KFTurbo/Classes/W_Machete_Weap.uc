//Killing Floor Turbo W_Machete_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Machete_Weap extends WeaponMachete;

static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount)
{
	Super(KFWeapon).PreloadAssets(Inv, bSkipRefCount);

	default.BloodyMaterial = Material(DynamicLoadObject(default.BloodyMaterialRef, class'Material', true));

	if (KFMeleeGun(Inv) != None)
	{
		KFMeleeGun(Inv).BloodyMaterial = default.BloodyMaterial;
	}
}

defaultproperties
{
     FireModeClass(0)=Class'KFTurbo.W_Machete_Fire'
     FireModeClass(1)=Class'KFTurbo.W_Machete_Fire_Alt'
     PickupClass=Class'KFTurbo.W_Machete_Pickup'
     
     WeaponRange=80.000000
     bSpeedMeUp=True

     Skins(0)=None
     Skins(1)=None
     SkinRefs(0)="KF_Weapons_Trip_T.melee.Machete_cmb"

     BloodyMaterial=None
     BloodyMaterialRef="KF_Weapons2_Trip_T.melee.Katana_Bloody_cmb"
     
     Mesh=None
     MeshRef="KF_Weapons_Trip.Machete_Trip"

     HudImage=None
     SelectedHudImage=None
     HudImageRef="KillingFloorHUD.WeaponSelect.machette_unselected"
     SelectedHudImageRef="KillingFloorHUD.WeaponSelect.machette"
}
