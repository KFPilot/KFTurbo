//Killing Floor Turbo TurboGameVoteTest
//Used to test voting system. Doesn't actually get used.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameVoteTest extends TurboGameVoteBase;

//Do not check for vote completion.
function EvaluateVote(Name Reason)
{
    UpdateVoteCounts();
}

defaultproperties
{
    VoteID="TEST"
    VoteDuration=30.f
    

    VotePercent=0.51f
    bCanSpectatorsVote=false

    VoteInitiatedString="%k%p%d started a %ktest vote%d. Type %kvote yes%d or %kvote no in console%d to vote."
    VoteTitleString="My Testvote"
    VoteDescriptionString="Testvote description."
}