class W_SPGrenade_Proj extends SPGrenadeProjectile;

var int TrickBounceCount;
var int MaxTrickBounceCount;
var float TrickBounceMultiplier;
var float TrickBounceBonusCoefficient; // by how much it should increase the bounce multiplier after bouncing
var float CurrentCoefficient;

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
    if ( Other == none || Other == Instigator || Other.Base == Instigator )
    {
		return;
    }

    if( KFBulletWhipAttachment(Other) != none )
    {
        return;
    }

    if( KFHumanPawn(Other) != none && Instigator != none && KFHumanPawn(Other).PlayerReplicationInfo.Team.TeamIndex == Instigator.PlayerReplicationInfo.Team.TeamIndex )
    {
        return;
    }

    if( Instigator != none )
    {
        OrigLoc = Instigator.Location;
    }

	Explode(HitLocation,Normal(HitLocation-Other.Location));
}

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

    Speed = VSize(Velocity);

    if (Speed > default.Speed * 0.33f )
    {
        TrickBounceCount++;
        CurrentCoefficient = (TrickBounceBonusCoefficient ** (float(Min(TrickBounceCount-1, MaxTrickBounceCount-1))));
        Damage = default.Damage * ((CurrentCoefficient * TrickBounceMultiplier) ** float(Min(TrickBounceCount, MaxTrickBounceCount)));
    } 
    // first bounce: damage*multiplier, second: damage*(multiplier*coef)*(multiplier*coef), third:damage*(multiplier*coef*coef)*(multiplier*coef*coef)*(multiplier*coef*coef)

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
		if ( (Level.NetMode != NM_DedicatedServer) && (Speed > 250) )
        {
			PlaySound(ImpactSound, SLOT_Misc );
        }
    }
}

defaultproperties
{
    MaxTrickBounceCount=3
    TrickBounceCount=0
    TrickBounceMultiplier=1.5f
    TrickBounceBonusCoefficient=1.1f
}