class KFTTProjPoof extends KFTTProjBase;

simulated function ProcessTouch(Actor Other, Vector HitLocation) {
	local Pawn HitPawn;

	if (Other == None || Other == Instigator || Other.Base == Instigator)
		return;
	
	if (Role == ROLE_Authority) {
		if (ExtendedZCollision(Other) != None)
			HitPawn = Pawn(Other.Base);
		else
			HitPawn = Pawn(Other);
		
		if (HitPawn != None)
			HitPawn.Died(Instigator.Controller, MyDamageType, HitLocation);
	}

	Destroy();
}

defaultproperties
{
     MyDamageType=Class'KFMod.DamTypeDwarfAxe'
}
