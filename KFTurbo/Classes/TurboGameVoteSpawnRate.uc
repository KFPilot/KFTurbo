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

    if ((TGRI.Level.Game.GetCurrentWaveNum() < TGRI.Level.Game.GetFinalWaveNum()) || !KFTurboGameType(TGRI.Level.Game).bWaveInProgress || KFTurboGameType(TGRI.Level.Game).TotalMaxMonsters <= 5)
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

state VoteInProgress
{
Begin:
    while(true)
    {
        if (!KFTurboGameType(Level.Game).bWaveInProgress || VoteEndTime < Level.TimeSeconds)
        {
            break;
        }

        sleep(0.2f);
    }

    OnVoteExpired();
}

defaultproperties
{
    VoteID="SPAWNRATE"

    VotePercent=0.51f
    bCanSpectatorsVote=false

    VoteInitiatedString="%k%p%d started a vote to %kincrease spawnrate%d. Type %kvote yes or vote no in console%d to vote."
    VoteTitleString="Increase Spawnrate"
    VoteDescriptionString="Accepting this vote will increase spawnrate for the rest of the game."
}