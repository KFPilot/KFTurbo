//Killing Floor Turbo W_DualMK23_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_DualMK23_Pickup extends DualMK23Pickup;

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
	VariantClasses(0)=Class'KFTurbo.W_DualMK23_Pickup'
	VariantClasses(1)=Class'KFTurbo.W_V_DualMK23_Turbo_Pickup'
	VariantClasses(2)=Class'KFTurbo.W_V_DualMK23_Cyber_Pickup'

	InventoryType=Class'KFTurbo.W_DualMK23_Weap'
}
