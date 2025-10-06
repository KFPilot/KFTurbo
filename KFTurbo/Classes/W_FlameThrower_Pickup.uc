//Killing Floor Turbo W_FlameThrower_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Flamethrower_Pickup extends WeaponFlameThrowerPickup;

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
     VariantClasses(0)=Class'KFTurbo.W_FlameThrower_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_FlameThrower_Gold_Pickup'
     InventoryType=Class'KFTurbo.W_FlameThrower_Weap'
}
