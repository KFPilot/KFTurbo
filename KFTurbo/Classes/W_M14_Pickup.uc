//Killing Floor Turbo W_M14_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M14_Pickup extends M14EBRPickup;

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
     VariantClasses(0)=Class'KFTurbo.W_M14_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_M14_Cubic_Pickup'
     VariantClasses(2)=Class'KFTurbo.W_V_M14_SMP_Pickup'
     VariantClasses(3)=Class'KFTurbo.W_V_M14_Turbo_Pickup'
     VariantClasses(4)=Class'KFTurbo.W_V_M14_Pride_Pickup'
     InventoryType=Class'KFTurbo.W_M14_Weap'
}
