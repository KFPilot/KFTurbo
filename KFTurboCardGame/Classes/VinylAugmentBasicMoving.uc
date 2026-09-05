//Killing Floor Turbo VinylAugmentBasicMoving
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentBasicMoving extends VinylAugmentBasicConditional;

var const float MovingVelocityThreshold;

simulated function bool IsAugmentActive()
{
    local Pawn Pawn;

    if (OwningCardInfo == None)
    {
        return false;
    }

    Pawn = OwningCardInfo.GetOwnerPawn();

    if (Pawn == None || Pawn.Health <= 0)
    {
        return false;
    }

    return VSizeSquared(Pawn.Velocity) > MovingVelocityThreshold;
}

defaultproperties
{
    MovingVelocityThreshold=100.f
}
