class A_Zap extends A_BaseAffliction;

//We cache TotalZap in pretick and then use it in tick.
var float CachedTotalZap;
//Actual zap affliction properties.
var float ZapDischargeDelay; //How long to wait before losing charge.
var float ZapDischargeRate; //How fast to lose charge after delay.
var float ZappedModifier; //How much to reduce ground speed by when zapped. (Not hooked up yet.)

simulated function PreTick(float DeltaTime)
{
	CachedTotalZap = OwningMonster.TotalZap;

	if (OwningMonster.bZapped)
	{
		CachedMovementSpeedModifier = ZappedModifier;
	}
	else
	{
		CachedMovementSpeedModifier = 1.f;
	}
}

simulated function Tick(float DeltaTime)
{
	if (CachedTotalZap < 0.f)
	{
		return;
	}

	OwningMonster.TotalZap = CachedTotalZap;

	if( !OwningMonster.bZapped && OwningMonster.TotalZap > 0 && ((OwningMonster.Level.TimeSeconds - OwningMonster.LastZapTime) > ZapDischargeDelay)  )
	{
		OwningMonster.TotalZap -= DeltaTime * ZapDischargeRate;
	}
}

defaultproperties
{
	CachedTotalZap=0.f

	ZapDischargeDelay=1.f
	ZapDischargeRate=0.5f
	ZappedModifier=0.9f
}
