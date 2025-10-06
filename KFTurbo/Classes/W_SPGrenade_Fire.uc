//Killing Floor Turbo W_SPGrenade_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SPGrenade_Fire extends WeaponSPGrenadeFire;

function DoFireEffect()
{
     class'WeaponHelper'.static.OnWeaponFire(self);
     Super.DoFireEffect();
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    return class'WeaponHelper'.static.SpawnProjectile(Self, Start, Dir);
}

function Projectile ForceSpawnProjectile(Vector Start, Rotator Dir) { return None; }

defaultproperties
{
     ProjectileClass=Class'KFTurbo.W_SPGrenade_Proj'
     AmmoClass=Class'KFTurbo.W_SPGrenade_Ammo'
}