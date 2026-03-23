//Killing Floor Turbo TurboCommandHandler
//Commands are routed here for actual implemenetation to pull code out of TurboPlayerController and allow for submodules to modify how they behave.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCommandHandler extends Info
	dependson(TurboAdminLocalMessage);

//Always grabbed via class<TurboCommandHandler>.default.
var const array<TurboTypingPrompt.CommandHint> CommandBaseHintList;
var const array<TurboTypingPrompt.CommandHint> CommandHintList;
var const array<TurboTypingPrompt.CommandHint> AdminCommandHintList;

enum ECommandPermissionType
{
	Admin,
	Difficulty,
	Anyone
};

//Used by commands to figure out if a given user has permission to execute a command.
function bool CanExecuteCommand(TurboPlayerController CommandInstigator, ECommandPermissionType PermissionType)
{
	if (CommandInstigator == None || CommandInstigator.Role != ROLE_Authority)
	{
		return false;
	}

	if (PermissionType == Anyone)
	{
		return true;
	}

	if (PermissionType == Difficulty && class'KFTurboMut'.default.bRequireAdminForDifficultyCommands)
	{
		PermissionType = Admin;
	}

	if (PermissionType == Admin && !CommandInstigator.HasAdminPermission())
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

	if (!CanExecuteCommand(CommandInstigator, Admin))
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

	if (!CanExecuteCommand(CommandInstigator, Admin))
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

	if (!CanExecuteCommand(CommandInstigator, Admin))
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
	BroadcastCommand(CommandInstigator, EncodeInt(AC_SetWave, NewWaveNum + 1));
}

function PreventGameOver(TurboPlayerController CommandInstigator)
{
	local KFTurboGameType TurboGameType;
	
	if (!CanExecuteCommand(CommandInstigator, Admin))
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
	
	if (!CanExecuteCommand(CommandInstigator, Admin))
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
	
	if (!CanExecuteCommand(CommandInstigator, Admin))
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
	
	if (!CanExecuteCommand(CommandInstigator, Admin))
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
	
	if (!CanExecuteCommand(CommandInstigator, Admin))
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
	
	if (!CanExecuteCommand(CommandInstigator, Admin))
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
	
	if (!CanExecuteCommand(CommandInstigator, Admin))
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
	
	if (!CanExecuteCommand(CommandInstigator, Admin))
	{
		return;
	}

    KFTurboMut = class'KFTurboMut'.static.FindMutator(Level.Game);
	KFTurboMut.bSkipInitialMonsterWander = bEnabled;

	BroadcastCommand(CommandInstigator, EncodeBool(AC_SetMonsterWanderEnabled, bEnabled));
}

function SetZedTimeEnabled(TurboPlayerController CommandInstigator, bool bEnabled)
{	
	if (!CanExecuteCommand(CommandInstigator, Admin))
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
	
	if (!CanExecuteCommand(CommandInstigator, Anyone))
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

defaultproperties
{
	//The Vote and EndTrader are actually handled elsewhere but this is a convenient place to put them so they're here!
	CommandBaseHintList(0)=(Command="Vote",Hint="Command for initiating a vote.",ParameterType=String)
	CommandBaseHintList(1)=(Command="AdminShowSettings",Hint="Display current game settings.",ParameterType=NoParam)
	CommandBaseHintList(2)=(Command="EndTrader",Hint="Shortcut for Vote EndTrader.",ParameterType=NoParam)

	CommandHintList(0)=(Command="AdminShowSettings",Hint="Display current game settings.",ParameterType=NoParam)
	CommandHintList(1)=(Command="AdminLogin",Hint="Log in as admin.",ParameterType=String,DefaultValue="admin 123")
	CommandHintList(2)=(Command="EndTrader",Hint="Shortcut for vote endtrader.",ParameterType=NoParam)
	CommandHintList(3)=(Command="TossCash",Hint="Tosses cash of a specified amount.",ParameterType=NoParam,DefaultValue="50")

	AdminCommandHintList(0)=(Command="AdminSetTraderTime",Hint="Set trader countdown time.",ParameterType=Integer)
	AdminCommandHintList(1)=(Command="AdminSetMaxPlayers",Hint="Set maximum player count.",ParameterType=Integer,DefaultValue="6")
	AdminCommandHintList(2)=(Command="AdminSetFakedPlayer",Hint="Set faked player count.",ParameterType=Integer,DefaultValue="0")
	AdminCommandHintList(3)=(Command="AdminSetPlayerHealth",Hint="Set forced player health count.",ParameterType=Integer,DefaultValue="0")
	AdminCommandHintList(4)=(Command="AdminSetSpawnRate",Hint="Set spawn rate modifier.",ParameterType=Float,DefaultValue="1.0")
	AdminCommandHintList(5)=(Command="AdminSetMaxMonsters",Hint="Set max monsters modifier.",ParameterType=Float,DefaultValue="1.0")
	AdminCommandHintList(6)=(Command="AdminSetMonsterWanderEnabled",Hint="Enable or disable initial monster wander.",ParameterType=Boolean,DefaultValue="true")
	AdminCommandHintList(7)=(Command="AdminSetZedTimeEnabled",Hint="Enable or disable zed time.",ParameterType=Boolean,DefaultValue="true")
	AdminCommandHintList(8)=(Command="ServerDebugSkipWave",Hint="Skip the current wave.",ParameterType=NoParam)
	AdminCommandHintList(9)=(Command="ServerDebugRestartWave",Hint="Restart the current wave.",ParameterType=NoParam)
	AdminCommandHintList(10)=(Command="ServerDebugSetWave",Hint="Set the current wave number.",ParameterType=Integer)
	AdminCommandHintList(11)=(Command="ServerDebugPreventGameOver",Hint="Prevent the game from ending.",ParameterType=NoParam)
	AdminCommandHintList(12)=(Command="ServerDebugSpawnFriend",Hint="Spawn a bot ally.",ParameterType=NoParam)
}