//Killing Floor Turbo VinylAugmentPointBlank
//Scales its damage multiplier by how close the player is to the injured zed.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentPointBlank extends VinylAugmentBasic;

var const float FullBonusDistance;
var const float NoBonusDistance;

function float GetDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageInstigator, int InDamage, class<DamageType> DamageType)
{
    local float Ratio;

    if (Injured == None || DamageInstigator == None || NoBonusDistance <= FullBonusDistance)
    {
        return BaseMultiplier;
    }

    Ratio = 1.f - FClamp((VSize(Injured.Location - DamageInstigator.Location) - FullBonusDistance) / (NoBonusDistance - FullBonusDistance), 0.f, 1.f);
    return Lerp(Ratio, BaseMultiplier, Super.GetDamageMultiplier(KFPRI, Injured, DamageInstigator, InDamage, DamageType));
}

defaultproperties
{
    FullBonusDistance=100.f
    NoBonusDistance=500.f
}
