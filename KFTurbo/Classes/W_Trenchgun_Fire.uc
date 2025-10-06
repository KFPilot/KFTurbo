//Killing Floor Turbo W_Trenchgun_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Trenchgun_Fire extends WeaponTrenchgunFire;

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
     KickMomentum=(X=-40.000000,Z=8.000000)
     ProjectileClass=Class'KFTurbo.W_Trenchgun_Proj'
     AmmoClass=class'W_Trenchgun_Ammo'
}