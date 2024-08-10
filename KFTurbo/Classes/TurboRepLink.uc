class TurboRepLink extends LinkedReplicationInfo;

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
const PrideVariantID = "PRIDE";
const SMPVariantID = "SHOWME";

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

//This local player's variant list.
var array<WeaponVariantData> PlayerVariantList;

var KFTurboMut KFTurboMutator;
var KFPlayerController OwningController;
var KFPlayerReplicationInfo OwningReplicationInfo;
var String PlayerID;
var array<String> PlayerGroups;

var int FailureCount;
var bool bNeedsDestroy;
var bool bHasPerformedSetup;
var bool bHasPerformedVariantStatusUpdate;

replication
{
    reliable if (Role == ROLE_Authority)
        Client_Reliable_SetupComplete;
}

simulated function PreBeginPlay()
{
    Super.PreBeginPlay();

    if (Role == ROLE_Authority)
    {
        return;
    }

    if (OwningController == None)
    {
        OwningController = KFPlayerController(Level.GetLocalPlayerController());
    }

    if (OwningReplicationInfo == None)
    {
        OwningReplicationInfo = KFPlayerReplicationInfo(OwningController.PlayerReplicationInfo);
    }
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    Disable('Tick');
}

function CleanUpRepLink()
{
    bNeedsDestroy = true;
    Enable('Tick');
}

function IncrementFailureCounter()
{
    FailureCount++;
    if (FailureCount % 20 == 0)
    {
        log("WARNING FAILURE LIMIT REACHED " $ FailureCount $ " TIMES ON " $ string(Self) $ "WAITING FOR CPRL.", 'KFTurbo');
        if (FailureCount > 60)
        {
            CleanUpRepLink();
        }
    }
}

state RepSetup
{
    function Tick(float DeltaTime)
    {
        Global.Tick(DeltaTime);

        if (bNeedsDestroy)
        {
            Destroy();
        }
    }

Begin:
    if (Level.NetMode == NM_Client)
    {
        Stop;
    }

    FailureCount = 0;
    while (!IsClientPerkRepLinkReady())
    {
        IncrementFailureCounter();
        Sleep(0.5f);
    }

    Sleep(0.25f);

    if (!IsClientPerkRepLinkReady())
    {
        log ("CPRL Failed Completely!");
        stop;
    }
    
    if (NetConnection(OwningController.Player) == None)
    {
        UpdateVariantStatus();
    }
    else
    {
        Client_Reliable_SetupComplete();
    }

    Sleep(0.25f);

    if (!IsClientPerkRepLinkReady())
    {
        stop;
    }

    CachePlayerStats();
    GotoState('');
}

simulated function CachePlayerStats()
{
    local ClientPerkRepLink CPRL;

    if (OwningController == None)
    {
        return;
    }

    CPRL = class'ClientPerkRepLink'.static.FindStats(OwningController);
    
    if (CPRL == None)
    {
        return;
    }

    //Add way to cache perk values here and then provide bonuses to them later.
}

simulated function bool IsClientPerkRepLinkReady()
{
    local ClientPerkRepLink CPRL;

    if (bNeedsDestroy)
    {
        return false;
    }

    if (OwningController == None)
    {
        return false;
    }

    CPRL = class'ClientPerkRepLink'.static.FindStats(OwningController);

    if (CPRL == None)
    {
        return false;
    }

    if (Level.NetMode != NM_Client && CPRL.IsInState('RepSetup'))
    {
        return false;
    }

    return true;
}

simulated function InitializeRepSetup()
{
    GotoState('RepSetup');
}

simulated function SetupPlayerInfo()
{
    local int ShopIndex;
    local int VariantIndex;
    local ClientPerkRepLink CPRL;
    local class<KFWeaponPickup> WeaponPickup, VariantPickup;
    local int PlayerVariantListIndex, PlayerVariantListVariantIndex;
    local VariantWeapon VariantData;

    if (bHasPerformedSetup || OwningController == None)
    {
        return;
    }

    CPRL = class'ClientPerkRepLink'.static.FindStats(OwningController);

    bHasPerformedSetup = true;
    PlayerVariantList.Length = 0;

    for (ShopIndex = CPRL.ShopInventory.Length - 1; ShopIndex >= 0; ShopIndex--)
    {
        WeaponPickup = class<KFWeaponPickup>(CPRL.ShopInventory[ShopIndex].PC);

        if (WeaponPickup.default.VariantClasses.Length == 0)
        {
            continue;
        }

        PlayerVariantListIndex = PlayerVariantList.Length;
        PlayerVariantList.Insert(PlayerVariantListIndex, 1);

        PlayerVariantList[PlayerVariantListIndex].WeaponPickup = WeaponPickup;
    
        for (VariantIndex = 0; VariantIndex < WeaponPickup.default.VariantClasses.Length; VariantIndex++)
        {
            VariantPickup = class<KFWeaponPickup>(WeaponPickup.default.VariantClasses[VariantIndex]);

            if (VariantPickup == None)
            {
                continue;
            }

            VariantData.VariantClass = VariantPickup;
            SetupVariantWeaponEntry(VariantData);

            PlayerVariantListVariantIndex = PlayerVariantList[PlayerVariantListIndex].VariantList.Length;
            PlayerVariantList[PlayerVariantListIndex].VariantList.Insert(PlayerVariantListVariantIndex, 1);
            PlayerVariantList[PlayerVariantListIndex].VariantList[PlayerVariantListVariantIndex] = VariantData;
        }
    }
}

