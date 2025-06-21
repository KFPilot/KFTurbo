//Killing Floor Turbo W_BlowerThrower_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_BlowerThrower_Pickup extends BlowerThrowerPickup;

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
     VariantClasses(0)=Class'KFTurbo.W_BlowerThrower_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_BlowerThrower_VM_Pickup'
     InventoryType=Class'KFTurbo.W_BlowerThrower_Weap'
}
