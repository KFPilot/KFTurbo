class W_Huskgun_Fire extends HuskGunFire;

var float MaxDamageMultiplier;

simulated function float GetScaledMaxChargeTime()
{
    local float ScaledMaxChargeTime;
    ScaledMaxChargeTime = MaxChargeTime;
	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		ScaledMaxChargeTime /= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetFireSpeedMod(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), Weapon);
	}

    return ScaledMaxChargeTime;
}

function Timer()
{
    local float ChargeScale;
	local HuskGunAttachment WA;

	WA = HuskGunAttachment(Weapon.ThirdPersonActor);

    if (HoldTime > 0.0 && !bNowWaiting)
    {
        if( HoldTime < GetScaledMaxChargeTime() )
        {
            PlayAmbientSound(AmbientChargeUpSound);
            ChargeScale = HoldTime/GetScaledMaxChargeTime();
            WA.HuskGunCharge = ChargeScale * 255;
            WA.UpdateHuskGunCharge();
            if( ChargeEmitter != none )
            {
                ChargeEmitter.Emitters[0].SizeScale[1].RelativeSize = Lerp( ChargeScale, 4, 10 );
                ChargeEmitter.Emitters[1].StartVelocityRadialRange.Min = Lerp( ChargeScale, 50, 300 );
                ChargeEmitter.Emitters[1].StartVelocityRadialRange.Max = Lerp( ChargeScale, 50, 300 );
                ChargeEmitter.Emitters[1].SizeScale[0].RelativeSize = Lerp( ChargeScale, 2, 6 );
            }
        }
        else
        {
            PlayAmbientSound(AmbientFireSound);
            WA.HuskGunCharge = 255;
            WA.UpdateHuskGunCharge();

            if( ChargeEmitter != none )
            {
                ChargeEmitter.Emitters[0].SizeScale[1].RelativeSize = 10;
                ChargeEmitter.Emitters[1].StartVelocityRadialRange.Min = 300;
                ChargeEmitter.Emitters[1].StartVelocityRadialRange.Max = 300;
                ChargeEmitter.Emitters[1].SizeScale[0].RelativeSize = 6;
            }
        }
    }
    else
    {
        PlayAmbientSound(none);
        DestroyChargeEffect();
        WA.HuskGunCharge = 0;
        WA.UpdateHuskGunCharge();

        SetTimer(0, false);
    }
}

/* Accessor function that returns the type of projectile we want this weapon to fire right now. */
function class<Projectile> GetDesiredProjectileClass()
{
    if( HoldTime < (GetScaledMaxChargeTime() * 0.33) )
    {
        return WeakProjectileClass;
    }
    else if( HoldTime < (GetScaledMaxChargeTime() * 0.66) )
    {
        return default.ProjectileClass;
    }
    else
    {
        return StrongProjectileClass;
    }
}

/* Convenient place to perform changes to a newly spawned projectile */
function PostSpawnProjectile(Projectile P)
{
    local float ChargePercentage;

    Super(KFShotgunFire).PostSpawnProjectile(P);

    ChargePercentage = FClamp(HoldTime / GetScaledMaxChargeTime(), 0.f, 1.f);

    HuskGunProjectile(p).ImpactDamage *= Lerp(ChargePercentage, 1.f, MaxDamageMultiplier);
    HuskGunProjectile(p).Damage *= (1.0 + ChargePercentage);  // Up to double damage.
    HuskGunProjectile(p).DamageRadius *= (1.0 + (ChargePercentage * 2.0));  // Up to 3x the damage radius.

}

event ModeDoFire()
{
	local float Rec;
	local float AmmoAmountToUse;

	if (!AllowFire())
		return;

	Spread = Default.Spread;
	Rec = 1;

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		Spread *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.ModifyRecoilSpread(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self, Rec);
	}

	if( !bFiringDoesntAffectMovement )
	{
		if (FireRate > 0.25)
		{
			Instigator.Velocity.x *= 0.1;
			Instigator.Velocity.y *= 0.1;
		}
		else
		{
			Instigator.Velocity.x *= 0.5;
			Instigator.Velocity.y *= 0.5;
		}
	}

    if (!AllowFire())
        return;

    if (MaxHoldTime > 0.0)
        HoldTime = FMin(HoldTime, MaxHoldTime);

    // server
    if (Weapon.Role == ROLE_Authority)
    {
        if( HoldTime < GetScaledMaxChargeTime() )
        {
            AmmoAmountToUse = (1.0 + (HoldTime/(GetScaledMaxChargeTime()/9.0)));// 10 ammo for full charge, at least 1 ammo used
        }
        else
        {
            AmmoAmountToUse = 10.0;// 10 ammo for full charge, at least 1 ammo used
        }

        if( Weapon.AmmoAmount(ThisModeNum) < AmmoAmountToUse )
        {
            AmmoAmountToUse = Weapon.AmmoAmount(ThisModeNum);
        }

        Weapon.ConsumeAmmo(ThisModeNum, AmmoAmountToUse);


        DoFireEffect();
		HoldTime = 0;	// if bot decides to stop firing, HoldTime must be reset first
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
            NextFireTime += MaxHoldTime + FireRate;
        else
            NextFireTime = Level.TimeSeconds + FireRate;
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

    // client
    if (Instigator.IsLocallyControlled())
    {
        HandleRecoil(Rec);
    }
}

defaultproperties
{
    MaxChargeTime=2.000000
    Spread=0.000000
    AmmoClass=Class'KFTurbo.W_HuskGun_Ammo'
    MaxDamageMultiplier=7.5

    WeakProjectileClass=Class'W_HuskGun_Proj_Weak'
    StrongProjectileClass=Class'W_HuskGun_Proj_Strong'
    ProjectileClass=Class'W_HuskGun_Proj_Medium'
}