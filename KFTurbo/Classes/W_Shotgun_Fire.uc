//Killing Floor Turbo W_Shotgun_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Shotgun_Fire extends WeaponShotgunFire;

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
    return class'WeaponHelper'.static.SpawnProjectile(Self, Start, Dir);
}

function Projectile ForceSpawnProjectile(Vector Start, Rotator Dir)
{
    return class'WeaponHelper'.static.ForceSpawnProjectile(Self, Start, Dir);
}

defaultproperties
{
     ProjPerFire=9
     FireAnimRate=1.020000
     FireRate=0.900000
     AmmoClass=Class'KFTurbo.W_Shotgun_Ammo'
     ProjectileClass=Class'KFTurbo.W_Shotgun_Proj'
     Spread=1250.000000
}
