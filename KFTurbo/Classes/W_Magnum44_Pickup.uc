//Killing Floor Turbo W_Magnum44_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Magnum44_Pickup extends WeaponMagnum44Pickup;

function inventory SpawnCopy( pawn Other )
{
	class'WeaponHelper'.static.SingleWeaponSpawnCopy(Self, Other, class'W_Dual44_Weap');
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
	Weight=3.000000
	InventoryType=Class'KFTurbo.W_Magnum44_Weap'
	
	VariantClasses(0)=Class'KFTurbo.W_Magnum44_Pickup'
	VariantClasses(1)=Class'KFTurbo.W_V_Magnum44_Gold_Pickup'
}
