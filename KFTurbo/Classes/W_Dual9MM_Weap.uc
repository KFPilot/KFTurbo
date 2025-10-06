//Killing Floor Turbo W_Dual9MM_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Dual9MM_Weap extends WeaponDualies;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

function bool HandlePickupQuery( pickup Item )
{
	if (class'WeaponHelper'.static.DualWeaponHandlePickupQuery(Self, Item))
	{
		return true;
	}

	return Super(KFWeapon).HandlePickupQuery(Item);
}

function GiveTo( pawn Other, optional Pickup Pickup )
{
	class'WeaponHelper'.static.DualWeaponGiveTo(Self, Other, Pickup);

	Super(KFWeapon).GiveTo(Other, Pickup);
}

function DropFrom(vector StartLocation)
{
	class'WeaponHelper'.static.DualWeaponDropFrom(Self, StartLocation);
}

simulated function bool PutDown()
{
	class'WeaponHelper'.static.DualWeaponPutDown(Self);

	return Super(KFWeapon).PutDown();
}

defaultproperties
{
	Weight=1

	FireModeClass(0)=Class'KFTurbo.W_Dual9MM_Fire'
	FireModeClass(1)=Class'KFMod.SingleALTFire'
	
	PickupClass=Class'KFTurbo.W_Dual9MM_Pickup'

	DemoReplacement=Class'KFTurbo.W_9MM_Weap'

	HudImageRef="KillingFloorHUD.WeaponSelect.dual_9mm_unselected"
	SelectedHudImageRef="KillingFloorHUD.WeaponSelect.dual_9mm"

	Skins(0)=None
	SkinRefs(0)="KF_Weapons_Trip_T.Pistols.Ninemm_cmb"
	
	Mesh=None
	MeshRef="KF_Weapons_Trip.Dual9mm"
}
