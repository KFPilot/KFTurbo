//Killing Floor Turbo TurboGameVoteBase
//ReplicationInfo that represents a voting instance. All votes are Yes/No votes.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameVoteBase extends ReplicationInfo
    abstract;

var TurboGameReplicationInfo OwnerGRI;
var TurboServerTimeActor ServerTimeActor;

var string VoteID; //Used to specify an ID for a given vote instance.
var protected float VoteDuration; //Duration of this vote. Once this time is reached, the vote will expire.
var protected float VoteCooldown; //Cooldown of this vote. If the vote fails, this cooldown will be applied.
var protected float VotePercent; //Percent of the vote required for this vote to pass.
var protected bool bCanSpectatorsVote; //If true, spectators can vote.


enum EVote
{
    Unset,
    Yes,
    No
};
struct PlayerVoteEntry
{
    var TurboPlayerReplicationInfo TPRI;
    var EVote Vote;
};
var protected array<PlayerVoteEntry> VoteList;

var protected TurboPlayerReplicationInfo InitiatingPlayer;

enum EVotingState
{
    Initializing, //Default state.
    Started,
    InProgress,
    
    Expired,
    Succeeded,
    Failed
};
var protected EVotingState VoteState, LastVoteState;

var protected int VoteYesCount, LastVoteYesCount;
var protected int VoteNoCount, LastVoteNoCount;
var protected int TotalVoterCount, LastTotalVoterCount;

var protected float VoteStartTime, VoteEndTime;

var protected int TotalVoteCount;
var protected EVote AdminOverrideVote; //Will be set if an admin voted for an option.

var protected class<TurboVoteLocalMessage> TurboVoteLocalMessage;
var protected localized string VoteInitiatedString;
var protected localized string VoteTitleString;
var protected localized string VoteDescriptionString;

delegate OnVoteStateChanged(TurboGameVoteBase VoteInstance, EVotingState NewState);
delegate OnVoteTallyChanged(TurboGameVoteBase VoteInstance, int NewYesVoteCount, int NewNoVoteCount);

replication
{
    reliable if(bNetDirty && Role == ROLE_Authority)
        InitiatingPlayer, VoteState, VoteYesCount, VoteNoCount, TotalVoterCount, VoteStartTime, VoteEndTime;
}

simulated function PreBeginPlay()
{
    Super.PreBeginPlay();

    OwnerGRI = TurboGameReplicationInfo(Level.GRI);
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role == ROLE_Authority)
    {
        return;
    }
    
    GotoState('WaitingForGameReplicationInfo');
}

simulated function PostNetReceive()
{
    UpdateVoteInfo('PostNetReceive');
}

simulated function UpdateVoteInfo(Name Reason)
{
    TotalVoteCount = VoteYesCount + VoteNoCount;

    if (VoteState != LastVoteState)
    {
        LastVoteState = VoteState;
        OnVoteStateChanged(Self, VoteState);
    }

    if (VoteYesCount != LastVoteYesCount || VoteNoCount != LastVoteNoCount || TotalVoterCount != LastTotalVoterCount)
    {
        LastVoteYesCount = VoteYesCount;
        LastVoteNoCount = VoteNoCount;
        LastTotalVoterCount = TotalVoterCount;
        OnVoteTallyChanged(Self, VoteYesCount, VoteNoCount);
    }
}

//These simulated functions use replicated data/data the remote handles and so are safe to use for UI.

simulated static final function string GetVoteID()
{
    return default.VoteID;
}

simulated final function EVotingState GetVoteState()
{
    return VoteState;
}

//Returns number of people who are able to vote.
simulated final function int GetVoterCount()
{
    return TotalVoterCount;
}

//Returns total number of votes cast.
simulated final function int GetVoteCount()
{
    return TotalVoteCount;
}

//Returns number of people who have voted yes.
simulated final function int GetYesVoteCount()
{
    return VoteYesCount;
}

//Returns number of people who have voted no.
simulated final function int GetNoVoteCount()
{
    return VoteNoCount;
}

