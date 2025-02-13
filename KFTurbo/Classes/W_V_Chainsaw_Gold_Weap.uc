//Killing Floor Turbo W_V_Chainsaw_Gold_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_Chainsaw_Gold_Weap extends W_Chainsaw_Weap;

defaultproperties
{
    BloodyMaterialRef="KF_Weapons_Gold_T.Gold_Blood_chainsaw_cmb"
    TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Gold_Chainsaw'
    SkinRefs(0)="KF_Weapons_Gold_T.Weapons.Gold_chainsaw_cmb"
    HudImageRef="KillingFloor2HUD.WeaponSelect.Gold_Chainsaw_unselected"
    SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Gold_Chainsaw"
    AppID=210944
    PickupClass=Class'KFTurbo.W_V_Chainsaw_Gold_Pickup'
    AttachmentClass=Class'KFTurbo.W_V_Chainsaw_Gold_Attachment'
    ItemName="Golden Chainsaw"
}