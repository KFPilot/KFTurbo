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
    SetTimer(0.01f, false);
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
    
    for(i = (PendingReplicationLinkList.Length - 1); i>=0; --i)
    {
        CurrentPlayerController = KFPlayerController(PendingReplicationLinkList[i].Owner);

        if (CurrentPlayerController == none)
        {
            continue;
        }

        if (CurrentPlayerController.PlayerReplicationInfo == none)
        {
            continue;
        }

        LastLinkedReplicationInfo = CurrentPlayerController.PlayerReplicationInfo.CustomReplicationInfo;

        if (LastLinkedReplicationInfo == none)
        {
            NewRepLink = Spawn(class'TurboRepLink', CurrentPlayerController);
            NewRepLink.KFTurboMutator = KFTurboMutator;
            NewRepLink.OwningController = CurrentPlayerController;
            NewRepLink.OwningReplicationInfo = KFPlayerReplicationInfo(CurrentPlayerController.PlayerReplicationInfo);

            CurrentPlayerController.PlayerReplicationInfo.CustomReplicationInfo = NewRepLink;
        }
        else
        {
            while (LastLinkedReplicationInfo.NextReplicationInfo != none)
            {
                LastLinkedReplicationInfo = LastLinkedReplicationInfo.NextReplicationInfo;
            }

            NewRepLink = Spawn(class'TurboRepLink', CurrentPlayerController);
            NewRepLink.KFTurboMutator = KFTurboMutator;
            NewRepLink.OwningController = CurrentPlayerController;
            NewRepLink.OwningReplicationInfo = KFPlayerReplicationInfo(CurrentPlayerController.PlayerReplicationInfo);

            LastLinkedReplicationInfo.NextReplicationInfo = NewRepLink;
        }

        NewRepLinkList[NewRepLinkList.Length] = NewRepLink;
    }

    PendingReplicationLinkList.Length = 0;

    for(i = (NewRepLinkList.Length - 1); i>=0; --i)
    {
        TurboRepLink(NewRepLinkList[i]).InitializeRepSetup();
    }
}

defaultproperties
{

}