//Killing Floor Turbo TurboCardWaveSizeModifier
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardWaveSizeModifier extends KFTurbo.TurboWaveEventHandler;

var float WaveSizeModifier;

static function OnWaveStarted(KFTurboGameType GameType, int StartedWave)
{
    //Wave size modification should not apply to boss wave.
    if (GameType.FinalWave <= StartedWave)
    {
        return;
    }

    GameType.TotalMaxMonsters = Max(float(GameType.TotalMaxMonsters) * default.WaveSizeModifier, 1);
    KFGameReplicationInfo(GameType.GameReplicationInfo).MaxMonsters = GameType.TotalMaxMonsters;
}

static function OnAddBossBuddySquad(KFTurboGameType GameType, out int TotalSquadSize)
{
    TotalSquadSize = Max(float(TotalSquadSize) * default.WaveSizeModifier, 1);
}

defaultproperties
{
    WaveSizeModifier=1.f
}