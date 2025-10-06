//Killing Floor Turbo W_SPGrenade_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SPGrenade_Proj extends WeaponSPGrenadeProjectile;

var int TrickBounceCount;
var int MaxTrickBounceCount;
var float TrickBounceMultiplier;
var float TrickBounceBonusCoefficient; // by how much it should increase the bounce multiplier after bouncing
var float CurrentCoefficient;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
    class'WeaponHelper'.static.SPGrenadeProjTakeDamage(self, Damage, InstigatedBy, Hitlocation, Momentum, DamageType, HitIndex);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (bHasExploded)
	{
		return;
	}

	Super.Explode(HitLocation, HitNormal);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local TurboPlayerEventHandler.MonsterHitData HitData;

    if (bHasExploded)
    {
        return;
    }

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

    class'TurboPlayerEventHandler'.static.CollectMonsterHitData(Other, HitLocation, Normal(Velocity), HitData);
    
	Explode(HitLocation,Normal(HitLocation-Other.Location));
    
    if (HitData.DamageDealt > 0 && Weapon(Owner) != None && Owner.Instigator != None)
    {
        class'TurboPlayerEventHandler'.static.BroadcastPlayerFireHit(Owner.Instigator.Controller, Weapon(Owner).GetFireMode(0), HitData);
    }
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
    bGameRelevant=false
}