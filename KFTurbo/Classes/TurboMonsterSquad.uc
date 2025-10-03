//Killing Floor Turbo TurboMonsterSquad
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMonsterSquad extends Object
     editinlinenew;

enum EMonsterShortHand
{
     Clot,
     Crawler,
     Gorefast,
     Stalker,
     Scrake,
     Fleshpound,
     Bloat,
     Siren,
     Husk,
     Boss,
     JumperCrawler,
     ClassyGorefast,
     FatheadBloat,
     CarolerSiren,
     ShotgunHusk
};

struct SquadEntry
{
     var EMonsterShortHand Monster;
     var int Count;
};

var array<SquadEntry> Squad;
var bool bEntireSquadMustFit;

var bool bHasInitMonsterList;
var array< class<KFMonster> > MonsterList;

final function InitializeSquad(TurboMonsterCollection TurboCollection)
{
     local int Index, Count;

     if (bHasInitMonsterList)
     {
          return;
     }

     bHasInitMonsterList = true;
     MonsterList.Length = 0;

     for (Index = 0; Index < Squad.Length; Index++)
     {
          for (Count = 0; Count < Squad[Index].Count; Count++)
          {
               MonsterList[MonsterList.Length] = TurboCollection.LoadedMonsterList[Squad[Index].Monster];
          }
     }
}

defaultproperties
{
     bHasInitMonsterList=false
     bEntireSquadMustFit=true
}