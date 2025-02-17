//Killing Floor Turbo TurboCommandHandler
//Commands are routed here for actual implemenetation to pull code out of TurboPlayerController and allow for submodules to modify how they behave.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCommandHandler extends Info;

function SkipWave(TurboPlayerController Instigator)
{
	local KFTurboGameType TurboGameType;

	if (Instigator == None || Instigator.Role != ROLE_Authority)
	{
		return;
	}

	if (!Instigator.HasPermissionForCommand())
	{
		return;
	}

	TurboGameType = KFTurboGameType(Instigator.Level.Game);

	if (TurboGameType == None || !TurboGameType.bWaveInProgress)
	{
		return;
	}

	class'KFTurboGameType'.static.StaticDisableStatsAndAchievements(Instigator);

	TurboGameType.TotalMaxMonsters = 0;
	TurboGameType.NextSpawnSquad.Length = 0;
	TurboGameType.KillZeds();
	
	//TurboGameType.ClearEndGame();

	Instigator.Level.Game.BroadcastLocalized(Instigator.Level.GRI, class'TurboAdminLocalMessage', 0, Instigator.PlayerReplicationInfo); //EAdminCommand.AC_SkipWave
}

function RestartWave(TurboPlayerController Instigator)
{
	local KFTurboGameType TurboGameType;

	if (Instigator == None || Instigator.Role != ROLE_Authority)
	{
		return;
	}

	if (!Instigator.HasPermissionForCommand())
	{
		return;
	}

	TurboGameType = KFTurboGameType(Instigator.Level.Game);

	if (TurboGameType == None || !TurboGameType.bWaveInProgress)
	{
		return;
	}

	class'KFTurboGameType'.static.StaticDisableStatsAndAchievements(Instigator);

	TurboGameType.WaveNum = TurboGameType.WaveNum - 1;

	TurboGameType.TotalMaxMonsters = 0;
	TurboGameType.NextSpawnSquad.Length = 0;
	TurboGameType.KillZeds();
	
	TurboGameType.ClearEndGame();
	
	Instigator.Level.Game.BroadcastLocalized(Instigator.Level.GRI, class'TurboAdminLocalMessage', 1, Instigator.PlayerReplicationInfo); //EAdminCommand.AC_RestartWave
}

function SetWave(TurboPlayerController Instigator, int NewWaveNum)
{
	local KFTurboGameType TurboGameType;

	if (Instigator == None || Instigator.Role != ROLE_Authority)
	{
		return;
	}

	if (!Instigator.HasPermissionForCommand())
	{
		return;
	}

	TurboGameType = KFTurboGameType(Instigator.Level.Game);

	if (TurboGameType == None)
	{
		return;
	}

	NewWaveNum = Max(NewWaveNum - 1, 0);

	class'KFTurboGameType'.static.StaticDisableStatsAndAchievements(Instigator);
	
	if (TurboGameType.bWaveInProgress)
	{
		TurboGameType.WaveNum = NewWaveNum - 1;
        InvasionGameReplicationInfo(Instigator.GameReplicationInfo).WaveNumber = NewWaveNum;

		TurboGameType.TotalMaxMonsters = 0;
		TurboGameType.NextSpawnSquad.Length = 0;
		TurboGameType.KillZeds();
	}
	else
	{
		TurboGameType.WaveNum = NewWaveNum;
        InvasionGameReplicationInfo(Instigator.GameReplicationInfo).WaveNumber = NewWaveNum;
	}

	TurboGameType.ClearEndGame();
	
	//Encode the wave number into the switch value.
	Instigator.Level.Game.BroadcastLocalized(Instigator.Level.GRI, class'TurboAdminLocalMessage', (2 | ((NewWaveNum + 1) << 8)), Instigator.PlayerReplicationInfo); //EAdminCommand.AC_SetWave
}

