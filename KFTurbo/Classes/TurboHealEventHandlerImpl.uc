//Killing Floor Turbo TurboHealEventHandlerImpl
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHealEventHandlerImpl extends TurboHealEventHandler;

static function OnPawnDartHealed(Pawn Instigator, Pawn Target, int HealingAmount, HealingProjectile HealDart)
{
    RewardHealedHealth(Instigator, Target, HealingAmount);
}

static function OnPawnSyringeHealed(Pawn Instigator, Pawn Target, int HealingAmount)
{
    RewardHealedHealth(Instigator, Target, HealingAmount);
}

static function OnPawnGrenadeHealed(Pawn Instigator, Pawn Target, int HealingAmount)
{
    RewardHealedHealth(Instigator, Target, HealingAmount);
}

static function RewardHealedHealth(Pawn Instigator, Pawn Target, int HealingAmount)
{
    if (Instigator == None || Instigator == Target || TurboPlayerReplicationInfo(Instigator.PlayerReplicationInfo) == None)
    {
        return;
    }
    
    TurboPlayerReplicationInfo(Instigator.PlayerReplicationInfo).HealthHealed += HealingAmount;
}