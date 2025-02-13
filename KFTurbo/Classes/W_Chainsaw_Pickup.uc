//Killing Floor Turbo W_Chainsaw_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Chainsaw_Pickup extends ChainsawPickup;

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
     InventoryType=Class'KFTurbo.W_Chainsaw_Weap'
     VariantClasses(0)=Class'KFTurbo.W_Chainsaw_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_Chainsaw_Gold_Pickup'
}
