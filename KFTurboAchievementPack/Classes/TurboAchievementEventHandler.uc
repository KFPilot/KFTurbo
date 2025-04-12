//Killing Floor Turbo TurboAchievementEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievementEventHandler extends KFTurbo.TurboGameplayEventHandler;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    OnPawnIgnited = PawnIgnited;
    OnPawnZapped = PawnZapped;
    OnPawnHarpooned = PawnHarpooned;
    OnBurnMitigatedDamage = BurnMitigatedDamage;
    OnPawnPushedWithMCZThrower = PawnPushedWithMCZThrower;
}

static final function SAReplicationInfo ResolveSARI(Pawn Instigator)
{
    if (Instigator == None || Instigator.PlayerReplicationInfo == None)
    {
        return None;
    }

    return class'SAReplicationInfo'.static.findSAri(Instigator.PlayerReplicationInfo);
}

function PawnIgnited(Pawn Instigator, Pawn Target, class<KFWeaponDamageType> DamageType, int BurnDamage)
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
            AchievementPack.OnPawnIgnited(Target, DamageType, BurnDamage);
        }
    }
}

function PawnZapped(Pawn Instigator, Pawn Target, float ZapAmount, bool bCausedZapped)
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
            AchievementPack.OnPawnZapped(Target, ZapAmount, bCausedZapped);
        }
    }
}

function PawnHarpooned(Pawn Instigator, Pawn Target, int CurrentHarpoonCount)
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
            AchievementPack.OnPawnHarpooned(Target, CurrentHarpoonCount);
        }
    }
}

function BurnMitigatedDamage(Pawn Instigator, Pawn Target, int Damage, int MitigatedDamage)
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
            AchievementPack.OnBurnMitigatedDamage(Target, Damage, MitigatedDamage);
        }
    }
}

function PawnPushedWithMCZThrower(Pawn Instigator, Pawn Target, Vector VelocityAdded)
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
            AchievementPack.OnPawnPushedWithMCZThrower(Target, VelocityAdded);
        }
    }
}