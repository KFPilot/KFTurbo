//Killing Floor Turbo KFTurboMasterServerUplink
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboMasterServerUplink extends IpDrv.MasterServerUplink
	config(KFTurboServer);

var config string ServerColorString;
var string ServerNameString;
var config array<Color> ColorLookup;
var array<string> ColorLookupStringList;

var string MapNameString;
var config int MapGradientSteps;
var config array<Color> MapGradient;
var array<string> MapGradientStringList;

var string GameTypeString;
var string TurboVersionTitle, TurboVersionString;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(2.f, false);
}

function Timer()
{
	GotoState('SetupUplinkInfo');
}

function Refresh() {}

state SetupUplinkInfo
{
	function BeginState()
	{
		local int Index;
		ColorLookupStringList.Length = ColorLookup.Length;
		for (Index = ColorLookupStringList.Length - 1; Index >= 0; Index--)
		{
			ColorLookupStringList[Index] = class'GUIComponent'.static.MakeColorCode(ColorLookup[Index]);
		}
		
		MapGradientStringList.Length = MapGradient.Length;
		for (Index = MapGradientStringList.Length - 1; Index >= 0; Index--)
		{
			MapGradientStringList[Index] = class'GUIComponent'.static.MakeColorCode(MapGradient[Index]);
		}

		BuildServerName();
		BuildMapName();
		BuildGameModeName();
		BuildVersionName();

		SetTimer(0.1f, false);
	}

	function Timer()
	{
		GotoState('UplinkReady');
	}
}

function BuildServerName()
{
	ServerNameString = Repl(ServerColorString, "%v", class'KFTurboMut'.static.GetTurboVersionID());

	ServerNameString = ApplyServerNameGradientToString(ServerNameString);
}

final function string ApplyServerNameGradientToString(string InString)
{
	local int Index;

	for (Index = ColorLookupStringList.Length - 1; Index >= 0; Index--)
	{
		InString = Repl(InString, "%c"$string(Index), ColorLookupStringList[Index]);
	}

	return InString;
}

function BuildMapName()
{
	local string MapName;

	MapName = Left(string(Level), InStr(string(Level), "."));

	//Remove Turbo Super map variants.
	if (Right(MapName, 2) ~= "-S")
	{
		MapName = Left(MapName, Len(MapName) - 2);
	}
	
	MapNameString = ApplyMapGradientToString(MapName);
}

function BuildGameModeName()
{
	GameTypeString = ApplyMapGradientToString(GetGameTypeString());
}


function BuildVersionName()
{
	TurboVersionTitle = ApplyServerNameGradientToString("%c6T%c7u%c8r%c9bo %c6V%c7er%c8si%c9on");
	TurboVersionString = ApplyMapGradientToString(class'KFTurboMut'.static.GetTurboVersionID());
}

final function string ApplyMapGradientToString(string InString)
{
	local int Index, GradientIndex;
	local string GradientString;

	GradientString = "";
	for (Index = 0; Index < Len(InString); Index += MapGradientSteps)
	{
		if (GradientIndex >= MapGradientStringList.Length)
		{
			break;
		}

		GradientString = GradientString $ MapGradientStringList[GradientIndex] $ Mid(InString, Index, MapGradientSteps);
		GradientIndex++;
	}

	return GradientString $ Mid(InString, Index);
}

state UplinkReady
{
	function BeginState()
	{
		bInitialStateCached = false;
		SetTimer(5.f, true);
	}

	function Refresh()
	{
		PerformUpdate();
	}

	function Timer()
	{
		PerformUpdate();
	}
}

