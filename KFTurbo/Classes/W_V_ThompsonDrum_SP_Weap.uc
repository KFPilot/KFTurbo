class W_V_ThompsonDrum_SP_Weap extends W_ThompsonDrum_Weap;

defaultproperties
{
    PickupClass=Class'KFTurbo.W_V_ThompsonDrum_SP_Pickup'
    WeaponReloadAnim="Reload_IJC_spThompson_Drum"
    ReloadAnimRate=0.900000 //possibly need tweaking
    TraderInfoTexture=Texture'KF_IJC_HUD.Trader_Weapon_Icons.Trader_SteamPunk_Tommygun' // can be removed?
    MeshRef="KF_IJC_Summer_Weps1.Steampunk_Thompson"
    SkinRefs(1)="KF_IJC_Summer_Weapons.Steampunk_Thompson.Steampunk_Thompson_cmb"
    SelectSoundRef="KF_SP_ThompsonSnd.KFO_SP_Thompson_Select"
    HudImageRef="KF_IJC_HUD.WeaponSelect.SteamPunk_Tommygun_Unselected"
    SelectedHudImageRef="KF_IJC_HUD.WeaponSelect.SteamPunk_Tommygun_Selected"
    Description="Thy weapon is before you. May it's drum beat a sound of terrible fear into your enemies."
    AttachmentClass=Class'KFMod.SPThompsonAttachment'
    ItemName="Dr. T's Lead Delivery System"
}