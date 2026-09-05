//Killing Floor Turbo VinylAugmentIceCave
//Scales its augment list by the portion of the alive squad standing near the player.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentIceCave extends VinylAugmentBasic;

var const float NearbyRadius;
var const float AliveCountUpdateInterval;
var const float NearbyCountUpdateInterval;

var int CachedAliveCount, CachedNearbyCount;
var float NextAliveCountUpdateTime, NextNearbyCountUpdateTime;

simulated final function float GetSquadRatio()
{
    //At most one scan per call so the two counters never run on the same frame.
    if (Level.TimeSeconds >= NextAliveCountUpdateTime)
    {
        UpdateAliveCount();
    }
    else if (Level.TimeSeconds >= NextNearbyCountUpdateTime)
    {
        UpdateNearbyCount();
    }

    if (CachedAliveCount <= 0)
    {
        return 0.f;
    }

    return FClamp(float(CachedNearbyCount) / float(CachedAliveCount), 0.f, 1.f);
}

//PRIs always replicate, so both sides can count the living squad.
simulated final function UpdateAliveCount()
{
    local KFPlayerReplicationInfo PRI;
    local int Index, AliveCount;

    NextAliveCountUpdateTime = Level.TimeSeconds + AliveCountUpdateInterval + (FRand() * 0.1f);
    CachedAliveCount = 0;

    if (Level.GRI == None)
    {
        return;
    }

    for (Index = 0; Index < Level.GRI.PRIArray.Length; Index++)
    {
        PRI = KFPlayerReplicationInfo(Level.GRI.PRIArray[Index]);

        if (PRI == None || PRI.bOnlySpectator || PRI.PlayerHealth <= 0)
        {
            continue;
        }

        AliveCount++;
    }

    CachedAliveCount = AliveCount;
}

//Any pawn close enough to count is relevant, so both sides can count the nearby squad.
simulated final function UpdateNearbyCount()
{
    local Pawn OwnerPawn;
    local TurboHumanPawn NearbyPawn;
    local int NearbyCount;

    NextNearbyCountUpdateTime = Level.TimeSeconds + NearbyCountUpdateInterval + (FRand() * 0.1f);
    CachedNearbyCount = 0;

    if (OwningCardInfo == None)
    {
        return;
    }

    OwnerPawn = OwningCardInfo.GetOwnerPawn();

    if (OwnerPawn == None || OwnerPawn.Health <= 0)
    {
        return;
    }

    foreach OwnerPawn.RadiusActors(class'TurboHumanPawn', NearbyPawn, NearbyRadius)
    {
        if (NearbyPawn.Health > 0)
        {
            NearbyCount++;
        }
    }

    CachedNearbyCount = NearbyCount;
}

simulated final function float ApplySquadRatio(float Multiplier)
{
    return Lerp(GetSquadRatio(), 1.f, Multiplier);
}

function float GetDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageInstigator, int InDamage, class<DamageType> DamageType) { return ApplySquadRatio(Super.GetDamageMultiplier(KFPRI, Injured, DamageInstigator, InDamage, DamageType)); }
function float GetHeadshotDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType) { return ApplySquadRatio(Super.GetHeadshotDamageMultiplier(KFPRI, Pawn, DamageType)); }

simulated function float GetFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return ApplySquadRatio(Super.GetFireRateMultiplier(KFPRI, Other)); }
simulated function float GetReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return ApplySquadRatio(Super.GetReloadRateMultiplier(KFPRI, Other)); }
simulated function float GetMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { return ApplySquadRatio(Super.GetMagazineAmmoMultiplier(KFPRI, Other)); }
simulated function float GetMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { return ApplySquadRatio(Super.GetMaxAmmoMultiplier(KFPRI, AmmoType)); }
simulated function float GetWeaponPenetrationMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { return ApplySquadRatio(Super.GetWeaponPenetrationMultiplier(KFPRI, Other)); }
simulated function float GetWeaponSpreadRecoilMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { return ApplySquadRatio(Super.GetWeaponSpreadRecoilMultiplier(KFPRI, Other)); }
simulated function float GetPlayerMovementSpeedMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { return ApplySquadRatio(Super.GetPlayerMovementSpeedMultiplier(KFPRI, KFGRI)); }
simulated function float GetPlayerMovementAccelMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { return ApplySquadRatio(Super.GetPlayerMovementAccelMultiplier(KFPRI, KFGRI)); }
simulated function float GetPlayerMaxHealthMultiplier(Pawn Pawn) { return ApplySquadRatio(Super.GetPlayerMaxHealthMultiplier(Pawn)); }
function float GetHealPotencyMultiplier(KFPlayerReplicationInfo KFPRI) { return ApplySquadRatio(Super.GetHealPotencyMultiplier(KFPRI)); }
simulated function float GetHealRechargeMultiplier(KFPlayerReplicationInfo KFPRI) { return ApplySquadRatio(Super.GetHealRechargeMultiplier(KFPRI)); }

function float ModifyDamage(int Damage, Pawn Injured, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
    return ApplySquadRatio(Super.ModifyDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType));
}

defaultproperties
{
    NearbyRadius=1000.f
    AliveCountUpdateInterval=1.f
    NearbyCountUpdateInterval=0.25f
}
