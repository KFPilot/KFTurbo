class W_SPGrenade_Proj extends SPGrenadeProjectile;


simulated function HitWall( vector HitNormal, actor Wall )
{
    local Vector VNorm;

    if( Instigator != none )
    {
        OrigLoc = Instigator.Location;
    }

	if ( (Pawn(Wall) != None) || (GameObjective(Wall) != None) )
	{
		Explode(Location, HitNormal);
		return;
	}

    // Reflect off Wall w/damping
    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

    Speed = VSize(Velocity);
    
    if ( Speed < 20 )
    {
        bBounce = False;
		SetPhysics(PHYS_None);
		DesiredRotation = Rotation;
		DesiredRotation.Roll = 0;
		DesiredRotation.Pitch = 0;
		SetRotation(DesiredRotation);
    }
    else
    {
		PlaySound(ImpactSound, SLOT_Misc );
		if ( Speed > 250 )
        {
            Damage=Damage*1.75f;
        }
    }
}


defaultproperties
{
}