//Killing Floor Turbo TurboGameVoteEndTrader
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameVoteEndTrader extends TurboGameVoteBase;

static function bool CanInitiateVote(TurboGameReplicationInfo TGRI, TurboPlayerReplicationInfo Initiator, string VoteString)
{
    local KFTurboGameType GameType;
    if (!Super.CanInitiateVote(TGRI, Initiator, VoteString))
    {
        return false;
    }

    GameType = KFTurboGameType(TGRI.Level.Game);

    if (GameType == None || GameType.bWaveInProgress || GameType.WaveCountDown <= 10)
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

    KFTurboGameType(Level.Game).WaveCountDown = Min(KFTurboGameType(Level.Game).WaveCountDown, 10);
    TurboGameReplicationInfo(Level.GRI).TimeToNextWave = KFTurboGameType(Level.Game).WaveCountDown;
}

state VoteInProgress
{
Begin:
    sleep(0.25f);
    while(true)
    {
        if (KFTurboGameType(Level.Game).bWaveInProgress || KFTurboGameType(Level.Game).WaveCountDown <= 10)
        {
            break;
        }
        
        sleep(0.25f);
    }

    OnVoteExpired();
}

defaultproperties
{
    VoteID="ENDTRADER"
    VoteDuration=-1.f
    

    VotePercent=0.51f
    bCanSpectatorsVote=false

    VoteInitiatedString="%k%p%d started a vote to %kend trader%d. Type %kEndTrader in console%d to vote."
    VoteSucceededVoteString="%kVote%d to %kend trader%d has %pksucceeded%d."
    VoteFailedVoteString="%kVote%d to %kend trader%d has %nkfailed%d."
    VoteExpiredVoteString=""
    
    bBroadcastSucceeded=true
    bBroadcastFailed=true
    bBroadcastExpired=false

    VoteTitleString="End Trader"
    VoteDescriptionString="Accepting this vote will end trader time."
}