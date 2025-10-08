//Killing Floor Turbo TurboGameplayHelper
//Helpful gameplay statics.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameplayHelper extends Object;

static final function array<CorePlayerController> GetPlayerControllerList(LevelInfo Level, optional bool bIncludeSpectators)
{
    return CoreKFGameType(Level.Game).GetPlayerList(bIncludeSpectators);
}

static final function int GetPlayerControllerCount(LevelInfo Level, optional bool bIncludeSpectators)
{
    return CoreKFGameType(Level.Game).GetPlayerCount(bIncludeSpectators);
}

static final function array<CoreHumanPawn> GetPlayerPawnList(LevelInfo Level)
{
    return CoreKFGameType(Level.Game).GetPlayerPawnList();
}

static final function array<Monster> GetMonsterPawnList(LevelInfo Level, optional class<Monster> FilterClass)
{
    return CoreKFGameType(Level.Game).GetMonsterPawnList(FilterClass);
}