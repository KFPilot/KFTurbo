//Killing Floor Turbo TurboIdleServerHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboIdleServerHandler extends Info;

var KFTurboGameType TurboGT;
var int EmptyIdleCount;
var bool bHasExpired;

const EMPTY_IDLE_EXPIRE_COUNT = 1440; //If EmptyIdleCount reaches this, the server should be considered expired and try to restart.

function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    SetTimer(10.f, true);
    Disable('Tick');

    TurboGT = KFTurboGameType(Level.Game);
    DebugLog("Idle checker is enabled.");
}

static final function DebugLog(string String)
{
    Log(String, 'KFTurboIdleHandler');
}

event Timer()
{
    if (bHasExpired)
    {
        return;
    }

    if (!TurboGT.bWaitingToStartMatch)
    {
        EmptyIdleCount = 0;
        SetTimer(0.f, false);
        LifeSpan = 0.1f;
        return;
    }

    if (TurboGT.NumPlayers > 0)
    {
        EmptyIdleCount = 0;
        return;
    }

    EmptyIdleCount++;

    if (EmptyIdleCount > EMPTY_IDLE_EXPIRE_COUNT)
    {
        DebugLog("Idle checker has expired. Initiating re-travel to current level and options...");
        Level.ServerTravel(Level.GetURLMap(true), true);
        SetTimer(0.f, false);
        bHasExpired = true;
    }
}

defaultproperties
{

}