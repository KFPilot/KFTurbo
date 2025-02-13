//Killing Floor Turbo W_FlareRevolver_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_FlareRevolver_Pickup extends FlareRevolverPickup;

function inventory SpawnCopy( pawn Other )
{
	class'WeaponHelper'.static.SingleWeaponSpawnCopy(Self, Other, class'W_DualFlare_Weap');
	return Super(KFWeaponPickup).SpawnCopy(Other);
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
     InventoryType=Class'KFTurbo.W_FlareRevolver_Weap'
}