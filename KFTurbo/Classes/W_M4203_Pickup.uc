//Killing Floor Turbo W_M4203_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M4203_Pickup extends WeaponM4203Pickup;

var W_M4203_Weap.ELoadState SecondaryLoadState;

function Inventory SpawnCopy(Pawn Other)
{
	local W_M4203_Weap Weap;

	if (Inventory != None)
	{
		Weap = W_M4203_Weap(Inventory);
		Inventory = None;
	}
	else
	{
		Weap = W_M4203_Weap(Spawn(InventoryType, Other, , , rot(0, 0, 0)));
	}

	Weap.GiveTo(Other, Self);
	Weap.UpdateSecondaryFromLoadState(SecondaryLoadState);

	return Weap;
}

function InitDroppedPickupFor(Inventory Inv)
{
	local W_M4203_Weap Weap;

	Super.InitDroppedPickupFor(Inv);

	Weap = W_M4203_Weap(Inv);

	if (Weap != None)
	{
		if (W_M4203_Fire(Weap.GetFireMode(1)).IsReadyAndLoaded())
		{
			SecondaryLoadState = Loaded;
		}
		else
		{
			SecondaryLoadState = Unloaded;
		}
	}
}

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
	Cost=1200
	VariantClasses(0)=Class'KFTurbo.W_M4203_Pickup'
	VariantClasses(1)=Class'KFTurbo.W_V_M4203_Camo_Pickup'
	VariantClasses(2)=Class'KFTurbo.W_V_M4203_Retart_Pickup'
	VariantClasses(3)=Class'KFTurbo.W_V_M4203_Scuddles_Pickup'
	VariantClasses(4)=Class'KFTurbo.W_V_M4203_Turbo_Pickup'
	InventoryType=Class'KFTurbo.W_M4203_Weap'
}
