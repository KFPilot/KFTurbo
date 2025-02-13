//Killing Floor Turbo W_Syringe_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Syringe_Pickup extends KFMod.SyringePickup;

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
    InventoryType=Class'W_Syringe_Weap'
}