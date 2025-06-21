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
var protected float FailedVoteCooldown; //Cooldown of this vote. If the vote fails, this cooldown will be applied.
var protected float VotePercent; //Percent of the vote required for this vote to pass.
var protected bool bCanSpectatorsVote; //If true, spectators can vote.
var protected bool bCanVoteDuringEndGame; //If true, this vote can be initiated after the game is over.


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
var protected bool bBroadcastSucceeded;
var protected bool bBroadcastFailed;
var protected bool bBroadcastExpired;
var protected localized string VoteInitiatedString;
var protected localized string VoteSucceededVoteString;
var protected localized string VoteFailedVoteString;
var protected localized string VoteExpiredVoteString;

var protected localized string VoteTitleString;
var protected localized string VoteDescriptionString;
var protected localized string YesString, NoString;
var protected Color TitleColor;

delegate OnVoteStateChanged(TurboGameVoteBase VoteInstance, EVotingState NewState);
delegate OnVoteTallyChanged(TurboGameVoteBase VoteInstance, int NewYesVoteCount, int NewNoVoteCount);

replication
{
    reliable if(Role == ROLE_Authority)
        InitiatingPlayer, VoteState, VoteYesCount, VoteNoCount, TotalVoterCount, VoteStartTime, VoteEndTime;
}

simulated function PreBeginPlay()
{
    Super.PreBeginPlay();

    if (Level.GRI != None)
    {
        OwnerGRI = TurboGameReplicationInfo(Level.GRI);
    }
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role == ROLE_Authority)
    {
        ServerTimeActor = OwnerGRI.ServerTimeActor;
        return;
    }
    
    SetTimer(0.1f, false);
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

simulated final function float GetYesVotePercent()
{
    if (TotalVoterCount <= 0)
    {
        return 0.f;
    }

    return float(VoteYesCount) / float(TotalVoterCount);
}

//Returns number of people who have voted no.
simulated final function int GetNoVoteCount()
{
    return VoteNoCount;
}

simulated final function float GetNoVotePercent()
{
    if (TotalVoterCount <= 0)
    {
        return 0.f;
    }

    return float(VoteNoCount) / float(TotalVoterCount);
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
    if (ServerTimeActor == None || VoteStartTime <= 0.f || VoteEndTime <= 0.f)
    {
        return -1.f;
    }

    return ServerTimeActor.GetServerTimeSecondsUntil(VoteEndTime);
}

simulated final function float GetVoteDurationPercentRemaining()
{
    if (ServerTimeActor == None || VoteStartTime <= 0.f || VoteEndTime <= 0.f || (VoteEndTime - VoteStartTime) <= 0.f)
    {
        return -1.f;
    }

    return ServerTimeActor.GetServerTimeSecondsUntil(VoteEndTime) / (VoteEndTime - VoteStartTime);
}

//Returns the (localizable) string that is used when a vote is started. Players are specified by %p.
//The initialize string getters is static because when initialized the local message may arrive before the vote actor is replicated to the remote.
static final simulated function string GetVoteInitiatedString()
{
    return default.VoteInitiatedString;
}

static final simulated function string GetVoteSucceededString()
{
    return default.VoteSucceededVoteString;
}

static final simulated function string GetVoteFailedString()
{
    return default.VoteFailedVoteString;
}

static final simulated function string GetVoteExpiredString()
{
    return default.VoteExpiredVoteString;
}

//Returns the (localizable) string that represents the name of this vote.
simulated function string GetVoteTitleString()
{
    return VoteTitleString;
}

//Returns the color that represents the no vote.
simulated final function Color GetVoteTitleColor()
{
    return default.TitleColor;
}

//Returns the (localizable) string that represents the description of this vote.
simulated final function string GetVoteDescriptionString()
{
    return VoteDescriptionString;
}

//Returns the (localizable) string that represents the yes vote.
simulated final function string GetVoteYesString()
{
    return YesString;
}

//Returns the color that represents the no vote.
simulated final function Color GetVoteYesColor()
{
    return class'TurboLocalMessage'.default.PositiveKeywordColor;
}

//Returns the (localizable) string that represents the no vote.
simulated final function string GetVoteNoString()
{
    return NoString;
}

//Returns the color that represents the no vote.
simulated final function Color GetVoteNoColor()
{
    return class'TurboLocalMessage'.default.NegativeKeywordColor;
}

//Returns the player who initiated this vote.
simulated final function TurboPlayerReplicationInfo GetVoteInitiator()
{
    return InitiatingPlayer;
}

