// KFTurbo Holdout Game Type's wave for spawning. Mutates itself over the course of the game.
class TurboMonsterHoldoutWave extends TurboMonsterWave
     editinlinenew;

var array<TurboMonsterSquad> SquadList;
enum ESquadIndex
{
     Wave1Squad, //0
     Wave2Squad,
     Wave5Squad,
     Wave7Squad,
     Wave9Squad,
     Wave11Squad, //5
     Wave15Squad
};

var float ScoreMultiplier;

function Initialize(TurboMonsterCollection TurboCollection)
{
     local int Index;

     Super.Initialize(TurboCollection);

     for (Index = 0; Index < SquadList.Length; Index++)
     {
          SquadList[Index].InitializeSquad(TurboCollection);
     }
}

function InitializeForWave(int Wave)
{
     local int RegularInsertIndex;
     local int MixInInsertIndex;
     local int BeatInsertIndex;
     local int WaveCount;

     Wave++; //1-indexed waves instead of 0-indexed.

     //Empty these out in preparation to fill them out.
     WaveCount = 0;
     while (WaveCount < ArrayCount(RegularSquad))
     {
          RegularSquad[WaveCount] = None;
          MixInSquad[WaveCount] = None;
          BeatSquad[WaveCount] = None;
          WaveCount++;
     }

	RegularSquad[0]=SquadList[ESquadIndex.Wave1Squad];
	RegularSquad[1]=SquadList[ESquadIndex.Wave1Squad];
	RegularSquad[2]=SquadList[ESquadIndex.Wave1Squad];
	RegularSquad[3]=SquadList[ESquadIndex.Wave1Squad];

     MaxMonsters = default.MaxMonsters;
     TotalMonsters = default.TotalMonsters;
     
     WaveDifficulty = default.WaveDifficulty;
     NextSquadSpawnTime = default.NextSquadSpawnTime;

     RegularSequenceSize = default.RegularSequenceSize;
     MinMixInSquadCount = default.MinMixInSquadCount;
     MaxMixInSquadCount = default.MaxMixInSquadCount;
     BeatSize = default.BeatSize;
     
     ScoreMultiplier = default.ScoreMultiplier;

     if (Wave == 1)
     {
          TotalMonsters *= 0.5f;
          ScoreMultiplier *= 2.f;
          return;
     }

     if (Wave <= 10)
     {
          ScoreMultiplier *= Lerp(float(Wave) / 10.f, 2.f, 1.f);
          TotalMonsters *= Lerp(float(Wave) / 10.f, 0.5f, 1.f);

          TotalMonsters = Max(TotalMonsters, 1);
     }

     RegularInsertIndex = GetNextRegularSquadIndex();
     MixInInsertIndex = GetNextMixinSquadIndex();
     BeatInsertIndex = GetNextBeatSquadIndex();

     WaveCount = 1;
     while (WaveCount <= Wave)
     {
          TryAddRegularSquad(WaveCount, RegularInsertIndex, 2, 2, SquadList[ESquadIndex.Wave2Squad]);
          TryAddRegularSquad(WaveCount, RegularInsertIndex, 5, 2, SquadList[ESquadIndex.Wave5Squad]);
          TryAddRegularSquad(WaveCount, RegularInsertIndex, 7, 2, SquadList[ESquadIndex.Wave7Squad]);
          TryAddRegularSquad(WaveCount, RegularInsertIndex, 9, 2, SquadList[ESquadIndex.Wave9Squad]);
          WaveCount++;
     }

     MaxMonsters += (Wave - 1);
     TotalMonsters += Wave * 2;

     WaveDifficulty = FMin(2.75f, Lerp(float(Wave) / 20.f, default.WaveDifficulty, 2.75f));
     NextSquadSpawnTime *= ((0.8) ** float(Wave));

     if (Wave >= 10)
     {
          ScoreMultiplier *= Lerp(FClamp((float(Wave) - 10.f) / 10.f, 0.f, 1.f), 1.f, 0.1f);
     }

     if (Wave >= 11)
     {
          MinMixInSquadCount++;
          MaxMixInSquadCount++;

          MixInSquad[MixInInsertIndex++] = SquadList[ESquadIndex.Wave11Squad];

          MaxMonsters++;
     }

     if (Wave >= 13)
     {
          MinMixInSquadCount++;
          MaxMixInSquadCount++;

          MixInSquad[MixInInsertIndex++] = SquadList[ESquadIndex.Wave11Squad];
     }

     if (Wave >= 15)
     {
          BeatSize++;

          MixInSquad[BeatInsertIndex++] = SquadList[ESquadIndex.Wave15Squad];

          MaxMonsters++;
     }

     if (Wave >= 16)
     {
          MinMixInSquadCount++;
          MaxMixInSquadCount++;
          
          MixInSquad[MixInInsertIndex++] = SquadList[ESquadIndex.Wave11Squad];
     }

     if (Wave >= 17)
     {
          BeatSize++;

          MixInSquad[BeatInsertIndex++] = SquadList[ESquadIndex.Wave15Squad];

          MaxMonsters++;
     }

     if (Wave >= 19)
     {
          MinMixInSquadCount++;
          MaxMixInSquadCount++;
          
          MixInSquad[MixInInsertIndex++] = SquadList[ESquadIndex.Wave11Squad];
     }

     if (Wave >= 19)
     {
          BeatSize++;

          MixInSquad[BeatInsertIndex++] = SquadList[ESquadIndex.Wave15Squad];

          MaxMonsters++;
     }
}

