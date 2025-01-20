class W_FNFAL_Fire extends FNFALFire;

function DoFireEffect()
{
     class'WeaponHelper'.static.OnWeaponFire(self);
     Super.DoFireEffect();
}

function DoTrace(Vector Start, Rotator Direction)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, Direction, KFWeapon(Weapon), self, 1, 0.9);
}

defaultproperties
{
     DamageType=Class'KFTurbo.W_FNFAL_DT'
     DamageMin=52
     DamageMax=52
     FireRate=0.150000
     bWaitForRelease=True
     AmmoClass=Class'KFTurbo.W_FNFAL_Ammo'
     MaxSpread=0.048000
}
