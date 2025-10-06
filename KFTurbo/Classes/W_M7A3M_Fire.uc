//Killing Floor Turbo W_M7A3M_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M7A3M_Fire extends WeaponM7A3MFire;

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
     maxVerticalRecoilAngle=750
     maxHorizontalRecoilAngle=175
     DamageType=Class'KFTurbo.W_M7A3M_DT'
     DamageMax=75
     Momentum=8000.000000
     bWaitForRelease=True
     FireRate=0.200000
     AmmoClass=Class'KFTurbo.W_M7A3M_Ammo'
     MaxSpread=0.084000
     Spread=0.006500
}
