//Killing Floor Turbo TurboHumanBot
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHumanBot extends TurboHumanPawn;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role != ROLE_Authority)
    {
        return;
    }
    
    if (ControllerClass != None && Controller == None)
    {
        Controller = Spawn(ControllerClass);
    }
        
    if (Controller != None)
    {
        Controller.Possess(self);
    }
}

defaultproperties
{
    RequiredEquipment(0)="KFTurbo.W_Shotgun_Weap"
    ControllerClass=Class'TurboHumanBotController'
}
