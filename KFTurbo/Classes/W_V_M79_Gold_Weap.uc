//Killing Floor Turbo W_V_M79_Gold_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_M79_Gold_Weap extends W_M79_Weap;

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Gold_M79'
     SkinRefs(0)="KF_Weapons_Gold_T.Weapons.Gold_M79_cmb"
     HudImageRef="KillingFloor2HUD.WeaponSelect.Gold_M79_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Gold_M79"
     AppID=210938
     Description="Gold plating. Gold filigree inlay on the woodwork. You probably want the rounds gold as well. Bosh! "
     PickupClass=Class'KFTurbo.W_V_M79_Gold_Pickup'
     AttachmentClass=Class'KFTurbo.W_V_M79_Gold_Attachment'
     ItemName="Golden M79 Grenade Launcher"
}