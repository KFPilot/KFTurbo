//Killing Floor Turbo VinylAugmentRegeneration
//Heals the player on an interval while IsRegenerating() is true. Subclasses define the condition. The augment list applies flat.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentRegeneration extends VinylAugmentBasic
	abstract;

var const int HealthPerTick;
var const float RegenInterval;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role == ROLE_Authority)
    {
        SetTimer(RegenInterval, true);
    }
}

function bool IsRegenerating()
{
    return true;
}

function Timer()
{
    local Pawn OwnerPawn;

    if (OwningCardInfo == None || !IsRegenerating())
    {
        return;
    }

    OwnerPawn = OwningCardInfo.GetOwnerPawn();

    if (OwnerPawn == None || OwnerPawn.Health <= 0)
    {
        return;
    }

    OwnerPawn.GiveHealth(HealthPerTick, OwnerPawn.HealthMax);
}

defaultproperties
{
    HealthPerTick=1
    RegenInterval=1.f
}
