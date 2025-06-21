//Killing Floor Turbo TurboCommandHandler
//Commands are routed here for actual implemenetation to pull code out of TurboPlayerController and allow for submodules to modify how they behave.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCommandHandler extends Info
	dependson(TurboAdminLocalMessage);

//Used by commands to figure out if a given user has permission to execute a command.
function bool CanExecuteCommand(TurboPlayerController CommandInstigator, bool bIsAdminOnlyCommand)
{
	if (CommandInstigator == None || CommandInstigator.Role != ROLE_Authority)
	{
		return false;
	}

	if (!CommandInstigator.HasPermissionForCommand(bIsAdminOnlyCommand))
	{
		return false;
	}

	return true;
}

static final function BroadcastCommand(TurboPlayerController CommandInstigator, int Data)
{
	CommandInstigator.Level.Game.BroadcastLocalized(CommandInstigator.Level.GRI, class'TurboAdminLocalMessage', Data, CommandInstigator.PlayerReplicationInfo);
}		

//Unrealscript has problems resolving enums that are declared externally.
//These functions allow for a specific EAdminCommand enum to specified directly instead of having to use their byte representation.
static final function int Encode(TurboAdminLocalMessage.EAdminCommand Type)
{
	return int(Type);
}

static final function int EncodeInt(TurboAdminLocalMessage.EAdminCommand Type, int Value)
{
	return (int(Type) | (Value << 8));
}

static final function int EncodeFloat(TurboAdminLocalMessage.EAdminCommand Type, float Value)
{
	return (int(Type) | (class'TurboAdminLocalMessage'.static.EncodeFloat(Value) << 8));
}

static final function int EncodeBool(TurboAdminLocalMessage.EAdminCommand Type, bool bValue)
{
	return (int(Type) | (class'TurboAdminLocalMessage'.static.EncodeBool(bValue) << 8));
}

function SkipWave(TurboPlayerController CommandInstigator)
{
	local KFTurboGameType TurboGameType;

	if (CanExecuteCommand(CommandInstigator, true))
	{
		return;
	}

	TurboGameType = KFTurboGameType(CommandInstigator.Level.Game);

	if (TurboGameType == None || !TurboGameType.bWaveInProgress)
	{
		return;
	}

	class'KFTurboGameType'.static.StaticDisableStatsAndAchievements(CommandInstigator);

	TurboGameType.TotalMaxMonsters = 0;
	TurboGameType.NextSpawnSquad.Length = 0;
	TurboGameType.KillZeds();

	BroadcastCommand(CommandInstigator, Encode(AC_SkipWave));
}

function RestartWave(TurboPlayerController CommandInstigator)
{
	local KFTurboGameType TurboGameType;

	if (CanExecuteCommand(CommandInstigator, true))
	{
		return;
	}

	TurboGameType = KFTurboGameType(CommandInstigator.Level.Game);

	if (TurboGameType == None || !TurboGameType.bWaveInProgress)
	{
		return;
	}

	class'KFTurboGameType'.static.StaticDisableStatsAndAchievements(CommandInstigator);

	TurboGameType.WaveNum = TurboGameType.WaveNum - 1;

	TurboGameType.TotalMaxMonsters = 0;
	TurboGameType.NextSpawnSquad.Length = 0;
	TurboGameType.KillZeds();
	
	TurboGameType.ClearEndGame();
	
	BroadcastCommand(CommandInstigator, Encode(AC_RestartWave));
}

