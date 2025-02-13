//Killing Floor Turbo W_Bullpup_brrt_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Bullpup_brrt_Weap extends Bullpup;

simulated function DoToggle()
{

}

function ServerChangeFireMode(bool bNewWaitForRelease)
{

}

defaultproperties
{
     MagCapacity=80
     FireModeClass(0)=Class'KFTurboRandomizer.W_Bullpup_brrt_Fire'
     PickupClass=Class'KFTurboRandomizer.W_Bullpup_brrt_Pickup'
     ItemName="Questionable Bullpup"
}