//Killing Floor Turbo TurboPlayerReplicationInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerReplicationInfo extends KFPlayerReplicationInfo;

var int ShieldStrength;

var int HealthMax;
var int HealthHealed;
var bool bVotedForTraderEnd;

var array<TurboPlayerStatCollectorBase> StatCollectorList;
var array<TurboPlayerStatCollectorBase> StatReplicatorList;

var bool bHasRegisteredOnReceiveStatCollector;
var bool bHasRegisteredOnReceiveStatReplicator;
delegate OnReceiveStatCollector(TurboPlayerReplicationInfo PlayerReplicationInfo, TurboPlayerStatCollectorBase Collector);
delegate OnReceiveStatReplicator(TurboPlayerReplicationInfo PlayerReplicationInfo, TurboPlayerStatCollectorBase Replicator);


replication
{
	reliable if ( bNetDirty && (Role == Role_Authority) )
		ShieldStrength, HealthMax, HealthHealed, bVotedForTraderEnd;
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
}

simulated function Destroyed()
{
    local int Index;

    if (Level.bLevelChange)
    {
        Super.Destroyed();
        return;
    }

    for (Index = StatCollectorList.Length - 1; Index >= 0; Index--)
    {
        if (StatCollectorList[Index] != None)
        {
            StatCollectorList[Index].Destroy();
        }
    }

    for (Index = StatReplicatorList.Length - 1; Index >= 0; Index--)
    {
        if (StatReplicatorList[Index] != None)
        {
            StatReplicatorList[Index].Destroy();
        }
    }

    Super.Destroyed();
}

simulated function RegisterStatCollector(TurboPlayerStatCollectorBase Collector)
{
    StatCollectorList.Length = StatCollectorList.Length + 1;
    StatCollectorList[StatCollectorList.Length - 1] = Collector;
    OnReceiveStatCollector(Self, Collector);
}

simulated function UnregisterStatCollector(TurboPlayerStatCollectorBase Collector)
{
    local int Index;
    for (Index = StatCollectorList.Length - 1; Index >= 0; Index--)
    {
        if (StatCollectorList[Index] == Collector || StatCollectorList[Index] == None)
        {
            StatCollectorList.Remove(Index, 1);
        }
    }
}

simulated function RegisterStatReplicator(TurboPlayerStatCollectorBase Replicator)
{
    StatReplicatorList.Length = StatReplicatorList.Length + 1;
    StatReplicatorList[StatReplicatorList.Length - 1] = Replicator;
    OnReceiveStatReplicator(Self, Replicator);
}

simulated function UnregisterStatReplicator(TurboPlayerStatCollectorBase Replicator)
{
    local int Index;
    for (Index = StatReplicatorList.Length - 1; Index >= 0; Index--)
    {
        if (StatReplicatorList[Index] == Replicator || StatReplicatorList[Index] == None)
        {
            StatReplicatorList.Remove(Index, 1);
        }
    }
}

defaultproperties
{
    ShieldStrength=0

    HealthMax=100
    HealthHealed=0

    bVotedForTraderEnd=false
}