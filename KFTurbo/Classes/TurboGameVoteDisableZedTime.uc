//Killing Floor Turbo TurboGameVoteDisableZedTime
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameVoteDisableZedTime extends TurboGameVoteBase;

static function bool CanInitiateVote(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator, string VoteString)
{
    if (!Super.CanInitiateVote(TGRI, Initiator, VoteString))
    {
        return false;
    }

    if (!KFTurboGameType(TGRI.Level.Game).bZEDTimeActive)
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

    KFTurboGameType(Level.Game).bZEDTimeActive = false;
}

defaultproperties
{
    VoteID="DISABLEZEDTIME"

    VoteInitiatedString="%k%p%d started a vote to %kdisable zed time%d. Type %kvote yes%d or %kvote no%d in %kconsole%d to vote."
    VoteSucceededVoteString="%kVote%d to %kdisable zed time%d has %pksucceeded%d."
    VoteFailedVoteString="%kVote%d to %kdisable zed time%d has %nkfailed%d."
    VoteExpiredVoteString="%kVote%d to %kdisable zed time%d has %akexpired%d."

    VoteTitleString="Disable Zed Time"
    VoteDescriptionString="Accepting this vote will disable zed time for the rest of the game."
}