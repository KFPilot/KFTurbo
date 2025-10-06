//Killing Floor Turbo W_Knife_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Knife_Weap extends WeaponKnife;

defaultproperties
{
     bCanThrow=false

     PickupClass=class'W_Knife_Pickup'
     FireModeClass(0)=Class'KFTurbo.W_Knife_Fire'
     FireModeClass(1)=Class'KFTurbo.W_Knife_Fire_Alt'
}
