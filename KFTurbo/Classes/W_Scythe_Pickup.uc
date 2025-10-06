//Killing Floor Turbo W_Scythe_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Scythe_Pickup extends WeaponScythePickup;

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
     cost=2000
     InventoryType=Class'KFTurbo.W_Scythe_Weap'
}