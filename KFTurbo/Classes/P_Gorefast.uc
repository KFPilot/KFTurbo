//Killing Floor Turbo P_Gorefast
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Gorefast extends MonsterGorefast DependsOn(PawnHelper);

defaultproperties
{
    Begin Object Class=AfflictionBurn Name=BurnAffliction
        BurnDurationModifier=1.f
    End Object
    MonsterAfflictionList(0)=CoreMonsterAffliction'BurnAffliction'

    Begin Object Class=AfflictionZap Name=ZapAffliction
        ZapDischargeRate=0.5f
    End Object
    MonsterAfflictionList(1)=CoreMonsterAffliction'ZapAffliction'

    Begin Object Class=AfflictionHarpoon Name=HarpoonAffliction
        HarpoonStunnedSpeedModifier=0.5f
    End Object
    MonsterAfflictionList(2)=CoreMonsterAffliction'HarpoonAffliction'
}
