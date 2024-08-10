class W_BoomStick_Weap extends BoomStick;

simulated function BringUp(optional Weapon PrevWeapon)
{
     class'WeaponHelper'.static.WeaponCheckForHint(Self, 17);
     class'WeaponHelper'.static.WeaponPulloutRemark(Self, 21);

     Super.BringUp(PrevWeapon);
}

defaultproperties
{
     FireModeClass(0)=Class'KFTurbo.W_BoomStick_Fire_Alt'
     FireModeClass(1)=Class'KFTurbo.W_BoomStick_Fire'
     PickupClass=Class'KFTurbo.W_BoomStick_Pickup'
}
