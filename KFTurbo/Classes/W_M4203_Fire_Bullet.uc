class W_M4203_Fire_Bullet extends KFFire;

function DoFireEffect()
{
     class'WeaponHelper'.static.OnWeaponFire(self);
     Super.DoFireEffect();
}

function DoTrace(Vector Start, Rotator Direction)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, Direction, KFWeapon(Weapon), self, 2, 0.5);
}

defaultproperties
{
     FireAimedAnim="Fire_Iron"
     RecoilRate=0.065000
     maxVerticalRecoilAngle=200
     maxHorizontalRecoilAngle=75
     ShellEjectClass=Class'ROEffects.KFShellEjectM4Rifle'
     ShellEjectBoneName="Shell_eject"
     RandomPitchAdjustAmt=0.075000
     FireSoundRef="KF_M4RifleSnd.M4Rifle_Fire_Single_M"
     StereoFireSoundRef="KF_M4RifleSnd.M4Rifle_Fire_Single_S"
     NoAmmoSoundRef="KF_SCARSnd.SCAR_DryFire"
     DamageType=Class'KFTurbo.W_M4203_DT_Bullet'
     DamageMin=43
     DamageMax=43
     Momentum=8500.000000
     bPawnRapidFireAnim=True
     TransientSoundVolume=1.800000
     TweenTime=0.025000
     FireForce="AssaultRifleFire"
     FireRate=0.096000
     AmmoClass=Class'KFTurbo.W_M4203_Ammo_Bullet'
     AmmoPerFire=1
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=350.000000)
     ShakeRotRate=(X=5000.000000,Y=5000.000000,Z=5000.000000)
     ShakeRotTime=0.750000
     ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=7.500000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.250000
     BotRefireRate=0.990000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSTG'
     MaxSpread=0.090000
}
