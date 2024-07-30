class W_FlareRevolver_Pickup extends FlareRevolverPickup;

function inventory SpawnCopy( pawn Other )
{
	local Inventory I;

	for ( I = Other.Inventory; I != none; I = I.Inventory )
	{
		if ( FlareRevolver(I) != none )
		{
			if( Inventory != none )
				Inventory.Destroy();
			InventoryType = Class'W_DualFlare_Weap';
            AmmoAmount[0] += FlareRevolver(I).AmmoAmount(0);
            MagAmmoRemaining += FlareRevolver(I).MagAmmoRemaining;
			I.Destroyed();
			I.Destroy();
			Return Super(KFWeaponPickup).SpawnCopy(Other);
		}
	}
	InventoryType = Default.InventoryType;
	Return Super(KFWeaponPickup).SpawnCopy(Other);
}
defaultproperties
{
     InventoryType=Class'KFTurbo.W_FlareRevolver_Weap'
}