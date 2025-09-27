//Killing Floor Turbo W_V_SealSqueal_Vet_Attachment
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_SealSqueal_Vet_Attachment extends SealSquealAttachment;

var byte WeaponTier, PreviousTier;
var array<string> LoadedStateMaterialRefList;
var array<Material> LoadedStateMaterialList;

replication
{
	reliable if(bNetDirty && Role == ROLE_Authority)
		WeaponTier;
}

function PostBeginPlay()
{
     Super.PostBeginPlay();
     ApplyPlayerWeaponTier();
}

simulated function PostNetBeginPlay()
{
     Super.PostNetBeginPlay();
     UpdateWeaponTier(WeaponTier);
}

simulated function PostNetReceive()
{
     Super.PostNetReceive();
     UpdateWeaponTier(WeaponTier);
}

function ApplyPlayerWeaponTier()
{
     WeaponTier = class'VetWeaponHelper'.static.GetPlayerWeaponTier(Pawn(Owner), class'V_Demolitions');
     UpdateWeaponTier(WeaponTier);
}

function SetWeaponTier(byte NewWeaponTier)
{
     WeaponTier = NewWeaponTier;
     UpdateWeaponTier(NewWeaponTier);
}

simulated function UpdateWeaponTier(byte NewWeaponTier)
{
     class'VetWeaponHelper'.static.UpdateWeaponAttachmentTier(Self, NewWeaponTier, PreviousTier, LoadedStateMaterialRefList, LoadedStateMaterialList);
     PreviousTier = WeaponTier;
}

static function PreloadAssets(optional KFWeaponAttachment Spawned)
{
     local W_V_SealSqueal_Vet_Attachment WeaponAttachment;

     Super.PreloadAssets(Spawned);
	class'VetWeaponHelper'.static.PreloadVeterancyAttachmentAssets(Spawned, default.LoadedStateMaterialRefList, default.LoadedStateMaterialList);

     WeaponAttachment = W_V_SealSqueal_Vet_Attachment(Spawned);
     if (WeaponAttachment != None)
     {
          WeaponAttachment.LoadedStateMaterialList = default.LoadedStateMaterialList;
          WeaponAttachment.ApplyPlayerWeaponTier();
     }
}

static function bool UnloadAssets()
{
     Super.UnloadAssets();
	class'VetWeaponHelper'.static.UnloadAttachmentAssets(default.LoadedStateMaterialList);
	return true;
}

defaultproperties
{
     bNetNotify=true
     
     LoadedStateMaterialRefList(0)="KFTurbo.VetTiers.SealSqueal_Vet_3rd_Red_SHDR"
     LoadedStateMaterialRefList(1)="KFTurbo.VetTiers.SealSqueal_Vet_3rd_Green_SHDR"
     LoadedStateMaterialRefList(2)="KFTurbo.VetTiers.SealSqueal_Vet_3rd_Blue_SHDR"
     LoadedStateMaterialRefList(3)="KFTurbo.VetTiers.SealSqueal_Vet_3rd_Pink_SHDR"
     LoadedStateMaterialRefList(4)="KFTurbo.VetTiers.SealSqueal_Vet_3rd_Purple_SHDR"
     LoadedStateMaterialRefList(5)="KFTurbo.VetTiers.SealSqueal_Vet_3rd_Orange_SHDR"
     LoadedStateMaterialRefList(6)="KFTurbo.VetTiers.SealSqueal_Vet_3rd_Gold_SHDR"
     LoadedStateMaterialRefList(7)="KFTurbo.VetTiers.SealSqueal_Vet_3rd_Plat_SHDR"
     LoadedStateMaterialRefList(8)="KFTurbo.VetTiers.SealSqueal_Vet_3rd_Rainbow_SHDR"

     Skins(0)=Shader'KFTurbo.SealSqueal.SealSqueal_Vet_3rd_SHDR'
}
