//Killing Floor Turbo TurboGameRules
//Adds a few more gameplay hooks to GameRules.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameRules extends Engine.GameRules;

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType)
{
    local GameRules GameRules;
    local TurboGameRules TurboGameRules;

    GameRules = NextGameRules;

    //Find next TurboGameRules.
    while (GameRules != None)
    {
        TurboGameRules = TurboGameRules(GameRules);

        if (TurboGameRules != None)
        {
            break;
        }
        
        GameRules = GameRules.NextGameRules;
    }

    if (TurboGameRules != None)
    {
        TurboGameRules.Killed(Killer, Killed, KilledPawn, DamageType);
    }
}

defaultproperties
{

}