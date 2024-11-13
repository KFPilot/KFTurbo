class W_KrissM_Fire extends KFFire;

defaultproperties
{
     DamageMin=42
     DamageMax=42
     AmmoClass=Class'KFTurbo.W_KrissM_Ammo'

     MaxSpread=0.060000

     FireAimedAnim="Fire_Iron"
     FireEndAimedAnim="Fire_Iron_End"
     FireLoopAimedAnim="Fire_Iron_Loop"
     FireLoopAnim="Fire_Loop"
     FireEndAnim="Fire_End"
     bPawnRapidFireAnim=True

     maxVerticalRecoilAngle=40
     maxHorizontalRecoilAngle=25
     RecoilVelocityScale=0.000000
     RecoilRate=0.060000
     ShellEjectClass=Class'KFMod.ShellEjectKriss'
     ShellEjectBoneName="Shell_eject"
     NoAmmoSoundRef="KF_MP7Snd.MP7_DryFire"
     DamageType=Class'KFMod.DamTypeKrissM'
     Momentum=12500.000000
     FireRate=0.093000
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=350.000000)
     ShakeRotRate=(X=5000.000000,Y=5000.000000,Z=5000.000000)
     ShakeRotTime=0.750000
     ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=7.500000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.250000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stMP'
     Spread=0.012500
     SpreadStyle=SS_Random
     bRandomPitchFireSound=False
     FireSoundRef="KFTurbo.Weapons.KrissM_Fire_M"
     StereoFireSoundRef="KFTurbo.Weapons.KrissM_Fire_S"
     bAccuracyBonusForSemiAuto=True
     TransientSoundVolume=1.800000
     TweenTime=0.025000
     FireForce="AssaultRifleFire"
     AmmoPerFire=1
     BotRefireRate=0.100000
     aimerror=30.000000
}
