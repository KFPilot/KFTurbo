class W_Bullpup_Fire extends BullpupFire;

function DoTrace(Vector Start, Rotator Dir)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, KFWeapon(Weapon), self, 2, 0.75);
}

defaultproperties
{
     RecoilRate=0.070000
     DamageMin=28
     DamageMax=28
     FireRate=0.100000
     aimerror=38.000000
     Spread=0.008500
     SpreadStyle=SS_Random
     AmmoClass=Class'KFTurbo.W_Bullpup_Ammo'
}