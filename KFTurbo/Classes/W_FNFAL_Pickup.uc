//Killing Floor Turbo W_FNFAL_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_FNFAL_Pickup extends WeaponFNFAL_ACOG_Pickup;

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
     cost=2500
     VariantClasses(0)=Class'KFTurbo.W_FNFAL_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_FNFAL_Turbo_Pickup'
     InventoryType=Class'KFTurbo.W_FNFAL_Weap'
}
