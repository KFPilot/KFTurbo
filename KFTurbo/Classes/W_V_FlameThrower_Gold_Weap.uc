//Killing Floor Turbo W_V_FlameThrower_Gold_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_FlameThrower_Gold_Weap extends W_Flamethrower_Weap;

defaultproperties
{
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Gold_Flamethrower'
     SkinRefs(0)="KF_Weapons_Gold_T.Weapons.Gold_Flamethrower_cmb"
     HudImageRef="KillingFloor2HUD.WeaponSelect.Gold_Flamethrower_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Gold_Flamethrower"
     AppID=210944
     PickupClass=Class'KFTurbo.W_V_Flamethrower_Gold_Pickup'
     AttachmentClass=Class'KFMod.GoldenFTAttachment'
     ItemName="Golden Flamethrower"
}
