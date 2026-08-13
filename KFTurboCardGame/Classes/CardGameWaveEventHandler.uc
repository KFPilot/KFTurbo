//Killing Floor Turbo CardGameWaveEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardGameWaveEventHandler extends KFTurbo.TurboWaveEventHandler;

var KFTurboCardGameMut Mutator;
var int GameStartWaitTime;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    Mutator = KFTurboCardGameMut(Owner);

    OnGameStarted = GameStarted;
    OnGameEnded = GameEnded;
    OnWaveStarted = WaveStarted;
    OnWaveEnded = WaveEnded;
}

final function GameStarted(KFTurboGameType GameType, int StartedWave)
{
    GameType.WaveCountDown = Max(GameStartWaitTime, GameType.WaveCountDown);
    Mutator.TurboCardReplicationInfo.StartSelection(StartedWave);
    //Prototype - offer vinyls at a random trader during the first vote round.
    Mutator.SpawnVinylsAtGameStart();
}

final function GameEnded(KFTurboGameType GameType, int Result)
{
    if (Mutator == None || Mutator.TurboCardStatsTcpLink == None)
    {
        return;
    }

    Mutator.TurboCardStatsTcpLink.OnGameEnd(Result, Mutator.TurboCardReplicationInfo.GetActiveCardList());
}

final function WaveStarted(KFTurboGameType GameType, int StartedWave)
{
    if (Mutator == None)
    {
        return;
    }
    
    Mutator.TurboCardReplicationInfo.OnSelectionTimeEnd();
    Mutator.TurboCardGameplayManagerInfo.OnWaveStart(StartedWave);
    Mutator.DestroyVinyls();
}

final function WaveEnded(KFTurboGameType GameType, int EndedWave)
{
    if (GameType.FinalWave <= EndedWave)
    {
        return;
    }

    if (Mutator == None)
    {
        return;
    }

    Mutator.TurboCardGameplayManagerInfo.OnWaveEnd(EndedWave);
    Mutator.TurboCardReplicationInfo.StartSelection(EndedWave + 1);
    Mutator.SpawnVinyls();
}

defaultproperties
{
    GameStartWaitTime=60
}