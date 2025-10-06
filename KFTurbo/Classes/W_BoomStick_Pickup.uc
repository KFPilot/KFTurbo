//Killing Floor Turbo W_BoomStick_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_BoomStick_Pickup extends WeaponBoomStickPickup;

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
     cost=750
     InventoryType=Class'KFTurbo.W_BoomStick_Weap'

     VariantClasses(0)=class'KFTurbo.W_BoomStick_Pickup'
     VariantClasses(1)=class'KFTurbo.W_V_BoomStick_Vet_Pickup'
}