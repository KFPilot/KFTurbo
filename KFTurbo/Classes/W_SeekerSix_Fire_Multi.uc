class W_SeekerSix_Fire_Multi extends KFMod.SeekerSixMultiFire;

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
