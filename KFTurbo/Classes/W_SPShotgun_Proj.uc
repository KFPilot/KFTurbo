class W_SPShotgun_Proj extends W_BaseShotgunBullet;

event PreBeginPlay()
{
	Super.PreBeginPlay();
}

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
	Super.ProcessTouch(Other, HitLocation);
}

defaultproperties
{
	PenDamageReduction=0.750000
	MomentumTransfer=60000.000000
	DrawScale=1.500000

	Damage=25.000000
	MyDamageType=Class'KFMod.DamTypeSPShotgun'
}
