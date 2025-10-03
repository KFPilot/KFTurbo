//Killing Floor Turbo AfflictionZap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class AfflictionZap extends CoreMonsterAfflictionZap;

//We cache TotalZap in pretick and then use it in tick.
var float CachedTotalZap;
//Actual zap affliction properties.
var float ZapDischargeDelay; //How long to wait before losing charge.
var float ZapDischargeRate; //How fast to lose charge after delay.
var float ZappedModifier; //How much to reduce ground speed by when zapped. (Not hooked up yet.)

simulated function PreTick(KFMonster Monster, float DeltaTime)
{
	if (Monster == None)
	{
		return;
	}

	CachedTotalZap = Monster.TotalZap;

	if (Monster.bZapped)
	{
		CachedMovementSpeedModifier = ZappedModifier;
	}
	else
	{
		CachedMovementSpeedModifier = 1.f;
	}
}

simulated function Tick(KFMonster Monster, float DeltaTime)
{
	if (Monster == None)
	{
		return;
	}

	if (CachedTotalZap < 0.f)
	{
		return;
	}

	Monster.TotalZap = CachedTotalZap;

	if (!Monster.bZapped && Monster.TotalZap > 0 && ((Monster.Level.TimeSeconds - Monster.LastZapTime) > ZapDischargeDelay))
	{
		Monster.TotalZap -= DeltaTime * ZapDischargeRate;
	}
}

defaultproperties
{
	CachedTotalZap=0.f

	ZapDischargeDelay=1.f
	ZapDischargeRate=0.5f
	ZappedModifier=0.9f
}
