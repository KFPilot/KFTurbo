class W_SPShotgun_Proj extends SPShotgunBullet;

var array<Pawn> HitPawnList;

event PreBeginPlay()
{
	Super.PreBeginPlay();

	class'WeaponHelper'.static.NotifyPostProjectileSpawned(self);
}

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
	if (class'WeaponHelper'.static.AlreadyHitPawn(Other, HitPawnList))
	{
		return;
	}

	Super.ProcessTouch(Other, HitLocation);
}

defaultproperties
{
     MaxSpeed=2500.000000
     Damage=25.000000
}
