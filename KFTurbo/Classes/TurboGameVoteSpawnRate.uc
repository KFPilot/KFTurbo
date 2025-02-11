//Killing Floor Turbo TurboGameVoteSpawnRate
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameVoteSpawnRate extends TurboGameVoteBase;

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

    KFTurboGameType(Level.Game).AdminSpawnRateModifier *= 0.75f;
}

defaultproperties
{
    VoteID="SPAWNRATE"

    VotePercent=0.51f
    bCanSpectatorsVote=false

    VoteInitiatedString="%k%p%d started a vote to %kincrease spawnrate%d. Type %kvote yes%d or %kvote no%d in %kconsole%d to vote."
    VoteSucceededVoteString="%kVote%d to %kincrease spawnrate%d has %pksucceeded%d."
    VoteFailedVoteString="%kVote%d to %kincrease spawnrate%d has %nkfailed%d."
    VoteExpiredVoteString="%kVote%d to %kincrease spawnrate%d has %akexpired%d."

    VoteTitleString="Increase Spawnrate"
    VoteDescriptionString="Accepting this vote will increase spawnrate by 25% for the rest of the game."
}