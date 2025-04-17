//Killing Floor Turbo TurboPlayerCardCustomInfo
//Contains per-player info for KFTurbo's Card Game.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerCardCustomInfo extends TurboPlayerCustomInfo;

var bool bHasCheatedDeath;
var float CheatDeathTime;

var int NegateDamageCount;

var float PerpetualCriticalHitStartTime;
var float PerpetualCriticalHitTime;
var float PerpetualCriticalHitCooldown;

var int NonCriticalHitCount;

final function bool IsInPerpetualCriticalHitTime()
{
	if (PerpetualCriticalHitStartTime <= 0.f)
	{
		return false;
	}
	
	return Level.TimeSeconds < PerpetualCriticalHitStartTime + PerpetualCriticalHitTime;
}

final function AttemptGrantPerpetualCriticalHit()
{
	if (PerpetualCriticalHitStartTime > 0.f && Level.TimeSeconds < (PerpetualCriticalHitStartTime + PerpetualCriticalHitTime + PerpetualCriticalHitCooldown))
	{
		return;
	}

	PerpetualCriticalHitStartTime = Level.TimeSeconds;
}

defaultproperties
{
	bHasCheatedDeath=false
	CheatDeathTime=-1.f

	NegateDamageCount=0

	PerpetualCriticalHitStartTime=-1.f
	PerpetualCriticalHitTime=5.f
	PerpetualCriticalHitCooldown=20.f

	NonCriticalHitCount=0
}