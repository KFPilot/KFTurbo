class W_SPShotgun_Fire extends SPShotgunFire;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local Projectile Proj;

	if (GetDesiredProjectileClass() != None)
	{
		Proj = Weapon.Spawn(GetDesiredProjectileClass(), , , Start, Dir);
	}

	if (Proj == None)
	{
		return None;
	}

	return Proj;
}

defaultproperties
{
     ProjPerFire=12
     FireAnimRate=1.272727
     FireRate=0.275000
     AmmoClass=Class'KFTurbo.W_SPShotgun_Ammo'
     ProjectileClass=Class'KFTurbo.W_SPShotgun_Proj'
     Spread=2500.000000
}
