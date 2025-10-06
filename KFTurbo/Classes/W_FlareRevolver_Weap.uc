//Killing Floor Turbo W_FlareRevolver_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_FlareRevolver_Weap extends WeaponFlareRevolver;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

function bool HandlePickupQuery( pickup Item )
{
	if (class'WeaponHelper'.static.SingleWeaponHandlePickupQuery(Self, Item))
	{
		return false;
	}

	return Super.HandlePickupQuery(Item);
}

simulated function bool PutDown()
{
	if (W_DualFlare_Weap(Instigator.PendingWeapon) != None)
	{
		bIsReloading = false;
	}

	return Super(KFWeapon).PutDown();
}

defaultproperties
{
     FireModeClass(0)=Class'KFTurbo.W_FlareRevolver_Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PickupClass=Class'KFTurbo.W_FlareRevolver_Pickup'
}