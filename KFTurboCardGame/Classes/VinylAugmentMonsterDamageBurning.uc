//Killing Floor Turbo VinylAugmentMonsterDamageBurning
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentMonsterDamageBurning extends VinylAugmentMonsterDamage;

function bool IsValidTarget(KFMonster Injured)
{
    return class'PawnHelper'.static.IsPawnBurning(Injured);
}
