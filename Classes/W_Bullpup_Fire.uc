class W_Bullpup_Fire extends BullpupFire;

function DoTrace(Vector Start, Rotator Dir)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, KFWeapon(Weapon), self, 2, 0.75);
}

defaultproperties
{
     RecoilRate=0.070000
     DamageMin=31
     DamageMax=31
     FireRate=0.100000
     aimerror=30.000000
     Spread=0.008500
     SpreadStyle=SS_Random
}