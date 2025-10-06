//Killing Floor Turbo W_Syringe_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Syringe_Weap extends WeaponSyringe;

defaultproperties
{
    bCanThrow=false

	FireModeClass(0)=Class'KFTurbo.W_Syringe_Fire'
	FireModeClass(1)=Class'KFTurbo.W_Syringe_Fire_Alt'
	
	PickupClass=Class'KFTurbo.W_Syringe_Pickup'
}