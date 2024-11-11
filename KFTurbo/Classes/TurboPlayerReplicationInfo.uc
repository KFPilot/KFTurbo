class TurboPlayerReplicationInfo extends KFPlayerReplicationInfo;

var int ShieldStrength;

var int HealthMax;
var int HealthHealed;
var bool bVotedForTraderEnd;

replication
{
	reliable if ( bNetDirty && (Role == Role_Authority) )
		ShieldStrength, HealthMax, HealthHealed;
}

function Timer()
{
    Super.Timer();
    
    if(Controller(Owner) != None && Controller(Owner).Pawn != None)
    {
        ShieldStrength = Controller(Owner).Pawn.ShieldStrength;
        HealthMax = Controller(Owner).Pawn.HealthMax;
    }
	else
    {
        ShieldStrength = 0.f;
		HealthMax = 100;
    }

    if (bOnlySpectator && bVotedForTraderEnd)
    {
        bVotedForTraderEnd = false;
    }
}

function RequestTraderEnd()
{
    local KFTurboGameType GameType;

    if (bVotedForTraderEnd)
    {
        return;
    }

    GameType = KFTurboGameType(Level.Game);

    if (GameType == None || GameType.bWaveInProgress || GameType.WaveCountDown <= 10)
    {
        return;
    }

    bVotedForTraderEnd = true;
    GameType.AttemptTraderEnd(TurboPlayerController(Owner));
}

function ClearTraderEndVote()
{
    bVotedForTraderEnd = false;
}

defaultproperties
{
    ShieldStrength=0

    HealthMax=100
    HealthHealed=0

    bVotedForTraderEnd=false
}