//Returns total duration of the vote. Will return -1.f if the client has yet to receive this value.
simulated final function float GetVoteDuration()
{
    if (VoteStartTime <= 0.f && VoteEndTime <= 0.f)
    {
        return -1.f;
    }

    return FMax(VoteEndTime - VoteStartTime, 0.f);
}

//Returns the remaining duration of the vote. Will return -1.f if the client has yet to receive this value.
simulated final function float GetVoteDurationRemaining()
{
    if (VoteStartTime <= 0.f && VoteEndTime <= 0.f)
    {
        return -1.f;
    }

    return ServerTimeActor.GetServerTimeSecondsUntil(VoteEndTime);
}

//Returns the (localizable) string that is used when a vote is started. Players are specified by %p.
//The initialize string getters is static because when initialized the local message may arrive before the vote actor is replicated to the remote.
static simulated function string GetVoteInitiatedString()
{
    return default.VoteInitiatedString;
}

//Returns the (localizable) string that represents the name of this vote.
simulated function string GetVoteTitleString()
{
    return VoteTitleString;
}

//Returns the (localizable) string that represents the description of this vote.
simulated function string GetVoteDescriptionString()
{
    return VoteDescriptionString;
}

//Returns the player who initiated this vote.
simulated function TurboPlayerReplicationInfo GetVoteInitiator()
{
    return InitiatingPlayer;
}

//Returns true if the provided player can initiate this vote.
static function bool CanInitiateVote(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator)
{
    if (TGRI == None || Initiator.bOnlySpectator && !default.bCanSpectatorsVote)
    {
        return false;
    }

    return true;
}

//Called when a vote instance is initiated by a specified player.
function InitiateVote(TurboPlayerReplicationInfo Initiator)
{    
    InitiatingPlayer = Initiator;

    Level.Game.BroadcastLocalizedMessage(TurboVoteLocalMessage, 0, InitiatingPlayer);

    VoteList.Length = 1;
    VoteList[0].TPRI = Initiator;
    VoteList[0].Vote = EVote.Yes;

    if (VoteDuration <= 0.f)
    {
        VoteStartTime = -1.f;
        VoteEndTime = -1.f;
    }
    else
    {
        VoteStartTime = Level.TimeSeconds;
        VoteEndTime = Level.TimeSeconds + VoteDuration;
    }
    
    GotoState('VoteInProgress');
    EvaluateVote('ReceivedVote');
}

//Returns true if the specified player is allowed to vote.
function bool CanPlayerVote(TurboPlayerReplicationInfo TPRI)
{
    return !TPRI.bOnlySpectator || default.bCanSpectatorsVote;
}

function PlayerVote(TurboPlayerReplicationInfo TPRI, string VoteString)
{
    local EVote PlayerVote;

    if (!CanPlayerVote(TPRI))
    {
        return;
    }

    switch(VoteString)
    {
        case "YES":
            PlayerVote = EVote.Yes;
            break;
        case "NO":
            PlayerVote = EVote.No;
            break;
        default:
            PlayerVote = EVote.Unset;
    }

    if (PlayerVote == EVote.Unset)
    {
        if (VoteString == GetVoteID())
        {
            PlayerVote = EVote.Yes;
        }
        else
        {
            return;
        }
    }
    
    VoteList.Length = VoteList.Length + 1;
    VoteList[VoteList.Length - 1].TPRI = TPRI;
    VoteList[VoteList.Length - 1].Vote = PlayerVote;

    EvaluateVote('ReceivedVote');
}

function OnVoteExpired()
{
    //Allow the vote evaluator to know we're about to expire the vote so they can do something special if they want instead.
    EvaluateVote('Expired');

    //If expiring did not end up causing some change in vote state, consider this vote expired.
    if (VoteState < EVotingState.Expired)
    {
        SetVoteState(EVotingState.Expired);
    }
}

function OnPlayerListChanged()
{
    EvaluateVote('PlayerList');
}

function SetVoteState(EVotingState NewVoteState)
{
    if (VoteState >= Expired)
    {
        return;
    }

    VoteState = NewVoteState;
    PostNetReceive();
    ForceNetUpdate();

    if (NewVoteState >= Expired)
    {
        OnVoteResult(GetResultFromState());
        GotoState('VoteComplete');
    }
}

