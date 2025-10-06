//Killing Floor Turbo W_MAC10_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_MAC10_Fire extends CoreFire;

function DoFireEffect()
{
     class'WeaponHelper'.static.OnWeaponFire(self);
     Super.DoFireEffect();
}

function DoTrace(Vector Start, Rotator Direction)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, Direction, KFWeapon(Weapon), self, 0, 0.0);
}

defaultproperties
{
     FireAimedAnim="Fire_Iron"
     RecoilRate=0.050000
     maxVerticalRecoilAngle=150
     maxHorizontalRecoilAngle=100
     RecoilVelocityScale=1.500000
     ShellEjectClass=Class'ROEffects.KFShellEjectMac'
     ShellEjectBoneName="Mac11_Ejector"
     bRandomPitchFireSound=False
     FireSoundRef="KF_MAC10MPSnd.MAC10_Silenced_Fire"
     StereoFireSoundRef="KF_MAC10MPSnd.MAC10_Silenced_FireST"
     NoAmmoSoundRef="KF_AK47Snd.AK47_DryFire"
     DamageType=Class'KFTurbo.W_MAC10_DT'
     DamageMin=30
     DamageMax=30
     Momentum=6500.000000
     bAccuracyBonusForSemiAuto=True
     bPawnRapidFireAnim=True
     TransientSoundVolume=1.800000
     TweenTime=0.025000
     FireForce="AssaultRifleFire"
     FireRate=0.096000
     AmmoClass=Class'W_MAC10_Ammo'
     AmmoPerFire=1
     ShakeRotMag=(X=35.000000,Y=35.000000,Z=200.000000)
     ShakeRotRate=(X=8000.000000,Y=8000.000000,Z=8000.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=4.500000,Y=2.800000,Z=5.500000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.250000
     BotRefireRate=0.990000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSTG'
     MaxSpread=0.072000
     Spread=0.01000
     SpreadStyle=SS_Random
}