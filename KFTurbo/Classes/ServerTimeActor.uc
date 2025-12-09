//Common Core ServerTimeActor
//This actor provides a basic way to handle synchronizing times between the authority and the remote.
//The goal is to allow other systems to only need to send the remote the server's Level.TimeSeconds and/or times relative to that.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/CommonCore.
class ServerTimeActor extends ReplicationInfo;

var protected int ServerTimeSeconds, LastServerTimeSeconds;
var protected float ClientServerTimeSeconds;

//This property applies a tiny amount of time dilation to the remote's tick.
var protected float ClientDeltaTimeAdjustment;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority )
		ServerTimeSeconds;
}

static final function ServerTimeActor FindServerTimeActor(Actor Context)
{
    if (Context == None || CoreGameReplicationInfo(Context.Level.GRI) == None)
    {
        return None;
    }

    return CoreGameReplicationInfo(Context.Level.GRI).ServerTimeActor;
}

simulated final function float GetServerTimeSeconds()
{
    return ClientServerTimeSeconds;
}

simulated final function float GetServerTimeSecondsSince(float TimeSeconds)
{
    return FMax(ClientServerTimeSeconds - TimeSeconds, 0.f);
}

simulated final function float GetServerTimeSecondsUntil(float TimeSeconds)
{
    return FMax(TimeSeconds - ClientServerTimeSeconds, 0.f);
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role == ROLE_Authority)
    {
        SetServerTimeSeconds(Level.TimeSeconds);
    }
    else
    {
        SetTimer(0.1f, false);
    }
}

function SetServerTimeSeconds(int NewServerTimeSeconds)
{
    ClientServerTimeSeconds = Level.TimeSeconds;

    if (NewServerTimeSeconds == ServerTimeSeconds)
    {
        return;
    }

    ServerTimeSeconds = NewServerTimeSeconds;
    NetUpdateTime = Level.TimeSeconds - 3.f;
}

simulated function Tick(float DeltaTime)
{
    if (Role == ROLE_Authority)
    {
        SetServerTimeSeconds(Level.TimeSeconds);
        return;
    }

    if (ServerTimeSeconds > LastServerTimeSeconds)
    {
        LastServerTimeSeconds = ServerTimeSeconds;
        ClientServerTimeSeconds = float(LastServerTimeSeconds);
    }

    ClientServerTimeSeconds = FMin(ClientServerTimeSeconds + (DeltaTime * ClientDeltaTimeAdjustment), LastServerTimeSeconds + 1.f);
}

simulated function Timer()
{
    if (Role == ROLE_Authority)
    {
        return;
    }
    
    if (Level.GRI == None)
    {
        SetTimer(0.1f, false);
        return;
    }

    CoreGameReplicationInfo(Level.GRI).ServerTimeActor = Self;
}

defaultproperties
{
    NetUpdateFrequency=0.5f

    ServerTimeSeconds=0
    LastServerTimeSeconds=0

    ClientServerTimeSeconds=0.f

    ClientDeltaTimeAdjustment=0.95f
}