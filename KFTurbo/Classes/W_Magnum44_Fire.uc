class W_Magnum44_Fire extends Magnum44Fire;

function DoTrace(Vector Start, Rotator Direction)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, Direction, KFWeapon(Weapon), self, 2, 0.9);
}

defaultproperties
{
     RecoilRate=0.090000
     maxVerticalRecoilAngle=1250
     maxHorizontalRecoilAngle=250
     DamageType=Class'KFTurbo.W_Magnum44_DT'
     DamageMin=100
     DamageMax=120
     FireRate=0.150000
     Spread=0.008000
}