final function TryAddRegularSquad(int Wave, out int InsertIndex, int StartWave, int Interval, TurboMonsterSquad Squad)
{
     if (Wave < StartWave)
     {
          return;
     }

     if (((Wave - StartWave) % Interval) == 0)
     {
          RegularSquad[InsertIndex++] = Squad;
     }
}

final function int GetNextRegularSquadIndex()
{
     local int Index;
     for (Index = 0; Index < ArrayCount(RegularSquad); Index++)
     {
          if (RegularSquad[Index] == None)
          {
               return Index;
          }
     }

     return -1;
}

final function int GetNextMixInSquadIndex()
{
     local int Index;
     for (Index = 0; Index < ArrayCount(MixInSquad); Index++)
     {
          if (MixInSquad[Index] == None)
          {
               return Index;
          }
     }

     return -1;
}

final function int GetNextBeatSquadIndex()
{
     local int Index;
     for (Index = 0; Index < ArrayCount(BeatSquad); Index++)
     {
          if (BeatSquad[Index] == None)
          {
               return Index;
          }
     }

     return -1;
}

function float GetScoreMultiplier()
{
     return ScoreMultiplier;
}

defaultproperties
{
	Begin Object Class=TurboMonsterSquad Name=Wave1Squad
		Squad(0)=(Monster=Clot,Count=4)
	End Object
     SquadList(0)=TurboMonsterSquad'Wave1Squad'

	Begin Object Class=TurboMonsterSquad Name=Wave2Squad
		Squad(0)=(Monster=Gorefast,Count=1)
	End Object
     SquadList(1)=TurboMonsterSquad'Wave2Squad'

	Begin Object Class=TurboMonsterSquad Name=Wave5Squad
		Squad(0)=(Monster=Crawler,Count=2)
	End Object
     SquadList(2)=TurboMonsterSquad'Wave5Squad'

	Begin Object Class=TurboMonsterSquad Name=Wave7Squad
		Squad(0)=(Monster=Stalker,Count=2)
	End Object
     SquadList(3)=TurboMonsterSquad'Wave7Squad'

	Begin Object Class=TurboMonsterSquad Name=Wave9Squad
		Squad(0)=(Monster=Bloat,Count=1)
	End Object
     SquadList(4)=TurboMonsterSquad'Wave9Squad'

	Begin Object Class=TurboMonsterSquad Name=Wave11Squad
		Squad(0)=(Monster=Scrake,Count=1)
	End Object
     SquadList(5)=TurboMonsterSquad'Wave11Squad'

	Begin Object Class=TurboMonsterSquad Name=Wave15Squad
		Squad(0)=(Monster=Fleshpound,Count=1)
	End Object
     SquadList(6)=TurboMonsterSquad'Wave15Squad'

     MaxMonsters=8
     TotalMonsters=8    

     WaveDifficulty=1.f
     NextSquadSpawnTime=1.f

     RegularSequenceSize=10
     MinMixInSquadCount=0
     MaxMixInSquadCount=0
     BeatSize=0

     ScoreMultiplier=1.f
}
