class W_V_SCARMK17_Cyber_Weap extends W_SCARMK17_Weap;

var array<Material> LoadedStateMaterialList;
var array<string> LoadedStateMaterialRefList;

var int LastKnownMagAmmo;

simulated function ClientReload()
{
     Super.ClientReload();

     Skins[0] = LoadedStateMaterialList[3];
}

simulated function ClientFinishReloading()
{
     Super.ClientFinishReloading();
     UpdateSkin();
}

simulated function ClientInterruptReload()
{
     Super.ClientFinishReloading();
     UpdateSkin();
}

simulated function WeaponTick(float DeltaTime)
{
     Super.WeaponTick(DeltaTime);

     if (Level.NetMode == NM_DedicatedServer || bIsReloading)
     {
          return;
     }

     UpdateSkin();
}

simulated function UpdateSkin()
{
     if (LastKnownMagAmmo == MagAmmoRemaining)
     {
          return;
     }

     LastKnownMagAmmo = MagAmmoRemaining;

     if (MagAmmoRemaining > 10)
     {
          Skins[0] = LoadedStateMaterialList[0];
          return;
     }
     
     if (MagAmmoRemaining > 0)
     {
          Skins[0] = LoadedStateMaterialList[1];
          return;
     }

     
     Skins[0] = LoadedStateMaterialList[2];
}

static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount)
{
     local W_V_SCARMK17_Cyber_Weap Weapon;

     Super.PreloadAssets(Inv, bSkipRefCount);

     default.LoadedStateMaterialList.Length = 4;
     default.LoadedStateMaterialList[0] = Shader(DynamicLoadObject(default.LoadedStateMaterialRefList[0], class'Shader'));
     default.LoadedStateMaterialList[1] = Shader(DynamicLoadObject(default.LoadedStateMaterialRefList[1], class'Shader'));
     default.LoadedStateMaterialList[2] = Shader(DynamicLoadObject(default.LoadedStateMaterialRefList[2], class'Shader'));
     default.LoadedStateMaterialList[3] = Shader(DynamicLoadObject(default.LoadedStateMaterialRefList[3], class'Shader'));

     Weapon = W_V_SCARMK17_Cyber_Weap(Inv);

     if (Weapon != None)
     {
          Weapon.LoadedStateMaterialList = default.LoadedStateMaterialList;
          Weapon.LastKnownMagAmmo = -1;
          Weapon.UpdateSkin();
     }
}

static function bool UnloadAssets()
{
     default.LoadedStateMaterialList.Length = 0;

     return Super.UnloadAssets();
}

defaultproperties
{
     LoadedStateMaterialRefList(0)="KFTurbo.Cyber.Cyber_SCAR_SHDR"
     LoadedStateMaterialRefList(1)="KFTurbo.Cyber.Cyber_SCAR_Warn_SHDR"
     LoadedStateMaterialRefList(2)="KFTurbo.Cyber.Cyber_SCAR_Empty_SHDR"
     LoadedStateMaterialRefList(3)="KFTurbo.Cyber.Cyber_SCAR_Reload_SHDR"

     SkinRefs(0)="KFTurbo.Cyber.Cyber_SCAR_SHDR"
     SkinRefs(1)="KFTurbo.Cyber.Cyber_SCAR_SightDot_SHDR"
     PickupClass=Class'KFTurbo.W_V_SCARMK17_Cyber_Pickup'
     AttachmentClass=Class'KFTurbo.W_V_SCARMK17_Cyber_Attachment'
     Skins(0)=None
     Skins(1)=None
}
