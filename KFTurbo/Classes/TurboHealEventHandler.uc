//Killing Floor Turbo TurboHealEventHandler
//Base class for heal events in KFTurbo. See TurboHealEventHandlerImpl for example implementation.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHealEventHandler extends Object;

static function OnPawnDartHealed(Pawn Instigator, Pawn Target, int HealingAmount, HealingProjectile HealDart);
static function OnPawnSyringeHealed(Pawn Instigator, Pawn Target, int HealingAmount);
static function OnPawnGrenadeHealed(Pawn Instigator, Pawn Target, int HealingAmount);

//Event registration.
static final function RegisterHealHandler(Actor Context, class<TurboHealEventHandler> HealEventHandlerClass)
{
    local KFTurboGameType KFTurboGameType;
    local int Index;

    if (Context == None || HealEventHandlerClass == None)
    {
        return;
    }

    KFTurboGameType = KFTurboGameType(Context.Level.Game);

    if (KFTurboGameType == None)
    {
        return;
    }

    for (Index = 0; Index < KFTurboGameType.HealEventHandlerList.Length; Index++)
    {
        if (KFTurboGameType.HealEventHandlerList[Index] == HealEventHandlerClass)
        {
            return;
        }
    }

    KFTurboGameType.HealEventHandlerList[KFTurboGameType.HealEventHandlerList.Length] = HealEventHandlerClass;
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

    for (Index = KFTurboGameType.HealEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        KFTurboGameType.HealEventHandlerList[Index].static.OnPawnDartHealed(Instigator, Target, HealingAmount, HealDart);
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

    for (Index = KFTurboGameType.HealEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        KFTurboGameType.HealEventHandlerList[Index].static.OnPawnSyringeHealed(Instigator, Target, HealingAmount);
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

    for (Index = KFTurboGameType.HealEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        KFTurboGameType.HealEventHandlerList[Index].static.OnPawnGrenadeHealed(Instigator, Target, HealingAmount);
    }
}