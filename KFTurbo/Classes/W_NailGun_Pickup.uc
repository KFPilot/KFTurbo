//Killing Floor Turbo W_NailGun_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_NailGun_Pickup extends NailGunPickup;

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
     Weight=11.000000
     cost=3000
     InventoryType=Class'KFTurbo.W_NailGun_Weap'
}
