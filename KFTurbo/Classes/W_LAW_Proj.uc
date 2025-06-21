//Killing Floor Turbo W_LAW_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_LAW_Proj extends LAWProj;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	class'WeaponHelper'.static.LawProjTakeDamage(self, Damage, InstigatedBy, Hitlocation, Momentum, DamageType, HitIndex);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local TurboPlayerEventHandler.MonsterHitData HitData;

	if (Other == None || Other == Instigator || Other.Base == Instigator || KFBulletWhipAttachment(Other) != None)
	{
		return;
	}

    if (KFHumanPawn(Other) != None && Instigator != None && KFHumanPawn(Other).PlayerReplicationInfo.Team.TeamIndex == Instigator.PlayerReplicationInfo.Team.TeamIndex )
    {
        return;
    }

	if (Instigator != None)
	{
		OrigLoc = Instigator.Location;
	}

	if (!bDud && ((VSizeSquared(Location - OrigLoc) < ArmDistSquared) || OrigLoc == vect(0,0,0)) )
	{
		if (Role == ROLE_Authority)
		{
			AmbientSound=none;
			PlaySound(Sound'ProjectileSounds.PTRD_deflect04',,2.0);

			class'TurboPlayerEventHandler'.static.CollectMonsterHitData(Other, HitLocation, Normal(Velocity), HitData);

			Other.TakeDamage(ImpactDamage, Instigator, HitLocation, Normal(Velocity), ImpactDamageType);

			if (HitData.DamageDealt > 0 && Weapon(Owner) != None && Owner.Instigator != None)
			{
				class'TurboPlayerEventHandler'.static.BroadcastPlayerFireHit(Owner.Instigator.Controller, Weapon(Owner).GetFireMode(0), HitData);	
			}
		}

		bDud = true;
		Velocity = vect(0,0,0);
		LifeSpan=1.0;
		SetPhysics(PHYS_Falling);
		return;
	}

	if (!bDud)
	{
		class'TurboPlayerEventHandler'.static.CollectMonsterHitData(Other, HitLocation, Normal(Velocity), HitData);

		Explode(HitLocation,Normal(HitLocation-Other.Location));

		if (HitData.DamageDealt > 0 && Weapon(Owner) != None && Owner.Instigator != None)
		{
			class'TurboPlayerEventHandler'.static.BroadcastPlayerFireHit(Owner.Instigator.Controller, Weapon(Owner).GetFireMode(0), HitData);	
		}
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (bHasExploded)
	{
		return;
	}

	Super.Explode(HitLocation, HitNormal);
}

simulated function HurtRadius(float DamageAmount, float Radius, class<DamageType> DamageType, float Momentum, vector HitLocation)
{
	local PipeBombProjectile HitPipebomb;
	local bool bFoundPipebomb;

	bFoundPipebomb = false;
	foreach CollidingActors (class'PipeBombProjectile', HitPipebomb, Radius * 0.33f, HitLocation)
	{
		HitPipebomb.TakeDamage(default.Damage, Instigator, HitPipebomb.Location, vect(0,0,0), default.ImpactDamageType);
		bFoundPipebomb = true;
	}

	if (bFoundPipebomb)
	{
		DamageAmount *= 2.f;
	}

	Super.HurtRadius(DamageAmount, Radius, DamageType, Momentum, HitLocation);
}

defaultproperties
{
	ArmDistSquared=202500.000000
	ImpactDamage=475
	Damage=1000.000000
    bGameRelevant=false
}
