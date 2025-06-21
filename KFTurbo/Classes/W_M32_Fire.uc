//Killing Floor Turbo W_M32_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M32_Fire extends KFMod.M32Fire;

function DoFireEffect()
{
    class'WeaponHelper'.static.OnWeaponFire(self);
    Super.DoFireEffect();
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
    AmmoClass=Class'W_M32_Ammo'
    ProjectileClass=Class'W_M32_Proj'
}
