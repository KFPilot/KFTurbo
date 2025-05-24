//Killing Floor Turbo TurboAchievementHealEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievementHealEventHandler extends KFTurbo.TurboHealEventHandler;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    OnPawnDartHealed = PawnDartHealed;
    OnPawnSyringeHealed = PawnSyringeHealed;
    OnPawnGrenadeHealed = PawnGrenadeHealed;
}

static final function SAReplicationInfo ResolveSARI(Pawn Instigator)
{
    if (Instigator == None || Instigator.PlayerReplicationInfo == None)
    {
        return None;
    }

    return class'SAReplicationInfo'.static.findSAri(Instigator.PlayerReplicationInfo);
}

function PawnDartHealed(Pawn Instigator, Pawn Target, int HealingAmount, HealingProjectile HealDart)
{
    local SAReplicationInfo SARI;
    local TurboAchievementPackImpl AchievementPack;
    local int Index;
    
    if (HealingAmount <= 0)
    {
        return;
    }

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

function PawnSyringeHealed(Pawn Instigator, Pawn Target, int HealingAmount)
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

function PawnGrenadeHealed(Pawn Instigator, Pawn Target, int HealingAmount)
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