//Killing Floor Turbo TurboGameVoteFloatValue
//Standardized way to vote for float values.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameVoteFloatValue extends TurboGameVoteBase;

var float VoteFloatValue;
var float MinVoteFloatValue;
var float MaxVoteFloatValue;

replication
{
    reliable if(Role == ROLE_Authority)
        VoteFloatValue;
}

static function float GetValueFromVoteString(string VoteString)
{
    local string ValueString;
    
    if (!Divide(VoteString, " ", VoteString, ValueString))
    {
        return -1.f;
    }

    return FClamp(float(ValueString), default.MinVoteFloatValue, default.MaxVoteFloatValue);
}

simulated function string GetVoteTitleString()
{
    return Repl(VoteTitleString, "%f", string(VoteFloatValue));
}

function int GetBroadcastDataForState(EVotingState State)
{
    return int(State) | class'TurboVoteFloatLocalMessage'.static.EncodeFloat(VoteFloatValue);
}

static function bool CanInitiateVote(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator, string VoteString)
{
    local float Value;
    if (!Super.CanInitiateVote(TGRI, Initiator, VoteString))
    {
        return false;
    }

    Value = GetValueFromVoteString(VoteString);
    if (Value < 0.f || (Abs(Value - GetCurrentVoteValue(TGRI, Initiator)) < 0.001f))
    {
        return false;
    }

    return true;
}

//Used to determine if a vote being initiated is for a value that is already set.
static function float GetCurrentVoteValue(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator)
{
    return -1.f;
}

function InitiateVote(TurboPlayerReplicationInfo Initiator, optional string VoteString)
{
    VoteFloatValue = GetValueFromVoteString(VoteString);

    Super.InitiateVote(Initiator, VoteString);
}

defaultproperties
{
    VoteFloatValue=1.f
    MinVoteFloatValue=1.f
    MaxVoteFloatValue=1000.f

    TurboVoteLocalMessage=class'TurboVoteFloatLocalMessage'
}