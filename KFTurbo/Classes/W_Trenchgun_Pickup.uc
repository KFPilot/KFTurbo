//Killing Floor Turbo W_Trenchgun_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Trenchgun_Pickup extends TrenchgunPickup;

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
     cost=1500
     InventoryType=Class'KFTurbo.W_Trenchgun_Weap'
}