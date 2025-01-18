class W_MKb42_Fire extends MKb42Fire;

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
     MaxSpread=0.102000
     AmmoClass=class'W_MKb42_Ammo'
     DamageMin=45
     DamageMax=51
}