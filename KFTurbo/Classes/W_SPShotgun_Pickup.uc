//Killing Floor Turbo W_SPShotgun_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SPShotgun_Pickup extends SPShotgunPickup;

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
     Weight=8.000000
     cost=1500
     InventoryType=Class'KFTurbo.W_SPShotgun_Weap'
}
