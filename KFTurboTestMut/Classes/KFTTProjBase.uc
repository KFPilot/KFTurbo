class KFTTProjBase extends KFMod.ShotgunBullet;

simulated function ProcessTouch (Actor Other, Vector HitLocation) {
	local Vector X, TempHitLocation, HitNormal;
	local array<int> HitPoints;
	local KFPawn HitPawn;

	if (Other == None || Other == Instigator || Other.Base == Instigator || !Other.bBlockHitPointTraces )
		return;

	X = Vector(Rotation);

 	if (ROBulletWhipAttachment(Other) != None) {
		if (!Other.Base.bDeleteMe) {
			Other = Instigator.HitPointTrace(TempHitLocation, HitNormal, HitLocation + (200 * X), HitPoints, HitLocation,, 1);

			if (Other == None || HitPoints.length == 0)
				return;
			
			if (Role == ROLE_Authority) {
				HitPawn = KFPawn(Other);
				if (HitPawn != None && !HitPawn.bDeleteMe)
					HitPawn.ProcessLocationalDamage(damage, Instigator, TempHitLocation, momentumTransfer * Normal(Velocity), MyDamageType, HitPoints);
			}
		}
	}
	else {
		Other.TakeDamage(damage, Instigator, HitLocation, momentumTransfer * Normal(Velocity), MyDamageType);
	}
	
	Destroy();
}

defaultproperties
{
}
