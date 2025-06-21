//Killing Floor Turbo TurboGameVoteMaxPlayers
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameVoteMaxPlayers extends TurboGameVoteIntValue;

static function bool CanInitiateVote(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator, string VoteString)
{
    if (!Super.CanInitiateVote(TGRI, Initiator, VoteString))
    {
        return false;
    }

    //Can only vote for this if it's Turbo+.
    if (!KFTurboGameType(TGRI.Level.Game).IsHighDifficulty())
    {
        return false;
    }

    return true;
}

static function int GetCurrentVoteValue(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator)
{
    return TGRI.Level.Game.MaxPlayers;
}

function OnVoteResult(Name Outcome)
{
    if (Outcome != 'Succeeded')
    {
        return;
    }

    Level.Game.MaxPlayers = VoteIntValue;
    Level.Game.default.MaxPlayers = VoteIntValue;
}

defaultproperties
{
    VoteID="MAXPLAYERS"
    MinVoteIntValue=1
    MaxVoteIntValue=6

    VotePercent=0.51f
    bCanSpectatorsVote=false

    VoteInitiatedString="%k%p%d started a vote to %kset max players%d to %k%ix%d. Type %kvote yes%d or %kvote no%d in %kconsole%d to vote."
    VoteSucceededVoteString="%kVote%d to %kset max players%d to %k%ix%d has %pksucceeded%d."
    VoteFailedVoteString="%kVote%d to %kset max players%d to %k%ix%d has %nkfailed%d."
    VoteExpiredVoteString="%kVote%d to %kset max players%d to %k%ix%d has %akexpired%d."

    VoteTitleString="%ix Max Players"
    VoteDescriptionString="Accepting this vote will change max players for the rest of the game."
}