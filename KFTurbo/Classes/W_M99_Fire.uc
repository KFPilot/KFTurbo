//Killing Floor Turbo W_M99_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M99_Fire extends WeaponM99Fire;

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
     KickMomentum=(X=-225.000000,Z=100.000000)
     AmmoClass=Class'KFTurbo.W_M99_Ammo'
     ProjectileClass=Class'KFTurbo.W_M99_Proj'
}
