//Killing Floor Turbo MonsterRegenActor
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class MonsterRegenActor extends Engine.Info;

struct MonsterRegenEntry
{
    var KFMonster Monster;
    var float LastDamagedTime;
};
var array<MonsterRegenEntry> MonsterList;

var float RegenInterval;
var float RegenDelay; //How long a monster needs to go without taking damage before it starts regenerating.
var float RegenHealthFraction; //Fraction of max health regenerated per regen interval.

function PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(RegenInterval, true);
}

function NotifyMonsterDamaged(KFMonster Monster)
{
    local int Index;

    if (Monster == None || Monster.Health <= 0)
    {
        return;
    }

    for (Index = 0; Index < MonsterList.Length; Index++)
    {
        if (MonsterList[Index].Monster == Monster)
        {
            MonsterList[Index].LastDamagedTime = Level.TimeSeconds;
            return;
        }
    }

    MonsterList.Length = MonsterList.Length + 1;
    MonsterList[MonsterList.Length - 1].Monster = Monster;
    MonsterList[MonsterList.Length - 1].LastDamagedTime = Level.TimeSeconds;
}

function Timer()
{
    local int Index;
    local KFMonster Monster;

    for (Index = MonsterList.Length - 1; Index >= 0; Index--)
    {
        Monster = MonsterList[Index].Monster;

        if (Monster == None || Monster.Health <= 0 || Monster.Health >= Monster.HealthMax)
        {
            MonsterList.Remove(Index, 1);
            continue;
        }

        if (Level.TimeSeconds - MonsterList[Index].LastDamagedTime < RegenDelay)
        {
            continue;
        }

        Monster.Health = Min(Monster.Health + Max(1, Round(Monster.HealthMax * RegenHealthFraction)), Monster.HealthMax);
    }
}

defaultproperties
{
    RegenInterval=1.f
    RegenDelay=10.f
    RegenHealthFraction=0.01f
}