//Slim down the info the server provides to relevant data.
function PerformUpdate()
{
	if ((!bInitialStateCached) || (Level.TimeSeconds > CacheRefreshTime))
	{
		Level.Game.GetServerInfo(FullCachedServerState);
		FullCachedServerState.ServerName = ServerNameString;
		FullCachedServerState.MapName = MapNameString;

		class'GameInfo'.static.AddServerDetail(FullCachedServerState, "Server Mode", Eval(Level.NetMode == NM_ListenServer, "non-dedicated", "dedicated") );
    	class'GameInfo'.static.AddServerDetail(FullCachedServerState, "Server Version", Level.ROVersion);
    	class'GameInfo'.static.AddServerDetail(FullCachedServerState, TurboVersionTitle, TurboVersionString);
   		class'GameInfo'.static.AddServerDetail(FullCachedServerState, "VAC Secured", Eval(Level.Game.IsVACSecured(), "Enabled", "Disabled"));
		class'GameInfo'.static.AddServerDetail(FullCachedServerState, "Max Spectators", Level.Game.MaxSpectators);

		if (Level.Game.AccessControl != None && Level.Game.AccessControl.RequiresPassword())
		{
			class'GameInfo'.static.AddServerDetail(FullCachedServerState, "Passworded", "True");
		}

		ApplyServerFlags(FullCachedServerState);
		AppendMutators(FullCachedServerState);
		class'GameInfo'.static.AddServerDetail(FullCachedServerState, "Game Mode", GameTypeString);

		CachedServerState = FullCachedServerState;

		Level.Game.GetServerPlayers(FullCachedServerState);

		ServerState 		= FullCachedServerState;
		CacheRefreshTime 	= Level.TimeSeconds + 240.f; //Slowed interval.
		bInitialStateCached = true;
	}
	else if (Level.Game.GetNumPlayers() != CachePlayerCount || Level.Game.MaxPlayers != CachedServerState.MaxPlayers)
	{
		CachedServerState.MaxPlayers = Level.Game.MaxPlayers;
		ServerState = CachedServerState;
    	ServerState.PlayerInfo.Length = 0;
		
		Level.Game.GetServerPlayers(ServerState);

		FullCachedServerState = ServerState;
	}
	else
	{
		ServerState = FullCachedServerState;
	}

	CachePlayerCount = Level.Game.NumPlayers;
}

function ApplyServerFlags(out GameInfo.ServerResponseLine ServerState)
{
	local float GameDifficulty;
	GameDifficulty = Level.Game.GameDifficulty;

	if (GameDifficulty >= 7.f)
	{
        ServerState.Flags = ServerState.Flags | 512;
	}
	else if (GameDifficulty >= 5.f)
	{
        ServerState.Flags = ServerState.Flags | 256;
	}
	else if (GameDifficulty >= 4.f)
	{
        ServerState.Flags = ServerState.Flags | 128;
	}
	else if (GameDifficulty >= 2.f)
	{
        ServerState.Flags = ServerState.Flags | 64;
	}
	else if (GameDifficulty >= 1.f)
	{
        ServerState.Flags = ServerState.Flags | 32;
	}

	if (Level.Game.IsVACSecured())
	{
		ServerState.Flags = ServerState.Flags | 16;
	}

	if (Level.Game.AccessControl != None && Level.Game.AccessControl.RequiresPassword())
	{
		ServerState.Flags = ServerState.Flags | 1;
	}

	ServerState.Flags = ServerState.Flags & (~(2)); //This flag is being set and that's not intended.
}

function AppendMutators(out GameInfo.ServerResponseLine ServerState)
{
	local Mutator Mutator;
	local String MutatorName;
	local int ListLength;
	local bool bFound;

	for (Mutator = Level.Game.BaseMutator.NextMutator; Mutator != None; Mutator = Mutator.NextMutator)
	{
		bFound = false;
		MutatorName = Mutator.GetHumanReadableName();

		//Make these more readable. :)
		if (MutatorName ~= "ServerPerksMut")
		{
			MutatorName = "Server Perks";
		}
		else if (MutatorName ~= "SAMutator")
		{
			MutatorName = "Server Achievements";
		}

		ListLength = ServerState.ServerInfo.Length;
		ServerState.ServerInfo.Length = ListLength + 1;
		ServerState.ServerInfo[ListLength].Key = "Mutator";
		ServerState.ServerInfo[ListLength].Value = ApplyMapGradientToString(MutatorName);
	}
}

function string GetGameTypeString()
{
    local Mutator Mutator;

	if (Level.Game == None)
	{
		return "Turbo Game Mode";
	}

    for (Mutator = Level.Game.BaseMutator; Mutator != None; Mutator = Mutator.NextMutator)
    {
		switch(Mutator.GroupName)
		{
			case "KF-CardGame":
				return "Turbo Card Game Mode";
			case "KF-Randomizer":
				return "Turbo Randomizer Game Mode";
			case "KF-Holdout":
				return "Turbo Holdout Game Mode";
		}
    }

	return "Turbo Game Mode";
}

defaultproperties
{
	bInitialStateCached=false
	CacheRefreshTime=0.f
}
