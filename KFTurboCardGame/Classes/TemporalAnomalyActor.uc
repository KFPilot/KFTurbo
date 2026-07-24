//Killing Floor Turbo TemporalAnomalyActor
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TemporalAnomalyActor extends Engine.ReplicationInfo;

var float StartTimeDilation;
var float EndTimeDilation;
var float ApplyStartTime;
var float ApplyEndTime;
var int ID;

var int LastAppliedID;
var float TimeUntilNextDilation;

var const float MinSpeedUpVariance;
var const float MaxSpeedUpVariance;

var const float MinSpeedDownVariance;
var const float MaxSpeedDownVariance;

var const float MinAnomalyTime;
var const float MaxAnomalyTime;

var const float MinRegularTime;
var const float MaxRegularTime;

var ServerTimeActor ServerTimeActor;

replication
{
    reliable if (Role == ROLE_Authority)
        StartTimeDilation, EndTimeDilation, ApplyStartTime, ApplyEndTime, ID;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role == ROLE_Authority)
    {
        InitializeServerTimeActor();
        CoreKFGameType(Level.Game).RequestZedTimeDisable(self);
        ID = 0;
        TimeUntilNextDilation = 10.f;
    }

    GotoState('Initializing');
    InitialState = GetStateName();
}

function Destroyed()
{
    CoreKFGameType(Level.Game).RevokeZedTimeDisable(self);
    SetTimeDilation(1.f); //Make sure we don't leave an anomaly's time dilation applied forever.

    Super.Destroyed();
}

simulated function bool InitializeServerTimeActor()
{
    if (CoreGameReplicationInfo(Level.GRI) == None)
    {
        return false;
    }

    if (CoreGameReplicationInfo(Level.GRI).ServerTimeActor == None)
    {
        return false;
    }

    ServerTimeActor = CoreGameReplicationInfo(Level.GRI).ServerTimeActor;
    return true;
}

final function float GetSpeedUpRate()
{
    return (MinSpeedUpVariance + ((MaxSpeedUpVariance - MinSpeedUpVariance) * FRand()));
}

final function float GetSpeedDownRate()
{
    return (MinSpeedDownVariance + ((MaxSpeedDownVariance - MinSpeedDownVariance) * FRand()));
}

final function float GetAnomalyDuration()
{
    return (MinAnomalyTime + ((MaxAnomalyTime - MinAnomalyTime) * FRand()));
}

final function float GetRegularTimeDuration()
{
    return (MinRegularTime + ((MaxRegularTime - MinRegularTime) * FRand()));
}

function SetupNextTimeDilation(float DeltaTime)
{
    if (TimeUntilNextDilation > 0.f)
    {
        TimeUntilNextDilation -= DeltaTime / Level.TimeDilation;
        if (TimeUntilNextDilation > 0.f)
        {
            return;
        }
    }

    ID++;
    ApplyStartTime = Level.TimeSeconds + 2.f;
    ApplyEndTime = ApplyStartTime + 0.5f;
    StartTimeDilation = Level.TimeDilation;

    if (EndTimeDilation == 1.f)
    {
        if (FRand() > 0.5f)
        {
            EndTimeDilation = GetSpeedUpRate();
        }
        else
        {
            EndTimeDilation = GetSpeedDownRate();
        }
        
        TimeUntilNextDilation = GetAnomalyDuration();
    }
    else
    {
        EndTimeDilation = 1.f;
        TimeUntilNextDilation = GetRegularTimeDuration();
    }

    ForceNetUpdate();
}

simulated final function SetTimeDilation(float TimeDilation)
{
    if (Level.Game != None)
    {
        Level.Game.SetGameSpeed(TimeDilation);
    }
    else
    {
        Level.TimeDilation = 1.1f * TimeDilation; //Wow base time dilations is 1.1!
    }
}

simulated function Tick(float DeltaTime)
{
    if (Role == ROLE_Authority)
    {
        SetupNextTimeDilation(DeltaTime);
    }

    if (LastAppliedID == ID || EndTimeDilation == 0.f)
    {
        return;
    }

    if (ApplyStartTime > ServerTimeActor.GetServerTimeSeconds())
    {
        return;
    }

    if (ApplyEndTime <= ServerTimeActor.GetServerTimeSeconds())
    {
        SetTimeDilation(EndTimeDilation);
        LastAppliedID = ID;
        return;
    }

    SetTimeDilation(Lerp((ServerTimeActor.GetServerTimeSeconds() - ApplyStartTime) / (ApplyEndTime - ApplyStartTime), StartTimeDilation, EndTimeDilation));
}

simulated state Initializing
{
    simulated function Tick(float DeltaTime) {}

Begin:
    while(true)
    {
        Sleep(0.1f);

        if (InitializeServerTimeActor())
        {
            log("Successfully started...");
            GotoState('');
            break;
        }
    }
}

function ForceNetUpdate()
{
    NetUpdateTime = Level.TimeSeconds - 5.f;
}

defaultproperties
{
    MinSpeedUpVariance=1.125f
    MaxSpeedUpVariance=1.2f

    MinSpeedDownVariance=0.65f
    MaxSpeedDownVariance=0.85f

    MinAnomalyTime=20.f
    MaxAnomalyTime=30.f

    MinRegularTime=25.f
    MaxRegularTime=35.f
    
    NetUpdateFrequency=1.f
}