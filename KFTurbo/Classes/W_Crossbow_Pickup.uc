//Killing Floor Turbo W_Crossbow_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Crossbow_Pickup extends CrossbowPickup;

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
     InventoryType=Class'KFTurbo.W_Crossbow_Weap'
}
