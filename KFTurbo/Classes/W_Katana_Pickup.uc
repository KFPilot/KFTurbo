//Killing Floor Turbo W_Katana_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Katana_Pickup extends KatanaPickup;

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
     VariantClasses(0)=Class'KFTurbo.W_Katana_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_Katana_Gold_Pickup'
     VariantClasses(2)=Class'KFTurbo.W_V_Katana_VM_Pickup'
     VariantClasses(3)=Class'KFTurbo.W_V_Katana_Vet_Pickup'
     InventoryType=Class'KFTurbo.W_Katana_Weap'
}
