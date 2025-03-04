//Killing Floor Turbo TurboMonsterCollectionWaveBase
//Base class for basic, wave-based spawning setups.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMonsterCollectionWaveBase extends TurboMonsterCollection
     editinlinenew;

var array<TurboMonsterWave> WaveList;
var TurboMonsterWave CurrentWave;

var array<TurboMonsterBossSquad> BossSquadList;

//These arrays are a cached list of a wave's squads. We construct sequences with them using them to reset squad lists once they're empty.
var array<TurboMonsterSquad> RegularSquadList;
var array<TurboMonsterSquad> MixInSquadList;
var array<TurboMonsterSquad> BeatSquadList;

//These are the "live" versions of the cached list that are consumed on use. When empty, they reset to the above cached list.
var array<TurboMonsterSquad> RemainingRegularSquadList;
var array<TurboMonsterSquad> RemainingMixInSquadList;
var array<TurboMonsterSquad> RemainingBeatSquadList;

//These are the squads for the current sequence and beat. Will be generated by PrepareSequence.
var array<TurboMonsterSquad> CurrentSequence;
var array<TurboMonsterSquad> CurrentBeat;

var bool bDebugWave;

function DebugLog(coerce string Message)
{
     if (!bDebugWave)
     {
          return;
     }

     Log(Message, 'KFTurboWave');
}

function InitializeCollection()
{
     local int Index;
     
     Super.InitializeCollection();

     for (Index = WaveList.Length - 1; Index >= 0; Index--)
     {
          if (WaveList[Index] == None)
          {
               continue;
          }

          WaveList[Index].Initialize(Self);
     }
     
     for (Index = BossSquadList.Length - 1; Index >= 0; Index--)
     {
          if (BossSquadList[Index] == None)
          {
               continue;
          }

          BossSquadList[Index].InitializeSquad(Self);
     }
}

function InitializeForWave(int WaveNumber)
{
     local int Index, WaveMask;

     DebugLog("Initializing For Wave:"@WaveNumber);

     RegularSquadList.Length = 0;
     MixInSquadList.Length = 0;
     BeatSquadList.Length = 0;
     CurrentSequence.Length = 0;
     CurrentBeat.Length = 0;

     WaveMask = 1;
     
     CurrentWave = WaveList[WaveNumber];

     //All arrays are the same size.
     for (Index = 0; Index < ArrayCount(CurrentWave.RegularSquad); Index++)
     {
          if ((CurrentWave.RegularWaveMask & WaveMask) != 0 && CurrentWave.RegularSquad[Index] != None)
          {
               RegularSquadList[RegularSquadList.Length] = CurrentWave.RegularSquad[Index];
          }

          if ((CurrentWave.MixInWaveMask & WaveMask) != 0 && CurrentWave.MixInSquad[Index] != None)
          {
               MixInSquadList[MixInSquadList.Length] = CurrentWave.MixInSquad[Index];
          }

          if ((CurrentWave.BeatWaveMask & WaveMask) != 0 && CurrentWave.BeatSquad[Index] != None)
          {
               BeatSquadList[BeatSquadList.Length] = CurrentWave.BeatSquad[Index];
          }

          WaveMask *= 2;
     }

     RemainingRegularSquadList = RegularSquadList;
     RemainingMixInSquadList = MixInSquadList;
     RemainingBeatSquadList = BeatSquadList;

     DebugLog("Initialized For Wave:");
     DebugLog(" - CurrentWave.RegularSquad:"@CurrentWave.RegularWaveMask);
     DebugLog(" - CurrentWave.MixInSquad:"@CurrentWave.MixInWaveMask);
     DebugLog(" - CurrentWave.BeatSquad:"@CurrentWave.BeatWaveMask);
     DebugLog(" - RegularSquadList:"@RegularSquadList.Length);
     DebugLog(" - MixInSquadList:"@MixInSquadList.Length);
     DebugLog(" - BeatSquadList:"@BeatSquadList.Length);
}

