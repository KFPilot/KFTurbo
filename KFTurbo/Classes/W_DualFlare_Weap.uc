//Killing Floor Turbo W_DualFlare_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_DualFlare_Weap extends DualFlareRevolver;

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

function GiveTo(Pawn Other, optional Pickup Pickup)
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
     FireModeClass(0)=Class'KFTurbo.W_DualFlare_Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PickupClass=Class'KFTurbo.W_DualFlare_Pickup'
	 DemoReplacement=Class'KFTurbo.W_FlareRevolver_Weap'
}