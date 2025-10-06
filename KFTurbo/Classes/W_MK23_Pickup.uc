//Killing Floor Turbo W_MK23_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_MK23_Pickup extends WeaponMK23Pickup;

function inventory SpawnCopy( pawn Other )
{
	class'WeaponHelper'.static.SingleWeaponSpawnCopy(Self, Other, class'W_DualMK23_Weap');
	return Super(KFWeaponPickup).SpawnCopy(Other);
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
     VariantClasses(0)=Class'KFTurbo.W_MK23_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_MK23_Turbo_Pickup'
     VariantClasses(2)=Class'KFTurbo.W_V_MK23_Cyber_Pickup'
     InventoryType=Class'KFTurbo.W_MK23_Weap'
}
