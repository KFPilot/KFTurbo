//Killing Floor Turbo W_Frag_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Frag_Fire extends FragFire;

event ModeDoFire()
{
    if (!AllowFire())
    {
        return;
    }

    if (MaxHoldTime > 0.0)
    {
        HoldTime = FMin(HoldTime, MaxHoldTime);
    }

    // server
    if (Weapon.Role == ROLE_Authority && Weapon.ConsumeAmmo(ThisModeNum, Load))
    {
        DoFireEffect();

        HoldTime = 0;   // if bot decides to stop firing, HoldTime must be reset first
        if ( (Instigator == None) || (Instigator.Controller == None) )
            return;

        if ( AIController(Instigator.Controller) != None )
            AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);

        Instigator.DeactivateSpawnProtection();
    }

    // client
    if (Instigator.IsLocallyControlled())
    {
        ShakeView();
        PlayFiring();
        FlashMuzzleFlash();
        StartMuzzleSmoke();
    }
    else // server
    {
        ServerPlayFiring();
    }

    Weapon.IncrementFlashCount(ThisModeNum);

    // set the next firing time. must be careful here so client and server do not get out of sync
    if (bFireOnRelease)
    {
        if (bIsFiring)
        {
            NextFireTime += MaxHoldTime + FireRate;
        }
        else
        {
            NextFireTime = Level.TimeSeconds + FireRate;
        }
    }
    else
    {
        NextFireTime += FireRate;
        NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
    }

    Load = AmmoPerFire;
    HoldTime = 0;

    if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
    {
        bIsFiring = false;
        Weapon.PutDown();
    }
}

function DoFireEffect()
{
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
