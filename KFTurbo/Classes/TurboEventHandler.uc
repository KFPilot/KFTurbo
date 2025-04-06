//Killing Floor Turbo TurboEventHandler
//Base class for delegate-based handlers of events in KFTurbo.
//Moved from being classes with static functions to delegates so that there's less runtime lookups.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboEventHandler extends Info
    abstract;

//We disable tick by default as a convenience.
function PostBeginPlay()
{
    Super.PostBeginPlay();
    Disable('Tick');
}

//This should be overridden to add the new handler to a relevant processing list.
static function TurboEventHandler CreateHandler(Actor Context)
{
    local TurboEventHandler Handler;
    local KFTurboGameType GameType;

    if (Context == None || Context.Level == None || Context.Level.bLevelChange || Context.Role != ROLE_Authority)
    {
        return None;
    }
    
    GameType = KFTurboGameType(Context.Level.Game);

    if (GameType == None)
    {
        return None;
    }

    Handler = Context.Spawn(default.Class, Context);
    GameType.EventHandlerList[GameType.EventHandlerList.Length] = Handler;
    return Handler;
}

defaultproperties
{
    bCollideActors=false
    bCollideWorld=false
    bBlockZeroExtentTraces=false
    bBlockNonZeroExtentTraces=false
    
    NetUpdateFrequency=0.001
}