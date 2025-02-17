//Killing Floor Turbo W_Shotgun_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Shotgun_Pickup extends ShotgunPickup;

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
     VariantClasses(0)=Class'KFTurbo.W_Shotgun_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_Shotgun_WL_Pickup'
     VariantClasses(2)=Class'KFTurbo.W_V_Shotgun_Camo_Pickup'
     InventoryType=Class'KFTurbo.W_Shotgun_Weap'
}
