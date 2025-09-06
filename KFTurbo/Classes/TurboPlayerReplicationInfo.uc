//Killing Floor Turbo TurboPlayerReplicationInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerReplicationInfo extends KFPlayerReplicationInfo;

var class<TurboSpectatorActor> SpectatorActorClass;

enum EConnectionState
{
    Normal,
    PoorConnection,
    NoConnection
};
var float LastPoorConnectionTime;
var float LastNoConnectionTime;

var int ShieldStrength;

var int HealthMax;
var int HealthHealed;
var bool bVotedForTraderEnd;

var array<TurboPlayerStatCollectorBase> StatCollectorList;
var array<TurboPlayerStatCollectorBase> StatReplicatorList;

var array<TurboPlayerCustomInfo> PlayerCustomInfoList;

//Doesn't seem to be an API for checking a delegate is bound so we'll just do the bookkeeping.
var bool bHasRegisteredOnReceiveStatCollector;
var bool bHasRegisteredOnReceiveStatReplicator;
var bool bHasRegisteredOnReceiveCustomInfo;

delegate OnReceiveStatCollector(TurboPlayerReplicationInfo PlayerReplicationInfo, TurboPlayerStatCollectorBase Collector);
delegate OnReceiveStatReplicator(TurboPlayerReplicationInfo PlayerReplicationInfo, TurboPlayerStatCollectorBase Replicator);
delegate OnReceiveCustomInfo(TurboPlayerReplicationInfo PlayerReplicationInfo, TurboPlayerCustomInfo Collector);

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

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role == ROLE_Authority && SpectatorActorClass != None && TurboPlayerController(Owner) != None)
    {
        Spawn(SpectatorActorClass, Self);
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

    for (Index = PlayerCustomInfoList.Length - 1; Index >= 0; Index--)
    {
        if (PlayerCustomInfoList[Index] != None)
        {
            PlayerCustomInfoList[Index].Destroy();
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

simulated function RegisterCustomInfo(TurboPlayerCustomInfo CustomInfo)
{
    PlayerCustomInfoList.Length = PlayerCustomInfoList.Length + 1;
    PlayerCustomInfoList[PlayerCustomInfoList.Length - 1] = CustomInfo;
    OnReceiveCustomInfo(Self, CustomInfo);
}

simulated function UnregisterCustomInfo(TurboPlayerCustomInfo CustomInfo)
{
    local int Index;
    for (Index = PlayerCustomInfoList.Length - 1; Index >= 0; Index--)
    {
        if (PlayerCustomInfoList[Index] == CustomInfo || PlayerCustomInfoList[Index] == None)
        {
            PlayerCustomInfoList.Remove(Index, 1);
        }
    }
}

simulated final function EConnectionState GetConnectionState()
{
    if (PacketLoss >= 50)
    {
        LastNoConnectionTime = Level.TimeSeconds + 10.f;
    }
    else if (PacketLoss >= 5)
    {
        LastPoorConnectionTime = Level.TimeSeconds + 10.f;
    }

    if (LastNoConnectionTime > 0.f && Level.TimeSeconds < LastNoConnectionTime)
    {
        return NoConnection;
    }
    else if (LastPoorConnectionTime > 0.f && Level.TimeSeconds < LastPoorConnectionTime)
    {
        return PoorConnection;
    }

    return Normal;
}

defaultproperties
{
    SpectatorActorClass=class'TurboSpectatorActorEye'

    ShieldStrength=0

    HealthMax=100
    HealthHealed=0

    bVotedForTraderEnd=false
}