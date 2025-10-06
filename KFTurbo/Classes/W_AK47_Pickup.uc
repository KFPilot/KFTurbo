//Killing Floor Turbo W_AK47_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_AK47_Pickup extends WeaponAK47Pickup;

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
     Weight=5.000000
     VariantClasses(0)=Class'KFTurbo.W_AK47_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_AK47_Gold_Pickup'
     VariantClasses(2)=Class'KFTurbo.W_V_AK47_Turbo_Pickup'
     VariantClasses(3)=Class'KFTurbo.W_V_AK47_Vet_Pickup'
     InventoryType=Class'KFTurbo.W_AK47_Weap'
}
