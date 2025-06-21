//Killing Floor Turbo W_Bullpup_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Bullpup_Pickup extends BullpupPickup;

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
     cost=500
     InventoryType=Class'KFTurbo.W_Bullpup_Weap'
     VariantClasses(0)=Class'KFTurbo.W_Bullpup_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_Bullpup_WL_Pickup'
}