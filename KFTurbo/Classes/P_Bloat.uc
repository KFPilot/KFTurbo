//Killing Floor Turbo P_Bloat
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Bloat extends MonsterBloat DependsOn(PawnHelper);

//TODO: MAKE RANGED ATTACK NOT WORK WHEN ANY bDecapitated && !bZapped && !bHarpoonStunned

defaultproperties
{
    Begin Object Class=AfflictionBurn Name=BurnAffliction
        BurnDurationModifier=1.f
    End Object
    MonsterBurnAffliction=AfflictionBurn'BurnAffliction'

    Begin Object Class=AfflictionZap Name=ZapAffliction
        ZapDischargeRate=0.5f
    End Object
    MonsterZapAffliction=AfflictionZap'ZapAffliction'

    Begin Object Class=AfflictionHarpoon Name=HarpoonAffliction
        HarpoonStunnedSpeedModifier=0.5f
    End Object
    MonsterHarpoonAffliction=AfflictionHarpoon'HarpoonAffliction'
}
