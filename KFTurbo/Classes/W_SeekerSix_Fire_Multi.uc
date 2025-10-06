//Killing Floor Turbo W_SeekerSix_Fire_Multi
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SeekerSix_Fire_Multi extends WeaponSeekerSixMultiFire;

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
	ProjectileClass=Class'KFTurbo.W_SeekerSix_Proj'
	AmmoClass=Class'KFTurbo.W_SeekerSix_Ammo'
}