simulated function SetupVariantWeaponEntry(out VariantWeapon Entry)
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
    else if (IsGenericSteampunkSkin(Entry.VariantClass))
    {
        Entry.VariantID = SteampunkVariantID;
        Entry.ItemStatus = 255; //Flag Dr T's as awaiting DLC update.
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
    else
    {
        Entry.VariantID = DefaultID;
        Entry.ItemStatus = 0;
    }
}

//Refers to sticker types that are not considered "generic" and only intend on being implemented on one or two weapons.
simulated function bool AssignSpecialVariantID(out VariantWeapon Entry)
{
    switch (Entry.VariantClass)
    {
        case class'W_V_M4203_Retart_Pickup' :
            Entry.VariantID = RetartVariantID;
            Entry.ItemStatus = 0;
            break;
        case class'W_V_M4203_Scuddles_Pickup' :
            Entry.VariantID = ScuddlesVariantID;
            Entry.ItemStatus = 0;
            break;
        case class'W_V_M14_Cubic_Pickup' :
            Entry.VariantID = CubicVariantID;
            Entry.ItemStatus = 0;
            break;
        case class'W_V_M14_SMP_Pickup' :
        case class'W_V_AA12_SMP_Pickup' :
            Entry.VariantID = SMPVariantID;
            Entry.ItemStatus = 0;
            break;
        case class'W_V_M14_Pride_Pickup' :
            Entry.VariantID = PrideVariantID;
            Entry.ItemStatus = 0;
            break;
    }

    return Entry.VariantID != "";
}

simulated function UpdateVariantStatus()
{
    if (!IsClientPerkRepLinkReady())
    {
        return;
    }

    SetupPlayerInfo();

    if (bHasPerformedVariantStatusUpdate)
    {
        return;
    }

    bHasPerformedVariantStatusUpdate = true;
    Spawn(Class'TurboSteamStatsGet', Owner).Link = Self;
}

simulated function DebugVariantInfo(bool bFilterStatus)
{
    local int i, j;
    local string VariantSet;

    for(i = 0; i < PlayerVariantList.Length; i++)
    {
        VariantSet = "Pickup: " $ PlayerVariantList[i].WeaponPickup;

        for(j = 0; j < PlayerVariantList[i].VariantList.Length; j++)
        {
            if (bFilterStatus && PlayerVariantList[i].VariantList[j].ItemStatus != 0)
            {
                continue;
            }

            VariantSet = VariantSet $ " | " $ j $ ": " $ PlayerVariantList[i].VariantList[j].VariantClass $ " (" $ PlayerVariantList[i].VariantList[j].ItemStatus $ ")";
        }

        log(VariantSet, 'KFTurbo');
    }

    if (PlayerVariantList.Length == 0)
    {
        log("WARNING: PlayerVariantList was empty!", 'KFTurbo');
    }
}

simulated function Client_Reliable_SetupComplete()
{
    UpdateVariantStatus();
}

simulated function GetVariantsForWeapon(class<KFWeaponPickup> Pickup, out array<VariantWeapon> VariantList)
{
    local int i;
    
    for (i = 0; i < PlayerVariantList.Length; i++)
    {
        if (PlayerVariantList[i].WeaponPickup != Pickup)
        {
            continue;
        }

        VariantList = PlayerVariantList[i].VariantList;
        break;
    }
}

static function TurboRepLink GetTurboRepLink(PlayerReplicationInfo PRI)
{
    local LinkedReplicationInfo LRI;
    local TurboRepLink KFPLRI;

    if (PRI == None)
    {
        return None;
    }

    for (LRI = PRI.CustomReplicationInfo; LRI != None; LRI = LRI.NextReplicationInfo)
    {
        if (TurboRepLink(LRI) != None)
        {
            return TurboRepLink(LRI);
        }
    }

    foreach PRI.DynamicActors(class'TurboRepLink', KFPLRI)
    {
        if (KFPLRI.OwningReplicationInfo == PRI)
        {
            return KFPLRI;
        }
    }

    return None;
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
    bOnlyRelevantToOwner=True
    bAlwaysRelevant=False

    bHasPerformedSetup=false
    bHasPerformedVariantStatusUpdate=false
}