function PreventGameOver(TurboPlayerController Instigator)
{
	local KFTurboGameType TurboGameType;

	if (Instigator.Role != ROLE_Authority)
	{
		return;
	}

	if (!Instigator.HasPermissionForCommand())
	{
		return;
	}

	TurboGameType = KFTurboGameType(Instigator.Level.Game);

	if (TurboGameType == None || TurboGameType.IsPreventGameOverEnabled())
	{
		return;
	}

	class'KFTurboGameType'.static.StaticDisableStatsAndAchievements(Instigator);

	KFTurboGameType(Instigator.Level.Game).PreventGameOver();
	
	Instigator.Level.Game.BroadcastLocalized(Instigator.Level.GRI, class'TurboAdminLocalMessage', 5, Instigator.PlayerReplicationInfo); //EAdminCommand.AC_PreventGameOver
}

function SetTraderTime(TurboPlayerController Instigator, int Time)
{
	local KFTurboGameType TurboGameType;

	if (Instigator.Role != ROLE_Authority)
	{
		return;
	}

	if (!Instigator.HasPermissionForCommand())
	{
		return;
	}

	TurboGameType = KFTurboGameType(Instigator.Level.Game);

	if (TurboGameType == None || TurboGameType.bWaveInProgress)
	{
		return;
	}

	Time = Max(10, Time);
	Time = Min(99999, Time);

	TurboGameType.WaveCountDown = Time;
	if (KFGameReplicationInfo(Instigator.Level.GRI) != None)
	{
		KFGameReplicationInfo(Instigator.Level.GRI).TimeToNextWave = TurboGameType.WaveCountDown;
	}
	
	Instigator.Level.Game.BroadcastLocalized(Instigator.Level.GRI, class'TurboAdminLocalMessage', (3 | ((Time) << 8)), Instigator.PlayerReplicationInfo); //EAdminCommand.AC_SetTraderTime
}

function SetMaxPlayers(TurboPlayerController Instigator, int PlayerCount)
{
	local KFTurboGameType TurboGameType;

	if (Instigator.Role != ROLE_Authority)
	{
		return;
	}

	if (!Instigator.HasPermissionForCommand())
	{
		return;
	}

	PlayerCount = Max(1, PlayerCount);
	PlayerCount = Min(12, PlayerCount);

	TurboGameType = KFTurboGameType(Instigator.Level.Game);

	if (TurboGameType == None || TurboGameType.bWaveInProgress)
	{
		return;
	}

 	TurboGameType.MaxPlayers = PlayerCount;
    TurboGameType.default.MaxPlayers = PlayerCount;
	
	Instigator.Level.Game.BroadcastLocalized(Instigator.Level.GRI, class'TurboAdminLocalMessage', (4 | ((PlayerCount) << 8)), Instigator.PlayerReplicationInfo); //EAdminCommand.AC_SetMaxPlayers
}

function SetFakedPlayer(TurboPlayerController Instigator, int FakedPlayerCount)
{
	local KFTurboGameType TurboGameType;

	if (Instigator.Role != ROLE_Authority)
	{
		return;
	}

	if (!Instigator.HasPermissionForCommand(true))
	{
		return;
	}

	TurboGameType = KFTurboGameType(Instigator.Level.Game);
	FakedPlayerCount = TurboGameType.SetFakedPlayerCount(FakedPlayerCount);
	Instigator.Level.Game.BroadcastLocalized(Instigator.Level.GRI, class'TurboAdminLocalMessage', (6 | ((FakedPlayerCount) << 8)), Instigator.PlayerReplicationInfo); //EAdminCommand.AC_SetFakedPlayerCount
}

