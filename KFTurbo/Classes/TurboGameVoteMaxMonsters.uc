//Killing Floor Turbo TurboGameVoteMaxMonsters
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameVoteMaxMonsters extends TurboGameVoteBase;

static function bool CanInitiateVote(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator)
{
    if (!Super.CanInitiateVote(TGRI, Initiator))
    {
        return false;
    }

    if (TGRI.Level.Game.GetCurrentWaveNum() >= TGRI.Level.Game.GetFinalWaveNum())
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

    KFTurboGameType(Level.Game).AdminMaxMonstersModifier *= 1.25f;
}

defaultproperties
{
    VoteID="MAXMONSTERS"

    VotePercent=0.51f
    bCanSpectatorsVote=false

    VoteInitiatedString="%k%p%d started a vote to %kincrease max monsters%d. Type %kvote yes%d or %kvote no%d in %kconsole%d to vote."
    VoteSucceededVoteString="%kVote%d to %kincrease max monsters%d has %pksucceeded%d."
    VoteFailedVoteString="%kVote%d to %kincrease max monsters%d has %nkfailed%d."
    VoteExpiredVoteString="%kVote%d to %kincrease max monsters%d has %akexpired%d."

    VoteTitleString="Increase Max Monsters"
    VoteDescriptionString="Accepting this vote will increase max monsters by 25% for the rest of the game."
}