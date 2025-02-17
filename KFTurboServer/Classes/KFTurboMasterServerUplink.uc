//Killing Floor Turbo KFTurboMasterServerUplink
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboMasterServerUplink extends IpDrv.MasterServerUplink
	config(KFTurboServer);

var config string ServerColorString;
var config int BlueGradientSteps;
var config array<string> BlueStringGradient;
var config bool bApplyVersionNumberToServerName;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(5.f, true);
}

final function string ApplyGradientToString(String BaseString)
{
	local string GradientString;
	local int StringIndex;
	local int GradientIndex;

	GradientString = "";
	GradientIndex = 0;

	for (StringIndex = 0; StringIndex < Len(BaseString); StringIndex += BlueGradientSteps)
	{
		if (GradientIndex >= BlueStringGradient.Length)
		{
			break;
		}

		GradientString = GradientString $ BlueStringGradient[GradientIndex] $ Mid(BaseString, StringIndex, BlueGradientSteps);
		GradientIndex++;
	}

	GradientString = GradientString $ Mid(BaseString, StringIndex);

	return GradientString;
}

//When this gets called seems arbitrary and infrequent from the non-native side...
//Will still do updates here but now also have a timer do it.
event Refresh()
{
	PerformUpdate();
}

function Timer()
{
	PerformUpdate();
}

//Slim down the info the server provides to relevant data.
function PerformUpdate()
{
	if ( (!bInitialStateCached) || ( Level.TimeSeconds > CacheRefreshTime )  )
	{
		Level.Game.GetServerInfo(FullCachedServerState);
		
		if (ServerColorString != "")
		{
			FullCachedServerState.ServerName = ServerColorString;

			if (bApplyVersionNumberToServerName)
			{
				FullCachedServerState.ServerName = Repl(FullCachedServerState.ServerName, "%v", class'KFTurboMut'.static.GetTurboVersionID());
			}
		}

		FullCachedServerState.MapName = ApplyGradientToString(FullCachedServerState.MapName);

		class'GameInfo'.static.AddServerDetail( FullCachedServerState, "Server Mode", Eval(Level.NetMode == NM_ListenServer, "non-dedicated", "dedicated") );
    	class'GameInfo'.static.AddServerDetail( FullCachedServerState, "Server Version", Level.ROVersion );
    	class'GameInfo'.static.AddServerDetail( FullCachedServerState, "Turbo Version", ApplyGradientToString(class'KFTurboMut'.static.GetTurboVersionID()));
   		class'GameInfo'.static.AddServerDetail( FullCachedServerState, "VAC Secured", Eval(Level.Game.IsVACSecured(), "Enabled", "Disabled"));
		class'GameInfo'.static.AddServerDetail( FullCachedServerState, "Max Spectators", Level.Game.MaxSpectators );

		if ( Level.Game.AccessControl != None && Level.Game.AccessControl.RequiresPassword() )
		{
			class'GameInfo'.static.AddServerDetail( FullCachedServerState, "Passworded", "True" );
		}

		ApplyServerFlags(FullCachedServerState);
		AppendMutators(FullCachedServerState);
		AppendGameModeInfo(FullCachedServerState);

		CachedServerState = FullCachedServerState;

		Level.Game.GetServerPlayers(FullCachedServerState);

		ServerState 		= FullCachedServerState;
		CacheRefreshTime 	= Level.TimeSeconds + 9.f; //Reduced interval
		bInitialStateCached = false;
	}
	else if (Level.Game.GetNumPlayers() != CachePlayerCount)
	{
		CachedServerState.MaxPlayers = Level.Game.MaxPlayers;
		ServerState = CachedServerState;

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

	if (Level.Game.AccessControl.RequiresPassword())
	{
		ServerState.Flags = ServerState.Flags | 1;
	}

	ServerState.Flags = ServerState.Flags & (~(2)); //This flag is being set and that's not intended.
}

function AppendMutators(out GameInfo.ServerResponseLine ServerState)
{
	local Mutator Mutator;
	local String MutatorName;
	local int Index, ListLength;
	local bool bFound;

	for (Mutator = Level.Game.BaseMutator.NextMutator; Mutator != None; Mutator = Mutator.NextMutator)
	{
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

		for ( Index=0; Index<ServerState.ServerInfo.Length; Index++ )
		{
			if ( (ServerState.ServerInfo[Index].Value ~= MutatorName) && (ServerState.ServerInfo[Index].Key ~= "Mutator") )
			{
				bFound = true;
				break;
			}
		}

		if ( !bFound )
		{
			ListLength = ServerState.ServerInfo.Length;
			ServerState.ServerInfo.Length = ListLength + 1;
			ServerState.ServerInfo[ListLength].Key = "Mutator";
			ServerState.ServerInfo[ListLength].Value = ApplyGradientToString(MutatorName);
		}
	}
}

function AppendGameModeInfo(out GameInfo.ServerResponseLine ServerState)
{
	local string GameTypeString;
	local KFTurboGameType GameType;

	GameType = KFTurboGameType(Level.Game);
	
	if (GameType == None)
	{
		return;
	}

	if (GameType.IsTestGameType())
	{
		GameTypeString = "Turbo Test Mode";
	}
	else if (GameType.IsHighDifficulty())
	{
		GameTypeString = "Turbo+ Game Mode";
	}
	else
	{
		if (IsPlayingCardGame())
		{
			GameTypeString = "Turbo Card Game Mode";
		}
		else if (IsPlayingRandomizer())
		{
			GameTypeString = "Turbo Randomizer Game Mode";
		}
		else if (IsPlayingHoldout())
		{
			GameTypeString = "Turbo Holdout Game Mode";
		}
		else
		{
			GameTypeString = "Turbo Game Mode";
		}
	}
	
	class'GameInfo'.static.AddServerDetail(ServerState, "Game Mode", ApplyGradientToString(GameTypeString));
}

function bool IsPlayingCardGame()
{
    return HasMutatorFromGroup("KF-CardGame");
}

function bool IsPlayingRandomizer()
{
    return HasMutatorFromGroup("KF-Randomizer");
}

function bool IsPlayingHoldout()
{
    return HasMutatorFromGroup("KF-Holdout");
}

function bool HasMutatorFromGroup(string GroupName)
{
    local Mutator Mutator;

	if (Level.Game == None)
	{
		return false;
	}

    for (Mutator = Level.Game.BaseMutator; Mutator != None; Mutator = Mutator.NextMutator)
    {
        if (Mutator.GroupName == GroupName)
        {
            return true;
        }
    }

    return false;
}

defaultproperties
{

}
