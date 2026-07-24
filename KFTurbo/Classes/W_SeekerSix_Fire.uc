//Killing Floor Turbo W_SeekerSix_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SeekerSix_Fire extends SeekerSixFire;

function DoFireEffect()
{
     class'WeaponHelper'.static.OnWeaponFire(self);
     Super.DoFireEffect();
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile SpawnedProjectile;

    SpawnedProjectile = W_SeekerSix_Weap(Weapon).SpawnProjectile(Start, Dir);

    if (SpawnedProjectile == None)
    {
        SpawnedProjectile = ForceSpawnProjectile(Start, Dir);
    }

    if (SpawnedProjectile == None)
    {
        return None;
    }

    PostSpawnProjectile(SpawnedProjectile);
    return SpawnedProjectile;
}

function Projectile ForceSpawnProjectile(Vector Start, Rotator Dir)
{
    return class'WeaponHelper'.static.ForceSpawnProjectile(Self, Start, Dir);
}

defaultproperties
{
     ProjectileClass=Class'KFTurbo.W_SeekerSix_Proj'
     AmmoClass=Class'KFTurbo.W_SeekerSix_Ammo'
}
