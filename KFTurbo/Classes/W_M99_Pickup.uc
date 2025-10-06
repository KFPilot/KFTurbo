//Killing Floor Turbo W_M99_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M99_Pickup extends WeaponM99Pickup;

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
     Weight=12.000000
     cost=1200
     AmmoCost=60
     VariantClasses(0)=Class'KFTurbo.W_M99_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_M99_Turbo_Pickup'
     VariantClasses(2)=Class'KFTurbo.W_V_M99_Vet_Pickup'     
     InventoryType=Class'KFTurbo.W_M99_Weap'
}
