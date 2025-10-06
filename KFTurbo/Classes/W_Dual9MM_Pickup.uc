//Killing Floor Turbo W_Dual9MM_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Dual9MM_Pickup extends WeaponDualiesPickup;

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
	Weight=1
     InventoryType=Class'KFTurbo.W_Dual9MM_Weap'
}