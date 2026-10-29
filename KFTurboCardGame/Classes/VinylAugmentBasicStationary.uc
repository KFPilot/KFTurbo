//Killing Floor Turbo VinylAugmentBasicStationary
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentBasicStationary extends VinylAugmentBasicConditional;

var const float StationaryVelocityThreshold;

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

    return VSizeSquared(Pawn.Velocity) <= StationaryVelocityThreshold;
}

defaultproperties
{
    StationaryVelocityThreshold=50.f
}
