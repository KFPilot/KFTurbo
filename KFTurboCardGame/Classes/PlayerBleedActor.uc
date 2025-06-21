//Killing Floor Turbo PlayerBleedActor
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PlayerBleedActor extends Engine.Info;

var float BleedInterval;
var float BleedDamage;
var float BleedCount;

struct BleedEntry
{
    var KFHumanPawn Pawn;
    var float NextBleedTime;
    var int BleedCount;
};
var array<BleedEntry> BleedList;

function PostBeginPlay()
{
    Super.PostBeginPlay();
}

function ModifyBleedCount(float Multiplier)
{
    BleedCount *= Multiplier;
}

function ApplyBleedToPlayer(KFHumanPawn Pawn)
{
    local int Index;
    for (Index = BleedList.Length - 1; Index >= 0; Index--)
    {
        if (BleedList[Index].Pawn == Pawn)
        {
            BleedList[Index].BleedCount = BleedCount;
            return;
        }
    }

    BleedList.Length = BleedList.Length + 1;
    BleedList[BleedList.Length - 1].Pawn = Pawn;
    BleedList[BleedList.Length - 1].NextBleedTime = Level.TimeSeconds + BleedInterval;
    BleedList[BleedList.Length - 1].BleedCount = int(BleedCount);
}

function Tick(float DeltaTime)
{
    local int Index;
    if (KFGameType(Level.Game) == None || !KFGameType(Level.Game).bWaveInProgress)
    {
        BleedList.Length = 0;
        return;
    }

    for (Index = BleedList.Length - 1; Index >= 0; Index--)
    {
        if (BleedList[Index].Pawn == None || BleedList[Index].Pawn.bDeleteMe || BleedList[Index].Pawn.Health <= 0)
        {
            BleedList.Remove(Index, 1);
            continue;
        }

        if (BleedList[Index].NextBleedTime > Level.TimeSeconds)
        {
            continue;
        }

        BleedList[Index].BleedCount--;
        BleedList[Index].Pawn.TakeDamage(BleedDamage, None, BleedList[Index].Pawn.Location, vect(0, 0, 0), class'TurboHumanBleed_DT');
        
        if (BleedList[Index].BleedCount <= 0)
        {
            BleedList.Remove(Index, 1);
            continue;
        }
         
        BleedList[Index].NextBleedTime = Level.TimeSeconds + BleedInterval;
    }
}

defaultproperties
{
    BleedInterval=1.f
    BleedDamage=2.f
    BleedCount=5
}