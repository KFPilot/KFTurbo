class W_ThompsonDrum_Fire extends ThompsonDrumFire;

function DoFireEffect()
{
     class'WeaponHelper'.static.OnWeaponFire(self);
     Super.DoFireEffect();
}

function DoTrace(Vector Start, Rotator Direction)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, Direction, KFWeapon(Weapon), self, 2, 0.75);
}

defaultproperties
{
     DamageMin=31
     DamageMax=31
     DamageType=Class'KFTurbo.W_ThompsonDrum_DT'
     AmmoClass=Class'KFTurbo.W_ThompsonDrum_Ammo'
     MaxSpread=0.096000
}
