//Killing Floor Turbo W_SPShotgun_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SPShotgun_Fire extends WeaponSPShotgunFire;

var int FireEffectCount;
var array<W_BaseShotgunBullet.HitRegisterEntry> HitRegistryList;

function DoFireEffect()
{
	class'WeaponHelper'.static.OnShotgunFire(Self, FireEffectCount, HitRegistryList);
	Super.DoFireEffect();
	FireEffectCount++;
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
     ProjPerFire=12
     FireAnimRate=1.272727
     FireRate=0.275000
     AmmoClass=Class'KFTurbo.W_SPShotgun_Ammo'
     ProjectileClass=Class'KFTurbo.W_SPShotgun_Proj'
     Spread=2500.000000
}