final function TurboMonsterSquad GetSequenceSquad()
{
     local TurboMonsterSquad Squad;
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

final function TurboMonsterSquad GetMixInSquad()
{
     local TurboMonsterSquad Squad;
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

final function TurboMonsterSquad GetBeatSquad()
{
     local TurboMonsterSquad Squad;
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

function Reset()
{
     CurrentSequence.Length = 0;
     CurrentBeat.Length = 0;
     RemainingRegularSquadList = RegularSquadList;
     RemainingMixInSquadList = MixInSquadList;
     RemainingBeatSquadList = BeatSquadList;
}

//Prepares a sequence of squads to spawn - [Regular Sequence Squads with Mix Ins] followed by [Beat Squads]
function PrepareSequence()
{   
     local int SequenceSize;
     local int MixInCount;
     local int BeatSize;
     local float MixInIndex;
     local float MixInFrequency;

     //If we're still consuming a sequence, do not make a new one.
     if (CurrentSequence.Length != 0 || CurrentBeat.Length != 0)
     {
          return;
     }

     DebugLog ("Building Sequence");

     SequenceSize = CurrentWave.RegularSequenceSize;
     MixInCount = CurrentWave.MinMixInSquadCount + Rand(1 + (CurrentWave.MaxMixInSquadCount - CurrentWave.MinMixInSquadCount));
     BeatSize = CurrentWave.BeatSize;

     //Setup the sequence with sequence squads.
     while(SequenceSize > 0 && RegularSquadList.Length != 0)
     {
          CurrentSequence[CurrentSequence.Length] = GetSequenceSquad();
          DebugLog ("- Added"@CurrentSequence[CurrentSequence.Length - 1]);
          SequenceSize--;
     }

     //Insert some Mix Ins
     if (MixInCount > 0 && MixInSquadList.Length != 0)
     {
          //Figure out how to space them out.
          MixInFrequency = float(CurrentSequence.Length) / float(MixInCount);
          MixInIndex = CurrentSequence.Length - 1;

          while(MixInCount > 0)
          {
               CurrentSequence.Insert(int(MixInIndex), 1);
               CurrentSequence[int(MixInIndex)] = GetMixInSquad();
               DebugLog ("- Added"@CurrentSequence[int(MixInIndex)]);
               MixInCount--;

               MixInIndex -= MixinFrequency;
          }
     }
     
     //Setup the beat for this sequence.
     while(BeatSize > 0 && BeatSquadList.Length != 0)
     {
          CurrentBeat[CurrentBeat.Length] = GetBeatSquad();
          DebugLog ("- Added"@CurrentSequence[CurrentSequence.Length - 1]);
          BeatSize--;
     }
}

function TurboMonsterSquad GetNextMonsterSquad()
{
     local TurboMonsterSquad Squad;

     PrepareSequence();

     if (CurrentSequence.Length > 0)
     {
          Squad = CurrentSequence[0];
          CurrentSequence.Remove(0, 1);
     }
     else if (CurrentBeat.Length > 0)
     {
          Squad = CurrentBeat[0];
          CurrentBeat.Remove(0, 1);
     }

     return Squad;
} 

function ApplyFinalSquad(int FinalSquadNumber, int PlayerCount, out array< class<KFMonster> > OutNextSpawnSquad)
{
     local array< class<KFMonster> > SquadMonsterList;
     local TurboMonsterSquad Squad;
     local int SpawnAmount, NextSpawnSquadIndex;
     local int BossSquadIndex;

     OutNextSpawnSquad.Length = 0;

     if (BossSquadList.Length == 0)
     {
          return;
     }

     BossSquadIndex = Min(BossSquadList.Length - 1, FinalSquadNumber);

     Squad = BossSquadList[BossSquadIndex].Squad;
     SpawnAmount = BossSquadList[BossSquadIndex].SquadSizePerPlayerCount[Min(PlayerCount - 1, ArrayCount(BossSquadList[BossSquadIndex].SquadSizePerPlayerCount) - 1)];

     SquadMonsterList = Squad.MonsterList;

     if (SquadMonsterList.Length == 0)
     {
          return;
     }

	class'TurboWaveSpawnEventHandler'.static.BroadcastAddBossBuddySquad(KFTurboGameType(Outer), SpawnAmount);
	class'TurboWaveSpawnEventHandler'.static.BroadcastNextSpawnSquadGenerated(KFTurboGameType(Outer), SquadMonsterList);

     while (SpawnAmount > OutNextSpawnSquad.Length)
     {
          NextSpawnSquadIndex = 0;

          while(NextSpawnSquadIndex < SquadMonsterList.Length)
          {
               OutNextSpawnSquad[OutNextSpawnSquad.Length] = SquadMonsterList[NextSpawnSquadIndex];
               NextSpawnSquadIndex++;

               if (SpawnAmount <= OutNextSpawnSquad.Length)
               {
                    break;
               }
          }
     }
}

function int GetWaveTotalMonsters(int WaveNumber, float GameDifficulty, int PlayerCount)
{
     return float(WaveList[Clamp(WaveNumber, 0, 9)].TotalMonsters) * GetDifficultyModifier(GameDifficulty) * GetPlayerCountModifier(PlayerCount);
}

function int GetWaveMaxMonsters(int WaveNumber, float GameDifficulty, int PlayerCount)
{
     return WaveList[Clamp(WaveNumber, 0, 9)].GetMaxMonsters(PlayerCount);
}

function float GetWaveDifficulty(int WaveNumber)
{
     return WaveList[Clamp(WaveNumber, 0, 9)].WaveDifficulty;
}

function float GetNextSquadSpawnTime(int WaveNumber, int PlayerCount)
{
     return WaveList[Clamp(WaveNumber, 0, 9)].GetNextSquadSpawnTime(PlayerCount);
}

defaultproperties
{
     bDebugWave=false
}
