class W_Shotgun_Weap extends Shotgun;

simulated function BringUp(optional Weapon PrevWeapon)
{
     class'WeaponHelper'.static.WeaponCheckForHint(Self, 14);

     Super.BringUp(PrevWeapon);
}

defaultproperties
{
     ReloadRate=0.550000
     ReloadAnimRate=1.212121
     Weight=7.000000
     FireModeClass(0)=Class'KFTurbo.W_Shotgun_Fire'
     PickupClass=Class'KFTurbo.W_Shotgun_Pickup'
}
