//Killing Floor Turbo W_Crossbuzzsaw_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Crossbuzzsaw_Proj extends CrossbuzzsawBlade;

var byte bHasRegisteredHit;
var() float PenetrationDamageMult;

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
	class'WeaponHelper'.static.CrossbowProjectileProcessTouch(Self, HeadShotDamageMult, PenetrationDamageMult, DamageTypeHeadShot, Other, HitLocation, BladeHitArmor, BladeHitFlesh, IgnoreImpactPawn, bHasRegisteredHit);
}    

simulated function HitWall( vector HitNormal, actor Wall )
{
    Super.HitWall(HitNormal, Wall);

    IgnoreImpactPawn = None;
}

defaultproperties
{
     HeadShotDamageMult=2.000000
     PenetrationDamageMult=1.000000
     StraightFlightTime=0.900000
     Damage=275.000000
}
