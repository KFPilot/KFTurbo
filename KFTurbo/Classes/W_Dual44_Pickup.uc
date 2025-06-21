//Killing Floor Turbo W_Dual44_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Dual44_Pickup extends Dual44MagnumPickup;

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
     Weight=6.000000
     InventoryType=Class'KFTurbo.W_Dual44_Weap'  

     VariantClasses(0)=Class'KFTurbo.W_Dual44_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_Dual44_Gold_Pickup'
}
