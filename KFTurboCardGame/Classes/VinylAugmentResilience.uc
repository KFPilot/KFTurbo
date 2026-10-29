//Killing Floor Turbo VinylAugmentResilience
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentResilience extends VinylAugmentBasicScaled;

simulated function float GetScaleRatio()
{
    if (OwningCardInfo == None)
    {
        return 0.f;
    }

    return FClamp(1.f - OwningCardInfo.GetHealthPercent(), 0.f, 1.f);
}
