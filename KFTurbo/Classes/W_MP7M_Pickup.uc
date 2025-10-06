//Killing Floor Turbo W_MP7M_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_MP7M_Pickup extends WeaponMP7MPickup;

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
     Cost=350
     InventoryType=Class'KFTurbo.W_MP7M_Weap'
}
