class TurboRepLinkSettingsImpl extends TurboRepLinkSettings;

//Mutator context.
var ServerPerksMut ServerPerksMut;
var KFTurboMut KFTurboMutator;

var array<WeaponVariantData> VariantWeaponList;


static final function DebugLog(string DebugString)
{
    log(DebugString, 'KFTurbo');
}

//For the given PlayerSteamID, provides back a list of all the Variant IDs they have access to.
function GetPlayerVariantIDList(String PlayerSteamID, out array<String> PlayerVariantIDList)
{
    local int PlayerIndex, GroupPlayerIDIndex;
    local int VariantIndex;
    local int GroupIndex;
    local TurboRepLinkSettingsUser UserObject;
    local TurboRepLinkSettingsGroup GroupObject;
    local bool bFoundGroupID;

    //DebugLog("| - | - GetPlayerVariantIDList");
    PlayerVariantIDList.Length = 0;

    for (PlayerIndex = 0; PlayerIndex < UserList.Length; PlayerIndex++)
    {
        if (UserList[PlayerIndex].PlayerSteamID != PlayerSteamID)
        {
            continue;
        }

        UserObject = UserList[PlayerIndex];
        PlayerVariantIDList = UserObject.VariantIDList;

        for (VariantIndex = 0; VariantIndex < PlayerVariantIDList.Length; VariantIndex++)
        {
            //DebugLog("| - | - | - (Adding user variant "$PlayerVariantIDList[VariantIndex]$")");
        }

        break;
    }

    for (GroupIndex = 0; GroupIndex < GroupList.Length; GroupIndex++)
    {
        GroupObject = GroupList[GroupIndex];

        if (!GroupObject.bDefaultGroup)
        {
            bFoundGroupID = false;

            for (GroupPlayerIDIndex = 0; GroupPlayerIDIndex < GroupObject.PlayerSteamIDList.Length; GroupPlayerIDIndex++)
            {
                if (PlayerSteamID == GroupObject.PlayerSteamIDList[GroupPlayerIDIndex])
                {
                    bFoundGroupID = true;
                    break;
                }
            }

            if (!bFoundGroupID)
            {
                continue;
            }
        }

        AppendPlayerVariantIDList(PlayerVariantIDList, GroupObject.VariantIDList);
    }
}

static final function AppendPlayerVariantIDList(out array<String> PlayerVariantIDList, array<String> NewVariantIDList)
{
    local int VariantIDIndex, PlayerVariantIDIndex;
    local bool bAlreadyInPlayerList;

    for (VariantIDIndex = NewVariantIDList.Length - 1; VariantIDIndex >= 0; VariantIDIndex--)
    {
        bAlreadyInPlayerList = false;
        for (PlayerVariantIDIndex = PlayerVariantIDList.Length - 1; PlayerVariantIDIndex >= 0; PlayerVariantIDIndex--)
        {
            if (NewVariantIDList[VariantIDIndex] == PlayerVariantIDList[PlayerVariantIDIndex])
            {
                bAlreadyInPlayerList = true;
                break;
            }
        }

        if (bAlreadyInPlayerList)
        {
            continue;
        }

        //DebugLog("| - | - | - (Adding group variant "$NewVariantIDList[VariantIDIndex]$")");
        PlayerVariantIDList[PlayerVariantIDList.Length] = NewVariantIDList[VariantIDIndex];
    }
}

