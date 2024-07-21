class W_V_ThompsonDrum_STP_Weap extends W_ThompsonDrum_Weap;

defaultproperties
{
    WeaponReloadAnim="Reload_IJC_spThompson_Drum"
    TraderInfoTexture=Texture'KF_IJC_HUD.Trader_Weapon_Icons.Trader_SteamPunk_Tommygun'
    MeshRef="KF_IJC_Summer_Weps1.Steampunk_Thompson"
    SkinRefs(1)="KF_IJC_Summer_Weapons.Steampunk_Thompson.Steampunk_Thompson_cmb"
    SelectSoundRef="KF_SP_ThompsonSnd.KFO_SP_Thompson_Select"
    HudImageRef="KF_IJC_HUD.WeaponSelect.SteamPunk_Tommygun_Unselected"
    SelectedHudImageRef="KF_IJC_HUD.WeaponSelect.SteamPunk_Tommygun_Selected"
    AppID=210943
    FireModeClass(0)=Class'KFTurbo.W_V_ThompsonDrum_STP_Fire'
    Description="Thy weapon is before you. May it's drum beat a sound of terrible fear into your enemies."
    AttachmentClass=Class'KFMod.SPThompsonAttachment'
    PickupClass=Class'KFTurbo.W_V_ThompsonDrum_STP_Pickup'
    ItemName="Dr. T's Lead Delivery System"
}