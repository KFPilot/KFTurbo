//Killing Floor Turbo TurboRepLink
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboRepLink extends LinkedReplicationInfo
    dependson(TurboVeterancyTypes);

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
const VeterancyVariantID = "VET"; //Neon weapon (Veterancy weapons) skins.
const DarkCamoVariantID = "DARKCAMO"; //Dark camo skins.
const FoundryVariantID = "FOUNDRY"; //Foundry sticker skins.
const BioticsVariantID = "BIOTICS"; //Biotics Lab sticker skins.

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
var bool bAwaitingDestroy;
var bool bReceivedSetupComplete; //Set to true on client receiving Client_Reliable_SetupComplete().
var bool bHasPerformedSetup;
var bool bHasPerformedVariantStatusUpdate;

struct VeterancyTierPreference
{
	var class<TurboVeterancyTypes> PerkClass;
	var int TierPreference;
};
var array<VeterancyTierPreference> VeterancyTierPreferenceList;

replication
{
    reliable if (Role == ROLE_Authority)
        Client_Reliable_SetupComplete;
    reliable if (Role < ROLE_Authority)
        ServerSetVeterancyTierPreference;
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

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    Disable('Tick');
}

function IncrementFailureCounter()
{
    FailureCount++;
    if (FailureCount % 30 == 0)
    {
        log("WARNING FAILURE LIMIT AT " $ FailureCount $ " TIMES ON " $ string(Self) $ "WAITING FOR CPRL.", 'KFTurbo');
        if (FailureCount > 60)
        {
            bAwaitingDestroy = true;
            Enable('Tick');
        }
    }
}

//Pretty much identical to Server Perks' RepLinkBroken setup.
simulated function RepLinkBroken()
{
    if (bAwaitingDestroy)
    {
        log("AWAITING DESTROY...", 'KFTurbo');
        return;
    }
    
    log("CLIENT DETECTED TURBOREPLINK WAS BROKEN.", 'KFTurbo');
    Enable('Tick');
    Tick(0.f);
}

simulated function Tick( float DeltaTime )
{
	local PlayerController PC;
	local LinkedReplicationInfo L;

    if (bAwaitingDestroy)
    {
        log("WARNING FAILURE LIMIT REACHED " $ FailureCount $ " TIMES ON " $ string(Self) $ "WAITING FOR CPRL. DESTROYING TRL", 'KFTurbo');
        Destroy();
        return;
    }

	if (Level.NetMode == NM_DedicatedServer)
	{
		Disable('Tick');
		return;
	}

	PC = Level.GetLocalPlayerController();
	
    if (Level.NetMode != NM_Client && PC != Owner)
	{
		Disable('Tick');
		return;
	}

	if (PC.PlayerReplicationInfo == None)
    {
        return;
    }
    
	Disable('Tick');

	if (PC.PlayerReplicationInfo.CustomReplicationInfo != None)
	{
        // Make sure not already added.
		for (L = PC.PlayerReplicationInfo.CustomReplicationInfo; L != None; L = L.NextReplicationInfo)
        {
			if (L == Self)
            {
				return;
            }
        }

        // Add to the end of the chain.
		NextReplicationInfo = None;
		for(L = PC.PlayerReplicationInfo.CustomReplicationInfo; L != None; L = L.NextReplicationInfo )
        {
			if (L.NextReplicationInfo == None)
			{
				L.NextReplicationInfo = Self;

                if (bReceivedSetupComplete)
                {
                    OnSetupComplete();
                }
				return;
			}
        }
	}

	PC.PlayerReplicationInfo.CustomReplicationInfo = Self;

    if (bReceivedSetupComplete)
    {
        OnSetupComplete();
    }
}

state RepSetup
{
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
        OnSetupComplete();
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
    
    GotoState('');
}

