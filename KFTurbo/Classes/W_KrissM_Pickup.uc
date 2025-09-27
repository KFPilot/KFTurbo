//Killing Floor Turbo W_KrissM_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_KrissM_Pickup extends KrissMPickup;

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
	Weight=4.000000
	Cost=1000
	InventoryType=Class'KFTurbo.W_KrissM_Weap'
	
	VariantClasses(0)=class'KFTurbo.W_KrissM_Pickup'
	VariantClasses(1)=class'KFTurbo.W_V_KrissM_Vet_Pickup'
	VariantClasses(2)=class'KFTurbo.W_V_KrissM_Kot_Pickup'
}
