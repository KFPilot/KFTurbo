//This class makes it easier for anyone extending KFTurbo to add weapon variants and have those variants show up in the trader just like ones built into KFTurbo.
//Can be set on a subclass of TurboBuyMenuSaleList via TurboBuyMenuSaleList::TurboBuyMenuSettingsClassString.
class TurboBuyMenuSettings extends Object;

var localized String HintDefault;
var localized String GoldDefault;
var localized String CamoDefault;
var localized String CyberDefault;
var localized String SteampunkDefault;
var localized String StickerDefault;

function Texture GetIconForPickup(String VariantID)
{
    switch (VariantID)
    {
        case "DEF":
            return Texture'KFTurbo.HUD.NoSkinIcon_D';
        case "GOLD":
            return Texture'KFTurbo.HUD.GoldIcon_D';
        case "CAMO":
            return Texture'KFTurbo.HUD.CamoIcon_D';
        case "TURBO":
            return Texture'KFTurbo.HUD.TurboIcon_D';
        case "VM":
            return Texture'KFTurbo.HUD.VMIcon_D';
        case "WEST":
            return Texture'KFTurbo.HUD.WestLondonIcon_D';
        case "RET":
            return Texture'KFTurbo.HUD.LevelIcon_D';
        case "SCUD":
            return Texture'KFTurbo.HUD.ScrubblesIcon_D';
        case "CUBIC":
            return Texture'KFTurbo.HUD.SkellIcon_D';
        case "SHOWME":
            return Texture'KFTurbo.HUD.ShowMeProIcon_D';
        case "CYB":
            return Texture'KFTurbo.HUD.CyberIcon_D';
        case "STP":
            return Texture'KFTurbo.HUD.SteampunkIcon_D';
        case "PRIDE":
            return Texture'KFTurbo.HUD.PrideIcon_D';
    }

    return Texture'KFTurbo.HUD.StickerIcon_D';
}

function String GetHintForPickup(String VariantID)
{
    switch (VariantID)
    {
        case "DEF":
            return HintDefault;
        case "GOLD":
            return GoldDefault;
        case "CAMO":
            return CamoDefault;
        case "CYB":
            return CyberDefault;
        case "STP":
            return SteampunkDefault;
        case "TURBO":
        case "VM":
        case "WEST":
        case "RET":
        case "SCUD":
        case "CUBIC":
        case "SHOWME":
        case "PRIDE":
            return StickerDefault;
    }
    
    return StickerDefault;
}

defaultproperties
{
    HintDefault = "Default"
    GoldDefault = "Gold"
    CamoDefault = "Camo"
    CyberDefault = "Cyber"
    SteampunkDefault = "Steampunk"
    StickerDefault = "Sticker"
}