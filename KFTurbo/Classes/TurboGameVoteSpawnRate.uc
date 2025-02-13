//Killing Floor Turbo TurboGameVoteSpawnRate
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameVoteSpawnRate extends TurboGameVoteFloatValue;

static function bool CanInitiateVote(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator, string VoteString)
{
    if (!Super.CanInitiateVote(TGRI, Initiator, VoteString))
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

    KFTurboGameType(Level.Game).AdminSpawnRateModifier = VoteFloatValue;
}

defaultproperties
{
    VoteID="SPAWNRATE"

    VotePercent=0.51f
    bCanSpectatorsVote=false

    VoteInitiatedString="%k%p%d started a vote to %kset spawn rate%d to %k%fx%d. Type %kvote yes%d or %kvote no%d in %kconsole%d to vote."
    VoteSucceededVoteString="%kVote%d to %kset spawn rate%d to %k%fx%d has %pksucceeded%d."
    VoteFailedVoteString="%kVote%d to %kset spawn rate%d to %k%fx%d has %nkfailed%d."
    VoteExpiredVoteString="%kVote%d to %kset spawn rate%d to %k%fx%d has %akexpired%d."

    VoteTitleString="%fx Spawn Rate"
    VoteDescriptionString="Accepting this vote will change spawn rate for the rest of the game."
}