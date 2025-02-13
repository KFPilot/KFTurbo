//Killing Floor Turbo W_9MM_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_9MM_Pickup extends SinglePickup;

function Inventory SpawnCopy(Pawn Other)
{
	class'WeaponHelper'.static.SingleWeaponSpawnCopy(Self, Other, class'W_Dual9MM_Weap');
	return Super(KFWeaponPickup).SpawnCopy(Other);
}

defaultproperties
{
     InventoryType=class'KFTurbo.W_9MM_Weap'
}