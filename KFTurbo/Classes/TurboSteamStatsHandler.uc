//Killing Floor Turbo TurboSteamStatsHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
Class TurboSteamStatsHandler extends Engine.Info
	transient;

var PlayerController PCOwner;
var int SteamDamageHealedStat, SteamWeldingPointsStat, SteamShotgunDamageStat,
	SteamHeadshotKillsStat, SteamStalkerKillsStat, SteamBullpupDamageStat, SteamMeleeDamageStat,
	SteamFlameThrowerDamageStat, SteamExplosivesDamageStat;

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
	PlayerController = TurboPlayerController(PCOwner);
	if (PlayerController == None)
	{
		return;
	}

	PlayerController.ServerInitializeSteamStatInt(0, SteamDamageHealedStat);
	PlayerController.ServerInitializeSteamStatInt(1, SteamWeldingPointsStat);
	PlayerController.ServerInitializeSteamStatInt(2, SteamShotgunDamageStat);
	PlayerController.ServerInitializeSteamStatInt(3, SteamHeadshotKillsStat);
	PlayerController.ServerInitializeSteamStatInt(4, SteamStalkerKillsStat);
	PlayerController.ServerInitializeSteamStatInt(5, SteamBullpupDamageStat);
	PlayerController.ServerInitializeSteamStatInt(6, SteamMeleeDamageStat);
	PlayerController.ServerInitializeSteamStatInt(7, SteamFlameThrowerDamageStat);
	PlayerController.ServerInitializeSteamStatInt(21, SteamExplosivesDamageStat);
}

defaultproperties
{
	RemoteRole=ROLE_None
}
