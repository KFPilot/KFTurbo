//Killing Floor Turbo TurboPlayerCardCustomInfo
//Contains per-player info for KFTurbo's Card Game.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerCardCustomInfo extends TurboPlayerCustomInfo;

var TurboServerTimeActor ServerTimeActor;

var bool bHasCheatedDeath;
var float CheatDeathTime;

var int NegateDamageCount;

var float PerpetualCriticalHitStartTime;
var float PerpetualCriticalHitTime;
var float PerpetualCriticalHitCooldown;

var int NonCriticalHitCount;

var float LastGrenadeThrowTime;
var float GrenadeBoostTime;

var float LastHealBoostTime;
var float HealBoostBoostTime;
var float HealBoostBoostCooldown;

var int RackEmUpHeadshotCount;
var float RackEmUpHeadshotStackExpireTime;

replication
{
    reliable if (Role == ROLE_Authority)
        LastGrenadeThrowTime, LastHealBoostTime, RackEmUpHeadshotCount, RackEmUpHeadshotStackExpireTime;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(0.1f, false);
}

simulated function Timer()
{
	if (TurboGameReplicationInfo(Level.GRI) != None)
	{
		ServerTimeActor = TurboGameReplicationInfo(Level.GRI).ServerTimeActor;
	}
	
	if (ServerTimeActor != None)
	{
		return;
	}

	SetTimer(0.1f, false);
}

simulated function Tick(float DeltaTime)
{
	local bool bNeedsTick;
	bNeedsTick = false;
	
	Super.Tick(DeltaTime);

	if (!bRegistered)
	{
		return;
	}

	if (RackEmUpHeadshotCount != 0)
	{
		if (RackEmUpHeadshotStackExpireTime > Level.TimeSeconds)
		{
			bNeedsTick = true;
		}
		else
		{
			ResetPlayerHeadshot();
		}
	}

	if (!bNeedsTick)
	{
		Disable('Tick');
	}
	else
	{
		Enable('Tick');
	}
}

//Doesn't use ServerTimeActor because this is only used on server.
final function bool IsInCheatDeathGracePeriod()
{
	return bHasCheatedDeath && CheatDeathTime > 0.f && Level.TimeSeconds < CheatDeathTime;
}

final function bool IsInPerpetualCriticalHitTime()
{
	if (PerpetualCriticalHitStartTime <= 0.f)
	{
		return false;
	}
	
	return ServerTimeActor.GetServerTimeSeconds() < PerpetualCriticalHitStartTime + PerpetualCriticalHitTime;
}

final function AttemptGrantPerpetualCriticalHit()
{
	if (PerpetualCriticalHitStartTime > 0.f && Level.TimeSeconds < (PerpetualCriticalHitStartTime + PerpetualCriticalHitTime + PerpetualCriticalHitCooldown))
	{
		return;
	}

	PerpetualCriticalHitStartTime = Level.TimeSeconds;
}

final simulated function PlayerThrewGrenade()
{
	LastGrenadeThrowTime = Level.TimeSeconds;
	ForceNetUpdate();
}

final simulated function bool IsInGrenadeBuffTime()
{
	return LastGrenadeThrowTime > 0.f && (LastGrenadeThrowTime + GrenadeBoostTime > ServerTimeActor.GetServerTimeSeconds());
}

final simulated function PlayerHealed()
{
	if (LastHealBoostTime > 0.f && ((LastHealBoostTime + HealBoostBoostTime + HealBoostBoostCooldown) > ServerTimeActor.GetServerTimeSeconds()))
	{
		return;
	}

	LastHealBoostTime = Level.TimeSeconds;
	ForceNetUpdate();
}

final simulated function bool IsInHealBoostTime()
{
	return LastHealBoostTime > 0.f && (LastHealBoostTime + HealBoostBoostTime > ServerTimeActor.GetServerTimeSeconds());
}

final simulated function PlayerScoredHeadshot()
{
	RackEmUpHeadshotCount++;
	RackEmUpHeadshotStackExpireTime = Level.TimeSeconds + 5.f;
	Enable('Tick');
	ForceNetUpdate();
}

final simulated function float GetPlayerHeadshotBonus()
{
	return 1.f + (float(Min(RackEmUpHeadshotCount, 15)) * 0.02f);
}

final simulated function ResetPlayerHeadshot()
{
	RackEmUpHeadshotCount = 0;
	ForceNetUpdate();
}

defaultproperties
{
	bHasCheatedDeath=false
	CheatDeathTime=-1.f

	NegateDamageCount=0

	PerpetualCriticalHitStartTime=-1.f
	PerpetualCriticalHitTime=5.f
	PerpetualCriticalHitCooldown=10.f

	NonCriticalHitCount=0

	LastGrenadeThrowTime=0.f
	GrenadeBoostTime=5.f

	LastHealBoostTime=0.f
	HealBoostBoostTime=5.f
	HealBoostBoostCooldown=10.f

	//Replicates now that the client has to be aware of certain properties on here.
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=false
    bOnlyRelevantToOwner=true
}