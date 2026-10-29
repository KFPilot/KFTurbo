//Killing Floor Turbo VinylAugmentLastRound
//Scales its augment list by how empty the current magazine is.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentLastRound extends VinylAugmentBasicScaled;

simulated function float GetScaleRatio()
{
    local Pawn Pawn;
    local KFWeapon Weapon;

    if (OwningCardInfo == None)
    {
        return 0.f;
    }

    Pawn = OwningCardInfo.GetOwnerPawn();

    if (Pawn == None || Pawn.Health <= 0)
    {
        return 0.f;
    }

    Weapon = KFWeapon(Pawn.Weapon);

    if (Weapon == None || Weapon.bMeleeWeapon || Weapon.default.MagCapacity <= 2)
    {
        return 0.f;
    }

    return 1.f - FClamp(float(Weapon.MagAmmoRemaining) / float(Weapon.MagCapacity), 0.f, 1.f);
}
