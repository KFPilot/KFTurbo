//Killing Floor Turbo W_MAC10_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_MAC10_Pickup extends MAC10Pickup;

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
     Weight=3.000000
     cost=650
     InventoryType=Class'KFTurbo.W_MAC10_Weap'

     VariantClasses(0)=class'KFTurbo.W_MAC10_Pickup'
     VariantClasses(1)=class'KFTurbo.W_V_MAC10_Vet_Pickup'
}