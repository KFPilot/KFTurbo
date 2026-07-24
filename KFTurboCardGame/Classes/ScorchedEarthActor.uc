//Killing Floor Turbo ScorchedEarthActor
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
//When a burning monster dies, spreads its fire (using the monster's own FireDamageClass,
//so the same AfflictionBurn slow is applied) to nearby monsters.
class ScorchedEarthActor extends Engine.Info;

struct PendingIgniteEntry
{
    var Vector IgniteLocation;
    var class<DamageType> BurnDamageType;
    var Controller KillerController;
    var float IgniteTime;
};
var array<PendingIgniteEntry> PendingIgniteList;

var float IgniteDelay;
var float IgniteRadius;
var int IgniteDamage;

function NotifyBurningMonsterDied(KFMonster Monster, Controller Killer)
{
    local class<DamageType> BurnDamageType;

    if (Monster == None)
    {
        return;
    }

    BurnDamageType = Monster.FireDamageClass;

    if (BurnDamageType == None)
    {
        BurnDamageType = class'DamTypeBurned';
    }

    PendingIgniteList.Length = PendingIgniteList.Length + 1;
    PendingIgniteList[PendingIgniteList.Length - 1].IgniteLocation = Monster.Location;
    PendingIgniteList[PendingIgniteList.Length - 1].BurnDamageType = BurnDamageType;
    PendingIgniteList[PendingIgniteList.Length - 1].KillerController = Killer;
    PendingIgniteList[PendingIgniteList.Length - 1].IgniteTime = Level.TimeSeconds + IgniteDelay;
}

function Tick(float DeltaTime)
{
    local int Index;
    local KFMonster Monster;
    local Pawn InstigatorPawn;

    for (Index = PendingIgniteList.Length - 1; Index >= 0; Index--)
    {
        if (Level.TimeSeconds < PendingIgniteList[Index].IgniteTime)
        {
            continue;
        }

        InstigatorPawn = None;
        if (PendingIgniteList[Index].KillerController != None)
        {
            InstigatorPawn = PendingIgniteList[Index].KillerController.Pawn;
        }

        foreach CollidingActors(class'KFMonster', Monster, IgniteRadius, PendingIgniteList[Index].IgniteLocation)
        {
            if (Monster.Health <= 0)
            {
                continue;
            }

            Monster.TakeDamage(IgniteDamage, InstigatorPawn, Monster.Location, vect(0, 0, 0), PendingIgniteList[Index].BurnDamageType);
        }

        PendingIgniteList.Remove(Index, 1);
    }
}

defaultproperties
{
    IgniteDelay=0.1f
    IgniteRadius=250.f
    IgniteDamage=5
}
