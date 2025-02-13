//Killing Floor Turbo TurboPlayerStatsHealEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerStatsHealEventHandler extends TurboHealEventHandler;

static final function TurboWavePlayerStatCollector GetPlayerWaveStats(Pawn Instigator)
{
    local TurboPlayerController Player;

    if (Instigator == None || !Instigator.IsPlayerPawn())
    {
        return None;
    }

    Player = TurboPlayerController(Instigator.Controller);

    if (Player == None)
    {
        return None;
    }

    return TurboWavePlayerStatCollector(class'TurboWavePlayerStatCollector'.static.FindStats(TurboPlayerReplicationInfo(Player.PlayerReplicationInfo)));
}

static final function IncrementHealStats(Pawn Instigator, Pawn Target, int HealingAmount)
{
    local TurboWavePlayerStatCollector StatCollector;
    if (Instigator == None || Instigator == Target)
    {
        return;
    }

    StatCollector = GetPlayerWaveStats(Instigator);

    if (StatCollector == None)
    {
        return;
    }

    StatCollector.IncrementHealthHealed(HealingAmount);
}

static function OnPawnDartHealed(Pawn Instigator, Pawn Target, int HealingAmount, HealingProjectile HealDart)
{
    IncrementHealStats(Instigator, Target, HealingAmount);
}

static function OnPawnSyringeHealed(Pawn Instigator, Pawn Target, int HealingAmount)
{
    IncrementHealStats(Instigator, Target, HealingAmount);
}

static function OnPawnGrenadeHealed(Pawn Instigator, Pawn Target, int HealingAmount)
{
    IncrementHealStats(Instigator, Target, HealingAmount);
}