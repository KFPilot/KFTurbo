//Killing Floor Turbo TurboGameVotePlayerHealth
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameVotePlayerHealth extends TurboGameVoteIntValue;

static function int GetCurrentVoteValue(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator)
{
    return KFTurboGameType(TGRI.Level.Game).GetForcedPlayerHealthCount();
}

function OnVoteResult(Name Outcome)
{
    if (Outcome != 'Succeeded')
    {
        return;
    }

    KFTurboGameType(Level.Game).SetForcedPlayerHealthCount(Clamp(VoteIntValue, MinVoteIntValue, MaxVoteIntValue));
}

defaultproperties
{
    MinVoteIntValue=0
    MaxVoteIntValue=6

    VoteID="PLAYERHEALTH"

    VotePercent=0.51f
    bCanSpectatorsVote=false

    VoteInitiatedString="%k%p%d started a vote to %kset player health%d to %k%i%d. Type %kvote yes%d or %kvote no%d in %kconsole%d to vote."
    VoteSucceededVoteString="%kVote%d to %kset player health%d to %k%i%d has %pksucceeded%d."
    VoteFailedVoteString="%kVote%d to %kset player health%d to %k%i%d has %nkfailed%d."
    VoteExpiredVoteString="%kVote%d to %kset player health%d to %k%i%d has %akexpired%d."

    VoteTitleString="%i Player Health"
    VoteDescriptionString="Accepting this vote will change player health for the rest of the game."
}