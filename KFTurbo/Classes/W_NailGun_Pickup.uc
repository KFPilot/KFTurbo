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
     Weight=9.000000
     cost=2000
     InventoryType=Class'KFTurbo.W_NailGun_Weap'
}
