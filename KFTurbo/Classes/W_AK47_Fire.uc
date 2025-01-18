class W_AK47_Fire extends AK47Fire;

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
     AmmoClass=Class'KFTurbo.W_AK47_Ammo'
     MaxSpread=0.096000
     DamageMin=45
     DamageMax=51
}
