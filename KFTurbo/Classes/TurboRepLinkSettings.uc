class TurboRepLinkSettings extends Object;

//User and Group configuration.
var editinline array<TurboRepLinkSettingsUser> UserList;
var editinline array<TurboRepLinkSettingsGroup> GroupList;

struct VariantWeapon
{
    var class<KFWeaponPickup> VariantClass;
    var String VariantID;
    var int ItemStatus;
};

struct WeaponVariantData
{
    var class<KFWeaponPickup> WeaponPickup;
    var array<VariantWeapon> VariantList;
};

// Built-in Variant Set Names:
//Common variants - accessible to all players.
const DefaultID = "DEF"; //All non-variants.
const GoldVariantID = "GOLD"; //Gold skins.
const CamoVariantID = "CAMO"; //Camo skins.
const TurboVariantID = "TURBO"; //KFTurbo sticker skins.
const VMVariantID = "VM"; //VM sticker skins.
const WLVariantID = "WEST"; //Westlondon sticker skins.
const CyberVariantID = "CYB"; //Cyber Weapon skins.
const SteampunkVariantID = "STP"; //Steampunk weapon skins.

//Special variants - accessible to specific players.
const RetartVariantID = "RET";
const ScuddlesVariantID = "SCUD";
const CubicVariantID = "CUBIC";
const SMPVariantID = "SHOWME";

function GeneratePlayerVariantData(String PlayerSteamID, out array<WeaponVariantData> PlayerVariantWeaponList)
{

}

//Setup a cache of all variant weapons and their associated IDs. This will prevent needing to refigure out what variants are available each time a player joins.
function Initialize()
{

}

static final function bool IsGenericGoldSkin(class<Pickup> PickupClass)
{
	return InStr(Caps(PickupClass), "_GOLD_") != -1;
}

static final function bool IsGenericCamoSkin(class<Pickup> PickupClass)
{
	return InStr(Caps(PickupClass), "_CAMO_") != -1;
}

static final function bool IsGenericTurboSkin(class<Pickup> PickupClass)
{
	return InStr(Caps(PickupClass), "_TURBO_") != -1;
}

static final function bool IsGenericVMSkin(class<Pickup> PickupClass)
{
	return InStr(Caps(PickupClass), "_VM_") != -1;
}

static final function bool IsGenericWestLondonSkin(class<Pickup> PickupClass)
{
	return InStr(Caps(PickupClass), "_WL_") != -1;
}

static final function bool IsGenericCyberSkin(class<Pickup> PickupClass)
{
	return InStr(Caps(PickupClass), "_CYBER_") != -1;
}

static final function bool IsGenericSteampunkSkin(class<Pickup> PickupClass)
{
	return InStr(Caps(PickupClass), "_STP_") != -1;
}

defaultproperties
{
    //Default group that gives all players access to a set weapon skins.
    Begin Object Class=TurboRepLinkSettingsGroup Name=RepLinkDefaultGroup
        DisplayName="DefaultGroup"
        bDefaultGroup=true
        VariantIDList(0)="DEF"
        VariantIDList(1)="GOLD"
        VariantIDList(2)="CAMO"
        VariantIDList(3)="TURBO"
        VariantIDList(4)="VM"
        VariantIDList(5)="WEST"
        VariantIDList(6)="CYB"
        VariantIDList(7)="STP"

    End Object
    GroupList(0)=TurboRepLinkSettingsGroup'KFTurbo.TurboRepLinkSettings.RepLinkDefaultGroup'

    Begin Object Class=TurboRepLinkSettingsUser Name=RepLinkTestUser
        PlayerSteamID="20b300195d48c2ccc2651885cfea1a2f"
        DisplayName="Retard"
        VariantIDList(0)="RET"
        VariantIDList(1)="SCUD"
        VariantIDList(2)="CUBIC"
        VariantIDList(3)="SHOWME"
    End Object
    UserList(0)=TurboRepLinkSettingsUser'KFTurbo.TurboRepLinkSettings.RepLinkTestUser'

}