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
            EndTimeDilation = 1.25f + (FRand() * 0.25f);
        }
        else
        {
            EndTimeDilation = 0.8f - (FRand() * 0.15f);
        }

        TimeUntilNextDilation = 20.f + (15.f * FRand());
    }
    else
    {
        EndTimeDilation = 1.f;
        TimeUntilNextDilation = 30.f + (30.f * FRand());
    }

    ForceNetUpdate();
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
        Level.TimeDilation = EndTimeDilation;
        LastAppliedID = ID;
        return;
    }

    Level.TimeDilation = Lerp((ServerTimeActor.GetServerTimeSeconds() - ApplyStartTime) / (ApplyEndTime - ApplyStartTime), StartTimeDilation, EndTimeDilation);
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
    NetUpdateFrequency=1.f
}