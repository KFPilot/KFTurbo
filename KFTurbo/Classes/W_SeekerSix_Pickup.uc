//Killing Floor Turbo W_SeekerSix_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SeekerSix_Pickup extends SeekerSixPickup;

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
     Weight=8.000000
     Cost=1700
     InventoryType=Class'KFTurbo.W_SeekerSix_Weap'
	 
     VariantClasses(0)=Class'KFTurbo.W_SeekerSix_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_SeekerSix_Biotics_Pickup'
}
