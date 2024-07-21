class W_V_ThompsonDrum_STP_Fire extends W_ThompsonDrum_Fire;

defaultproperties
{
     FireEndSoundRef="KF_SP_ThompsonSnd.SP_Thompson_Fire_LoopEnd_M"
     FireEndStereoSoundRef="KF_SP_ThompsonSnd.SP_Thompson_Fire_LoopEnd_S"
     AmbientFireSoundRef="KF_SP_ThompsonSnd.SP_Thompson_Fire_Loop"
     ShellEjectClass=Class'ROEffects.KFShellEjectMP5SMG'
     ShellEjectBoneName="Shell_eject"
     bRandomPitchFireSound=False
     FireSoundRef="KF_SP_ThompsonSnd.SP_Thompson_Fire_Single_M"
     StereoFireSoundRef="KF_SP_ThompsonSnd.SP_Thompson_Fire_Single_S"
     NoAmmoSoundRef="KF_AK47Snd.AK47_DryFire"
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=350.000000)
     ShakeRotRate=(X=5000.000000,Y=5000.000000,Z=5000.000000)
     ShakeRotTime=0.750000
     ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=7.500000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.250000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSPThompson'
}