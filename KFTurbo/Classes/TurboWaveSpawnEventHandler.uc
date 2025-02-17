//Killing Floor Turbo TurboWaveSpawnEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboWaveSpawnEventHandler extends Object;

//Note that wave 0 is wave 1 for the UI.

//Allows for mutation of the generated next spawn squad.
static function OnNextSpawnSquadGenerated(KFTurboGameType GameType, out array < class<KFMonster> > NextSpawnSquad);

static function OnBossSpawned(KFTurboGameType GameType);
//Allows for mutation of the generated next spawn squad.
static function OnAddBossBuddySquad(KFTurboGameType GameType, out int TotalSquadSize);

//Event registration.
static final function RegisterWaveHandler(Actor Context, class<TurboWaveSpawnEventHandler> WaveEventHandlerClass)
{
    local KFTurboGameType KFTurboGameType;
    local int Index;

    if (Context == None || WaveEventHandlerClass == None)
    {
        return;
    }

    KFTurboGameType = KFTurboGameType(Context.Level.Game);

    if (KFTurboGameType == None)
    {
        return;
    }

    for (Index = 0; Index < KFTurboGameType.WaveSpawnEventHandlerList.Length; Index++)
    {
        if (KFTurboGameType.WaveSpawnEventHandlerList[Index] == WaveEventHandlerClass)
        {
            return;
        }
    }

    KFTurboGameType.WaveSpawnEventHandlerList[KFTurboGameType.WaveSpawnEventHandlerList.Length] = WaveEventHandlerClass;
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
        GameType.WaveSpawnEventHandlerList[Index].static.OnNextSpawnSquadGenerated(GameType, NextSpawnSquad);
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
        GameType.WaveSpawnEventHandlerList[Index].static.OnAddBossBuddySquad(GameType, TotalSquadSize);
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
        GameType.WaveSpawnEventHandlerList[Index].static.OnBossSpawned(GameType);
    }
}