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

    KFTurboGameType(Level.Game).AdminMaxMonstersModifier *= 1.25f;
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
    VoteID="MAXMONSTERS"

    VotePercent=0.51f
    bCanSpectatorsVote=false

    VoteInitiatedString="%k%p%d started a vote to %kincrease max monsters%d. Type %kvote yes or vote no in console%d to vote."
    VoteTitleString="Increase Max Monsters"
    VoteDescriptionString="Accepting this vote will increase max monsters for the rest of the game."
}