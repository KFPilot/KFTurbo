//Killing Floor Turbo W_M7A3M_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M7A3M_Pickup extends M7A3MPickup;

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
     Cost=800
     BuyClipSize=10
     InventoryType=Class'KFTurbo.W_M7A3M_Weap'
	 
     VariantClasses(0)=Class'KFTurbo.W_M7A3M_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_M7A3_Foundry_Pickup'
}
