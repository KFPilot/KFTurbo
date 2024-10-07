class W_Magnum44_Pickup extends Magnum44Pickup;

function inventory SpawnCopy( pawn Other )
{
	class'WeaponHelper'.static.SingleWeaponSpawnCopy(Self, Other, class'W_Dual44_Weap');
	Return Super(KFWeaponPickup).SpawnCopy(Other);
}

defaultproperties
{
	Weight=3.000000
	InventoryType=Class'KFTurbo.W_Magnum44_Weap'
	
	VariantClasses(0)=Class'KFTurbo.W_Magnum44_Pickup'
	VariantClasses(1)=Class'KFTurbo.W_V_Magnum44_Gold_Pickup'
}
