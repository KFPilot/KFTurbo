//Killing Floor Turbo W_Dual44_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Dual44_Weap extends Dual44Magnum;

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
     ReloadRate=4.500000
     Weight=6.000000
     FireModeClass(0)=Class'KFTurbo.W_Dual44_Fire'
     DemoReplacement=Class'KFTurbo.W_Magnum44_Weap'
     PickupClass=Class'KFTurbo.W_Dual44_Pickup'
}
