//Killing Floor Turbo VinylAugmentMonsterDamageUnharmed
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentMonsterDamageUnharmed extends VinylAugmentMonsterDamage;

function bool IsValidTarget(KFMonster Injured)
{
    return Injured != None && Injured.Health >= Injured.HealthMax;
}
