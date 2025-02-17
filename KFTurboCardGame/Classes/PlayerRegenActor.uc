//Killing Floor Turbo PlayerRegenActor
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PlayerRegenActor extends Engine.Info;

var float RegenInterval;
var int RegenAmount;

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
    SetTimer(RegenInterval, true);
}

function SetRegenInterval(float NewRegenInterval)
{
    RegenInterval = NewRegenInterval;
    SetTimer(RegenInterval, true);
}

function SetRegenAmount(int NewRegenAmount)
{
    RegenAmount = NewRegenAmount;
}

function Timer()
{
    local array<TurboHumanPawn> PawnList;
    local int Index;

    PawnList = class'TurboGameplayHelper'.static.GetPlayerPawnList(Level);

    for (Index = PawnList.Length - 1; Index >= 0; Index--)
    {
        PawnList[Index].Health = Min(PawnList[Index].Health + RegenAmount, PawnList[Index].HealthMax);
    }
}

defaultproperties
{
    RegenInterval=5
    RegenAmount=0
}