//Killing Floor Turbo TurboGameVoteIntValue
//Standardized way to vote for int values.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameVoteIntValue extends TurboGameVoteBase;

var int VoteIntValue;
var int MinVoteIntValue;
var int MaxVoteIntValue;

replication
{
    reliable if(Role == ROLE_Authority)
        VoteIntValue;
}

static function int GetValueFromVoteString(string VoteString)
{
    local string ValueString;
    
    if (!Divide(VoteString, " ", VoteString, ValueString))
    {
        return -1;
    }

    return Clamp(int(Round(float(ValueString))), default.MinVoteIntValue, default.MaxVoteIntValue);
}

simulated function string GetVoteTitleString()
{
    return Repl(VoteTitleString, "%i", string(VoteIntValue));
}

function int GetBroadcastDataForState(EVotingState State)
{
    return int(State) | class'TurboVoteIntLocalMessage'.static.EncodeInt(VoteIntValue);
}

static function bool CanInitiateVote(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator, string VoteString)
{
    local int Value;
    if (!Super.CanInitiateVote(TGRI, Initiator, VoteString))
    {
        return false;
    }

    Value = GetValueFromVoteString(VoteString);
    if (Value < 0 || Value == GetCurrentVoteValue(TGRI, Initiator))
    {
        return false;
    }

    return true;
}

//Used to determine if a vote being initiated is for a value that is already set.
static function int GetCurrentVoteValue(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator)
{
    return -1;
}

function InitiateVote(TurboPlayerReplicationInfo Initiator, optional string VoteString)
{
    VoteIntValue = GetValueFromVoteString(VoteString);

    Super(TurboGameVoteBase).InitiateVote(Initiator, VoteString);
}

defaultproperties
{
    VoteIntValue=1
    MinVoteIntValue=1
    MaxVoteIntValue=1000

    VotePercent=0.51f
    bCanSpectatorsVote=false

    TurboVoteLocalMessage=class'TurboVoteIntLocalMessage'
}