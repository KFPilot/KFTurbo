class W_NailGun_Fire extends NailGunFire;

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
     KickMomentum=(X=-40.000000)
     maxVerticalRecoilAngle=1750
     maxHorizontalRecoilAngle=1250
     ProjPerFire=1
     TransientSoundVolume=3.000000
     TransientSoundRadius=750.000000
     FireAnimRate=0.750000
     FireRate=1.000000
     AmmoClass=Class'KFTurbo.W_NailGun_Ammo'
     ProjectileClass=Class'KFTurbo.W_NailGun_Proj'
     Spread=0.005000
     aimerror=1.000000
     SpreadStyle=SS_None
}
