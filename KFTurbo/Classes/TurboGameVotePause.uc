//Killing Floor Turbo TurboGameVotePause
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameVotePause extends TurboGameVoteBase;

static function bool CanInitiateVote(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator, string VoteString)
{
    local KFTurboGameType GameType;
    if (!Super.CanInitiateVote(TGRI, Initiator, VoteString))
    {
        return false;
    }

    if (TGRI.Level.Pauser != None)
    {
        return false;
    }

    GameType = KFTurboGameType(TGRI.Level.Game);

    if (GameType == None || GameType.bWaitingToStartMatch)
    {
        return false;
    }

    return true;
}

function OnVoteResult(Name Outcome)
{
    if (Outcome != 'Succeeded')
    {
        return;
    }

    Level.Pauser = None;
}

state VoteInProgress
{
Begin:
    sleep(0.25f);
    while(true)
    {
        if (Level.Pauser != None)
        {
            break;
        }

        sleep(0.25f);
    }

    OnVoteExpired();
}

defaultproperties
{
    VoteID="PAUSE"
    VoteDuration=-1.f

    VotePercent=0.51f
    bCanSpectatorsVote=false

    VoteInitiatedString="%k%p%d started a vote to %kpause the game%d. Type %kVOTE PAUSE in console%d to vote."
    VoteSucceededVoteString="%kVote%d to %kpause the game%d has %pksucceeded%d."
    VoteFailedVoteString="%kVote%d to %kpause the game%d has %nkfailed%d."
    VoteExpiredVoteString=""

    bBroadcastSucceeded=true
    bBroadcastFailed=true
    bBroadcastExpired=false

    VoteTitleString="Pause Game"
    VoteDescriptionString="Accepting this vote will pause the game."

	CommandHint=(Command="Vote Pause",Hint="Votes to pause the game.",ParameterType=NoParam)
}
