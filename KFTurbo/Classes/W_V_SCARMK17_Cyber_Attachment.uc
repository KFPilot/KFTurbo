//Killing Floor Turbo W_V_SCARMK17_Cyber_Attachment
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_SCARMK17_Cyber_Attachment extends SCARMK17Attachment;

var byte WeaponState, PreviousWeaponState;
var array<Material> LoadedStateMaterialList;
var array<string> LoadedStateMaterialRefList;

replication
{
	reliable if( bNetDirty && (Role==ROLE_Authority) )
		WeaponState;
}

simulated function PostNetReceive()
{
     Super.PostNetReceive();
     UpdateWeaponState(WeaponState);
}

function SetWeaponState(byte NewWeaponState)
{
     WeaponState = NewWeaponState;

     if (Level.NetMode != NM_DedicatedServer)
     {
          UpdateWeaponState(NewWeaponState);
     }
}

simulated function UpdateWeaponState(byte NewWeaponState)
{
     NewWeaponState = Clamp(NewWeaponState, 0, 3);

     if (NewWeaponState == PreviousWeaponState)
     {
          return;
     }

     PreviousWeaponState = NewWeaponState;
     Skins[0] = LoadedStateMaterialList[NewWeaponState];
}

static function PreloadAssets(optional KFWeaponAttachment Spawned)
{
     local W_V_SCARMK17_Cyber_Attachment WeaponAttachment;

     Super.PreloadAssets(Spawned);

     default.LoadedStateMaterialList.Length = 4;
     default.LoadedStateMaterialList[0] = Shader(DynamicLoadObject(default.LoadedStateMaterialRefList[0], class'Shader'));
     default.LoadedStateMaterialList[1] = Shader(DynamicLoadObject(default.LoadedStateMaterialRefList[1], class'Shader'));
     default.LoadedStateMaterialList[2] = Shader(DynamicLoadObject(default.LoadedStateMaterialRefList[2], class'Shader'));
     default.LoadedStateMaterialList[3] = Shader(DynamicLoadObject(default.LoadedStateMaterialRefList[3], class'Shader'));

     WeaponAttachment = W_V_SCARMK17_Cyber_Attachment(Spawned);

     if (WeaponAttachment != None)
     {
          WeaponAttachment.LoadedStateMaterialList = default.LoadedStateMaterialList;
          WeaponAttachment.UpdateWeaponState(WeaponAttachment.WeaponState);
     }
}

static function bool UnloadAssets()
{
     default.LoadedStateMaterialList.Length = 0;

     return Super.UnloadAssets();
}

defaultproperties
{
     bNetNotify=true
     //bFastAttachmentReplication=false
     
     LoadedStateMaterialRefList(0)="KFTurbo.Cyber.Cyber_SCAR_3rd_SHDR"
     LoadedStateMaterialRefList(1)="KFTurbo.Cyber.Cyber_SCAR_3rd_Warn_SHDR"
     LoadedStateMaterialRefList(2)="KFTurbo.Cyber.Cyber_SCAR_3rd_Empty_SHDR"
     LoadedStateMaterialRefList(3)="KFTurbo.Cyber.Cyber_SCAR_3rd_Reload_SHDR"
     Skins(0)=Shader'KFTurbo.Cyber.Cyber_SCAR_3rd_SHDR'
}