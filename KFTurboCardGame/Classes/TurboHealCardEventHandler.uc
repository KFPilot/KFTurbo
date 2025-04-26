//Killing Floor Turbo TurboPlayerCardEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHealCardEventHandler extends TurboHealEventHandler;

var bool bHealingBoost;

static function TurboPlayerCardCustomInfo FindCardCustomInfo(TurboPlayerReplicationInfo TPRI)
{
    return TurboPlayerCardCustomInfo(class'TurboPlayerCardCustomInfo'.static.FindCustomInfo(TPRI));
}

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
    local TurboPlayerCardCustomInfo CardCustomInfo;

    if (!bHealingBoost)
    {
        return;
    }

    if (Instigator == None || Instigator == Target)
    {
        return;
    }
    
    CardCustomInfo = FindCardCustomInfo(TurboPlayerReplicationInfo(Target.PlayerReplicationInfo));

    if (CardCustomInfo == None)
    {
        return;
    }

    CardCustomInfo.PlayerHealed();
}

defaultproperties
{
    bHealingBoost=false
}