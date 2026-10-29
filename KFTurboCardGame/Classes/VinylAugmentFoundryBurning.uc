//Killing Floor Turbo VinylAugmentFoundryBurning
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentFoundryBurning extends VinylAugmentFoundry;

function bool IsValidKill(KFMonster Target, class<DamageType> DamageType)
{
    local class<KFWeaponDamageType> WeaponDamageType;

    WeaponDamageType = class<KFWeaponDamageType>(DamageType);
    return WeaponDamageType != None && WeaponDamageType.default.bDealBurningDamage;
}
