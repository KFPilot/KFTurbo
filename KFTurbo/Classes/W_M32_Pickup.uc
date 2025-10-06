//Killing Floor Turbo W_M32_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M32_Pickup extends WeaponM32Pickup;

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
     Cost=2400
     VariantClasses(0)=Class'KFTurbo.W_M32_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_M32_Camo_Pickup'
     VariantClasses(2)=Class'KFTurbo.W_V_M32_Turbo_Pickup'
     VariantClasses(3)=Class'KFTurbo.W_V_M32_Vet_Pickup'
     InventoryType=Class'KFTurbo.W_M32_Weap'
}
