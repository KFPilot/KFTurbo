//Killing Floor Turbo VinylAugmentBasicPristine
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentBasicPristine extends VinylAugmentBasicDamaged;

simulated function bool IsAugmentActive()
{
    if (WasRecentlyDamaged())
    {
        return false;
    }

    return OwningCardInfo != None && OwningCardInfo.GetHealthPercent() >= 1.f;
}

defaultproperties
{
    DamageTakenDuration=1.f
}
