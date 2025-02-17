//Killing Floor Turbo TurboMonsterWave
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMonsterWave extends Object
     editinlinenew;

//Monster cap for this wave.
var int MaxMonsters;

//Total monsters for this wave (scaled by player/difficulty).
var int TotalMonsters;

var float WaveDifficulty;

//Time between squads in seconds. If less than SPAWN_TIME, gets set to SPAWN_TIME (currently 1 second).
var float NextSquadSpawnTime;

//Squads that are shuffled in between "beats".
var TurboMonsterSquad RegularSquad[30];
var int RegularWaveMask; //Allows for a "base" class to define a bunch of squads and then use a wave mask to filter. Defaults to MaxInt (all).

//Squads that are randomly placed into squads between "beats". 
var TurboMonsterSquad MixInSquad[30];
var int MixInWaveMask; //Allows for a "base" class to define a bunch of squads and then use a wave mask to filter. Defaults to MaxInt (all).

//Squads that can be used for "beats".
var TurboMonsterSquad BeatSquad[30];
var int BeatWaveMask; //Allows for a "base" class to define a bunch of squads and then use a wave mask to filter. Defaults to MaxInt (all).

//Number of regular squads to "roll" for a sequence between beats.
var int RegularSequenceSize;
//Number of MixIn squads to randomly add to the sequence between beats.
var int MinMixInSquadCount;
var int MaxMixInSquadCount;
//Number of Beat squads to use for beats between sequences.
var int BeatSize;

function Initialize(TurboMonsterCollection TurboCollection)
{
     local int Index;

     if (RegularWaveMask == -1)
     {
          RegularWaveMask = MaxInt;
     }
     
     if (MixInWaveMask == -1)
     {
          MixInWaveMask = MaxInt;
     }

     if (BeatWaveMask == -1)
     {
          BeatWaveMask = MaxInt;
     }

     for (Index = ArrayCount(RegularSquad) - 1; Index >= 0; Index--)
     {
          if (RegularSquad[Index] == None)
          {
               continue;
          }

          RegularSquad[Index].InitializeSquad(TurboCollection);
     }

     for (Index = ArrayCount(MixInSquad) - 1; Index >= 0; Index--)
     {
          if (MixInSquad[Index] == None)
          {
               continue;
          }

          MixInSquad[Index].InitializeSquad(TurboCollection);
     }

     for (Index = ArrayCount(BeatSquad) - 1; Index >= 0; Index--)
     {
          if (BeatSquad[Index] == None)
          {
               continue;
          }

          BeatSquad[Index].InitializeSquad(TurboCollection);
     }
}

function int GetMaxMonsters(int PlayerCount)
{
     return MaxMonsters;
}

function float GetNextSquadSpawnTime(int PlayerCount)
{
     return NextSquadSpawnTime;
}

defaultproperties
{
     MaxMonsters=32
     TotalMonsters=32
     
     WaveDifficulty=1.f
     NextSquadSpawnTime=1.f

     RegularSequenceSize=10
     MinMixInSquadCount=1
     MaxMixInSquadCount=1
     BeatSize=1

     RegularWaveMask=-1
     MixInWaveMask=-1
     BeatWaveMask=-1
}
