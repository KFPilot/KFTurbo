//Killing Floor Turbo W_HuskGun_Proj_Medium
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_HuskGun_Proj_Medium extends KFMod.HuskGunProjectile
    dependson(TurboPlayerEventHandler);

function TakeDamage(int Damage, Pawn InstigatedBy, vector Hitlocation, vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
    class'WeaponHelper'.static.HuskGunProjTakeDamage(self, Damage, InstigatedBy, Hitlocation, Momentum, DamageType, HitIndex);
}

simulated final function bool CanDamage(Actor Other)
{
    local Pawn Pawn;

	if (Other == None || Other == Instigator || Other.Base == Instigator)
    {
		return false;
    }

    Pawn = Pawn(Other);
    if (Pawn != None)
    {
        if (Pawn.Health <= 0)
        {
            return false;
        }

        if (Instigator != None)
        {
            if (Instigator.PlayerReplicationInfo != None && Pawn.PlayerReplicationInfo != None && Pawn.PlayerReplicationInfo.Team.TeamIndex == Instigator.PlayerReplicationInfo.Team.TeamIndex)
            {
                return false;
            }
        }
    }

    return true;
}

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
    local vector X;
	local vector TempHitLocation, HitNormal;
    local vector OtherLocation;
	local array<int> HitPoints;
    local KFPawn HitPawn;

	local TurboPlayerEventHandler.MonsterHitData HitData;

    if (ROBulletWhipAttachment(Other) != None)
    {
        return;
    }

    if (Pawn(Other.Base) != None)
    {
        Other = Other.Base;
    }

    if (!CanDamage(Other))
    {
        return;
    }
    
    OtherLocation = Other.Location;
	if (Instigator != None)
	{
		OrigLoc = Instigator.Location;
	}

    X = vector(Rotation);

    if (Role != ROLE_Authority)
    {
        if (!bDud)
        {
            Explode(HitLocation, Normal(HitLocation - Other.Location));
        }

        return;
    }

    if (Other.bDeleteMe)
    {
        return;
    }

    HitPawn = KFPawn(Other);
    if (HitPawn != None)
    {
        Other = Instigator.HitPointTrace(TempHitLocation, HitNormal, HitLocation + (200 * X), HitPoints, HitLocation,, 1);

        if (Other == None || HitPoints.Length == 0)
        {
            return;
        }
        
        HitPawn.ProcessLocationalDamage(ImpactDamage, Instigator, TempHitLocation, MomentumTransfer * Normal(Velocity), ImpactDamageType,HitPoints);
    }
    else
    {
        class'TurboPlayerEventHandler'.static.CollectMonsterHitData(Other, HitLocation, Normal(Velocity), HitData);

        Other.TakeDamage(ImpactDamage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), ImpactDamageType);
        
        if (HitData.DamageDealt > 0 && Weapon(Owner) != None && Owner.Instigator != None)
        {
            class'TurboPlayerEventHandler'.static.BroadcastPlayerFireHit(Owner.Instigator.Controller, Weapon(Owner).GetFireMode(0), HitData);
        }
    }

	if (!bDud)
	{
	    Explode(HitLocation, Normal(HitLocation - OtherLocation));
	}
}

defaultproperties
{
    HeadShotDamageMult=1.f
}
