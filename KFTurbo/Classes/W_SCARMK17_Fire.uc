class W_SCARMK17_Fire extends SCARMK17Fire;

function DoFireEffect()
{
     class'WeaponHelper'.static.OnWeaponFire(self);
     Super.DoFireEffect();
}

function DoTrace(Vector Start, Rotator Direction)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, Direction, KFWeapon(Weapon), self, 1, 0.75);
}

defaultproperties
{
     MaxSpread=0.090000
     AmmoClass=class'W_SCARMK17_Ammo'
     DamageMin=60
     DamageMax=65
}