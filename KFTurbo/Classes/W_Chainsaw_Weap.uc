//Killing Floor Turbo W_Chainsaw_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Chainsaw_Weap extends Chainsaw;

defaultproperties
{
    PickupClass=Class'KFTurbo.W_Chainsaw_Pickup'
     
	FireModeClass(0)=Class'KFTurbo.W_Chainsaw_Fire'
	FireModeClass(1)=Class'KFTurbo.W_Chainsaw_Fire_Alt'

    bSpeedMeUp = True
}
