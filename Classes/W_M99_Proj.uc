class W_M99_Proj extends M99Bullet;

var bool bRefreshedLifeSpan;

simulated function HitWall( vector HitNormal, actor Wall)
{
	Super.HitWall(HitNormal, Wall);

	if(KFDoorMover(Wall) != None)
	{
		//We have transformed into a grenade.
		KFDoorMover(Wall).TakeDamage(100.f, Instigator, Location, MomentumTransfer * Vector(Rotation), class'DamTypeFrag');
		return;
	}

	//4 fun.
	if(!bRefreshedLifeSpan && KFTraderDoor(Wall) != None)
	{
		LifeSpan = 2.f;
		bRefreshedLifeSpan = true;
	}
}

defaultproperties
{
     HeadShotDamageMult=2.250000
     Damage=490.000000
}
