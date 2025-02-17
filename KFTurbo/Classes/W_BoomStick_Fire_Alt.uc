//Killing Floor Turbo W_BoomStick_Fire_Alt
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_BoomStick_Fire_Alt extends BoomStickAltFire;

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
     AmmoClass=Class'KFTurbo.W_BoomStick_Ammo'
     ProjectileClass=Class'KFTurbo.W_BoomStick_Proj'
}
