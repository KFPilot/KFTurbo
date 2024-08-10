class TurboEventHandlerImpl extends TurboEventHandler;

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
    local TurboPlayerReplicationInfo TPRI;

    if (Instigator == None || Instigator == Target || Instigator.PlayerReplicationInfo == None)
    {
        return;
    }

    TPRI = class'TurboPlayerReplicationInfo'.static.GetTurboPRI(Instigator.PlayerReplicationInfo);

    if (TPRI == None)
    {
        return;
    }

    TPRI.HealthHealed += HealingAmount;
}