//Killing Floor Turbo TurboRepLinkHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboRepLinkHandler extends Info;

var KFTurboMut KFTurboMutator;
var array<ServerStStats> PendingReplicationLinkList;

event PostBeginPlay()
{
    Super.PostBeginPlay();
}

function OnServerStatsAdded(ServerStStats Stats)
{
    PendingReplicationLinkList[PendingReplicationLinkList.Length] = Stats;
    SetTimer(0.5f, false);
}

function bool IsClientReady(KFPlayerController PlayerController)
{
    if (PlayerController.SteamStatsAndAchievements == None)
	{
		return false;
	}

	if (SRStatsBase(PlayerController.SteamStatsAndAchievements) == None)
	{
		return false;
	}

	if (!SRStatsBase(PlayerController.SteamStatsAndAchievements).bStatsReadyNow)
	{
		return false;
	}

    return true;
}

function Timer()
{
    local int i;
    local KFPlayerController CurrentPlayerController;
    local LinkedReplicationInfo LastLinkedReplicationInfo;
    local TurboRepLink NewRepLink;
    local array<LinkedReplicationInfo> NewRepLinkList;

    if (KFTurboMutator == None)
    {
        foreach Level.AllActors( class'KFTurboMut', KFTurboMutator )
            break;
    }
    
    for (i = (PendingReplicationLinkList.Length - 1); i >= 0; --i)
    {
        if (PendingReplicationLinkList[i] == None)
        {
            PendingReplicationLinkList.Remove(i, 1);
            continue;
        }

        CurrentPlayerController = KFPlayerController(PendingReplicationLinkList[i].Owner);

        if (CurrentPlayerController == none)
        {
            continue;
        }

        if (CurrentPlayerController.PlayerReplicationInfo == none)
        {
            continue;
        }

        if (!IsClientReady(CurrentPlayerController))
        {
            continue;
        }

        LastLinkedReplicationInfo = CurrentPlayerController.PlayerReplicationInfo.CustomReplicationInfo;
        NewRepLink = Spawn(class'TurboRepLink', CurrentPlayerController);
        NewRepLink.KFTurboMutator = KFTurboMutator;
        NewRepLink.OwningController = CurrentPlayerController;
        NewRepLink.OwningReplicationInfo = KFPlayerReplicationInfo(CurrentPlayerController.PlayerReplicationInfo);

        if (LastLinkedReplicationInfo == none)
        {
            CurrentPlayerController.PlayerReplicationInfo.CustomReplicationInfo = NewRepLink;
        }
        else
        {
            while (LastLinkedReplicationInfo.NextReplicationInfo != none)
            {
                LastLinkedReplicationInfo = LastLinkedReplicationInfo.NextReplicationInfo;
            }

            LastLinkedReplicationInfo.NextReplicationInfo = NewRepLink;
        }

        NewRepLinkList[NewRepLinkList.Length] = NewRepLink;
        PendingReplicationLinkList.Remove(i, 1);
    }

    for(i = (NewRepLinkList.Length - 1); i>=0; --i)
    {
        TurboRepLink(NewRepLinkList[i]).InitializeRepSetup();
    }

    if (PendingReplicationLinkList.Length != 0)
    {
        SetTimer(0.5f, false);
    }
}

defaultproperties
{

}