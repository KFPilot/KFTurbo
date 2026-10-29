//Killing Floor Turbo VinylAugmentMonsterDamage
//Applies its damage multiplier against zeds that pass IsValidTarget() and BaseMultiplier against the rest. Subclasses define the filter.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentMonsterDamage extends VinylAugmentBasic
	abstract;

function bool IsValidTarget(KFMonster Injured)
{
    return Injured != None;
}

function float GetDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageInstigator, int InDamage, class<DamageType> DamageType)
{
    if (IsValidTarget(Injured))
    {
        return Super.GetDamageMultiplier(KFPRI, Injured, DamageInstigator, InDamage, DamageType);
    }

    return BaseMultiplier;
}
