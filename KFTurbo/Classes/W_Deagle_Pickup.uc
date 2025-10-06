//Killing Floor Turbo W_Deagle_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Deagle_Pickup extends WeaponDeaglePickup;

function Inventory SpawnCopy(pawn Other)
{
	class'WeaponHelper'.static.SingleWeaponSpawnCopy(Self, Other, class'W_DualDeagle_Weap');
	Return Super(KFWeaponPickup).SpawnCopy(Other);
}

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
	InventoryType=Class'KFTurbo.W_Deagle_Weap'
	
	VariantClasses(0)=Class'KFTurbo.W_Deagle_Pickup'
	VariantClasses(1)=Class'KFTurbo.W_V_Deagle_Gold_Pickup'
	VariantClasses(2)=Class'KFTurbo.W_V_Deagle_Vet_Pickup'	
}
