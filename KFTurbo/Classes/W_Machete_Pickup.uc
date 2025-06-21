//Killing Floor Turbo W_Machete_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Machete_Pickup extends MachetePickup;

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
     InventoryType=Class'KFTurbo.W_Machete_Weap'
}
