//Killing Floor Turbo W_ThompsonSMG_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_ThompsonSMG_Fire extends KFFire;

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
     RecoilRate=0.080000
     maxVerticalRecoilAngle=150
     maxHorizontalRecoilAngle=100
     ShellEjectClass=Class'KFMod.IJCShellEjectThompson'
     ShellEjectBoneName="Shell_eject"
     bRandomPitchFireSound=False
     FireSoundRef="KF_IJC_HalloweenSnd.Thompson_Fire_Single_M"
     StereoFireSoundRef="KF_IJC_HalloweenSnd.Thompson_Fire_Single_S"
     NoAmmoSoundRef="KF_AK47Snd.AK47_DryFire"
     DamageType=Class'KFTurbo.W_ThompsonSMG_DT'
     DamageMin=38
     DamageMax=38
     Momentum=7000.000000
     bAccuracyBonusForSemiAuto=True
     TransientSoundVolume=1.800000
     FireForce="AssaultRifleFire"
     FireRate=0.140000
     AmmoClass=Class'KFTurbo.W_ThompsonSMG_Ammo'
     AmmoPerFire=1
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=350.000000)
     ShakeRotRate=(X=5000.000000,Y=5000.000000,Z=5000.000000)
     ShakeRotTime=0.750000
     ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=7.500000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.250000
     BotRefireRate=0.150000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSTG'
     MaxSpread=0.102000
     Spread=0.008000
     SpreadStyle=SS_Random

     //RecoilVelocityScale=1.500000
     //bRandomPitchFireSound=False
     //bPawnRapidFireAnim=True
     //TransientSoundVolume=1.800000
     //TweenTime=0.025000
}
