//Killing Floor Turbo TurboGameplayEventHandler
//Base class for combat gameplay events in KFTurbo. See TurboAchievementEventHandler for example implementation.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameplayEventHandler extends TurboEventHandler;

delegate OnPawnIgnited(Pawn Instigator, Pawn Target, class<KFWeaponDamageType> DamageType, int BurnDamage);
delegate OnPawnZapped(Pawn Instigator, Pawn Target, float ZapAmount, bool bCausedZapped);
delegate OnPawnHarpooned(Pawn Instigator, Pawn Target, int CurrentHarpoonCount);

delegate OnBurnMitigatedDamage(Pawn Instigator, Pawn Target, int Damage, int MitigatedDamage);

delegate OnPawnPushedWithMCZThrower(Pawn Instigator, Pawn Target, Vector VelocityAdded);

static function TurboEventHandler CreateHandler(Actor Context)
{
    local TurboEventHandler Handler;
    local KFTurboGameType GameType;

    Handler = Super.CreateHandler(Context);

    if (Handler == None)
    {
        return None;
    }

    GameType = KFTurboGameType(Context.Level.Game);
    GameType.GameplayEventHandlerList[GameType.GameplayEventHandlerList.Length] = TurboGameplayEventHandler(Handler);
    return Handler;
}

//Event broadcasting.
static final function BroadcastPawnIgnited(Pawn Instigator, Pawn Target, class<KFWeaponDamageType> DamageType, int BurnDamage)
{
    local KFTurboGameType KFTurboGameType;
    local int Index;

    if (Instigator == None)
    {
        return;
    }

    KFTurboGameType = KFTurboGameType(Instigator.Level.Game);

    if (KFTurboGameType == None)
    {
        return;
    }

    for (Index = KFTurboGameType.GameplayEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        KFTurboGameType.GameplayEventHandlerList[Index].OnPawnIgnited(Instigator, Target, DamageType, BurnDamage);
    }
}

static final function BroadcastPawnZapped(Pawn Instigator, Pawn Target, float ZapAmount, bool bCausedZapped)
{
    local KFTurboGameType KFTurboGameType;
    local int Index;

    if (Instigator == None)
    {
        return;
    }

    KFTurboGameType = KFTurboGameType(Instigator.Level.Game);

    if (KFTurboGameType == None)
    {
        return;
    }

    for (Index = KFTurboGameType.GameplayEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        KFTurboGameType.GameplayEventHandlerList[Index].OnPawnZapped(Instigator, Target, ZapAmount, bCausedZapped);
    }
}

static final function BroadcastPawnHarpooned(Pawn Instigator, Pawn Target, int CurrentHarpoonCount)
{
    local KFTurboGameType KFTurboGameType;
    local int Index;

    if (Instigator == None)
    {
        return;
    }

    KFTurboGameType = KFTurboGameType(Instigator.Level.Game);

    if (KFTurboGameType == None)
    {
        return;
    }

    for (Index = KFTurboGameType.GameplayEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        KFTurboGameType.GameplayEventHandlerList[Index].OnPawnHarpooned(Instigator, Target, CurrentHarpoonCount);
    }
}

static final function BroadcastBurnMitigatedDamage(Pawn Instigator, Pawn Target, int Damage, int MitigatedDamage)
{
    local KFTurboGameType KFTurboGameType;
    local int Index;

    if (Instigator == None)
    {
        return;
    }

    KFTurboGameType = KFTurboGameType(Instigator.Level.Game);

    if (KFTurboGameType == None)
    {
        return;
    }

    for (Index = KFTurboGameType.GameplayEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        KFTurboGameType.GameplayEventHandlerList[Index].OnBurnMitigatedDamage(Instigator, Target, Damage, MitigatedDamage);
    }
}

static final function BroadcastPawnPushedWithMCZThrower(Pawn Instigator, Pawn Target, Vector VelocityAdded)
{
    local KFTurboGameType KFTurboGameType;
    local int Index;

    if (Instigator == None)
    {
        return;
    }

    KFTurboGameType = KFTurboGameType(Instigator.Level.Game);

    if (KFTurboGameType == None)
    {
        return;
    }

    for (Index = KFTurboGameType.GameplayEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        KFTurboGameType.GameplayEventHandlerList[Index].OnPawnPushedWithMCZThrower(Instigator, Target, VelocityAdded);
    }
}