//Killing Floor Turbo VinylAugmentFoundry
//Kills build the augment list toward its full value. The stack resets if no kill lands in time.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentFoundry extends VinylAugmentBasic;

var int KillCount;
var float KillExpireTime;

var const int MaxKillCount;
var const float KillStackDuration;

replication
{
	reliable if (Role == ROLE_Authority)
		KillCount, KillExpireTime;
}

function NotifyPlayerKilledMonster(TurboPlayerController Player, KFMonster Target, class<DamageType> DamageType)
{
    if (HasStackExpired())
    {
        KillCount = 0;
    }

    KillCount = Min(KillCount + 1, MaxKillCount);
    KillExpireTime = Level.TimeSeconds + KillStackDuration;
    ForceNetUpdate();
}

simulated final function bool HasStackExpired()
{
    local ServerTimeActor TimeActor;

    if (TurboGameReplicationInfo(Level.GRI) == None)
    {
        return true;
    }

    TimeActor = TurboGameReplicationInfo(Level.GRI).ServerTimeActor;
    if (TimeActor == None)
    {
        return true;
    }

    return KillExpireTime <= TimeActor.GetServerTimeSeconds();
}

simulated final function float GetStackRatio()
{
    if (MaxKillCount <= 0 || HasStackExpired())
    {
        return 0.f;
    }

    return float(Min(KillCount, MaxKillCount)) / float(MaxKillCount);
}

simulated final function float ApplyStack(float Multiplier)
{
    return Lerp(GetStackRatio(), 1.f, Multiplier);
}

function float GetDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageInstigator, int InDamage, class<DamageType> DamageType) { return ApplyStack(Super.GetDamageMultiplier(KFPRI, Injured, DamageInstigator, InDamage, DamageType)); }
function float GetHeadshotDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType) { return ApplyStack(Super.GetHeadshotDamageMultiplier(KFPRI, Pawn, DamageType)); }

simulated function float GetFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return ApplyStack(Super.GetFireRateMultiplier(KFPRI, Other)); }
simulated function float GetReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { return ApplyStack(Super.GetReloadRateMultiplier(KFPRI, Other)); }
simulated function float GetMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { return ApplyStack(Super.GetMagazineAmmoMultiplier(KFPRI, Other)); }
simulated function float GetMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { return ApplyStack(Super.GetMaxAmmoMultiplier(KFPRI, AmmoType)); }
simulated function float GetWeaponPenetrationMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { return ApplyStack(Super.GetWeaponPenetrationMultiplier(KFPRI, Other)); }
simulated function float GetWeaponSpreadRecoilMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { return ApplyStack(Super.GetWeaponSpreadRecoilMultiplier(KFPRI, Other)); }
simulated function float GetPlayerMovementSpeedMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { return ApplyStack(Super.GetPlayerMovementSpeedMultiplier(KFPRI, KFGRI)); }
simulated function float GetPlayerMovementAccelMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { return ApplyStack(Super.GetPlayerMovementAccelMultiplier(KFPRI, KFGRI)); }
simulated function float GetPlayerMaxHealthMultiplier(Pawn Pawn) { return ApplyStack(Super.GetPlayerMaxHealthMultiplier(Pawn)); }
function float GetHealPotencyMultiplier(KFPlayerReplicationInfo KFPRI) { return ApplyStack(Super.GetHealPotencyMultiplier(KFPRI)); }
simulated function float GetHealRechargeMultiplier(KFPlayerReplicationInfo KFPRI) { return ApplyStack(Super.GetHealRechargeMultiplier(KFPRI)); }
simulated function float GetTraderGrenadeCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item) { return ApplyStack(Super.GetTraderGrenadeCostMultiplier(KFPRI, Item)); }

simulated function GetTraderCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item, out float Multiplier)
{
    local float StackedMultiplier;

    StackedMultiplier = 1.f;
    Super.GetTraderCostMultiplier(KFPRI, Item, StackedMultiplier);
    Multiplier *= ApplyStack(StackedMultiplier);
}

function GetPlayerCarryWeightModifier(KFPlayerReplicationInfo KFPRI, out int OutCarryWeightModifier)
{
    local int StackedModifier;

    Super.GetPlayerCarryWeightModifier(KFPRI, StackedModifier);
    OutCarryWeightModifier += int(float(StackedModifier) * GetStackRatio());
}

function float ModifyDamage(int Damage, Pawn Injured, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
    return ApplyStack(Super.ModifyDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType));
}

defaultproperties
{
    bWantsPlayerKilledMonsterEvents=true
    MaxKillCount=5
    KillStackDuration=5.f
}