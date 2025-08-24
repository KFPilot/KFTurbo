//Killing Floor Turbo W_ThompsonSMG_Pickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_ThompsonSMG_Pickup extends ThompsonPickup;

defaultproperties
{
     VariantClasses=()

     Weight=6.000000
     cost=1250
	CorrespondingPerkIndex=5
     AmmoCost=15
     BuyClipSize=20
     PowerValue=40
     SpeedValue=80
     RangeValue=50
     ItemName="Thompson Incendiary SMG"
     ItemShortName="Thompson Incendiary"
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     InventoryType=Class'KFTurbo.W_ThompsonSMG_Weap'
     PickupMessage="You got the Thompson Incendiary SMG"
     PickupForce="AssaultRiflePickup"
	 
     VariantClasses(0)=Class'KFTurbo.W_ThompsonSMG_Pickup'
     VariantClasses(1)=Class'KFTurbo.W_V_ThompsonSMG_Foundry_Pickup'
}