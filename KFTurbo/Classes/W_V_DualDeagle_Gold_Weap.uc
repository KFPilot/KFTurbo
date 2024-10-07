class W_V_DualDeagle_Gold_Weap extends W_DualDeagle_Weap;

defaultproperties
{
	FireModeClass(0)=Class'KFTurbo.W_V_DualDeagle_Gold_Fire'
	DemoReplacement=Class'KFTurbo.W_V_Deagle_Gold_Weap'
	PickupClass=Class'KFTurbo.W_V_DualDeagle_Gold_Pickup' 

	HudImage=Texture'KillingFloor2HUD.WeaponSelect.Gold_Dual_Deagle_unselected'
	SelectedHudImage=Texture'KillingFloor2HUD.WeaponSelect.Gold_Dual_Deagle'
	TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Gold_Dual_Deagle'
	AppID=210944
	Description="Dual golden .50 calibre action express handgun. Dual golden 50's is double the fun."
	AttachmentClass=Class'KFMod.GoldenDualDeagleAttachment'
	ItemName="Dual Golden Handcannons"
	Skins(0)=Combiner'KF_Weapons_Gold_T.Weapons.Gold_deagle_cmb'
}
