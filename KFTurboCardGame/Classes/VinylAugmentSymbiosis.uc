//Killing Floor Turbo VinylAugmentSymbiosis
//Healing a teammate heals the player for a portion of the amount. The augment list applies flat.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentSymbiosis extends VinylAugmentBasic;

var const float HealShareRatio;

function NotifyPlayerHealed(Pawn Instigator, Pawn Target, int HealingAmount)
{
    local Pawn OwnerPawn;

    if (OwningCardInfo == None || HealingAmount <= 0)
    {
        return;
    }

    OwnerPawn = OwningCardInfo.GetOwnerPawn();

    if (OwnerPawn == None || OwnerPawn != Instigator || OwnerPawn.Health <= 0)
    {
        return;
    }

    HealingAmount = Round(float(HealingAmount) * HealShareRatio);

    if (HealingAmount <= 0)
    {
        return;
    }

    OwnerPawn.GiveHealth(HealingAmount, OwnerPawn.HealthMax);
}

defaultproperties
{
    bWantsPlayerHealedEvents=true
    HealShareRatio=0.2f
}
