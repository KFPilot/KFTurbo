//Killing Floor Turbo W_V_MP5M_Camo_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_MP5M_Camo_Weap extends W_MP5M_Weap;

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_MP5Camo'
     SkinRefs(0)="KF_Weapons_camo_Trip_T.Weapons.MP5_camo_cmb"
     SkinRefs(1)="KF_Weapons2_Trip_T.Special.Aimpoint_sight_shdr"
     HudImageRef="KillingFloor2HUD.WeaponSelect.MP5Camo_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.MP5Camo"
     AppID=258752
     PickupClass=Class'KFTurbo.W_V_MP5M_Camo_Pickup'
     AttachmentClass=Class'KFTurbo.W_V_MP5M_Camo_Attachment'
     ItemName="Camo MP5M Medic Gun"
}
