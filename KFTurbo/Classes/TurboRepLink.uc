class TurboRepLink extends LinkedReplicationInfo
    dependson(TurboRepLinkSettings);

//This local player's variant list.
var array<TurboRepLinkSettings.WeaponVariantData> PlayerVariantList;

var KFTurboMut KFTurboMutator;
var KFPlayerController OwningController;
var KFPlayerReplicationInfo OwningReplicationInfo;
var String PlayerID;
var array<String> PlayerGroups;

var int WeaponIndex;
var int VariantIndex;

var int FailureCount;
var bool bHasPerformedSetup;
var bool bHasPerformedVariantStatusUpdate;

replication
{
    reliable if (Role == ROLE_Authority)
        Client_Reliable_SendVariant, Client_Reliable_SendComplete;
}

state RepSetup
{
Begin:
    if (Level.NetMode == NM_Client)
    {
        Stop;
    }

    Sleep(1.f);

    while (OwningController == None)
    {
        FailureCount++;
        if (FailureCount % 20 == 0)
        {
            log("WARNING FAILURE LIMIT REACHED " $ FailureCount $ " TIMES ON " $ string(Self) $ ".", 'KFTurbo');
        }

        Sleep(1.f);
    }

    SetupPlayerInfo();
    Sleep(1.f);
    
    if (NetConnection(OwningController.Player) == None)
    {
        UpdateVariantStatus();
        Stop;
    }

    for (WeaponIndex = 0; WeaponIndex < PlayerVariantList.Length; WeaponIndex++)
    {
        for (VariantIndex = 0; VariantIndex < PlayerVariantList[WeaponIndex].VariantList.Length; VariantIndex++)
        {
            Client_Reliable_SendVariant(PlayerVariantList[WeaponIndex].WeaponPickup, PlayerVariantList[WeaponIndex].VariantList[VariantIndex]);
        }
        Sleep(0.1f);
    }

    Client_Reliable_SendComplete();

    Sleep(1.f);
}

simulated function InitializeRepSetup()
{
    GotoState('RepSetup');
}

function SetupPlayerInfo()
{
    if (bHasPerformedSetup)
    {
        return;
    }

    bHasPerformedSetup = true;

    PlayerID = OwningController.GetPlayerIDHash();
    
	KFTurboMutator.InitializeRepLinkSettings();
    KFTurboMutator.RepLinkSettings.GeneratePlayerVariantData(PlayerID, PlayerVariantList);
}

simulated function UpdateVariantStatus()
{
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

        //log(VariantSet, 'KFTurbo');
    }

    if (PlayerVariantList.Length == 0)
    {
        //log("WARNING: PlayerVariantList was empty!", 'KFTurbo');
    }
}

simulated function Client_Reliable_SendVariant(class<KFWeaponPickup> Pickup, TurboRepLinkSettings.VariantWeapon Variant)
{
    local int i;

    for (i = 0; i < PlayerVariantList.Length; i++)
    {
        if (PlayerVariantList[i].WeaponPickup != Pickup)
        {
            continue;
        }

        PlayerVariantList[i].VariantList[PlayerVariantList[i].VariantList.Length] = Variant;
        return;
    }

    i = PlayerVariantList.Length;
    PlayerVariantList.Length = i + 1;

    PlayerVariantList[i].WeaponPickup = Pickup;
    PlayerVariantList[i].VariantList[0] = Variant;
}

simulated function Client_Reliable_SendComplete()
{
    UpdateVariantStatus();
}

simulated function GetVariantsForWeapon(class<KFWeaponPickup> Pickup, out array<TurboRepLinkSettings.VariantWeapon> VariantList)
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

defaultproperties
{
    bOnlyRelevantToOwner=True
    bAlwaysRelevant=False

    bHasPerformedSetup=false
    bHasPerformedVariantStatusUpdate=false
}
