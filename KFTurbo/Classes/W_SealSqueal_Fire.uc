//Killing Floor Turbo W_SealSqueal_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SealSqueal_Fire extends SealSquealFire;

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
     FireAnimRate=1.300000
     FireRate=0.375000
     ProjectileClass=Class'KFTurbo.W_SealSqueal_Proj'
     Spread=0.005000
     SpreadStyle=SS_None
     AmmoClass=Class'W_SealSqueal_Ammo'
}
