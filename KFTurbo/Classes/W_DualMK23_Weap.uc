class W_DualMK23_Weap extends DualMK23Pistol;

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
     ReloadRate=4.120000
     ReloadAnimRate=1.090000
     AttachmentClass=Class'KFTurbo.W_DualMK23_Attachment'
     FireModeClass(0)=Class'KFTurbo.W_DualMK23_Fire'
     DemoReplacement=Class'KFTurbo.W_MK23_Weap'
     PickupClass=Class'KFTurbo.W_DualMK23_Pickup'
}
