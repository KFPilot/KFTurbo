//Killing Floor Turbo W_Deagle_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Deagle_Weap extends Deagle;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

simulated function BringUp(optional Weapon PrevWeapon)
{
     class'WeaponHelper'.static.WeaponCheckForHint(Self, 12);

     Super.BringUp(PrevWeapon);
}

function bool HandlePickupQuery(pickup Item)
{
	if (class'WeaponHelper'.static.SingleWeaponHandlePickupQuery(Self, Item))
	{
		return false;
	}

	return Super.HandlePickupQuery(Item);
}

simulated function bool PutDown()
{
	if (DualDeagle(Instigator.PendingWeapon) != None)
	{
		bIsReloading = false;
	}

	return super(KFWeapon).PutDown();
}

defaultproperties
{
	FireModeClass(0)=Class'KFTurbo.W_Deagle_Fire'
	PickupClass=Class'KFTurbo.W_Deagle_Pickup'
}
