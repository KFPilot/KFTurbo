//Killing Floor Turbo W_KSG_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_KSG_Pickup extends WeaponKSGPickup;

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
     Weight=7.000000
     cost=1750
     InventoryType=Class'KFTurbo.W_KSG_Weap'
     VariantClasses(0)=Class'KFTurbo.W_KSG_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_KSG_Vet_Pickup'
}