simulated function bool IsClientPerkRepLinkReady()
{
    local ClientPerkRepLink CPRL;

    if (bAwaitingDestroy)
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
    else if (IsGenericVeterancySkin(Entry.VariantClass))
    {
        Entry.VariantID = VeterancyVariantID;
        Entry.ItemStatus = 0;
    }
    else if (IsGenericDarkCamoSkin(Entry.VariantClass))
    {
        Entry.VariantID = DarkCamoVariantID;
        Entry.ItemStatus = 0;
    }
    else if (IsGenericFoundrySkin(Entry.VariantClass))
    {
        Entry.VariantID = FoundryVariantID;
        Entry.ItemStatus = 0;
    }
    else if (IsGenericBioticsSkin(Entry.VariantClass))
    {
        Entry.VariantID = BioticsVariantID;
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

    if (OwningController != None && Viewport(OwningController.Player) != None)
    {
        SetupPlayerInfo();
    }
    else
    {
        bHasPerformedSetup = true;
    }

    if (bHasPerformedVariantStatusUpdate)
    {
        return;
    }

    bHasPerformedVariantStatusUpdate = true;

    if (OwningController != None && Viewport(OwningController.Player) != None)
    {
        Spawn(Class'TurboSteamStatsGet', Owner).Link = Self;
    }
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
    bReceivedSetupComplete = true;
    OnSetupComplete();
}

//Can be called multiple times if RepLinkBroken() is called.
simulated function OnSetupComplete()
{
    UpdateVariantStatus();
    
    if (TurboPlayerController(OwningController).TurboInteraction != None)
    {
        TurboPlayerController(OwningController).TurboInteraction.InitializeTurboInteraction();
    }
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

static function TurboRepLink FindTurboRepLink(PlayerController PlayerController)
{
    local LinkedReplicationInfo LRI;
    local TurboRepLink TRL;

    if (PlayerController == None)
    {
        return None;
    }

	if (PlayerController.PlayerReplicationInfo == None)
	{
		foreach PlayerController.DynamicActors(Class'TurboRepLink', TRL)
        {
			if (TRL.Owner == PlayerController || (TRL.Owner == None && TRL.OwningController == PlayerController))
			{
                TRL.SetOwner(PlayerController);
				TRL.RepLinkBroken();
				return TRL;
			}
        }

		return None;
	}

    for (LRI = PlayerController.PlayerReplicationInfo.CustomReplicationInfo; LRI != None; LRI = LRI.NextReplicationInfo)
    {
        if (TurboRepLink(LRI) != None)
        {
            return TurboRepLink(LRI);
        }
    }

    foreach PlayerController.DynamicActors(class'TurboRepLink', TRL)
    {
        if (TRL.Owner == PlayerController || (TRL.Owner == None && TRL.OwningController == PlayerController))
        {
            TRL.SetOwner(PlayerController);
            TRL.RepLinkBroken();
            return TRL;
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

static final function bool IsGenericVeterancySkin(class<Pickup> PickupClass)
{
	return InStr(Caps(PickupClass), "_VET_") != -1;
}

static final function bool IsGenericDarkCamoSkin(class<Pickup> PickupClass)
{
	return InStr(Caps(PickupClass), "_DARKCAMO_") != -1;
}

static final function bool IsGenericFoundrySkin(class<Pickup> PickupClass)
{
	return InStr(Caps(PickupClass), "_FOUNDRY_") != -1;
}

static final function bool IsGenericBioticsSkin(class<Pickup> PickupClass)
{
	return InStr(Caps(PickupClass), "_BIOTICS_") != -1;
}

function ServerSetVeterancyTierPreference(class<TurboVeterancyTypes> PerkClass, int TierPreference)
{
    if (Role == ROLE_Authority)
    {
        SetVeterancyTierPreference(PerkClass, TierPreference);
    }
}

simulated function SetVeterancyTierPreference(class<TurboVeterancyTypes> PerkClass, int TierPreference)
{
    if (VeterancyTierPreferenceList.Length == 0)
    {
        VeterancyTierPreferenceList.Length = class'TurboVeterancyTypes'.static.GetMaxTier();
    }

	switch(PerkClass)
	{
		case class'V_FieldMedic':
			VeterancyTierPreferenceList[0].TierPreference = TierPreference;
			break;
		case class'V_SupportSpec':
			VeterancyTierPreferenceList[1].TierPreference = TierPreference;
			break;
		case class'V_Sharpshooter':
			VeterancyTierPreferenceList[2].TierPreference = TierPreference;
			break;
		case class'V_Commando':
			VeterancyTierPreferenceList[3].TierPreference = TierPreference;
			break;
		case class'V_Berserker':
			VeterancyTierPreferenceList[4].TierPreference = TierPreference;
			break;
		case class'V_Firebug':
			VeterancyTierPreferenceList[5].TierPreference = TierPreference;
			break;
		case class'V_Demolitions':
			VeterancyTierPreferenceList[6].TierPreference = TierPreference;
			break;
	}

    if (Role != ROLE_Authority)
    {
        ServerSetVeterancyTierPreference(PerkClass, TierPreference);
    }
}

simulated function int GetVeterancyTierPreference(class<TurboVeterancyTypes> PerkClass)
{
    if (VeterancyTierPreferenceList.Length == 0)
    {
        return class'TurboVeterancyTypes'.static.GetMaxTier();
    }

	switch(PerkClass)
	{
		case class'V_FieldMedic':
			return VeterancyTierPreferenceList[0].TierPreference;
		case class'V_SupportSpec':
			return VeterancyTierPreferenceList[1].TierPreference;
		case class'V_Sharpshooter':
			return VeterancyTierPreferenceList[2].TierPreference;
		case class'V_Commando':
			return VeterancyTierPreferenceList[3].TierPreference;
		case class'V_Berserker':
			return VeterancyTierPreferenceList[4].TierPreference;
		case class'V_Firebug':
			return VeterancyTierPreferenceList[5].TierPreference;
		case class'V_Demolitions':
			return VeterancyTierPreferenceList[6].TierPreference;
	}

	return class'TurboVeterancyTypes'.static.GetMaxTier();
}

defaultproperties
{
    bOnlyRelevantToOwner=True
    bAlwaysRelevant=False
    NetUpdateFrequency=0.1f

    bReceivedSetupComplete=false;
    bHasPerformedSetup=false
    bAwaitingDestroy=false
    bHasPerformedVariantStatusUpdate=false
}
