class TurboMonsterCollection extends Object
     editinlinenew;

var TurboMonsterCollectionWave WaveList[10];
var TurboMonsterCollectionSquad BossSquadList[3];

var array< class<KFMonster> > LoadedMonsterList;

//These arrays are a cached list of a wave's squads. We construct sequences with them using them to reset squad lists once they're empty.
var array<TurboMonsterCollectionSquad> RegularSquadList;
var array<TurboMonsterCollectionSquad> MixInSquadList;
var array<TurboMonsterCollectionSquad> BeatSquadList;

//These are the "live" versions of the cached list that are consumed on use. When empty, they reset to the above cached list.
var array<TurboMonsterCollectionSquad> RemainingRegularSquadList;
var array<TurboMonsterCollectionSquad> RemainingMixInSquadList;
var array<TurboMonsterCollectionSquad> RemainingBeatSquadList;

//These are the squads for the current sequence and beat. Will be generated by PrepareSequence.
var array<TurboMonsterCollectionSquad> CurrentSequence;
var array<TurboMonsterCollectionSquad> CurrentBeat;

final function InitializeWaves()
{
     local int Index;
     for (Index = ArrayCount(WaveList) - 1; Index >= 0; Index--)
     {
          WaveList[Index].Initialize(Self);
     }
     
     for (Index = ArrayCount(BossSquadList) - 1; Index >= 0; Index--)
     {
          BossSquadList[Index].InitializeSquad(Self);
     }
}

final function InitializeForWave(int WaveNumber)
{
     local int Index, WaveMask;
     local TurboMonsterCollectionWave WaveObject;

     RegularSquadList.Length = 0;
     MixInSquadList.Length = 0;
     BeatSquadList.Length = 0;
     CurrentSequence.Length = 0;
     CurrentBeat.Length = 0;

     WaveMask = 1;
     
     WaveObject = WaveList[WaveNumber];

     //All arrays are the same size.
     for (Index = 0; Index < ArrayCount(WaveObject.RegularSquad); Index++)
     {
          if ((WaveObject.RegularWaveMask & WaveMask) != 0 && WaveObject.RegularSquad[Index] != None)
          {
               RegularSquadList[RegularSquadList.Length] = WaveObject.RegularSquad[Index];
          }

          if ((WaveObject.MixInWaveMask & WaveMask) != 0 && WaveObject.MixInSquad[Index] != None)
          {
               MixInSquadList[MixInSquadList.Length] = WaveObject.MixInSquad[Index];
          }

          if ((WaveObject.BeatWaveMask & WaveMask) != 0 && WaveObject.BeatSquad[Index] != None)
          {
               BeatSquadList[BeatSquadList.Length] = WaveObject.BeatSquad[Index];
          }

          WaveMask *= 2;
     }

     RemainingRegularSquadList = RegularSquadList;
     RemainingMixInSquadList = MixInSquadList;
     RemainingBeatSquadList = BeatSquadList;

     log("Initialized For Wave:");
     log(" - WaveObject.RegularSquad:"@WaveObject.RegularWaveMask);
     log(" - WaveObject.MixInSquad:"@WaveObject.MixInWaveMask);
     log(" - WaveObject.BeatSquad:"@WaveObject.BeatWaveMask);
     log(" - RegularSquadList:"@RegularSquadList.Length);
     log(" - MixInSquadList:"@MixInSquadList.Length);
     log(" - BeatSquadList:"@BeatSquadList.Length);
}

final function TurboMonsterCollectionSquad GetSequenceSquad()
{
     local TurboMonsterCollectionSquad Squad;
     local int Index;

     if (RemainingRegularSquadList.Length == 0)
     {
          RemainingRegularSquadList = RegularSquadList;
     }

     Index = Rand(RemainingRegularSquadList.Length);
     Squad = RemainingRegularSquadList[Index];
     RemainingRegularSquadList.Remove(Index, 1);

     return Squad;
}

