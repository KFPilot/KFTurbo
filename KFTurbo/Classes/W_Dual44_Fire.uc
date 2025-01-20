class W_Dual44_Fire extends Dual44MagnumFire;

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
     maxVerticalRecoilAngle=1250
     maxHorizontalRecoilAngle=250
     DamageType=Class'KFTurbo.W_Dual44_DT'
     AmmoClass=Class'W_Magnum44_Ammo'
     DamageMin=100
     DamageMax=120
     FireRate=0.075000
     Spread=0.008000
     MaxSpread=0.108000
}