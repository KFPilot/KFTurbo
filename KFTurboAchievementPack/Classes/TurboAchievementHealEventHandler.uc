//Killing Floor Turbo TurboAchievementHealEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievementHealEventHandler extends KFTurbo.TurboHealEventHandler;

static function SAReplicationInfo ResolveSARI(Pawn Instigator)
{
    if (Instigator == None || Instigator.PlayerReplicationInfo == None)
    {
        return None;
    }

    return class'SAReplicationInfo'.static.findSAri(Instigator.PlayerReplicationInfo);
}

static function OnPawnDartHealed(Pawn Instigator, Pawn Target, int HealingAmount, HealingProjectile HealDart)
{
    local SAReplicationInfo SARI;
    local TurboAchievementPackImpl AchievementPack;
    local int Index;
    SARI = ResolveSARI(Instigator);

    if (SARI == None)
    {
        return;
    }

    for (Index = SARI.achievementPacks.Length - 1; Index >= 0; Index--)
    {
        AchievementPack = TurboAchievementPackImpl(SARI.achievementPacks[Index]);

        if (AchievementPack != None)
        {
            AchievementPack.OnPawnDartHeal(Target, HealingAmount, HealDart);
            AchievementPack.OnPawnHealed(Target, HealingAmount);
        }
    }
}

static function OnPawnSyringeHealed(Pawn Instigator, Pawn Target, int HealingAmount)
{
    local SAReplicationInfo SARI;
    local TurboAchievementPackImpl AchievementPack;
    local int Index;
    SARI = ResolveSARI(Instigator);

    if (SARI == None)
    {
        return;
    }

    for (Index = SARI.achievementPacks.Length - 1; Index >= 0; Index--)
    {
        AchievementPack = TurboAchievementPackImpl(SARI.achievementPacks[Index]);

        if (AchievementPack != None)
        {
            AchievementPack.OnPawnSyringeHeal(Target, HealingAmount);
            AchievementPack.OnPawnHealed(Target, HealingAmount);
        }
    }
}

static function OnPawnGrenadeHealed(Pawn Instigator, Pawn Target, int HealingAmount)
{
    local SAReplicationInfo SARI;
    local TurboAchievementPackImpl AchievementPack;
    local int Index;
    SARI = ResolveSARI(Instigator);

    if (SARI == None)
    {
        return;
    }

    for (Index = SARI.achievementPacks.Length - 1; Index >= 0; Index--)
    {
        AchievementPack = TurboAchievementPackImpl(SARI.achievementPacks[Index]);

        if (AchievementPack != None)
        {
            AchievementPack.OnPawnGrenadeHeal(Target, HealingAmount);
            AchievementPack.OnPawnHealed(Target, HealingAmount);
        }
    }
}