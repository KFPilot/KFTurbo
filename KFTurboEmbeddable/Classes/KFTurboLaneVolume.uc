//Killing Floor Turbo KFTurboLaneVolume
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboLaneVolume extends Volume;

simulated final function bool HasPlayers()
{
    local KFHumanPawn Pawn;
    foreach TouchingActors(class'KFHumanPawn', Pawn)
    {
        if (Pawn.Health > 0)
        {
            return true;
        }
    }

    return false;
}