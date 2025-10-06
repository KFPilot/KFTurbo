//Killing Floor Turbo W_Claymore_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Claymore_Pickup extends WeaponClaymoreSwordPickup;

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
     Weight=7.000000
     cost=2500
     InventoryType=Class'KFTurbo.W_Claymore_Weap'
}