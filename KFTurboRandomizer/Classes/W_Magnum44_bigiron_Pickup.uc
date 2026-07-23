//Killing Floor Turbo W_Magnum44_bigiron_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Magnum44_bigiron_Pickup extends W_Magnum44_Pickup;

function inventory SpawnCopy( pawn Other )
{
	Return Super(KFWeaponPickup).SpawnCopy(Other);
}

defaultproperties
{
     Weight = 5.000000
     InventoryType=Class'KFTurboRandomizer.W_Magnum44_bigiron_Weap'

     VariantClasses=()
}
