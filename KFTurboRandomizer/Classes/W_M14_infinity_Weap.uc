//Killing Floor Turbo W_M14_infinity_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M14_infinity_Weap extends W_M14_Weap;

defaultproperties
{
     MagCapacity=8000
     ItemName="M14 Infinity"
     PickupClass=Class'KFTurboRandomizer.W_M14_infinity_Pickup'
     FireModeClass(0)=Class'KFTurboRandomizer.W_M14_infinity_Fire'
}