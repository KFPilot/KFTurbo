//Killing Floor Turbo W_ThompsonDrum_spread_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_ThompsonDrum_spread_Weap extends W_ThompsonDrum_Weap;

simulated function DoToggle()
{

}

function ServerChangeFireMode(bool bNewWaitForRelease)
{

}

defaultproperties
{
     FireModeClass(0)=Class'KFTurboRandomizer.W_ThompsonDrum_spread_Fire'
     ItemName="Questionable Tommy Gun"
     PickupClass=Class'KFTurboRandomizer.W_ThompsonDrum_spread_Pickup'
}