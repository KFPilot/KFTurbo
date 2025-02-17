//Killing Floor Turbo W_Benelli_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Benelli_Fire extends BenelliFire;

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
     KickMomentum=(X=-10.000000,Z=2.000000)
     maxVerticalRecoilAngle=1250
     maxHorizontalRecoilAngle=750
     AmmoClass=Class'KFTurbo.W_Benelli_Ammo'
     ProjectileClass=Class'KFTurbo.W_Benelli_Proj'
}
