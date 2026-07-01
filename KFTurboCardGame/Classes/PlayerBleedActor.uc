//Killing Floor Turbo PlayerBleedActor
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PlayerBleedActor extends Engine.Info;

var const float BleedInterval;
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
    local TurboPlayerCardCustomInfo CardCustomInfo;
    
    CardCustomInfo = TurboPlayerCardCustomInfo(class'TurboPlayerCardCustomInfo'.static.FindCustomInfo(TurboPlayerReplicationInfo(BleedList[Index].Pawn.PlayerReplicationInfo)));

    for (Index = BleedList.Length - 1; Index >= 0; Index--)
    {
        if (BleedList[Index].Pawn == Pawn)
        {
            BleedList[Index].BleedCount = BleedCount;
            CardCustomInfo.UpdateBleedCounter(BleedList[Index].BleedCount, BleedList[Index].NextBleedTime);
            return;
        }
    }

    Index = BleedList.Length;
    BleedList.Length = Index + 1;
    BleedList[Index].Pawn = Pawn;
    BleedList[Index].NextBleedTime = Level.TimeSeconds + BleedInterval;
    BleedList[Index].BleedCount = int(BleedCount);
    
    CardCustomInfo.UpdateBleedCounter(BleedList[Index].BleedCount, BleedList[Index].NextBleedTime);
}

function Tick(float DeltaTime)
{
    local int Index;
    local TurboPlayerCardCustomInfo CardCustomInfo;

    if (KFGameType(Level.Game) == None || !KFGameType(Level.Game).bWaveInProgress)
    {
        for (Index = BleedList.Length - 1; Index >= 0; Index--)
        {
            CardCustomInfo = TurboPlayerCardCustomInfo(class'TurboPlayerCardCustomInfo'.static.FindCustomInfo(TurboPlayerReplicationInfo(BleedList[Index].Pawn.PlayerReplicationInfo)));

            if (CardCustomInfo != None)
            {
                CardCustomInfo.UpdateBleedCounter(0, 0.f);
            }
        }
        
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
    
        CardCustomInfo = TurboPlayerCardCustomInfo(class'TurboPlayerCardCustomInfo'.static.FindCustomInfo(TurboPlayerReplicationInfo(BleedList[Index].Pawn.PlayerReplicationInfo)));

        if (BleedList[Index].BleedCount <= 0)
        {
            CardCustomInfo.UpdateBleedCounter(0, 0.f);
            BleedList.Remove(Index, 1);
            continue;
        }

        BleedList[Index].NextBleedTime = Level.TimeSeconds + BleedInterval;
        CardCustomInfo.UpdateBleedCounter(BleedList[Index].BleedCount, BleedList[Index].NextBleedTime);
    }
}

defaultproperties
{
    BleedInterval=1.f
    BleedDamage=2.f
    BleedCount=5
}