//Killing Floor Turbo W_V_M32_Camo_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_M32_Camo_Weap extends W_M32_Weap;

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_M32Camo'
     SkinRefs(0)="KF_Weapons_camo_Trip_T.Weapons.M32_camo_cmb"
     HudImageRef="KillingFloor2HUD.WeaponSelect.M32Camo_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.M32Camo"
     Description="A camouflaged advanced semi automatic grenade launcher. Launches high explosive grenades."
     PickupClass=Class'KFTurbo.W_V_M32_Camo_Pickup'
     AttachmentClass=Class'KFMod.CamoM32Attachment'
     ItemName="Camo M32 Grenade Launcher"
}
