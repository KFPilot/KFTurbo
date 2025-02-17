// KFTurbo Holdout Game Type's wave spawn system.
class TurboMonsterCollectionHoldoutImpl extends TurboMonsterCollectionWaveBase;

var TurboMonsterHoldoutWave HoldoutWave;

function InitializeCollection()
{
     Super.InitializeCollection();

     HoldoutWave = TurboMonsterHoldoutWave(WaveList[0]);
}

function InitializeForWave(int WaveNumber)
{
     HoldoutWave.InitializeForWave(WaveNumber);
     Super.InitializeForWave(0);
}

function int GetWaveTotalMonsters(int WaveNumber, float GameDifficulty, int PlayerCount)
{
     return float(HoldoutWave.TotalMonsters) * GetDifficultyModifier(GameDifficulty) * GetPlayerCountModifier(PlayerCount);
}

function int GetWaveMaxMonsters(int WaveNumber, float GameDifficulty, int PlayerCount)
{
     return HoldoutWave.GetMaxMonsters(PlayerCount);
}

function float GetWaveDifficulty(int WaveNumber)
{
     return HoldoutWave.WaveDifficulty;
}

function float GetNextSquadSpawnTime(int WaveNumber, int PlayerCount)
{
     return HoldoutWave.GetNextSquadSpawnTime(PlayerCount);
}

function float GetScoreMultiplier()
{
     return HoldoutWave.GetScoreMultiplier();
}

defaultproperties
{
	Begin Object Class=TurboMonsterHoldoutWave Name=HoldoutWave0
	End Object
	WaveList(0)=TurboMonsterWave'HoldoutWave0'
}