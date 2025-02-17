//Killing Floor Turbo W_M79_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M79_Pickup extends M79Pickup;

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
     Cost=750
     InventoryType=Class'KFTurbo.W_M79_Weap'
     VariantClasses(0)=Class'KFTurbo.W_M79_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_M79_Gold_Pickup'
}
