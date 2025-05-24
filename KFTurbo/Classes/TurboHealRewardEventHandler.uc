//Killing Floor Turbo TurboHealRewardEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHealRewardEventHandler extends TurboHealEventHandler;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    OnPawnDartHealed = PawnDartHealed;
    OnPawnSyringeHealed = RewardHealedHealth;
    OnPawnGrenadeHealed = RewardHealedHealth;
}

final function PawnDartHealed(Pawn Instigator, Pawn Target, int HealingAmount, HealingProjectile HealDart)
{
    RewardHealedHealth(Instigator, Target, HealingAmount);
}

final function RewardHealedHealth(Pawn Instigator, Pawn Target, int HealingAmount)
{
    if (HealingAmount <= 0)
    {
        return;
    }
    
    if (Instigator == None || Instigator == Target || TurboPlayerReplicationInfo(Instigator.PlayerReplicationInfo) == None)
    {
        return;
    }
    
    TurboPlayerReplicationInfo(Instigator.PlayerReplicationInfo).HealthHealed += HealingAmount;
}