//Killing Floor Turbo TurboPlayerCardEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHealCardEventHandler extends TurboHealEventHandler;

//If true, notify the player's TurboPlayerCardCustomInfo that they were healed.
//This is really just an optimization to prevent unneeded lookups.
var bool bNotifyCardCustomInfo;

var float ReciprocalHealthMultiplier;

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

    //Healing amounts equal to 0 is fine, it should still attempt to trigger on player healed effects.
    if (HealingAmount < 0)
    {
        return;
    }

    if (Instigator == None || Instigator == Target)
    {
        return;
    }

    if (ReciprocalHealthMultiplier > 0.f)
    {
        ReciprocateHeal(Instigator, HealingAmount);
    }
    
    if (!bNotifyCardCustomInfo)
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

final function ReciprocateHeal(Pawn Instigator, int HealingAmount)
{
    HealingAmount = Round(float(HealingAmount) * ReciprocalHealthMultiplier);

    if (HealingAmount == 0 || Instigator == None)
    {
        return;
    }

    Instigator.GiveHealth(HealingAmount, Instigator.HealthMax);
}

defaultproperties
{
    bNotifyCardCustomInfo=false
    ReciprocalHealthMultiplier=0.f
}