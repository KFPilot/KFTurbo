//Killing Floor Turbo VinylAugmentKMShipping
//Scales with how much carry weight is in use. The inverse of VinylAugmentVagrant.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentKMShipping extends VinylAugmentBasicScaled;

simulated function float GetScaleRatio()
{
    local KFHumanPawn Pawn;

    if (OwningCardInfo == None)
    {
        return 0.f;
    }

    Pawn = KFHumanPawn(OwningCardInfo.GetOwnerPawn());

    if (Pawn == None || Pawn.Health <= 0 || Pawn.MaxCarryWeight <= 0.f)
    {
        return 0.f;
    }

    return FClamp(Pawn.CurrentWeight / Pawn.MaxCarryWeight, 0.f, 1.f);
}
