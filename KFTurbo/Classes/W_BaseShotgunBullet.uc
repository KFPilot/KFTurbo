//Killing Floor Turbo W_BaseShotgunBullet
//Base class for shotguns in KFTurbo. Removes usage of redudant headshot multiplier (that barely worked).
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_BaseShotgunBullet extends KFMod.ShotgunBullet;

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
    local vector X;
	local Vector TempHitLocation, HitNormal;
	local array<int> HitPoints;
    local KFPawn HitPawn;

	if (Other == None || Other == Instigator || Other.Base == Instigator || !Other.bBlockHitPointTraces)
    {
        return;
    }

    X = Vector(Rotation);

 	if (ROBulletWhipAttachment(Other) != None)
	{
        if (!Other.Base.bDeleteMe)
        {
	        Other = Instigator.HitPointTrace(TempHitLocation, HitNormal, HitLocation + (200 * X), HitPoints, HitLocation,, 1);

			if (Other == none || HitPoints.Length == 0)
            {
				return;
            }

			HitPawn = KFPawn(Other);

            if (Role == ROLE_Authority && HitPawn != None && !HitPawn.bDeleteMe)
            {
                HitPawn.ProcessLocationalDamage(Damage, Instigator, TempHitLocation, MomentumTransfer * Normal(Velocity), MyDamageType, HitPoints);
            }
        }
	}
    else
    {
        //Just pass it through. It's likely a pawn or an extended z collision.
        Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);

        //If damage was applied and we're doing less than our default, assume it's a penetrated hit.
        if ((Monster(Other) != None || Monster(Other.Base) != None) && Damage < default.Damage)
        {
            class'WeaponHelper'.static.OnShotgunProjectileHit(Self, Other, Damage);
        }
    }

	if (KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != None && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != None)
	{
   		PenDamageReduction = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.static.GetShotgunPenetrationDamageMulti(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), default.PenDamageReduction);
	}
	else
	{
   		PenDamageReduction = default.PenDamageReduction;
   	}

   	Damage *= PenDamageReduction;

    if ((Damage / default.Damage) <= (PenDamageReduction / MaxPenetrations))
    {
        Destroy();
    }

    Speed = VSize(Velocity);

    if (Speed < (default.Speed * 0.25f))
    {
        Destroy();
    }
}

defaultproperties
{
    //Property is UNUSED!!!
    HeadShotDamageMult=1.000000
}