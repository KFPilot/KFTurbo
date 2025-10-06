//Killing Floor Turbo W_SPSniper_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SPSniper_Pickup extends WeaponSPSniperPickup;

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
      cost=1750
      InventoryType=Class'KFTurbo.W_SPSniper_Weap'
      VariantClasses=()
}
