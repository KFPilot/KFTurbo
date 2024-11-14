class W_Bullpup_Fire extends BullpupFire;

function DoTrace(Vector Start, Rotator Direction)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, Direction, KFWeapon(Weapon), self, 2, 0.75);
}

defaultproperties
{
     RecoilRate=0.070000
     maxVerticalRecoilAngle=200
     maxHorizontalRecoilAngle=175
     DamageMin=28
     DamageMax=28
     FireRate=0.100000
     aimerror=1.000000
     Spread=0.005000
     SpreadStyle=SS_None
     AmmoClass=Class'KFTurbo.W_Bullpup_Ammo'
}