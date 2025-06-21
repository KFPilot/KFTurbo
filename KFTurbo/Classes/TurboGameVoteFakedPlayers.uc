//Killing Floor Turbo TurboGameVoteFakedPlayers
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameVoteFakedPlayers extends TurboGameVoteIntValue;

static function int GetCurrentVoteValue(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator)
{
    return KFTurboGameType(TGRI.Level.Game).GetFakedPlayerCount();
}

function OnVoteResult(Name Outcome)
{
    if (Outcome != 'Succeeded')
    {
        return;
    }

    KFTurboGameType(Level.Game).SetFakedPlayerCount(Clamp(VoteIntValue, MinVoteIntValue, MaxVoteIntValue));
}

defaultproperties
{
    MinVoteIntValue=0
    MaxVoteIntValue=6

    VoteID="FAKEDPLAYERS"

    VotePercent=0.51f
    bCanSpectatorsVote=false

    VoteInitiatedString="%k%p%d started a vote to %kset faked players%d to %k%i%d. Type %kvote yes%d or %kvote no%d in %kconsole%d to vote."
    VoteSucceededVoteString="%kVote%d to %kset faked players%d to %k%i%d has %pksucceeded%d."
    VoteFailedVoteString="%kVote%d to %kset faked players%d to %k%i%d has %nkfailed%d."
    VoteExpiredVoteString="%kVote%d to %kset faked players%d to %k%i%d has %akexpired%d."

    VoteTitleString="%i Faked Players"
    VoteDescriptionString="Accepting this vote will change faked players for the rest of the game."
}