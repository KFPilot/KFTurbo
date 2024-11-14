class W_V_Deagle_Gold_Fire extends GoldenDeagleFire;

function DoTrace(Vector Start, Rotator Direction)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, Direction, KFWeapon(Weapon), self, 1, 0.8);
}

defaultproperties
{
     maxVerticalRecoilAngle=850
     maxHorizontalRecoilAngle=150
}