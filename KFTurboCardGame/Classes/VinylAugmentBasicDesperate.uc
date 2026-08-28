//Killing Floor Turbo VinylAugmentBasicDesperate
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentBasicDesperate extends VinylAugmentBasicConditional;

var const float HealthThreshold;

simulated function bool IsAugmentActive()
{
    return OwningCardInfo != None && OwningCardInfo.GetHealthPercent() <= HealthThreshold;
}

defaultproperties
{
    HealthThreshold=0.75f
}
