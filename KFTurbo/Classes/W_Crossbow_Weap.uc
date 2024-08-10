class W_Crossbow_Weap extends Crossbow;

simulated function BringUp(optional Weapon PrevWeapon)
{
     class'WeaponHelper'.static.WeaponCheckForHint(Self, 16);

     Super.BringUp(PrevWeapon);
}

defaultproperties
{
     FireModeClass(0)=Class'KFTurbo.W_Crossbow_Fire'
     PickupClass=Class'KFTurbo.W_Crossbow_Pickup'
}
