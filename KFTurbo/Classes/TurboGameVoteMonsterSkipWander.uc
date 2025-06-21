//Killing Floor Turbo TurboGameVoteMonsterSkipWander
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameVoteMonsterSkipWander extends TurboGameVoteBase;

static function bool CanInitiateVote(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator, string VoteString)
{
    local KFTurboMut KFTurboMut;
    if (!Super.CanInitiateVote(TGRI, Initiator, VoteString))
    {
        return false;
    }

    KFTurboMut = class'KFTurboMut'.static.FindMutator(TGRI.Level.Game);

    if (KFTurboMut == None || KFTurboMut.bSkipInitialMonsterWander)
    {
        return false;
    }

    return true;
}

function OnVoteResult(Name Outcome)
{
    local KFTurboMut KFTurboMut;
    if (Outcome != 'Succeeded')
    {
        return;
    }

    KFTurboMut = class'KFTurboMut'.static.FindMutator(Level.Game);

    if (KFTurboMut == None)
    {
        return;
    }

    KFTurboMut.bSkipInitialMonsterWander = true;
}

defaultproperties
{
    VoteID="DISABLEWANDER"

    VoteInitiatedString="%k%p%d started a vote to %kdisable zed wandering%d. Type %kvote yes%d or %kvote no%d in %kconsole%d to vote."
    VoteSucceededVoteString="%kVote%d to %kdisable zed wandering%d has %pksucceeded%d."
    VoteFailedVoteString="%kVote%d to %kdisable zed wandering%d has %nkfailed%d."
    VoteExpiredVoteString="%kVote%d to %kdisable zed wandering%d has %akexpired%d."

    VoteTitleString="Disable Zed Wandering"
    VoteDescriptionString="Accepting this vote will disable initial zed wandering."
}