function SetPlayerHealth(TurboPlayerController Instigator, int PlayerHealthCount)
{
	local KFTurboGameType TurboGameType;

	if (Instigator.Role != ROLE_Authority)
	{
		return;
	}

	if (!Instigator.HasPermissionForCommand(true))
	{
		return;
	}
	
	TurboGameType = KFTurboGameType(Instigator.Level.Game);
	PlayerHealthCount = TurboGameType.SetForcedPlayerHealthCount(PlayerHealthCount);
	Instigator.Level.Game.BroadcastLocalized(Instigator.Level.GRI, class'TurboAdminLocalMessage', (7 | ((PlayerHealthCount) << 8)), Instigator.PlayerReplicationInfo); //EAdminCommand.AC_SetPlayerHealthCount
}

function SetSpawnRate(TurboPlayerController Instigator, float SpawnRateModifier)
{
	local KFTurboGameType TurboGameType;

	if (Instigator.Role != ROLE_Authority)
	{
		return;
	}

	if (!Instigator.HasPermissionForCommand(true))
	{
		return;
	}
	
	TurboGameType = KFTurboGameType(Instigator.Level.Game);
	SpawnRateModifier = TurboGameType.SetAdminSpawnRateModifier(SpawnRateModifier);
	Instigator.Level.Game.BroadcastLocalized(Instigator.Level.GRI, class'TurboAdminLocalMessage', (8 | ((class'TurboAdminLocalMessage'.static.EncodeFloat(SpawnRateModifier)) << 8)), Instigator.PlayerReplicationInfo); //EAdminCommand.AC_SetSpawnRateModifier
}

function SetMaxMonsters(TurboPlayerController Instigator, float MaxMonstersModifier)
{
	local KFTurboGameType TurboGameType;

	if (Instigator.Role != ROLE_Authority)
	{
		return;
	}

	if (!Instigator.HasPermissionForCommand(true))
	{
		return;
	}
	
	TurboGameType = KFTurboGameType(Instigator.Level.Game);
	MaxMonstersModifier = TurboGameType.SetAdminMaxMonstersModifier(MaxMonstersModifier);
	Instigator.Level.Game.BroadcastLocalized(Instigator.Level.GRI, class'TurboAdminLocalMessage', (9 | ((class'TurboAdminLocalMessage'.static.EncodeFloat(MaxMonstersModifier)) << 8)), Instigator.PlayerReplicationInfo); //EAdminCommand.AC_SetMaxMonstersModifier
}

function ShowSettings(TurboPlayerController Instigator)
{
	local KFTurboGameType TurboGameType;

	if (Instigator.Role != ROLE_Authority)
	{
		return;
	}

	if (!Instigator.HasPermissionForCommand(true))
	{
		return;
	}
	
	TurboGameType = KFTurboGameType(Instigator.Level.Game);
	Instigator.Level.Game.BroadcastLocalized(Instigator.Level.GRI, class'TurboAdminLocalMessage', (10 | (TurboGameType.GetFakedPlayerCount() << 8)), Instigator.PlayerReplicationInfo); 			//EAdminCommand.AC_GetFakedPlayerCount
	Instigator.Level.Game.BroadcastLocalized(Instigator.Level.GRI, class'TurboAdminLocalMessage', (11 | (TurboGameType.GetForcedPlayerHealthCount() << 8)), Instigator.PlayerReplicationInfo);	//EAdminCommand.AC_GetPlayerHealthCount
	Instigator.Level.Game.BroadcastLocalized(Instigator.Level.GRI, class'TurboAdminLocalMessage', (12 | (class'TurboAdminLocalMessage'.static.EncodeFloat(TurboGameType.AdminSpawnRateModifier) << 8)), Instigator.PlayerReplicationInfo);	//EAdminCommand.AC_GetSpawnRateModifier
	Instigator.Level.Game.BroadcastLocalized(Instigator.Level.GRI, class'TurboAdminLocalMessage', (13 | (class'TurboAdminLocalMessage'.static.EncodeFloat(TurboGameType.AdminMaxMonstersModifier) << 8)), Instigator.PlayerReplicationInfo);	//EAdminCommand.AC_GetMaxMonstersModifier
}