function SetWave(TurboPlayerController CommandInstigator, int NewWaveNum)
{
	local KFTurboGameType TurboGameType;

	if (CanExecuteCommand(CommandInstigator, true))
	{
		return;
	}

	TurboGameType = KFTurboGameType(CommandInstigator.Level.Game);

	if (TurboGameType == None)
	{
		return;
	}

	NewWaveNum = Max(NewWaveNum - 1, 0);

	class'KFTurboGameType'.static.StaticDisableStatsAndAchievements(CommandInstigator);
	
	if (TurboGameType.bWaveInProgress)
	{
		TurboGameType.WaveNum = NewWaveNum - 1;
        InvasionGameReplicationInfo(CommandInstigator.GameReplicationInfo).WaveNumber = NewWaveNum;

		TurboGameType.TotalMaxMonsters = 0;
		TurboGameType.NextSpawnSquad.Length = 0;
		TurboGameType.KillZeds();
	}
	else
	{
		TurboGameType.WaveNum = NewWaveNum;
        InvasionGameReplicationInfo(CommandInstigator.GameReplicationInfo).WaveNumber = NewWaveNum;
	}

	TurboGameType.ClearEndGame();
	
	//Encode the wave number into the switch value.
	BroadcastCommand(CommandInstigator, Encode(AC_SetWave));
}

function PreventGameOver(TurboPlayerController CommandInstigator)
{
	local KFTurboGameType TurboGameType;
	
	if (CanExecuteCommand(CommandInstigator, true))
	{
		return;
	}

	TurboGameType = KFTurboGameType(CommandInstigator.Level.Game);

	if (TurboGameType == None || TurboGameType.IsPreventGameOverEnabled())
	{
		return;
	}

	class'KFTurboGameType'.static.StaticDisableStatsAndAchievements(CommandInstigator);

	KFTurboGameType(CommandInstigator.Level.Game).PreventGameOver();
	
	BroadcastCommand(CommandInstigator, Encode(AC_PreventGameOver));
}

function SetTraderTime(TurboPlayerController CommandInstigator, int Time)
{
	local KFTurboGameType TurboGameType;
	
	if (CanExecuteCommand(CommandInstigator, true))
	{
		return;
	}

	TurboGameType = KFTurboGameType(CommandInstigator.Level.Game);

	if (TurboGameType == None || TurboGameType.bWaveInProgress)
	{
		return;
	}

	Time = Max(10, Time);
	Time = Min(99999, Time);

	TurboGameType.WaveCountDown = Time;
	if (KFGameReplicationInfo(CommandInstigator.Level.GRI) != None)
	{
		KFGameReplicationInfo(CommandInstigator.Level.GRI).TimeToNextWave = TurboGameType.WaveCountDown;
	}
	
	BroadcastCommand(CommandInstigator, EncodeInt(AC_SetTraderTime, Time));
}

function SetMaxPlayers(TurboPlayerController CommandInstigator, int PlayerCount)
{
	local KFTurboGameType TurboGameType;
	
	if (CanExecuteCommand(CommandInstigator, true))
	{
		return;
	}

	PlayerCount = Max(1, PlayerCount);
	PlayerCount = Min(12, PlayerCount);

	TurboGameType = KFTurboGameType(CommandInstigator.Level.Game);

	if (TurboGameType == None || TurboGameType.bWaveInProgress)
	{
		return;
	}

 	TurboGameType.MaxPlayers = PlayerCount;
    TurboGameType.default.MaxPlayers = PlayerCount;
	
	BroadcastCommand(CommandInstigator, EncodeInt(AC_SetMaxPlayers, PlayerCount));
}

function SetFakedPlayer(TurboPlayerController CommandInstigator, int FakedPlayerCount)
{
	local KFTurboGameType TurboGameType;
	
	if (CanExecuteCommand(CommandInstigator, false))
	{
		return;
	}

	TurboGameType = KFTurboGameType(CommandInstigator.Level.Game);
	FakedPlayerCount = TurboGameType.SetFakedPlayerCount(FakedPlayerCount);

	BroadcastCommand(CommandInstigator, EncodeInt(AC_SetFakedPlayerCount, FakedPlayerCount));
}

