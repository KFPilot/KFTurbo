class W_MK23_Weap extends MK23Pistol;

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
	if (DualMK23Pistol(Instigator.PendingWeapon) != None)
	{
		bIsReloading = false;
	}

	return Super(KFWeapon).PutDown();
}

defaultproperties
{
     ReloadRate=2.400000
     ReloadAnimRate=1.090000
     FireModeClass(0)=Class'KFTurbo.W_MK23_Fire'
     PickupClass=Class'KFTurbo.W_MK23_Pickup'
}