final function Name GetResultFromState()
{
    switch(VoteState)
    {
        case EVotingState.Expired:
            return 'Expired';
        case EVotingState.Succeeded:
            return 'Succeeded';
        case EVotingState.Failed:
            return 'Failed';
    }

    return 'None';
}

function UpdateVoteCounts()
{
    local int Index;
    TotalVoterCount = class'TurboGameplayHelper'.static.GetPlayerControllerList(Level, bCanSpectatorsVote).Length;

    AdminOverrideVote = EVote.Unset;
    VoteYesCount = 0;
    VoteNoCount = 0;

    for (Index = 0; Index < VoteList.Length; Index++)
    {
        switch(VoteList[Index].Vote)
        {
            case EVote.Yes:
                VoteYesCount++;
                break;
            case EVote.No:
                VoteNoCount++;
                break;
        }

        if (VoteList[Index].TPRI.bAdmin)
        {
            AdminOverrideVote = VoteList[Index].Vote;
        }
    }

    PostNetReceive();
    ForceNetUpdate();
}

function EvaluateVote(Name Reason)
{
    UpdateVoteCounts();

    //If even the total vote number is not over the 51% threshold, don't bother checking.
    if (Reason != 'Expired' && AdminOverrideVote == EVote.Unset && (float(TotalVoteCount) / float(TotalVoterCount) < VotePercent))
    {
        return;
    }

    if (AdminOverrideVote == EVote.Yes || (float(VoteYesCount) / float(TotalVoterCount) >= VotePercent))
    {
        SetVoteState(EVotingState.Succeeded);
    }
    else if (AdminOverrideVote == EVote.No || (float(VoteNoCount) / float(TotalVoterCount) >= VotePercent))
    {
        SetVoteState(EVotingState.Failed);
    }
}

//By default called when SetVoteState is set to Expired, Succeeded or Failed and Outcome will be one of those 3 as an FName.
function OnVoteResult(Name Outcome) {}

//Client-only state. Await reception of the GRI.
state WaitingForGameReplicationInfo
{
    //Ignore PostNetReceive while we're waiting for the GRI.
    //EndState() will make sure we get caught up when we're ready.
    simulated function PostNetReceive() {}

    simulated function EndState()
    {
        UpdateVoteInfo('EndState');
    }

Begin:
    while (Level.GRI == None)
    {
        sleep(0.1f);
    }

    OwnerGRI = TurboGameReplicationInfo(Level.GRI);

    while (OwnerGRI.ServerTimeActor == None)
    {
        sleep(0.1f);
    }

    ServerTimeActor = OwnerGRI.ServerTimeActor;
    OwnerGRI.RegisterVoteInstance(Self);
    
    GotoState('');
}

//Server-only state.
state VoteInProgress
{
    function InitiateVote(TurboPlayerReplicationInfo Initiator) {}

Begin:
    sleep(VoteDuration);
    OnVoteExpired();
}

state VoteComplete
{
    //The vote is over. Nothing should be interacting with this vote instance now but, if they do, we're going to ignore them.
    function InitiateVote(TurboPlayerReplicationInfo Initiator) {}
    function ReceivedVote(TurboPlayerReplicationInfo TPRI, EVote Vote) {}
    function SetVoteState(EVotingState NewVoteState) {}
    function EvaluateVote(Name Reason) {}
    function OnVoteExpired() {}
    function OnVoteResult(Name Outcome) {}

Begin:
    LifeSpan = 5.f;
}

//Make NetUpdateTime want to update now.
simulated function ForceNetUpdate()
{
    NetUpdateTime = Max(Level.TimeSeconds - ((1.f / NetUpdateFrequency) + 1.f), 0.1f);
}

defaultproperties
{
    NetUpdateFrequency=0.1f
    bNetNotify=true

    VoteDuration=20.f
    VoteCooldown=5.f
    VotePercent=0.51f

    TurboVoteLocalMessage=class'TurboVoteLocalMessage'
}