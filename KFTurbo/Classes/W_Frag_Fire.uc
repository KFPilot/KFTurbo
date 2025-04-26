//Killing Floor Turbo W_Frag_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Frag_Fire extends FragFire;

var float PrevAmmo;

function DoFireEffect()
{
	local float MaxAmmo,CurAmmo;

	Weapon.GetAmmoCount(MaxAmmo,CurAmmo);
	
    if (CurAmmo == 0 && PrevAmmo == 0)
    {
        return;
    }
    
	PrevAmmo = CurAmmo;

	Super.DoFireEffect();
    
    class'WeaponHelper'.static.OnWeaponFire(self);
}

function class<Projectile> GetDesiredProjectileClass()
{
    local class<Projectile> DesiredProjectileClass;
    DesiredProjectileClass = Super.GetDesiredProjectileClass();

    //Ensure it never uses the original grenade.
    if (DesiredProjectileClass == class'KFMod.Nade')
    {
        DesiredProjectileClass = class'KFTurbo.W_Frag_Proj';
    }

	return DesiredProjectileClass;
}

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    return Super.SpawnProjectile(Start, Dir);
}

function PostSpawnProjectile(Projectile P)
{
    local Quat ResultQuat;
	local vector X, Y, Z;

    Super.PostSpawnProjectile(P);

    if (P != None)
    {
		Weapon.GetViewAxes(X,Y,Z);
        ResultQuat = QuatFromRotator(P.Rotation);
        ResultQuat = QuatProduct(ResultQuat, QuatFromAxisAndAngle(X, 0.6f));
        ResultQuat = QuatProduct(ResultQuat, QuatFromAxisAndAngle(Y, -0.5f));
        ResultQuat = QuatProduct(ResultQuat, QuatFromAxisAndAngle(Z,-0.75f));
        P.SetRotation(QuatToRotator(ResultQuat));
    }
}

defaultproperties
{
    ProjectileClass=Class'KFTurbo.W_Frag_Proj'
}
