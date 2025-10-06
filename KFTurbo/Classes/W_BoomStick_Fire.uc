//Killing Floor Turbo W_BoomStick_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_BoomStick_Fire extends WeaponBoomStickFire;

final function W_BoomStick_Fire_Alt GetRegistryFireMode()
{
    return W_BoomStick_Fire_Alt(Weapon.GetFireMode(0));
}

function DoFireEffect()
{
    class'WeaponHelper'.static.OnShotgunFire(Self, GetRegistryFireMode().FireEffectCount, GetRegistryFireMode().HitRegistryList);
    Super.DoFireEffect();
    GetRegistryFireMode().FireEffectCount++;
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
