//Killing Floor Turbo W_ThompsonDrum_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_ThompsonDrum_Pickup extends WeaponThompsonDrumPickup;

function Destroyed()
{
	if (Inventory != None)
	{
		Super.Destroyed();
	}
	else
	{
		Super(WeaponPickup).Destroyed();
	}
}

defaultproperties
{
     Weight=6.000000
     cost=1500
     InventoryType=Class'KFTurbo.W_ThompsonDrum_Weap'
     VariantClasses(0)=Class'KFTurbo.W_ThompsonDrum_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_ThompsonDrum_STP_Pickup'
}
