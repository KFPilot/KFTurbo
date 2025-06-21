//Killing Floor Turbo TurboWaveSpawnEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboWaveSpawnEventHandler extends TurboEventHandler;

//Note that wave 0 is wave 1 for the UI.

//Allows for mutation of the generated next spawn squad.
delegate OnNextSpawnSquadGenerated(KFTurboGameType GameType, out array < class<KFMonster> > NextSpawnSquad);

delegate OnBossSpawned(KFTurboGameType GameType);
//Allows for mutation of the generated next spawn squad.
delegate OnAddBossBuddySquad(KFTurboGameType GameType, out int TotalSquadSize);

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
    GameType.WaveSpawnEventHandlerList[GameType.WaveSpawnEventHandlerList.Length] = TurboWaveSpawnEventHandler(Handler);
    return Handler;
}

//Event broadcasting.
static final function BroadcastNextSpawnSquadGenerated(KFTurboGameType GameType,  out array < class<KFMonster> > NextSpawnSquad)
{
    local int Index;

    if (GameType == None)
    {
        return;
    }

    for (Index = GameType.WaveSpawnEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.WaveSpawnEventHandlerList[Index].OnNextSpawnSquadGenerated(GameType, NextSpawnSquad);
    }
}

static final function BroadcastAddBossBuddySquad(KFTurboGameType GameType, out int TotalSquadSize)
{
    local int Index;

    if (GameType == None)
    {
        return;
    }

    for (Index = GameType.WaveSpawnEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.WaveSpawnEventHandlerList[Index].OnAddBossBuddySquad(GameType, TotalSquadSize);
    }
}

static final function BroadcasBossSpawned(KFTurboGameType GameType)
{
    local int Index;

    if (GameType == None)
    {
        return;
    }

    for (Index = GameType.WaveSpawnEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.WaveSpawnEventHandlerList[Index].OnBossSpawned(GameType);
    }
}