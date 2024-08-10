class W_FlameThrower_Weap extends FlameThrower;

simulated function BringUp(optional Weapon PrevWeapon)
{
     class'WeaponHelper'.static.WeaponCheckForHint(Self, 18);

     Super.BringUp(PrevWeapon);
}

defaultproperties
{
     FireModeClass(0)=Class'KFTurbo.W_FlameThrower_Fire'
     PickupClass=Class'KFTurbo.W_FlameThrower_Pickup'
}
