class W_LAR_Weap extends Winchester;

simulated function BringUp(optional Weapon PrevWeapon)
{
     class'WeaponHelper'.static.WeaponCheckForHint(Self, 15);

     Super.BringUp(PrevWeapon);
}

defaultproperties
{
     PickupClass=Class'KFTurbo.W_LAR_Pickup'
}
