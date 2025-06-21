//Killing Floor Turbo W_NailGun_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_NailGun_Fire extends NailGunFire;

function DoFireEffect()
{
     class'WeaponHelper'.static.OnWeaponFire(self);
     Super.DoFireEffect();
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local Projectile Proj;

	if (GetDesiredProjectileClass() != None)
	{
		Proj = Weapon.Spawn(GetDesiredProjectileClass(), Weapon,, Start, Dir);
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
     FireAnimRate=0.80000
     FireRate=0.750000
     AmmoClass=Class'KFTurbo.W_NailGun_Ammo'
     ProjectileClass=Class'KFTurbo.W_NailGun_Proj'
     Spread=0.005000
     SpreadStyle=SS_None
}
