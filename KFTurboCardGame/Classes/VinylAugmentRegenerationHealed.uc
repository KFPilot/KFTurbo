//Killing Floor Turbo VinylAugmentRegenerationHealed
//Regenerates health for a while after a teammate heals the player.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentRegenerationHealed extends VinylAugmentRegeneration;

var float RegenEndTime;
var const float RegenDuration;

function NotifyPlayerHealed(Pawn Instigator, Pawn Target, int HealingAmount)
{
    if (OwningCardInfo == None || Target != OwningCardInfo.GetOwnerPawn())
    {
        return;
    }

    RegenEndTime = Level.TimeSeconds + RegenDuration;
}

function bool IsRegenerating()
{
    return Level.TimeSeconds < RegenEndTime;
}

defaultproperties
{
    bWantsPlayerHealedEvents=true
    HealthPerTick=2
    RegenDuration=5.f
}