function SetPlayerHealth(TurboPlayerController CommandInstigator, int PlayerHealthCount)
{
	local KFTurboGameType TurboGameType;
	
	if (CanExecuteCommand(CommandInstigator, false))
	{
		return;
	}
	
	TurboGameType = KFTurboGameType(CommandInstigator.Level.Game);
	PlayerHealthCount = TurboGameType.SetForcedPlayerHealthCount(PlayerHealthCount);

	BroadcastCommand(CommandInstigator, EncodeInt(AC_SetPlayerHealthCount, PlayerHealthCount));
}

function SetSpawnRate(TurboPlayerController CommandInstigator, float SpawnRateModifier)
{
	local KFTurboGameType TurboGameType;
	
	if (CanExecuteCommand(CommandInstigator, false))
	{
		return;
	}
	
	TurboGameType = KFTurboGameType(CommandInstigator.Level.Game);
	SpawnRateModifier = TurboGameType.SetAdminSpawnRateModifier(SpawnRateModifier);
	BroadcastCommand(CommandInstigator, EncodeFloat(AC_SetSpawnRateModifier, SpawnRateModifier));
}

function SetMaxMonsters(TurboPlayerController CommandInstigator, float MaxMonstersModifier)
{
	local KFTurboGameType TurboGameType;
	
	if (CanExecuteCommand(CommandInstigator, false))
	{
		return;
	}
	
	TurboGameType = KFTurboGameType(CommandInstigator.Level.Game);
	MaxMonstersModifier = TurboGameType.SetAdminMaxMonstersModifier(MaxMonstersModifier);

	BroadcastCommand(CommandInstigator, EncodeFloat(AC_SetMaxMonstersModifier, MaxMonstersModifier));
}

function SetMonsterWanderEnabled(TurboPlayerController CommandInstigator, bool bEnabled)
{
    local KFTurboMut KFTurboMut;
	
	if (CanExecuteCommand(CommandInstigator, false))
	{
		return;
	}

    KFTurboMut = class'KFTurboMut'.static.FindMutator(Level.Game);
	KFTurboMut.bSkipInitialMonsterWander = bEnabled;

	BroadcastCommand(CommandInstigator, EncodeBool(AC_SetMonsterWanderEnabled, bEnabled));
}

function SetZedTimeEnabled(TurboPlayerController CommandInstigator, bool bEnabled)
{	
	if (CanExecuteCommand(CommandInstigator, false))
	{
		return;
	}

	KFTurboGameType(CommandInstigator.Level.Game).SetZedTimeEnabled(bEnabled);
	BroadcastCommand(CommandInstigator, EncodeBool(AC_SetZedTimeEnabled, bEnabled));
}

function ShowSettings(TurboPlayerController CommandInstigator)
{
	local KFTurboGameType TurboGameType;
    local KFTurboMut KFTurboMut;
	
	if (CanExecuteCommand(CommandInstigator, false))
	{
		return;
	}
	
	TurboGameType = KFTurboGameType(CommandInstigator.Level.Game);
    KFTurboMut = class'KFTurboMut'.static.FindMutator(TurboGameType);
	BroadcastCommand(CommandInstigator, EncodeInt(AC_GetFakedPlayerCount, TurboGameType.GetFakedPlayerCount()));
	BroadcastCommand(CommandInstigator, EncodeInt(AC_GetPlayerHealthCount, TurboGameType.GetForcedPlayerHealthCount()));
	BroadcastCommand(CommandInstigator, EncodeFloat(AC_GetSpawnRateModifier, TurboGameType.AdminSpawnRateModifier));
	BroadcastCommand(CommandInstigator, EncodeFloat(AC_GetMaxMonstersModifier, TurboGameType.AdminMaxMonstersModifier));
	BroadcastCommand(CommandInstigator, EncodeBool(AC_GetMonsterWanderEnabled, !KFTurboMut.bSkipInitialMonsterWander));
	BroadcastCommand(CommandInstigator, EncodeBool(AC_GetZedTimeEnabled, TurboGameType.IsZedTimeEnabled()));
}