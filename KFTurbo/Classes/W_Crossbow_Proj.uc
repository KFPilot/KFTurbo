//Killing Floor Turbo W_Crossbow_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Crossbow_Proj extends WeaponCrossbowArrow;

var byte bHasRegisteredHit;

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
	class'WeaponHelper'.static.CrossbowProjectileProcessTouch(Self, HeadShotDamageMult, DamageTypeHeadShot, Other, HitLocation, Arrow_hitarmor, Arrow_hitflesh, IgnoreImpactPawn, bHasRegisteredHit);

	Stick(Other, HitLocation);
}

defaultproperties
{

}