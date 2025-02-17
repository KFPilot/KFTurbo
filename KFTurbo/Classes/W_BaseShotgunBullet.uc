//Killing Floor Turbo W_BaseShotgunBullet
//Base class for shotguns in KFTurbo. Removes usage of redudant headshot multiplier (that barely worked).
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_BaseShotgunBullet extends KFMod.ShotgunBullet;

var int FireModeHitRegisterCount; //HitRegisterCount associated with this projectile.

struct HitRegisterEntry
{
    var int HitRegisterCount;
    var float Expiration;
};

final function Controller GetWeaponController()
{
    local Weapon OwnerWeapon;
    OwnerWeapon = Weapon(Owner);
    if (OwnerWeapon != None && OwnerWeapon.Instigator != None)
    {
        return OwnerWeapon.Instigator.Controller;
    }

    return None;
}

//We assume index 0.
final function BaseProjectileFire GetWeaponFire()
{
    local Weapon OwnerWeapon;
    OwnerWeapon = Weapon(Owner);
    if (OwnerWeapon != None)
    {
        return BaseProjectileFire(OwnerWeapon.GetFireMode(0));
    }

    return None;
}

final function RegisterHit(out array<HitRegisterEntry> HitRegisterList, TurboPlayerEventHandler.MonsterHitData HitData)
{
    local int Index;

    for (Index = HitRegisterList.Length - 1; Index >= 0; Index--)
    {
        if (HitRegisterList[Index].HitRegisterCount == FireModeHitRegisterCount)
        {
            HitRegisterList.Remove(Index, 1);
            class'TurboPlayerEventHandler'.static.BroadcastPlayerFireHit(GetWeaponController(), GetWeaponFire(), HitData);
            continue;
        }

        //Cleanup hit registers that have expired.
        if (HitRegisterList[Index].Expiration < Level.TimeSeconds)
        {
            HitRegisterList.Remove(Index, 1);
        }
    }
}

//Implemented by specific shotgun projectiles to resolve firemode.
function NotifyProjectileRegisterHit(TurboPlayerEventHandler.MonsterHitData HitData) {}

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
    local vector X;
	local Vector TempHitLocation, HitNormal;
	local array<int> HitPoints;
    local KFPawn HitPawn;

	local TurboPlayerEventHandler.MonsterHitData HitData;

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
        class'TurboPlayerEventHandler'.static.CollectMonsterHitData(Other, HitLocation, Normal(Velocity), HitData);

        //Just pass it through. It's likely a pawn or an extended z collision.
        Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);

        NotifyProjectileRegisterHit(HitData);
              
        if (HitData.DamageDealt > 0 && Damage < default.Damage)
        {
            class'WeaponHelper'.static.OnShotgunPenetratingProjectileHit(Self, Other, Damage);
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
        return;
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