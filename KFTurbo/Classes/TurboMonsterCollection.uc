class TurboMonsterCollection extends Object
     editinlinenew;

var array< class<KFMonster> > LoadedMonsterList;

//Initializes this collection at the start of a game.
function InitializeCollection() {}

//Initializes this collection for a given wave number.
function InitializeForWave(int WaveNumber) {}

//Prepares a sequence of squads to spawn.
function PrepareSequence() {}

function TurboMonsterSquad GetNextMonsterSquad()
{
     return None;
} 

//Appends a list of monsters to spawn to OutNextSpawnSquad given a Final Squad Number (typically represents heal count for boss) and a Player Count.
function ApplyFinalSquad(int FinalSquadNumber, int PlayerCount, out array< class<KFMonster> > OutNextSpawnSquad) {}

//Default scaling to wave size by difficulty.
static final function float GetDifficultyModifier(float GameDifficulty)
{
    if ( GameDifficulty >= 7.0 ) // Hell on Earth
    {
        return 1.7f;
    }
    else if ( GameDifficulty >= 5.0 ) // Suicidal
    {
        return 1.5f;
    }
    else if ( GameDifficulty >= 4.0 ) // Hard
    {
        return 1.3f;
    }
    else if ( GameDifficulty >= 2.0 ) // Normal
    {
        return 1.0f;
    }
    
    return 0.7f;
}

//Default scaling to wave size by player count.
static final function float GetPlayerCountModifier(int PlayerCount)
{
    switch ( PlayerCount )
    {
        case 1:
            return 1.f;
        case 2:
            return 2.f;
        case 3:
            return 2.75f;
        case 4:
            return 3.5f;
        case 5:
            return 4.f;
        case 6:
            return 4.5f;
    }

    return float(PlayerCount) *0.8f;
}

//Gets the initial total monsters for a wave.
function int GetWaveTotalMonsters(int WaveNumber, float GameDifficulty, int PlayerCount )
{
     return 0;
}

//Gets the max monsters for a wave.
function int GetWaveMaxMonsters(int WaveNumber, float GameDifficulty, int PlayerCount)
{
     return 0;
}

//Gets the wave difficulty for a given wave.
function float GetWaveDifficulty(int WaveNumber)
{
     return 1.f;
}

//Gets the spawn rate for a given wave.
function float GetNextSquadSpawnTime(int WaveNumber)
{
     return 1.f;
}