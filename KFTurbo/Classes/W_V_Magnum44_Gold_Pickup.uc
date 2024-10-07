class W_V_Magnum44_Gold_Pickup extends W_Magnum44_Pickup;

function inventory SpawnCopy( pawn Other )
{
	class'WeaponHelper'.static.SingleWeaponSpawnCopy(Self, Other, class'W_V_Dual44_Gold_Weap');
	Return Super(KFWeaponPickup).SpawnCopy(Other);
}

defaultproperties
{
     ItemName="Gold 44 Magnum"
     ItemShortName="Gold 44 Magnum"
     PickupMessage="You got the Gold 44 Magnum"
     
     InventoryType=Class'KFTurbo.W_V_Magnum44_Gold_Weap'
     Skins(0)=Texture'KFTurbo.Gold.Revolver_Gold_3rd_D'
}
