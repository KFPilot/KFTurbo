//Killing Floor Turbo P_Husk
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Husk extends MonsterHusk;

//TODO: MAKE RANGED ATTACK NOT WORK WHEN ANY bDecapitated && !bZapped && !bHarpoonStunned

defaultproperties
{
    MonsterBurnAffliction=None //Clear burn affliction.

    Begin Object Class=AfflictionZap Name=ZapAffliction
        ZapDischargeRate=0.5f
    End Object
    MonsterZapAffliction=CoreMonsterAffliction'ZapAffliction'

    Begin Object Class=AfflictionHarpoon Name=HarpoonAffliction
        HarpoonStunnedSpeedModifier=0.2f //Slower for now to make the buggy movement look a little funnier.
    End Object
    MonsterHarpoonAffliction=CoreMonsterAffliction'HarpoonAffliction'
}
