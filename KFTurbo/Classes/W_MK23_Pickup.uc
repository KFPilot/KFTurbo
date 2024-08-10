class W_MK23_Pickup extends MK23Pickup;

function inventory SpawnCopy( pawn Other )
{
	class'WeaponHelper'.static.SingleWeaponSpawnCopy(Self, Other, class'W_DualMK23_Weap');
	Return Super(KFWeaponPickup).SpawnCopy(Other);
}

defaultproperties
{
     VariantClasses(0)=Class'KFTurbo.W_MK23_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_MK23_Turbo_Pickup'
     VariantClasses(2)=Class'KFTurbo.W_V_MK23_Cyber_Pickup'
     InventoryType=Class'KFTurbo.W_MK23_Weap'
}
