//Killing Floor Turbo W_SPSniper_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SPSniper_Fire extends SPSniperFire;

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
     maxVerticalRecoilAngle=700
     maxHorizontalRecoilAngle=425
     MaxSpread=0.048000
     DamageType=Class'KFTurbo.W_SPSniper_DT'
     DamageMin=175
     DamageMax=200
     AmmoClass=Class'KFTurbo.W_SPSniper_Ammo'
     Spread=0.002000
}
