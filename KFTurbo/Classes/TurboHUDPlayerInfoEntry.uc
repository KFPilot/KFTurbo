//Killing Floor Turbo TurboHUDPlayerInfoEntry
//Helper object for TurboHUDPlayerInfo's player list.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHUDPlayerInfoEntry extends Object;

var float DistanceSquared;
var TurboPlayerReplicationInfo.EConnectionState ConnectionState;

var float CurrentHealth;
var float LastCheckedHealth;
var float PreviousHealth;

var float CurrentHealToHealth;
var float PreviousHealToHealth;

var float CurrentShield;
var float PreviousShield;


struct PlayerInfoHitData
{
	var float HitAmount;
	var float Ratio;
	var float FadeRate;
};
var PlayerInfoHitData LastHit;

var bool bInitialized;
var float VisibilityFade;

var float VoiceSupportAnim;
var float VoiceAlertAnim;

var() float HealthInterpRate;
var() float ShieldInterpRate;

static final simulated function float GetHealthMax(TurboHUDPlayerInfo.PlayerInfoData PlayerInfo)
{
	if (PlayerInfo.HumanPawn != None)
	{
		return PlayerInfo.HumanPawn.HealthMax;
	}

	if (PlayerInfo.TPRI != None)
	{
		return PlayerInfo.TPRI.HealthMax;
	}

	return 100.f;
}

static final simulated function float GetHealth(TurboHUDPlayerInfo.PlayerInfoData PlayerInfo)
{
	if (PlayerInfo.HumanPawn != None)
	{
		return FClamp(float(PlayerInfo.HumanPawn.Health) / PlayerInfo.HumanPawn.HealthMax, 0.f, 1.f);
	}

	if (PlayerInfo.TPRI != None)
	{
		if (PlayerInfo.TPRI.PlayerHealth <= 0.f)
		{
			return 0.f;
		}

		return FClamp(float(PlayerInfo.TPRI.PlayerHealth) / float(PlayerInfo.TPRI.HealthMax), 0.f, 1.f);
	}

	return 0.f;
}

static final simulated function float GetHealthHealingTo(TurboHUDPlayerInfo.PlayerInfoData PlayerInfo)
{
	if (PlayerInfo.HumanPawn != None)
	{
		if (PlayerInfo.HumanPawn.HealthHealingTo == -1)
		{
			return 0.f;
		}

		return FClamp(float(PlayerInfo.HumanPawn.HealthHealingTo) / PlayerInfo.HumanPawn.HealthMax, 0.f, 1.f);
	}

	return 0.f;
}

static final simulated function float GetShield(TurboHUDPlayerInfo.PlayerInfoData PlayerInfo)
{
	if (PlayerInfo.HumanPawn != None)
	{
		return PlayerInfo.HumanPawn.ShieldStrength / 100.f;
	}

	return float(PlayerInfo.TPRI.ShieldStrength) / 100.f;
}

final simulated function InitializeHitData()
{
	local float NewLostHealth;
	NewLostHealth = PreviousHealth - CurrentHealth;
	if (LastHit.Ratio >= 1.f)
	{
		LastHit.HitAmount = NewLostHealth;
		LastHit.FadeRate = Lerp(FMin(NewLostHealth / 0.5f, 1.f), 4.f, 1.f);
		LastHit.Ratio = 0.f;
		return;
	}
	
	if (NewLostHealth < LastHit.HitAmount * 0.5f && LastHit.Ratio < 0.75f)
	{
		return;
	}

	LastHit.HitAmount = NewLostHealth;
	LastHit.FadeRate = Lerp(FMin(NewLostHealth / 0.5f, 1.f), 4.f, 1.f);
	LastHit.Ratio = 0.f;
}

final simulated function Tick(float DeltaTime, TurboHUDPlayerInfo.PlayerInfoData PlayerInfo)
{
	CurrentHealth = GetHealth(PlayerInfo);
	CurrentShield = GetShield(PlayerInfo);
	CurrentHealToHealth = GetHealthHealingTo(PlayerInfo);

	VisibilityFade = FMax(VisibilityFade - DeltaTime, 0.f);

	if (!bInitialized)
	{
		LastCheckedHealth = CurrentHealth;
		PreviousHealth = CurrentHealth;
		PreviousShield = CurrentShield;
		PreviousHealToHealth = CurrentHealToHealth;
		LastHit.Ratio = 1.f; //Mark as done playing.
		bInitialized = true;
		return;
	}

	if (VoiceSupportAnim > 0.f)
	{
		VoiceSupportAnim = FMax(VoiceSupportAnim - (DeltaTime * 0.5f), 0.f);
	}

	if (VoiceAlertAnim > 0.f)
	{
		VoiceAlertAnim = FMax(VoiceAlertAnim - DeltaTime, 0.f);
	}

	if (LastHit.Ratio < 1.f)
	{
		LastHit.Ratio += LastHit.FadeRate * DeltaTime;
		LastHit.Ratio = FMin(LastHit.Ratio, 1.f);
	}

	if (CurrentHealth != LastCheckedHealth)
	{
		if (CurrentHealth < LastCheckedHealth)
		{
			InitializeHitData();
		}

		LastCheckedHealth = CurrentHealth;
	}

	if (CurrentHealth < PreviousHealth)
	{
		PreviousHealth = Lerp(default.HealthInterpRate * DeltaTime, PreviousHealth, CurrentHealth);

		if (Abs(PreviousHealth - CurrentHealth) < 0.01f)
		{
			PreviousHealth = CurrentHealth;
		}
	}
	else if (CurrentHealth > PreviousHealth)
	{
		PreviousHealth = CurrentHealth;
	}

	if (CurrentHealToHealth <= 0.f)
	{
		PreviousHealToHealth = CurrentHealToHealth;
	}
	else if (CurrentHealToHealth != PreviousHealToHealth)
	{
		PreviousHealToHealth = Lerp(default.HealthInterpRate * 4.f * DeltaTime, FMax(PreviousHealToHealth, CurrentHealth), CurrentHealToHealth);

		if (Abs(PreviousHealToHealth - CurrentHealToHealth) < 0.01f)
		{
			PreviousHealToHealth = CurrentHealToHealth;
		}
	}

	if (CurrentShield < PreviousShield)
	{
		PreviousShield = Lerp(default.ShieldInterpRate * DeltaTime, PreviousShield, CurrentShield);

		if (Abs(PreviousShield - CurrentShield) < 0.01f)
		{
			PreviousShield = CurrentShield;
		}
	}
	else if (CurrentShield > PreviousShield)
	{
		PreviousShield = CurrentShield;
	}
}

defaultproperties
{
	bInitialized=false

	HealthInterpRate=1.f;
	ShieldInterpRate=2.f;
}