//Killing Floor Turbo VinylAugmentMonsterDamageType
//Applies its damage multiplier only against zeds of the listed monster types.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentMonsterDamageType extends VinylAugmentMonsterDamage
	dependson(PawnHelper)
	abstract;

var const array<PawnHelper.EMonster> TargetTypeList;

function bool IsValidTarget(KFMonster Injured)
{
    local PawnHelper.EMonster MonsterType;
    local int Index;

    if (Injured == None)
    {
        return false;
    }

    MonsterType = class'PawnHelper'.static.GetMonsterType(Injured.Class);

    for (Index = 0; Index < TargetTypeList.Length; Index++)
    {
        if (TargetTypeList[Index] == MonsterType)
        {
            return true;
        }
    }

    return false;
}
