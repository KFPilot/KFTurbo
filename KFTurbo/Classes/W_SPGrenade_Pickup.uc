//Killing Floor Turbo W_SPGrenade_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SPGrenade_Pickup extends WeaponSPGrenadePickup;

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
     Cost=800
     InventoryType=Class'KFTurbo.W_SPGrenade_Weap'
}