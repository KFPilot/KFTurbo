class W_DualDeagle_Weap extends DualDeagle;

simulated function BringUp(optional Weapon PrevWeapon)
{
    class'WeaponHelper'.static.WeaponPulloutRemark(Self, 22);

    Super.BringUp(PrevWeapon);
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
	FireModeClass(0)=Class'KFTurbo.W_DualDeagle_Fire'
	DemoReplacement=Class'KFTurbo.W_Deagle_Weap'
	PickupClass=Class'KFTurbo.W_DualDeagle_Pickup'
}
