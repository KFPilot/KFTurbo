//Killing Floor Turbo TurboSteamStatsHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
Class TurboSteamStatsHandler extends Engine.Info
	transient;

var PlayerController PCOwner;
var int SteamDamageHealedStat, SteamWeldingPointsStat, SteamShotgunDamageStat,
	SteamHeadshotKillsStat, SteamStalkerKillsStat, SteamBullpupDamageStat, SteamMeleeDamageStat,
	SteamFlameThrowerDamageStat, SteamExplosivesDamageStat;

enum EStatType
{
	DamageHealed,		// 0
	WeldingPoints,
	ShotgunDamage,
	HeadshotKills,
	StalkerKills,
	BullpupDamage,		// 5
	MeleeDamage,
	FlamethrowerDamage,
	ExplosiveDamage,
	StatMax				// 9
};

struct StatPair
{
	var EStatType Stat;
	var int StatValue;
};

const MAX_STAT_SIZE = 9;
struct StatPayload
{
	var StatPair StatList[MAX_STAT_SIZE];
};

simulated event PostBeginPlay()
{
	PCOwner = Level.GetLocalPlayerController();
	Super.PostBeginPlay();

	SetTimer(0.25f, false);
}

//Wait until we're sure server perks ftp request has finished.
simulated function Timer()
{
	if (PCOwner == None)
	{
		PCOwner = Level.GetLocalPlayerController();
		SetTimer(0.25f, false);
		return;
	}

	ApplySteamPerkStats();
}

simulated protected function ApplySteamPerkStats()
{
	local TurboPlayerController PlayerController;
	local StatPayload Payload;

	PlayerController = TurboPlayerController(PCOwner);
	if (PlayerController == None)
	{
		return;
	}

	Payload.StatList[0].Stat = DamageHealed;
	Payload.StatList[0].StatValue = SteamDamageHealedStat;

	Payload.StatList[1].Stat = WeldingPoints;
	Payload.StatList[1].StatValue = SteamWeldingPointsStat;

	Payload.StatList[2].Stat = ShotgunDamage;
	Payload.StatList[2].StatValue = SteamShotgunDamageStat;

	Payload.StatList[3].Stat = HeadshotKills;
	Payload.StatList[3].StatValue = SteamHeadshotKillsStat;

	Payload.StatList[4].Stat = StalkerKills;
	Payload.StatList[4].StatValue = SteamStalkerKillsStat;

	Payload.StatList[5].Stat = BullpupDamage;
	Payload.StatList[5].StatValue = SteamBullpupDamageStat;

	Payload.StatList[6].Stat = MeleeDamage;
	Payload.StatList[6].StatValue = SteamMeleeDamageStat;

	Payload.StatList[7].Stat = FlamethrowerDamage;
	Payload.StatList[7].StatValue = SteamFlameThrowerDamageStat;

	Payload.StatList[8].Stat = ExplosiveDamage;
	Payload.StatList[8].StatValue = SteamExplosivesDamageStat;

	PlayerController.ServerInitializeSteamStats(Payload);
}

function final class<SRCustomProgressInt> GetProgressClass(TurboSteamStatsHandler.EStatType StatType)
{
	switch (StatType)
	{
		case DamageHealed:
			return class'VP_DamageHealed';
		case WeldingPoints:
			return class'VP_WeldingPoints';
		case ShotgunDamage:
			return class'VP_ShotgunDamage';
		case HeadshotKills:
			return class'VP_HeadshotKills';
		case StalkerKills:
			return class'VP_StalkerKills';
		case BullpupDamage:
			return class'VP_BullpupDamage';
		case MeleeDamage:
			return class'VP_MeleeDamage';
		case FlamethrowerDamage:
			return class'VP_FlamethrowerDamage';
		case ExplosiveDamage:
			return class'VP_ExplosiveDamage';
	}

	return None;
}

defaultproperties
{
	RemoteRole=ROLE_None
}
