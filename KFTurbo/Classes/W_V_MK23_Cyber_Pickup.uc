class W_V_MK23_Cyber_Pickup extends W_MK23_Pickup;

function inventory SpawnCopy( pawn Other )
{
	class'WeaponHelper'.static.SingleWeaponSpawnCopy(Self, Other, class'W_V_DualMK23_Cyber_Weap');
	Return Super(KFWeaponPickup).SpawnCopy(Other);
}

defaultproperties
{
     ItemName="Cyber MK23"
     ItemShortName="Cyber MK23"
     PickupMessage="You got the Cyber MK.23"

     InventoryType=Class'KFTurbo.W_V_MK23_Cyber_Weap'
     Skins(0)=Shader'KFTurbo.Cyber.Cyber_MK23_3rd_SHDR'
}
