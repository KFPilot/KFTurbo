//Killing Floor Turbo VetWeaponHelper
//Anti redundancy class. Handles skin logic for vet weapons.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VetWeaponHelper extends Object;

var array<Material> VeterancyColorTextureList;

static final function byte GetPlayerWeaponTier(Pawn Pawn, class<TurboVeterancyTypes> VeterancyClass)
{
    local ClientPerkRepLink CPRL;
    local TurboRepLink TRL;
    local int Index;

    if (Pawn == None || TurboPlayerController(Pawn.Controller) == None)
    {
        return 0;
    }

    CPRL = TurboPlayerController(Pawn.Controller).GetClientPerkRepLink();

    if (CPRL == None)
    {
        return 0;
    }

	for(Index = 0; Index < CPRL.CachePerks.Length; Index++)
	{
		if (CPRL.CachePerks[Index].PerkClass == VeterancyClass)
		{
            TRL = TurboPlayerController(Pawn.Controller).GetTurboRepLink();

            if (TRL == None)
            {
                return VeterancyClass.static.GetPerkTier(CPRL.CachePerks[Index].CurrentLevel - 1);
            }
            
            return Min(VeterancyClass.static.GetPerkTier(CPRL.CachePerks[Index].CurrentLevel - 1), TRL.GetVeterancyTierPreference(VeterancyClass));
		}
	}

    return 0;
}

static final function UpdateWeaponAttachmentTier(KFWeaponAttachment Attachment, byte WeaponTier, byte PreviousWeaponTier, array<string> SkinRefList, out array<Material> LoadedSkinList)
{
    if (Attachment == None || Attachment.bDeleteMe || Attachment.Level.NetMode == NM_DedicatedServer)
    {
        return;
    }

    if (WeaponTier == PreviousWeaponTier)
    {
        return;
    }

    //Last chance attempt to load veterancy weapon skins.
    if (LoadedSkinList.Length == 0)
    {
        PreloadVeterancyAttachmentAssets(Attachment, SkinRefList, LoadedSkinList);

        if (LoadedSkinList.Length == 0)
        {
            return;
        }
    }

    WeaponTier = Clamp(WeaponTier, 0, LoadedSkinList.Length);

    if (WeaponTier == PreviousWeaponTier)
    {
        return;
    }

    Attachment.Skins[0] = LoadedSkinList[WeaponTier];
}

static final function PreloadVeterancyAttachmentAssets(KFWeaponAttachment Spawned, array<string> SkinRefList, out array<Material> LoadedSkinList)
{
    local int Index;

    LoadedSkinList.Length = SkinRefList.Length;
	for (Index = 0; Index < SkinRefList.Length; Index++)
	{
        if (LoadedSkinList[Index] != None)
        {
            continue;
        }

        LoadedSkinList[Index] = Material(DynamicLoadObject(SkinRefList[Index], class'Material'));
	}
}

static final function UnloadAttachmentAssets(out array<Material> LoadedSkinList)
{
    LoadedSkinList.Length = 0;
}

static final function UpdateWeaponSkin(KFWeapon Weapon, byte WeaponTier, array<int> SkinList)
{
    local int Index;

    if (Weapon == None || Weapon.Level.NetMode == NM_DedicatedServer)
    {
        return;
    }

    if (Weapon.Skins.Length == 0)
    {
        return;
    }

    if (SkinList.Length == 0)
    {
        if (Shader(Weapon.Skins[0]) != None)
        {
            Shader(Weapon.Skins[0]).SelfIllumination = default.VeterancyColorTextureList[WeaponTier];
        }

        return;
    }

    for (Index = SkinList.Length - 1; Index >= 0; Index--)
    {
        if (Shader(Weapon.Skins[Index]) == None)
        {
            continue;
        }

        Shader(Weapon.Skins[Index]).SelfIllumination = default.VeterancyColorTextureList[WeaponTier];
    }
}

defaultproperties
{
    VeterancyColorTextureList(0)=Texture'KFTurbo.Vet.VetRed_D'
    VeterancyColorTextureList(1)=Texture'KFTurbo.Vet.VetGreen_D'
    VeterancyColorTextureList(2)=Texture'KFTurbo.Vet.VetBlue_D'
    VeterancyColorTextureList(3)=Texture'KFTurbo.Vet.VetPink_D'
    VeterancyColorTextureList(4)=Texture'KFTurbo.Vet.VetPurple_D'
    VeterancyColorTextureList(5)=Texture'KFTurbo.Vet.VetOrange_D'
    VeterancyColorTextureList(6)=Texture'KFTurbo.Vet.VetGold_D'
    VeterancyColorTextureList(7)=Texture'KFTurbo.Vet.VetPlatinum_D'
    VeterancyColorTextureList(8)=TexScaler'KFTurbo.Vet.Rainbow_SCLR'
}