//Killing Floor Turbo W_LAW_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_LAW_Fire extends LAWFire;

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

function bool AllowFire()
{
    return ( Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire);
}

defaultproperties
{
     KickMomentum=(X=-75.000000,Z=30.000000)
     AmmoClass=Class'KFTurbo.W_LAW_Ammo'
     ProjectileClass=Class'KFTurbo.W_LAW_Proj'
     Spread=0.005000
}
