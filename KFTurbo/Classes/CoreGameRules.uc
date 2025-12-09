//Common Core CoreGameRules
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/CommonCore.
class CoreGameRules extends Engine.GameRules;

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType)
{
    local GameRules GameRules;
    local CoreGameRules CoreGameRules;

    GameRules = NextGameRules;

    //Find next CoreGameRules.
    while (GameRules != None)
    {
        CoreGameRules = CoreGameRules(GameRules);

        if (CoreGameRules != None)
        {
            break;
        }
        
        GameRules = GameRules.NextGameRules;
    }

    if (CoreGameRules != None)
    {
        CoreGameRules.Killed(Killer, Killed, KilledPawn, DamageType);
    }
}

defaultproperties
{

}