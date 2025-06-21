//Killing Floor Turbo TurboServerTimeActor
//ReplicationInfo that attempts to provide a general way for different systems to sync up to the server's Level.TimeSeconds on the authority and remote.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboServerTimeActor extends ReplicationInfo;

var protected int ServerTimeSeconds, LastServerTimeSeconds;
var protected float ClientDeltaTimeAdjustment;
var protected float ClientServerTimeSeconds;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority )
		ServerTimeSeconds;
}

static final function TurboServerTimeActor FindTurboServerTimeActor(Actor Context)
{
    if (Context == None || TurboGameReplicationInfo(Context.Level.GRI) == None)
    {
        return None;
    }

    return TurboGameReplicationInfo(Context.Level.GRI).ServerTimeActor;
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

    TurboGameReplicationInfo(Level.GRI).ServerTimeActor = Self;
}

defaultproperties
{
    NetUpdateFrequency=0.5f

    ServerTimeSeconds=0
    LastServerTimeSeconds=0

    ClientServerTimeSeconds=0.f
    ClientDeltaTimeAdjustment=0.95f
}