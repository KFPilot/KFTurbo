//Killing Floor Turbo CardGamePlayerReplicationInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardGamePlayerReplicationInfo extends Engine.LinkedReplicationInfo
    dependson(Interactions);

var KFPlayerReplicationInfo OwningReplicationInfo;
var TurboCardReplicationInfo TurboCardReplicationInfo;
var int VoteIndex;

var array< class<TurboCard> > SelectedCardList;

var int ValidationFailureCount;

var const bool bDebug;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		OwningReplicationInfo, TurboCardReplicationInfo, VoteIndex;
	reliable if ( Role < ROLE_Authority )
        SetVoteIndex;
	reliable if ( Role < ROLE_Authority )
        ServerDebugActivateCard, ServerDebugDeactivateCard;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role != ROLE_Authority)
    {
        if (bDebug)
        {
            log(" - Setting up Card Game ValidateCardGameLRI initial state.");
        }
        InitialState = 'ValidateCardGameLRI';
        GotoState(InitialState);
    }
}

//Attempts to make sure this CardGamePlayerReplicationInfo is in the LRI list.
simulated state ValidateCardGameLRI
{
    simulated final function bool IsValidLRI()
    {
        return GetCardGameLRI(OwningReplicationInfo) == Self;
    }

    simulated function bool IsReadyToEmplaceLRI()
    {
        local bool bHasCPRL, bHasTRL;
        local LinkedReplicationInfo LRI;

        if (OwningReplicationInfo == None)
        {
            return false;
        }

        for (LRI = OwningReplicationInfo.CustomReplicationInfo; LRI != None; LRI = LRI.NextReplicationInfo)
        {
            if (!bHasCPRL && ClientPerkRepLink(LRI) != None)
            {
                bHasCPRL = true;
            }
            else if (!bHasTRL && TurboRepLink(LRI) != None)
            {
                bHasTRL = true;
            }
        }

        return bHasCPRL && bHasTRL;
    }

    simulated final function RepairLRI()
    {
        local LinkedReplicationInfo NextLRI;
        NextLRI = OwningReplicationInfo.CustomReplicationInfo;
        OwningReplicationInfo.CustomReplicationInfo = Self;
        NextReplicationInfo = NextLRI;
    }

Begin:
    if (bDebug)
    {
        log(" - Starting Card Game LRI validation.");
    }
    while (true)
    {
        Sleep(1.f);

        if (IsValidLRI())
        {
            if (bDebug)
            {
                log(" - Card Game LRI was valid, stopping validation.");
            }
            break;
        }

        if (ValidationFailureCount < 20)
        {   
            if (bDebug)
            {
                log(" - Failed Card Game LRI validation."@ValidationFailureCount);
            }
            ValidationFailureCount++;
            continue;
        }

        //Need to wait for the other LRIs to be working.
        if (!IsReadyToEmplaceLRI())
        {   
            if (bDebug)
            {
                log(" - Card Game LRI repair waiting for CPRL and TRL to be ready.");
            }
            continue;
        }

        log(" - Performing repair.");
        RepairLRI();
        break;
    }
    
    GotoState('');
}

static simulated final function CardGamePlayerReplicationInfo GetCardGameLRI(PlayerReplicationInfo PRI)
{
    local LinkedReplicationInfo LRI;

    if (PRI == None)
    {
        return None;
    }

    for (LRI = PRI.CustomReplicationInfo; LRI != None; LRI = LRI.NextReplicationInfo)
    {
        if (CardGamePlayerReplicationInfo(LRI) != None)
        {
            return CardGamePlayerReplicationInfo(LRI);
        }
    }
    
    return None;
}

simulated function bool ProcessVoteKeyPressEvent(Interactions.EInputKey Key)
{
    local float KeyVoteIndex;
    local Interactions.EInputKey Offset;

	if (TurboCardReplicationInfo == None || !TurboCardReplicationInfo.bCurrentlyVoting)
    {
        return false;
    }

    if (Key <= IK_0 || Key > IK_9)
    {
        return false;
    }
    else
    {
        Offset = IK_0;
        KeyVoteIndex = int(Key) - int(Offset);

        if (class'TurboCardReplicationInfo'.static.ResolveCard(TurboCardReplicationInfo.SelectableCardList[KeyVoteIndex - 1]) == None)
        {
            KeyVoteIndex = 0;
        }
    }

    SetVoteIndex(KeyVoteIndex);
    return true;
}

function SetVoteIndex(int Index)
{
	if (!TurboCardReplicationInfo.bCurrentlyVoting)
    {
        return;
    }

    if (Index <= 0 || Index > 9 || class'TurboCardReplicationInfo'.static.ResolveCard(TurboCardReplicationInfo.SelectableCardList[Index - 1]) == None)
    {
        Index = 0;
    }

    VoteIndex = Index;
    ForceNetUpdate();
}

function ResetVote()
{
    VoteIndex = 0;
    ForceNetUpdate();
}

//Make NetUpdateTime want to update now.
simulated function ForceNetUpdate()
{
    NetUpdateTime = Max(Level.TimeSeconds - ((1.f / NetUpdateFrequency) + 1.f), 0.1f);
}

function ServerDebugActivateCard(string CardID)
{
    if (OwningReplicationInfo == None || TurboPlayerController(OwningReplicationInfo.Owner) == None || !TurboPlayerController(OwningReplicationInfo.Owner).HasAdminPermission())
    {
        return;
    }

    TurboCardReplicationInfo.DebugActivateCard(CardID);
}

function ServerDebugDeactivateCard(string CardID)
{
    if (OwningReplicationInfo == None || TurboPlayerController(OwningReplicationInfo.Owner) == None || !TurboPlayerController(OwningReplicationInfo.Owner).HasAdminPermission())
    {
        return;
    }
    
    TurboCardReplicationInfo.DebugDeactivateCard(CardID);
}

defaultproperties
{
    VoteIndex = 0
    NetUpdateFrequency=0.1

    bDebug=false
}
