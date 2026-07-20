//Killing Floor Turbo PrecisionChainManager
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PrecisionChainManager extends Info;

var bool bProcessingChainList;

struct PrecisionChainEntry
{
    var KFMonster Monster;
    var vector Location;
    var TurboPlayerReplicationInfo TPRI;
    var class<DamageType> DamageType;
    var int Damage;
};
var array<PrecisionChainEntry> PrecisionChainList;

function PostBeginPlay()
{
    Super.PostBeginPlay();
}

function Tick(float DeltaTime)
{
    local int Index;
    local Controller Controller;
    bProcessingChainList = true;

    for (Index = 0; Index < PrecisionChainList.Length; Index++)
    {
        if (PrecisionChainList[Index].TPRI == None)
        {
            continue;
        }

        Controller = Controller(PrecisionChainList[Index].TPRI.Owner);

        if (Controller == None || Controller.Pawn == None)
        {
            continue;
        }

        ProcessPrecisionChain(PrecisionChainList[Index]);
    }

    PrecisionChainList.Length = 0;
    bProcessingChainList = false;
}

function ProcessPrecisionChain(PrecisionChainEntry Entry)
{
    local KFMonster OriginalMonster, Monster;
    local array<KFMonster> MonsterList;
    local vector HeadshotLocation, HeadshotDirection;

    OriginalMonster = Entry.Monster;

    foreach VisibleCollidingActors(class'KFMonster', Monster, 150.f, Entry.Location)
    {
        if (Monster.Health <= 0 || OriginalMonster == Monster)
        {
            continue;
        }

        MonsterList[MonsterList.Length] = Monster;
    }

    if (MonsterList.Length == 0)
    {
        return;
    }

    Monster = MonsterList[Rand(MonsterList.Length)];
    ResolveHeadshotVectors(Monster, HeadshotLocation, HeadshotDirection);
    Monster.TakeDamage(Entry.Damage, Controller(Entry.TPRI.Owner).Pawn, HeadshotLocation, HeadshotDirection, Entry.DamageType);
}

final function ResolveHeadshotVectors(KFMonster Monster, out vector HeadshotLocation, out vector HeadshotDirection)
{
    local coords HeadCoords;
    local vector BoneHeadLocation, AltHeadLocation;

    HeadCoords = Monster.GetBoneCoords(Monster.HeadBone);
    BoneHeadLocation = HeadCoords.Origin + (Monster.HeadHeight * Monster.HeadScale * HeadCoords.XAxis);
    AltHeadLocation = Monster.Location + (Monster.OnlineHeadshotOffset >> Monster.Rotation);

    HeadshotLocation = BoneHeadLocation;
    HeadshotDirection = AltHeadLocation - BoneHeadLocation;

    if (HeadshotDirection == vect(0, 0, 0))
    {
        HeadshotDirection = HeadCoords.XAxis;
    }
    else
    {
        HeadshotDirection = Normal(HeadshotDirection);
    }
}

function NotifyPrecisionChain(KFMonster Monster, vector Location, TurboPlayerReplicationInfo TPRI, int Damage, class<DamageType> DamageType)
{
    local int Index;

    if (bProcessingChainList)
    {
        return;
    }

    Index = PrecisionChainList.Length;
    PrecisionChainList.Length = Index + 1;

    PrecisionChainList[Index].Monster = Monster;
    PrecisionChainList[Index].Location = Location;
    PrecisionChainList[Index].TPRI = TPRI;
    PrecisionChainList[Index].DamageType = DamageType;
    PrecisionChainList[Index].Damage = Damage;
}

defaultproperties
{

}
