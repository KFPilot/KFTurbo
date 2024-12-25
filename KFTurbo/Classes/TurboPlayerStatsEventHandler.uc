//Killing Floor Turbo TurboPlayerStatsEventHandler
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerStatsEventHandler extends TurboPlayerEventHandler;

static final function TurboWavePlayerStatCollector GetPlayerWaveStats(TurboPlayerController Player)
{
    if (Player == None)
    {
        return None;
    }

    return TurboWavePlayerStatCollector(class'TurboWavePlayerStatCollector'.static.FindStats(TurboPlayerReplicationInfo(Player.PlayerReplicationInfo)));
}

static function OnPlayerFire(TurboPlayerController Player, WeaponFire FireMode)
{
    local TurboWavePlayerStatCollector WavePlayerStatCollector;
    WavePlayerStatCollector = GetPlayerWaveStats(Player);

    if (WavePlayerStatCollector == None)
    {
        return;
    }

    WavePlayerStatCollector.IncrementShotsFired();
}

static function OnPlayerFireHit(TurboPlayerController Player, WeaponFire FireMode, KFMonster HitMonster, class<KFMonster> MonsterClass, bool bHeadshot, int Damage)
{
    local TurboWavePlayerStatCollector WavePlayerStatCollector;
    WavePlayerStatCollector = GetPlayerWaveStats(Player);

    if (WavePlayerStatCollector == None)
    {
        return;
    }

    WavePlayerStatCollector.IncrementShotsHit(bHeadShot);
}

static function OnPlayerMeleeFire(TurboPlayerController Player, KFMeleeFire FireMode)
{
    local TurboWavePlayerStatCollector WavePlayerStatCollector;
    WavePlayerStatCollector = GetPlayerWaveStats(Player);

    if (WavePlayerStatCollector == None)
    {
        return;
    }

    WavePlayerStatCollector.IncrementMeleeSwings();
}

static function OnPlayerReload(TurboPlayerController Player, KFWeapon Weapon)
{
    local TurboWavePlayerStatCollector WavePlayerStatCollector;
    WavePlayerStatCollector = GetPlayerWaveStats(Player);

    if (WavePlayerStatCollector == None)
    {
        return;
    }

    WavePlayerStatCollector.IncrementReloads();
}

static function OnPlayerDamagedMonster(TurboPlayerController Player, KFMonster Target, int Damage)
{
    local TurboWavePlayerStatCollector WavePlayerStatCollector;
    WavePlayerStatCollector = GetPlayerWaveStats(Player);

    if (WavePlayerStatCollector == None)
    {
        return;
    }

    WavePlayerStatCollector.IncrementDamageDone(Damage, Target.Class);
}

static function OnPlayerKilledMonster(TurboPlayerController Player, KFMonster Target)
{
    local TurboWavePlayerStatCollector WavePlayerStatCollector;
    WavePlayerStatCollector = GetPlayerWaveStats(Player);

    if (WavePlayerStatCollector == None)
    {
        return;
    }

    WavePlayerStatCollector.IncrementKills(Target.Class);
}