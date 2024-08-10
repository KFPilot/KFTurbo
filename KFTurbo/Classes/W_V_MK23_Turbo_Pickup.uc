class W_V_MK23_Turbo_Pickup extends W_MK23_Pickup;

function inventory SpawnCopy( pawn Other )
{
	class'WeaponHelper'.static.SingleWeaponSpawnCopy(Self, Other, class'W_V_DualMK23_Turbo_Weap');
	Return Super(KFWeaponPickup).SpawnCopy(Other);
}

defaultproperties
{
     ItemName="Turbo MK23"
     ItemShortName="Turbo MK23"
     PickupMessage="You got the Turbo MK.23"
     
     InventoryType=Class'KFTurbo.W_V_MK23_Turbo_Weap'
     Skins(0)=Combiner'KFTurbo.Turbo.MK23_3RD_Turbo_CMB'
}