function GeneratePlayerVariantData(String PlayerSteamID, out array<WeaponVariantData> PlayerVariantWeaponList)
{
    local array<String> PlayerVariantIDList;
    local int VariantWeaponListIndex;
    local int VariantIndex;
    local int PlayerVariantIDIndex;
    local class<KFWeaponPickup> WeaponPickup;
    local array<VariantWeapon> PlayerVariantList;

    StopWatch(false);

    GetPlayerVariantIDList(PlayerSteamID, PlayerVariantIDList);

    //DebugLog("Just called KFTurboRepLinkSettings::GetPlayerVariantIDList. Printing out variant ID access.");
    for (VariantWeaponListIndex = PlayerVariantIDList.Length - 1; VariantWeaponListIndex >= 0; VariantWeaponListIndex--)
    {
        //DebugLog("| - "$ PlayerVariantIDList[VariantWeaponListIndex]);
    }

    PlayerVariantWeaponList.Length = 0;

    for (VariantWeaponListIndex = VariantWeaponList.Length - 1; VariantWeaponListIndex >= 0; VariantWeaponListIndex--)
    {
        PlayerVariantList.Length = 0;

        WeaponPickup = VariantWeaponList[VariantWeaponListIndex].WeaponPickup;
    
        for (VariantIndex = VariantWeaponList[VariantWeaponListIndex].VariantList.Length - 1; VariantIndex >= 0; VariantIndex--)
        {
            for (PlayerVariantIDIndex = PlayerVariantIDList.Length - 1; PlayerVariantIDIndex >= 0; PlayerVariantIDIndex--)
            {
                if (VariantWeaponList[VariantWeaponListIndex].VariantList[VariantIndex].VariantID == PlayerVariantIDList[PlayerVariantIDIndex])
                {
                    PlayerVariantList.Insert(PlayerVariantList.Length, 1);
                    PlayerVariantList[PlayerVariantList.Length - 1] = VariantWeaponList[VariantWeaponListIndex].VariantList[VariantIndex];
                }
            }
        }

        PlayerVariantWeaponList.Insert(PlayerVariantWeaponList.Length, 1);
        PlayerVariantWeaponList[PlayerVariantWeaponList.Length - 1].WeaponPickup = WeaponPickup;
        PlayerVariantWeaponList[PlayerVariantWeaponList.Length - 1].VariantList = PlayerVariantList;
    }

    StopWatch(true);
    log("The above time is KFTurboRepLinkSettings::GeneratePlayerVariantData duration.", 'KFTurbo');
}

//Setup a cache of all variant weapons and their associated IDs. This will prevent needing to refigure out what variants are available each time a player joins.
function Initialize()
{
    local int LoadInventoryIndex, LoadInventoryVariantIndex, VariantWeaponListIndex;
    local int NewVariantIndex;
    local class<KFWeaponPickup> KFWeaponPickupClass, KFWeaponVariantPickupClass;
    local VariantWeapon VariantWeaponEntry;
    local bool bAlreadyInitializedWeapon;

    StopWatch(false);

    KFTurboMutator = KFTurboMut(Outer);

    foreach KFTurboMutator.Level.AllActors( class'ServerPerksMut', ServerPerksMut )
		break;

    for (LoadInventoryIndex = ServerPerksMut.LoadInventory.Length - 1;  LoadInventoryIndex >= 0; LoadInventoryIndex--)
    {
        KFWeaponPickupClass = class<KFWeaponPickup>(ServerPerksMut.LoadInventory[LoadInventoryIndex]);

        if (KFWeaponPickupClass == none || KFWeaponPickupClass.default.VariantClasses.Length == 0)
        {
            continue;
        }

        bAlreadyInitializedWeapon = false;
        for (VariantWeaponListIndex = 0; VariantWeaponListIndex < VariantWeaponList.Length; VariantWeaponListIndex++)
        {
            if (VariantWeaponList[VariantWeaponListIndex].WeaponPickup == KFWeaponPickupClass)
            {
                bAlreadyInitializedWeapon = true;
                break;
            }
        }

        if (bAlreadyInitializedWeapon)
        {
            continue;
        }

        VariantWeaponList.Insert(VariantWeaponList.Length, 1);
        NewVariantIndex = VariantWeaponList.Length - 1;

        VariantWeaponList[NewVariantIndex].WeaponPickup = KFWeaponPickupClass;
        
        //DebugLog("KFTurboRepLinkSettings::Initialize | Generating cache for: "$KFWeaponPickupClass$" (Has "$KFWeaponPickupClass.default.VariantClasses.Length$" variants.)");

        for (LoadInventoryVariantIndex = KFWeaponPickupClass.default.VariantClasses.Length - 1; LoadInventoryVariantIndex >= 0; LoadInventoryVariantIndex--)
        {
            KFWeaponVariantPickupClass = class<KFWeaponPickup>(KFWeaponPickupClass.default.VariantClasses[LoadInventoryVariantIndex]);

            //DebugLog("KFTurboRepLinkSettings::Initialize | |- Trying variant "$KFWeaponVariantPickupClass);

            if (KFWeaponVariantPickupClass == none)
            {
                continue;
            }

            if (KFWeaponVariantPickupClass == KFWeaponPickupClass)
            {
                VariantWeaponEntry.VariantClass = KFWeaponVariantPickupClass;
                VariantWeaponEntry.VariantID = DefaultID;
                VariantWeaponEntry.ItemStatus = 0; //Don't bother?
                VariantWeaponList[NewVariantIndex].VariantList[VariantWeaponList[NewVariantIndex].VariantList.Length] = VariantWeaponEntry;
                continue;
            }
            else
            {
                VariantWeaponEntry.VariantClass = KFWeaponVariantPickupClass;
                SetupVariantWeaponEntry(VariantWeaponEntry);
                VariantWeaponList[NewVariantIndex].VariantList[VariantWeaponList[NewVariantIndex].VariantList.Length] = VariantWeaponEntry;
            }

            //DebugLog("KFTurboRepLinkSettings::Initialize | | |- Result: VariantID "$VariantWeaponEntry.VariantID$" | Status "$VariantWeaponEntry.ItemStatus);
        }
    }

    StopWatch(true);
    log("The above time is KFTurboRepLinkSettings::Initialize duration.", 'KFTurbo');
}

