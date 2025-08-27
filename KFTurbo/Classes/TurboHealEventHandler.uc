//Killing Floor Turbo TurboHealEventHandler
//Base class for heal events in KFTurbo. See TurboHealEventHandlerImpl for example implementation.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHealEventHandler extends TurboEventHandler;

delegate OnPawnDartHealed(Pawn Instigator, Pawn Target, int HealingAmount, HealingProjectile HealDart);
delegate OnPawnSyringeHealed(Pawn Instigator, Pawn Target, int HealingAmount);
delegate OnPawnGrenadeHealed(Pawn Instigator, Pawn Target, int HealingAmount);

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
    GameType.HealEventHandlerList[GameType.HealEventHandlerList.Length] = TurboHealEventHandler(Handler);
    return Handler;
}

function RemoveEventHandler()
{
    local int Index;
    local KFTurboGameType GameType;
    GameType = KFTurboGameType(Level.Game);

    Super.RemoveEventHandler();

    for (Index = GameType.HealEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        if (GameType.HealEventHandlerList[Index] != self)
        {
            continue;
        }

        GameType.HealEventHandlerList.Remove(Index, 1);
        break;
    }
}

//Event broadcasting.
static final function BroadcastPawnDartHealed(Pawn Instigator, Pawn Target, int HealingAmount, HealingProjectile HealDart)
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

    HealingAmount = Max(HealingAmount, 0);

    for (Index = KFTurboGameType.HealEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        KFTurboGameType.HealEventHandlerList[Index].OnPawnDartHealed(Instigator, Target, HealingAmount, HealDart);
    }
}

static final function BroadcastPawnSyringeHealed(Pawn Instigator, Pawn Target, int HealingAmount)
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

    HealingAmount = Max(HealingAmount, 0);

    for (Index = KFTurboGameType.HealEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        KFTurboGameType.HealEventHandlerList[Index].OnPawnSyringeHealed(Instigator, Target, HealingAmount);
    }
}

static final function BroadcastPawnGrenadeHealed(Pawn Instigator, Pawn Target, int HealingAmount)
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
    
    HealingAmount = Max(HealingAmount, 0);

    for (Index = KFTurboGameType.HealEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        KFTurboGameType.HealEventHandlerList[Index].OnPawnGrenadeHealed(Instigator, Target, HealingAmount);
    }
}