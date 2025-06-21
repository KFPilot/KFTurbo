//Killing Floor Turbo W_V_Deagle_Gold_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_Deagle_Gold_Weap extends W_Deagle_Weap;

defaultproperties
{
	FireModeClass(0)=Class'KFTurbo.W_V_Deagle_Gold_Fire'
	PickupClass=Class'KFTurbo.W_V_Deagle_Gold_Pickup'
    AttachmentClass=Class'KFMod.GoldenDeagleAttachment'

	TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Gold_Deagle'
    SkinRefs(0)="KF_Weapons_Gold_T.Weapons.Gold_deagle_cmb"
    HudImageRef="KillingFloor2HUD.WeaponSelect.Gold_Deagle_unselected"
    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Gold_Deagle"
    AppID=210944
    ItemName="Golden Handcannon"
}
