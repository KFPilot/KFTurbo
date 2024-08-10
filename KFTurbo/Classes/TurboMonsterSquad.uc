class TurboMonsterSquad extends Object
     editinlinenew;


struct SquadEntry
{
     var MC_Turbo.EMonster Monster;
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