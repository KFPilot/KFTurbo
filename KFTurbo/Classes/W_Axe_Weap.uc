class W_Axe_Weap extends Axe;

simulated function BringUp(optional Weapon PrevWeapon)
{
    class'WeaponHelper'.static.WeaponCheckForHint(Self, 22);
    class'WeaponHelper'.static.WeaponPulloutRemark(Self, 24);

    Super.BringUp(PrevWeapon);
}

defaultproperties
{
     PickupClass=Class'KFTurbo.W_Axe_Pickup'
}
