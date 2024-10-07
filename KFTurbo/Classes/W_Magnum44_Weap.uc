class W_Magnum44_Weap extends Magnum44Pistol;

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
	if (Dual44Magnum(Instigator.PendingWeapon) != None)
	{
		bIsReloading = false;
	}

	return Super(KFWeapon).PutDown();
}

defaultproperties
{
     ReloadRate=2.500000
     Weight=3.000000
     FireModeClass(0)=Class'KFTurbo.W_Magnum44_Fire'
     PickupClass=Class'KFTurbo.W_Magnum44_Pickup'
}
