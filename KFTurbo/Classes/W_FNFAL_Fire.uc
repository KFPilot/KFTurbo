class W_FNFAL_Fire extends KFFire;

function DoFireEffect()
{
     class'WeaponHelper'.static.OnWeaponFire(self);
     Super.DoFireEffect();
}

function DoTrace(Vector Start, Rotator Direction)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, Direction, KFWeapon(Weapon), self, 1, 0.9);
}

defaultproperties
{
     DamageType=Class'KFTurbo.W_FNFAL_DT'
     DamageMin=52
     DamageMax=52
     FireRate=0.150000
     AmmoClass=Class'KFTurbo.W_FNFAL_Ammo'
     MaxSpread=0.048000
     FireLoopAnim="Fire"
     // from FNFALFire
     RecoilRate=0.080000
     maxVerticalRecoilAngle=150
     maxHorizontalRecoilAngle=115
     ShellEjectClass=Class'KFMod.KFShellEjectFAL'
     ShellEjectBoneName="Shell_eject"
     bRandomPitchFireSound=False
     FireSoundRef="KF_FNFALSnd.FNFAL_Fire_Single_M"
     StereoFireSoundRef="KF_FNFALSnd.FNFAL_Fire_Single_S"
     NoAmmoSoundRef="KF_SCARSnd.SCAR_DryFire"
     Momentum=8500.000000
     ShakeRotMag=(X=80.000000,Y=80.000000,Z=450.000000)
     ShakeRotRate=(X=7500.000000,Y=7500.000000,Z=7500.000000)
     ShakeRotTime=0.650000
     ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=8.500000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.150000
     BotRefireRate=0.990000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSTG'
     aimerror=42.000000
     Spread=0.008500
     SpreadStyle=SS_Random
     // from KFHighROFFire
     AmmoPerFire=1
     FireAimedAnim="Fire_Iron"
     TweenTime=0.025000
     FireForce="AssaultRifleFire"
     bAccuracyBonusForSemiAuto=True
     bPawnRapidFireAnim=False
     TransientSoundVolume=1.800000
}
