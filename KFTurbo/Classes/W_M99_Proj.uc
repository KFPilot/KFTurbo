//Killing Floor Turbo W_M99_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M99_Proj extends M99Bullet;

var bool bRefreshedLifeSpan;
var byte bHasRegisteredHit;

simulated function HitWall( vector HitNormal, actor Wall)
{
	Super.HitWall(HitNormal, Wall);

	if(KFDoorMover(Wall) != None)
	{
		//We have transformed into a grenade.
		//First try to break the weld of the door since this doesn't seem to be handled by TakeDamage in some cases.
		if (KFDoorMover(Wall).bSealed && KFDoorMover(Wall).MyTrigger != None)
		{
			KFDoorMover(Wall).MyTrigger.DamageWeld(100.f, Instigator, Location, MomentumTransfer * Vector(Rotation), class'DamTypeFrag');
		}
		else
		{
			KFDoorMover(Wall).TakeDamage(100.f, Instigator, Location, MomentumTransfer * Vector(Rotation), class'DamTypeFrag');
		}
		return;
	}

	//4 fun.
	if(!bRefreshedLifeSpan && KFTraderDoor(Wall) != None)
	{
		LifeSpan = 2.f;
		bRefreshedLifeSpan = true;
	}
}

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
	class'WeaponHelper'.static.CrossbowProjectileProcessTouch(Self, HeadShotDamageMult, DamageTypeHeadShot, Other, HitLocation, Arrow_hitarmor, Arrow_hitflesh, IgnoreImpactPawn, bHasRegisteredHit);
}

defaultproperties
{
     HeadShotDamageMult=2.250000
     Damage=490.000000
}
