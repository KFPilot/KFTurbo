//Killing Floor Turbo W_V_DualDeagle_Vet_Attachment
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_DualDeagle_Vet_Attachment extends WeaponDualDeagleAttachment;

var byte WeaponTier, PreviousTier;

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
	WeaponTier = class'VetWeaponHelper'.static.GetPlayerWeaponTier(Pawn(Owner), class'V_Sharpshooter');
	UpdateWeaponTier(WeaponTier);
}

function SetWeaponTier(byte NewWeaponTier)
{
	WeaponTier = NewWeaponTier;
	UpdateWeaponTier(NewWeaponTier);
}

simulated function UpdateWeaponTier(byte NewWeaponTier)
{
	//There's some issue where dualie PreloadAssets doesn't seem to get called... so check if materials aren't loaded and manually load them here.
	if (Level.NetMode != NM_DedicatedServer && class'W_V_Deagle_Vet_Attachment'.default.LoadedStateMaterialList.Length == 0)
	{
		class'VetWeaponHelper'.static.PreloadVeterancyAttachmentAssets(Self, class'W_V_Deagle_Vet_Attachment'.default.LoadedStateMaterialRefList, class'W_V_Deagle_Vet_Attachment'.default.LoadedStateMaterialList);
	}

	class'VetWeaponHelper'.static.UpdateWeaponAttachmentTier(Self, NewWeaponTier, PreviousTier, class'W_V_Deagle_Vet_Attachment'.default.LoadedStateMaterialRefList, class'W_V_Deagle_Vet_Attachment'.default.LoadedStateMaterialList);
	PreviousTier = WeaponTier;
}

defaultproperties
{
	bNetNotify=true
	PreviousTier=255
	
	Skins(0)=Shader'KFTurbo.Vet.Handcannon_Vet_3rd_SHDR'
}