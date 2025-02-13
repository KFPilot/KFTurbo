//Killing Floor Turbo W_V_Deagle_Vet_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_Deagle_Vet_Pickup extends W_Deagle_Pickup;

function Inventory SpawnCopy(pawn Other)
{
	class'WeaponHelper'.static.SingleWeaponSpawnCopy(Self, Other, class'W_V_DualDeagle_Vet_Weap');
	Return Super(KFWeaponPickup).SpawnCopy(Other);
}

defaultproperties
{
	InventoryType=Class'KFTurbo.W_V_Deagle_Vet_Weap'

	ItemName="Neon Handcannon"
	PickupMessage="You got the Neon Handcannon."
	Skins(0)=Texture'KFTurbo.Vet.Handcannon_Vet_3rd_D'
}
