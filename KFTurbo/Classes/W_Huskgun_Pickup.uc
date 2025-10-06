//Killing Floor Turbo W_Huskgun_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Huskgun_Pickup extends WeaponHuskGunPickup;

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
     AmmoCost=50
     BuyClipSize=40
     InventoryType=Class'KFTurbo.W_Huskgun_Weap'
}