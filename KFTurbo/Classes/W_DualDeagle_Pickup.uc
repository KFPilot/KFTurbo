//Killing Floor Turbo W_DualDeagle_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_DualDeagle_Pickup extends WeaponDualDeaglePickup;

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
     VariantClasses(0)=Class'KFTurbo.W_DualDeagle_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_DualDeagle_Gold_Pickup'
	VariantClasses(2)=Class'KFTurbo.W_V_DualDeagle_Vet_Pickup'	
     InventoryType=Class'KFTurbo.W_DualDeagle_Weap'
}
