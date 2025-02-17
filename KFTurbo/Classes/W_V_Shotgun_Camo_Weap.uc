//Killing Floor Turbo W_V_Shotgun_Camo_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_Shotgun_Camo_Weap extends W_Shotgun_Weap;

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_CombatShotgunCamo'
     Skins(0)=None
     SkinRefs(0)="KF_Weapons_camo_Trip_T.Shotguns.combat_shotgun_camo_cmb"
     HudImageRef="KillingFloor2HUD.WeaponSelect.CombatShotgunCamo_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.CombatShotgunCamo"
     AppID=258752
     PickupClass=Class'KFTurbo.W_V_Shotgun_Camo_Pickup'
     AttachmentClass=Class'KFTurbo.W_V_Shotgun_Camo_Attachment'
     ItemName="Camo Shotgun"
     
     Mesh=None
     MeshRef="KF_Weapons_Trip.Shotgun_Trip"
}
