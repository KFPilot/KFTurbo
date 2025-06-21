//Killing Floor Turbo W_MP7M_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_MP7M_Fire extends KFFire;

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
     AmmoClass=Class'KFTurbo.W_MP7M_Ammo'
     Spread=0.016000
     FireSoundRef="KFTurbo.Weapons.MP7_Fire_M"
     StereoFireSoundRef="KFTurbo.Weapons.MP7_Fire_S"
     NoAmmoSoundRef="KF_MP7Snd.MP7_DryFire"
     FireAimedAnim="Fire_Iron"
     RecoilRate=0.060000
     maxVerticalRecoilAngle=124
     maxHorizontalRecoilAngle=75
     RecoilVelocityScale=0.000000
     ShellEjectClass=Class'ROEffects.KFShellEjectMP5SMG'
     ShellEjectBoneName="Shell_eject"
     DamageType=Class'KFMod.DamTypeMP7M'
     DamageMin=20
     DamageMax=40
     Momentum=5500.000000
     FireRate=0.075000
     ShakeRotMag=(X=25.000000,Y=25.000000,Z=125.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=4.000000,Y=2.500000,Z=5.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.250000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stMP'
     SpreadStyle=SS_Random
     bRandomPitchFireSound=False
     bAccuracyBonusForSemiAuto=True
     bPawnRapidFireAnim=False
     TransientSoundVolume=1.800000
     TweenTime=0.025000
     FireForce="AssaultRifleFire"
     AmmoPerFire=1
     BotRefireRate=0.100000
}
