//Killing Floor Turbo W_MP5M_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_MP5M_Pickup extends MP5MPickup;

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
     Cost=600
     VariantClasses(0)=Class'KFTurbo.W_MP5M_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_MP5M_Camo_Pickup'
     InventoryType=Class'KFTurbo.W_MP5M_Weap'
}
