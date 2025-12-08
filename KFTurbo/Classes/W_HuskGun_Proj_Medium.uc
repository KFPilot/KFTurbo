//Killing Floor Turbo W_HuskGun_Proj_Medium
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_HuskGun_Proj_Medium extends WeaponHuskGunProjectile
    dependson(TurboPlayerEventHandler);

function TakeDamage( int Damage, Pawn InstigatedBy, vector Hitlocation, vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
    class'WeaponHelper'.static.HuskGunProjTakeDamage(self, Damage, InstigatedBy, Hitlocation, Momentum, DamageType, HitIndex);
}

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
    local vector X;
	local vector TempHitLocation, HitNormal;
    local vector OtherLocation;
	local array<int> HitPoints;
    local KFPawn HitPawn;

	local TurboPlayerEventHandler.MonsterHitData HitData;

	if (Other == none || Other == Instigator || Other.Base == Instigator || KFBulletWhipAttachment(Other) != None)
    {
		return;
    }

    OtherLocation = Other.Location;

    if (KFHumanPawn(Other) != None && Instigator != None && KFHumanPawn(Other).PlayerReplicationInfo.Team.TeamIndex == Instigator.PlayerReplicationInfo.Team.TeamIndex)
    {
        return;
    }

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

    if( ROBulletWhipAttachment(Other) != none )
    {
        if(!Other.Base.bDeleteMe)
        {
            Other = Instigator.HitPointTrace(TempHitLocation, HitNormal, HitLocation + (200 * X), HitPoints, HitLocation,, 1);

            if (Other == None || HitPoints.Length == 0)
            {
                return;
            }

            HitPawn = KFPawn(Other);

            if (Role == ROLE_Authority && HitPawn != None && !HitPawn.bDeleteMe)
            {
                HitPawn.ProcessLocationalDamage(ImpactDamage, Instigator, TempHitLocation, MomentumTransfer * Normal(Velocity), ImpactDamageType,HitPoints);
            }
        }
    }
    else
    {
        class'TurboPlayerEventHandler'.static.CollectMonsterHitData(Other, HitLocation, Normal(Velocity), HitData);

        if (Pawn(Other) != None && Pawn(Other).IsHeadShot(HitLocation, X, 1.0))
        {
            Pawn(Other).TakeDamage(ImpactDamage * HeadShotDamageMult, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), ImpactDamageType);
        }
        else
        {
            Other.TakeDamage(ImpactDamage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), ImpactDamageType);
        }

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
    ImpactDamageType=class'W_HuskGun_Impact_DT'
    MyDamageType=class'W_HuskGun_DT'
}
