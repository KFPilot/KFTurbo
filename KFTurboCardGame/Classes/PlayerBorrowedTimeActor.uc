//Killing Floor Turbo PlayerBorrowedTimeActor
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PlayerBorrowedTimeActor extends Engine.ReplicationInfo;

var TurboServerTimeActor ServerTimeActor;

var int BorrowedTimeStart, BorrowedTimeEnd;
var bool bHasExecutedBorrowedTime;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority )
		BorrowedTimeStart, BorrowedTimeEnd;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    ServerTimeActor = TurboGameReplicationInfo(Level.GRI).ServerTimeActor;

    if (Level.NetMode == NM_DedicatedServer)
    {
        return;
    }
    
    SetTimer(0.1f, false);
}

simulated function Timer()
{
    if (ServerTimeActor == None)
    {
        ServerTimeActor = TurboGameReplicationInfo(Level.GRI).ServerTimeActor;

        if (ServerTimeActor == None)
        {
            SetTimer(0.1f, false);
            return;
        }
    }

    if (Level.GetLocalPlayerController() != None && RegisterToOverlay(Level.GetLocalPlayerController()))
    {
        return;
    }

    SetTimer(0.1f, false);
}

simulated function bool RegisterToOverlay(PlayerController PlayerController)
{
    local TurboCardOverlay CardOverlay;

    CardOverlay = class'TurboCardOverlay'.static.FindCardOverlay(PlayerController);

    if (CardOverlay == None)
    {
        return false;
    }

    CardOverlay.BorrowedTimeActor = Self;
    return true;
}

simulated final function float GetBorrowedTimeRemaining()
{
    if (ServerTimeActor == None || BorrowedTimeEnd < 0.f)
    {
        return -1.f;
    }
    
    return ServerTimeActor.GetServerTimeSecondsUntil(BorrowedTimeEnd);
}

function StartBorrowedTime()
{
    BorrowedTimeStart = Level.TimeSeconds;
    BorrowedTimeEnd = BorrowedTimeStart + GetWaveBorrowedTime();
    ForceNetUpdate();
}

function int GetWaveBorrowedTime()
{
    local float TotalTime;

    if (KFGameType(Level.Game).WaveNum >= KFGameType(Level.Game).FinalWave)
    {
        return 60.f * 5.f;
    }

    TotalTime = 60.f; //Give 60 seconds base.
    TotalTime += float(KFGameType(Level.Game).TotalMaxMonsters) * 1.5f;
    return TotalTime;
}

function StopBorrowedTime()
{
    BorrowedTimeStart = -1;
    BorrowedTimeEnd = -1;
    ForceNetUpdate();
}

final function ForceNetUpdate()
{
    NetUpdateTime = Level.TimeSeconds - ((1.f / NetUpdateFrequency) * 2.f);
}

function Tick(float DeltaTime)
{
    local Controller C;
    if (BorrowedTimeEnd < 0)
    {
        if (KFGameType(Level.Game).bWaveInProgress)
        {
            StartBorrowedTime();
        }
        return;
    }

    if (!KFGameType(Level.Game).bWaveInProgress)
    {
        StopBorrowedTime();
        return;
    }

    if (BorrowedTimeEnd > Level.TimeSeconds)
    {
        return;
    }

    if (bHasExecutedBorrowedTime)
    {
        return;
    }

    bHasExecutedBorrowedTime = true;
    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if (PlayerController(C) != None && PlayerController(C).Pawn != None && !PlayerController(C).Pawn.bDeleteMe && PlayerController(C).Pawn.Health > 0)
        {
            PlayerController(C).Pawn.Died(None, class'OutOfBorrowedTime_DT', PlayerController(C).Pawn.Location);
        }
    }
}

defaultproperties
{
    BorrowedTimeStart = -1;
    BorrowedTimeEnd = -1;
    bHasExecutedBorrowedTime = false
    NetUpdateFrequency=0.1f
}