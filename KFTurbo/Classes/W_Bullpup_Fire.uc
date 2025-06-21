//Killing Floor Turbo W_Bullpup_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Bullpup_Fire extends BullpupFire;

function DoFireEffect()
{
     class'WeaponHelper'.static.OnWeaponFire(self);
     Super.DoFireEffect();
}

function DoTrace(Vector Start, Rotator Direction)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, Direction, KFWeapon(Weapon), self, 4, 0.9);
}

defaultproperties
{
     maxVerticalRecoilAngle=200
     maxHorizontalRecoilAngle=175
     DamageMin=28
     DamageMax=28
     FireRate=0.100000
     Spread=0.000850
     MaxSpread=0.012000
     SpreadStyle=SS_None
     AmmoClass=Class'KFTurbo.W_Bullpup_Ammo'
}