function float GetPlayerStartVoteCooldown(TurboPlayerController PlayerController)
{
    return FailedVoteCooldown;
}

function int GetBroadcastDataForState(EVotingState State)
{
    return int(State);
}

//Returns true if the provided player can initiate this vote.
static function bool CanInitiateVote(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator, string VoteString)
{
    if (TGRI == None || (Initiator.bOnlySpectator && !default.bCanSpectatorsVote))
    {
        return false;
    }

    if (!default.bCanVoteDuringEndGame && (TGRI.Level.Game.GetCurrentWaveNum() >= TGRI.Level.Game.GetFinalWaveNum()))
    {
        return false;
    }

    if (!TGRI.bMatchHasBegun)
    {
        return false;
    }

    return true;
}

//Called when a vote instance is initiated by a specified player.
function InitiateVote(TurboPlayerReplicationInfo Initiator, optional string VoteString)
{    
    SetVoteState(Initializing);
    InitiatingPlayer = Initiator;

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

    if (VoteState < Expired)
    {
        Level.Game.BroadcastLocalizedMessage(TurboVoteLocalMessage, GetBroadcastDataForState(EVotingState.Started), InitiatingPlayer,, Class);
    }
}

//Returns true if the specified player is allowed to vote.
function bool CanPlayerVote(TurboPlayerReplicationInfo TPRI)
{
    return !TPRI.bOnlySpectator || default.bCanSpectatorsVote;
}

function PlayerVote(TurboPlayerReplicationInfo TPRI, optional string VoteString)
{
    local EVote PlayerVote;
    local bool bUpdatedVote;
    local int Index;

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

    bUpdatedVote = false;
    
    for (Index = VoteList.Length - 1; Index >= 0; Index--)
    {
        if (VoteList[Index].TPRI != TPRI)
        {
            continue;
        }

        VoteList[Index].Vote = PlayerVote;
        bUpdatedVote = true;
        break;
    }

    if (!bUpdatedVote)
    {
        VoteList.Length = VoteList.Length + 1;
        VoteList[VoteList.Length - 1].TPRI = TPRI;
        VoteList[VoteList.Length - 1].Vote = PlayerVote;
    }

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

    if (VoteState >= Expired)
    {
        if ((bBroadcastSucceeded && VoteState == Succeeded) || (bBroadcastFailed && VoteState == Failed) || (bBroadcastExpired && VoteState == Expired))
        {
            Level.Game.BroadcastLocalizedMessage(TurboVoteLocalMessage, GetBroadcastDataForState(VoteState), InitiatingPlayer,, Class);
        }
        OnVoteResult(GetResultFromState());
        TurboGameReplicationInfo(Level.GRI).PlayerVoteComplete(Self, VoteState);
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
    TotalVoterCount = class'TurboGameplayHelper'.static.GetPlayerControllerCount(Level, bCanSpectatorsVote);

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

simulated function Timer()
{
    if (Role == ROLE_Authority)
    {
        return;
    }

    if (Level.GRI == None)
    {
        SetTimer(0.1f, false);
        return;
    }

    OwnerGRI = TurboGameReplicationInfo(Level.GRI);

    if (OwnerGRI.ServerTimeActor == None)
    {
        SetTimer(0.1f, false);
        return;
    }

    ServerTimeActor = OwnerGRI.ServerTimeActor;
    OwnerGRI.RegisterVoteInstance(Self);
}

//Server-only state.
state VoteInProgress
{
    function InitiateVote(TurboPlayerReplicationInfo Initiator, optional string VoteString) {}

Begin:
    SetVoteState(Started);
    if (VoteDuration > 0.f)
    {
        sleep(VoteDuration);
        OnVoteExpired();
    }
}

state VoteComplete
{
    //The vote is over. Nothing should be interacting with this vote instance now but, if they do, we're going to ignore them.
    function InitiateVote(TurboPlayerReplicationInfo Initiator, optional string VoteString) {}
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

    TitleColor=(R=255,G=255,B=255,A=255)
    YesString="Yes"
    NoString="No"

    VoteDuration=30.f
    FailedVoteCooldown=10.f
    VotePercent=0.51f

    bCanSpectatorsVote=false
    bCanVoteDuringEndGame=false

    bBroadcastSucceeded=true
    bBroadcastFailed=true
    bBroadcastExpired=true
    TurboVoteLocalMessage=class'TurboVoteLocalMessage'
}