final function TurboMonsterCollectionSquad GetMixInSquad()
{
     local TurboMonsterCollectionSquad Squad;
     local int Index;

     if (RemainingMixInSquadList.Length == 0)
     {
          RemainingMixInSquadList = MixInSquadList;
     }

     Index = Rand(RemainingMixInSquadList.Length);
     Squad = RemainingMixInSquadList[Index];
     RemainingMixInSquadList.Remove(Index, 1);

     return Squad;
}

final function TurboMonsterCollectionSquad GetBeatSquad()
{
     local TurboMonsterCollectionSquad Squad;
     local int Index;

     if (RemainingBeatSquadList.Length == 0)
     {
          RemainingBeatSquadList = BeatSquadList;
     }

     Index = Rand(RemainingBeatSquadList.Length);
     Squad = RemainingBeatSquadList[Index];
     RemainingBeatSquadList.Remove(Index, 1);

     return Squad;
}

//Prepares a sequence of squads to spawn - [Regular Sequence Squads with Mix Ins] followed by [Beat Squads]
final function PrepareSequence(int WaveNumber)
{   
     local int SequenceSize;
     local int MixInCount;
     local int BeatSize;
     local int RandomIndex;
     local TurboMonsterCollectionWave WaveObject;

     //If we're still consuming a sequence, do not make a new one.
     if (CurrentSequence.Length != 0 || CurrentBeat.Length != 0)
     {
          return;
     }

     log ("Building Sequence");

     WaveObject = WaveList[WaveNumber];

     SequenceSize = WaveObject.RegularSequenceSize;
     MixInCount = WaveObject.MinMixInSquadCount + Rand(1 + WaveObject.MaxMixInSquadCount - WaveObject.MinMixInSquadCount);
     BeatSize = WaveObject.BeatSize;

     //Setup the sequence with sequence squads.
     while(SequenceSize > 0 && RegularSquadList.Length != 0)
     {
          CurrentSequence[CurrentSequence.Length] = GetSequenceSquad();
          log ("- Added"@CurrentSequence[CurrentSequence.Length - 1]);
          SequenceSize--;
     }
     
     //Shuffle in some Mix Ins
     while(MixInCount > 0 && MixInSquadList.Length != 0)
     {
          RandomIndex = Rand(CurrentSequence.Length);
          CurrentSequence.Insert(RandomIndex, 1);
          CurrentSequence[RandomIndex] = GetMixInSquad();
          log ("- Added"@CurrentSequence[RandomIndex]);
          MixInCount--;
     }
     
     //Setup the beat for this sequence.
     while(BeatSize > 0 && BeatSquadList.Length != 0)
     {
          CurrentBeat[CurrentBeat.Length] = GetBeatSquad();
          log ("- Added"@CurrentSequence[CurrentSequence.Length - 1]);
          BeatSize--;
     }
}

final function float GetDifficultModifier(float GameDifficulty)
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

final function float GetPlayerCountModifier(int PlayerCount)
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

final function int GetWaveTotalMonsters(int WaveNumber, float GameDifficulty, int PlayerCount )
{
     return float(WaveList[Clamp(WaveNumber, 0, 9)].TotalMonsters) * GetDifficultModifier(GameDifficulty) * GetPlayerCountModifier(PlayerCount);
}

final function int GetWaveMaxMonsters(int WaveNumber, float GameDifficulty, int PlayerCount)
{
     return WaveList[Clamp(WaveNumber, 0, 9)].MaxMonsters;
}

final function float GetWaveDifficulty(int WaveNumber)
{
     return WaveList[Clamp(WaveNumber, 0, 9)].WaveDifficulty;
}

final function float GetNextSquadSpawnTime(int WaveNumber)
{
     return WaveList[Clamp(WaveNumber, 0, 9)].NextSquadSpawnTime;
}

defaultproperties
{

}