function SetupVariantWeaponEntry(out VariantWeapon Entry)
{
    Entry.VariantID = "";

    if (AssignSpecialVariantID(Entry))
    {
        return;
    }

    if (IsGenericGoldSkin(Entry.VariantClass))
    {
        Entry.VariantID = GoldVariantID;
        Entry.ItemStatus = 255; //Flag Gold weapons as awaiting DLC update.
    }
    else if (IsGenericCamoSkin(Entry.VariantClass))
    {
        Entry.VariantID = CamoVariantID;
        Entry.ItemStatus = 255; //Flag Camo weapons as awaiting DLC update.
    }
    else if (IsGenericTurboSkin(Entry.VariantClass))
    {
        Entry.VariantID = TurboVariantID;
        Entry.ItemStatus = 0;
    }
    else if (IsGenericVMSkin(Entry.VariantClass))
    {
        Entry.VariantID = VMVariantID;
        Entry.ItemStatus = 0;
    }
    else if (IsGenericWestLondonSkin(Entry.VariantClass))
    {
        Entry.VariantID = WLVariantID;
        Entry.ItemStatus = 0;
    }
    else if (IsGenericCyberSkin(Entry.VariantClass))
    {
        Entry.VariantID = CyberVariantID;
        Entry.ItemStatus = 0;
    }
    else if (IsGenericSteamPunkSkin(Entry.VariantClass))
    {
        Entry.VariantID = SteampunkVariantID;
        Entry.ItemStatus = 0;
    }
}

function bool AssignSpecialVariantID(out VariantWeapon Entry)
{
    switch (Entry.VariantClass)
    {
        case class'W_V_M4203_Retart_Pickup' :
            Entry.VariantID = RetartVariantID;
            break;
        case class'W_V_M4203_Scuddles_Pickup' :
            Entry.VariantID = ScuddlesVariantID;
            break;
        case class'W_V_M14_Cubic_Pickup' :
            Entry.VariantID = CubicVariantID;
            break;
        case class'W_V_M14_SMP_Pickup' :
        case class'W_V_AA12_SMP_Pickup' :
            Entry.VariantID = SMPVariantID;
            break;
    }
    return Entry.VariantID != "";
}

defaultproperties
{
    //Default group that gives all players access to a set weapon skins.
    Begin Object Class=TurboRepLinkSettingsGroup Name=RepLinkDefaultGroup
        DisplayName="Default"
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
    GroupList(0)=TurboRepLinkSettingsGroup'KFTurboServer.TurboRepLinkSettingsImpl.RepLinkDefaultGroup'

    Begin Object Class=TurboRepLinkSettingsGroup Name=RepLinkContributorGroup
        DisplayName="Contributor"
        bDefaultGroup=false
        PlayerSteamIDList(0)=76561198042213175
        PlayerSteamIDList(1)=76561198071841818
        PlayerSteamIDList(2)=76561197986596577
        VariantIDList(0)="RET"
        VariantIDList(1)="SCUD"
        VariantIDList(2)="CUBIC"
        VariantIDList(3)="SHOWME"
    End Object
    GroupList(1)=TurboRepLinkSettingsGroup'KFTurboServer.TurboRepLinkSettingsImpl.RepLinkContributorGroup'
}