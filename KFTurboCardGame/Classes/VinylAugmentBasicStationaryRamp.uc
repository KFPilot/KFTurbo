//Killing Floor Turbo VinylAugmentBasicStationaryRamp
//Ramps its augment list up over time while the player stands still.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentBasicStationaryRamp extends VinylAugmentBasicScaled;

var const float StationaryVelocityThreshold;
var const float RampDuration;

var float StationaryTime;

//Leaving AwaitingRegister disables Tick, so turn it back on.
protected simulated function OnRegister()
{
    Super.OnRegister();
    Enable('Tick');
}

simulated function Tick(float DeltaTime)
{
    local Pawn Pawn;

    Super.Tick(DeltaTime);

    if (OwningCardInfo == None)
    {
        StationaryTime = 0.f;
        return;
    }

    Pawn = OwningCardInfo.GetOwnerPawn();

    if (Pawn == None || Pawn.Health <= 0 || VSizeSquared(Pawn.Velocity) > StationaryVelocityThreshold)
    {
        StationaryTime = 0.f;
        return;
    }

    StationaryTime += DeltaTime;
}

simulated function float GetScaleRatio()
{
    if (RampDuration <= 0.f)
    {
        return 1.f;
    }

    return FClamp(StationaryTime / RampDuration, 0.f, 1.f);
}

defaultproperties
{
    StationaryVelocityThreshold=50.f
    RampDuration=3.f
}
