//Killing Floor Turbo W_SCARMK17_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SCARMK17_Pickup extends WeaponSCARMK17Pickup;

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
     VariantClasses(0)=Class'KFTurbo.W_SCARMK17_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_SCARMK17_Turbo_Pickup'
     VariantClasses(2)=Class'KFTurbo.W_V_SCARMK17_Cyber_Pickup'
     VariantClasses(3)=Class'KFTurbo.W_V_SCARMK17_Vet_Pickup'
     
     InventoryType=Class'KFTurbo.W_SCARMK17_Weap'
}
