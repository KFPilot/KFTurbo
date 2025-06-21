//Killing Floor Turbo TurboWaveEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboWaveEventHandler extends TurboEventHandler;

//Note that wave 0 is wave 1 for the UI.

delegate OnGameStarted(KFTurboGameType GameType, int StartingWave);

delegate OnGameEnded(KFTurboGameType GameType, int Result);

delegate OnWaveStarted(KFTurboGameType GameType, int StartedWave);
//EndedWave is the wave number we just completed (is Invasion::WaveNum - 1 as this is called right after we incremented the wave count and setup the trader wave)
delegate OnWaveEnded(KFTurboGameType GameType, int EndedWave);

static function TurboEventHandler CreateHandler(Actor Context)
{
    local TurboEventHandler Handler;
    local KFTurboGameType GameType;

    Handler = Super.CreateHandler(Context);

    if (Handler == None)
    {
        return None;
    }

    GameType = KFTurboGameType(Context.Level.Game);
    GameType.WaveEventHandlerList[GameType.WaveEventHandlerList.Length] = TurboWaveEventHandler(Handler);
    return Handler;
}

//Event broadcasting.
static final function BroadcastGameStarted(KFTurboGameType GameType, int StartedWave)
{
    local int Index;
    if (GameType == None)
    {
        return;
    }

    for (Index = GameType.WaveEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.WaveEventHandlerList[Index].OnGameStarted(GameType, StartedWave);
    }
}

static final function BroadcastGameEnded(KFTurboGameType GameType, int Result)
{
    local int Index;
    if (GameType == None)
    {
        return;
    }

    for (Index = GameType.WaveEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.WaveEventHandlerList[Index].OnGameEnded(GameType, Result);
    }
}

static final function BroadcastWaveStarted(KFTurboGameType GameType, int StartedWave)
{
    local int Index;
    if (GameType == None)
    {
        return;
    }

    for (Index = GameType.WaveEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.WaveEventHandlerList[Index].OnWaveStarted(GameType, StartedWave);
    }
}

static final function BroadcastWaveEnded(KFTurboGameType GameType, int EndedWave)
{
    local int Index;

    if (GameType == None)
    {
        return;
    }

    for (Index = GameType.WaveEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.WaveEventHandlerList[Index].OnWaveEnded(GameType, EndedWave);
    }
}