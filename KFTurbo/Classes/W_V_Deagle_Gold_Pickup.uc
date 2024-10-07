class W_V_Deagle_Gold_Pickup extends W_Deagle_Pickup;

function Inventory SpawnCopy(pawn Other)
{
	class'WeaponHelper'.static.SingleWeaponSpawnCopy(Self, Other, class'W_V_DualDeagle_Gold_Weap');
	Return Super(KFWeaponPickup).SpawnCopy(Other);
}

defaultproperties
{
	InventoryType=Class'KFTurbo.W_V_Deagle_Gold_Weap'

	ItemName="Golden Handcannon"
	ItemShortName="Golden Handcannon"
	PickupMessage="You got the gold handcannon."
	StaticMesh=StaticMesh'KF_pickupsGold_Trip.HandcannonGold_Pickup'
	Skins(0)=Texture'KF_Weapons3rd_Gold_T.Weapons.Gold_Handcannon_3rd'
}
