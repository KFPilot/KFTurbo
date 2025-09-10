//Killing Floor Turbo TurboVotingHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVotingHandler extends KFVotingHandler
	config(KFMapVote);

var globalconfig bool bCanSpectatorsMapVote; //If true, spectators can map vote.

var() config bool bDefaultToCurrentDifficulty;
var() config int CurrentDifficultyConfig;
var() config int DefaultDifficultyConfig;
var() config array<int> DifficultyConfig;

var bool bDecodeDuringSetupGameMap;

//Neither of these are replicated. Defined here 
var class<TurboMapVoteMessage> TurboMapVoteSubmitMessage; 
var class<TurboMapVoteMessage> TurboMapVoteCompleteMessage;
var class<TurboMapVoteMessage> TurboMapVoteAdminMessage; 

struct VoteTallyEntry
{
	var int MapIndex;
	var int GameConfig;
	var int VoteCount;
};

function PostBeginPlay()
{
	local int Index, Difficulty;
	Super.PostBeginPlay();

	if (bMapVote)
	{
		CurrentDifficultyConfig = 0;
		Difficulty = Level.Game.GameDifficulty;

		for (Index = 0; Index < DifficultyConfig.Length; Index++)
		{
			if (DifficultyConfig[Index] == Difficulty)
			{
				CurrentDifficultyConfig = Difficulty;
				break;
			}
		}
	}
}

function class<TurboVotingReplicationInfo> GetVotingReplicationInfoClass()
{
	return class'TurboVotingReplicationInfo';
}

function AddMapVoteReplicationInfo(PlayerController Player)
{
	local TurboVotingReplicationInfo VotingReplicationInfo;

	VotingReplicationInfo = Spawn(GetVotingReplicationInfoClass(), Player, , Player.Location);
	if (VotingReplicationInfo == None)
	{
		Log("___Failed to spawn VotingReplicationInfo", 'MapVote');
		return;
	}

	VotingReplicationInfo.PlayerID = Player.PlayerReplicationInfo.PlayerID;
	MVRI[MVRI.Length] = VotingReplicationInfo;
}

function SubmitMapVote(int MapIndex, int GameData, Actor Voter)
{
	local int VoteReplicationIndex;
	local int PreviousMapVote, PreviousGameVote;
	local int VoteCount;
	local int GameIndex, DifficultyIndex;

	if (bLevelSwitchPending)
	{
		return;
	}

	if (AdminForceMapChange(MapIndex, GameData, Voter))
	{
		return;
	}

	//Not sure why KFMapVoteV2 allows for spectator map voting by default.
	if (!bCanSpectatorsMapVote && PlayerController(Voter).PlayerReplicationInfo.bOnlySpectator)
	{
		PlayerController(Voter).ClientMessage(lmsgSpectatorsCantVote);
		return;
	}

	VoteReplicationIndex = GetMVRIIndex(PlayerController(Voter));

	if (VoteReplicationIndex == -1)
	{
		return;
	}

	Decode(GameData, GameIndex, DifficultyIndex);
    log("MapIndex: "$MapIndex$" GameConfig: "$GameIndex$" Difficulty: "$DifficultyIndex,'MapVoteDebug');

	if (MapIndex < 0 || MapIndex >= MapCount || GameIndex >= GameConfig.Length || (MVRI[VoteReplicationIndex].GameVote == GameData && MVRI[VoteReplicationIndex].MapVote == MapIndex) || !MapList[MapIndex].bEnabled)
	{
		return;
	}

	if (!IsValidVote(MapIndex, GameIndex))
	{
		return;
	}
	
	DifficultyIndex = GetCorrectedGameDifficulty(DifficultyIndex);
	GameData = Encode(GameIndex, DifficultyIndex); //Encode the GameData value again with a potentially corrected Game Difficulty.

	log("___" $ VoteReplicationIndex $ " - " $ PlayerController(Voter).PlayerReplicationInfo.PlayerName $ " voted for " $ MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ " - Difficulty " $ DifficultyIndex $ ")", 'MapVote');

	//Cache previous vote and update to new one.
	PreviousMapVote = MVRI[VoteReplicationIndex].MapVote;
	PreviousGameVote = MVRI[VoteReplicationIndex].GameVote;
	MVRI[VoteReplicationIndex].MapVote = MapIndex;
	MVRI[VoteReplicationIndex].GameVote = GameData;

	VoteCount = GetVoteCount(Voter);
	TurboMapVoteSubmitMessage.static.BroadcastMapVoteMessage(Level.Game, MapIndex, GameIndex, DifficultyIndex, PlayerController(Voter).PlayerReplicationInfo);

	UpdateVoteCount(MapIndex, GameData, VoteCount);

	//Previous vote has to be undone.
	if (PreviousMapVote > -1 && PreviousGameVote > -1)
	{
		UpdateVoteCount(PreviousMapVote, PreviousGameVote, -MVRI[VoteReplicationIndex].VoteCount);
	}

	MVRI[VoteReplicationIndex].VoteCount = VoteCount;
	TallyVotes(false);
}

function TallyVotes(bool bForceMapSwitch)
{
	local int OriginalNumPlayers;

	if (bCanSpectatorsMapVote)
	{
		OriginalNumPlayers = Level.Game.NumPlayers;
		Level.Game.NumPlayers += Level.Game.NumSpectators;
	}

	PerformVoteTally(bForceMapSwitch);
	
	if (bCanSpectatorsMapVote)
	{
		Level.Game.NumPlayers = OriginalNumPlayers;
	}
}

function bool IsValidVote(int MapIndex, int GameIndex)
{
	return Super.IsValidVote(MapIndex, GameIndex);
}

function string SetupGameMap(MapVoteMapList MapInfo, int GameData, MapHistoryInfo MapHistoryInfo)
{
	local int GameIndex, Difficulty;
	local string Result;

	if (bDecodeDuringSetupGameMap)
	{
		Decode(GameData, GameIndex, Difficulty);
	}
	else
	{
		GameIndex = GameData;
		Difficulty = GetCorrectedGameDifficulty(-1); //Give us whatever difficulty was configured to be the default.
	}

	Result = Super.SetupGameMap(MapInfo, GameIndex, MapHistoryInfo);

	if (InStr(Result, "?difficulty") == -1)
	{
		Result $= "?difficulty="$Difficulty;
	}

	return Result;
}

//Returns true if this was an admin forced map change vote.
function bool AdminForceMapChange(int MapIndex, int GameData, Actor Voter)
{
	local int GameIndex, Difficulty;
	if (GameData >= 0)
	{
		return false;
	}

	Decode(GameData, GameIndex, Difficulty);

	if (GameIndex >= GameConfig.Length || MapIndex < 0 || MapIndex >= MapList.Length)
	{
		return false;
	}

	if (!PlayerController(Voter).PlayerReplicationInfo.bAdmin && !PlayerController(Voter).PlayerReplicationInfo.bSilentAdmin)
	{
		return false;
	}

	TurboMapVoteAdminMessage.static.BroadcastMapVoteMessage(Level.Game, MapIndex, GameIndex, Difficulty, PlayerController(Voter).PlayerReplicationInfo);

	log("Admin has forced map switch to " $ MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")", 'MapVote');

	CloseAllVoteWindows();

	bLevelSwitchPending = true;
	bDecodeDuringSetupGameMap = true;
	ServerTravelString = SetupGameMap(MapList[MapIndex], GameData, History.PlayMap(MapList[MapIndex].MapName));
	bDecodeDuringSetupGameMap = false;
	log("ServerTravelString = " $ ServerTravelString, 'MapVoteDebug');

	Level.ServerTravel(ServerTravelString, false);

	SetTimer(1, true);
	return true;
}

function int GetVoteCount(Actor Voter)
{
	local int VoteCount;
	VoteCount = 0;

	if (bScoreMode)
	{
		VoteCount += Max(int(GetPlayerScore(PlayerController(Voter))), 1);
	}
	else
	{
		VoteCount += 1;
	}

	if (bAccumulationMode)
	{
		VoteCount += GetAccVote(PlayerController(Voter));
	}
	
	return Max(VoteCount, 1);
}

//Rewritten to not use an array of size (map list * game config * difficulty).
function PerformVoteTally(bool bForceMapSwitch)
{
	local int PlayerIndex;
	local VotingReplicationInfo PlayerVRI;
	local array<VoteTallyEntry> VoteTallyList;
	local array<int> RankingList;
	local int VoteTallyIndex;
	local bool bFoundEntry;
	local int Votes;
	local int PlayersThatVoted;
	local int TotalPossibleVoteCount, CurrentVoteCount;
	local int HighestVoteCount, HighestVoteIndex;
	
	local int TopTallyIndex;
	local int RankingIndex;
	local int TieCount;

	local int TempMapIndex, TempGameConfig, TempGameIndex, TempGameDifficulty;

	if (bLevelSwitchPending)
	{
		return;
	}

	HighestVoteCount = 0;
	HighestVoteIndex = -1;

	PlayersThatVoted = 0;
	TotalPossibleVoteCount = 0;
	CurrentVoteCount = 0;

	for (PlayerIndex = 0; PlayerIndex < MVRI.Length; PlayerIndex++)
	{
		PlayerVRI = MVRI[PlayerIndex];

		if (PlayerVRI == None)
		{
			continue;
		}

		Votes = GetVoteCount(PlayerVRI.PlayerOwner);
		TotalPossibleVoteCount += Votes;

		if (PlayerVRI.MapVote <= -1 || PlayerVRI.GameVote <= -1)
		{
			continue;
		}
		
		CurrentVoteCount += Votes;
		PlayersThatVoted++;

		bFoundEntry = false;
		for (VoteTallyIndex = 0; VoteTallyIndex < VoteTallyList.Length; VoteTallyIndex++)
		{
			if (PlayerVRI.MapVote != VoteTallyList[VoteTallyIndex].MapIndex || PlayerVRI.GameVote != VoteTallyList[VoteTallyIndex].GameConfig)
			{
				continue;
			}

			bFoundEntry = true;
			VoteTallyList[VoteTallyIndex].VoteCount += Votes;

			if (HighestVoteCount < VoteTallyList[VoteTallyIndex].VoteCount)
			{
				HighestVoteCount = VoteTallyList[VoteTallyIndex].VoteCount;
				HighestVoteIndex = VoteTallyIndex;
			}
			else if (HighestVoteCount == VoteTallyList[VoteTallyIndex].VoteCount)
			{
				HighestVoteCount = 0;
				HighestVoteIndex = -1;
			}
			break;
		}

		if (bFoundEntry)
		{
			continue;
		}

		VoteTallyIndex = VoteTallyList.Length;
		VoteTallyList.Length = VoteTallyList.Length + 1;
		VoteTallyList[VoteTallyIndex].MapIndex = PlayerVRI.MapVote;
		VoteTallyList[VoteTallyIndex].GameConfig = PlayerVRI.GameVote;
		VoteTallyList[VoteTallyIndex].VoteCount = Votes;

		if (HighestVoteCount < VoteTallyList[VoteTallyIndex].VoteCount)
		{
			HighestVoteCount = VoteTallyList[VoteTallyIndex].VoteCount;
			HighestVoteIndex = VoteTallyIndex;
		}
		else if (HighestVoteCount == VoteTallyList[VoteTallyIndex].VoteCount)
		{
			HighestVoteCount = 0;
			HighestVoteIndex = -1;
		}
	}

	TotalPossibleVoteCount = Max(TotalPossibleVoteCount, 1);

	if (Level.Game.bGameEnded)
	{
		if (Level.Game.NumPlayers >= 2 && HighestVoteIndex != -1 && (float(HighestVoteCount) / float(TotalPossibleVoteCount)) > 0.5f)
		{
			bForceMapSwitch = true;
		}
	}
	else
	{
		log("___Voted - " $ CurrentVoteCount $ " / " $ TotalPossibleVoteCount,'MapVoteDebug');

		if (Level.Game.NumPlayers >= 2 && !bMidGameVote && (float(CurrentVoteCount) / float(TotalPossibleVoteCount)) * 100 >= MidGameVotePercent)
		{
			Level.Game.Broadcast(self, lmsgMidGameVote);
			bMidGameVote = true;
			// Start voting count-down timer
			TimeLeft = VoteTimeLimit;
			ScoreBoardTime = 1;
			SetTimer(1, true);
		}
	}

	if (HighestVoteIndex != -1)
	{
		RankingList[0] = HighestVoteIndex;
	}
	else
	{
		for (VoteTallyIndex = 0; VoteTallyIndex < VoteTallyList.Length; VoteTallyIndex++)
		{
			bFoundEntry = false;
			for (RankingIndex = 0; RankingIndex < RankingList.Length; RankingIndex++)
			{
				if (VoteTallyList[RankingList[RankingIndex]].VoteCount < VoteTallyList[VoteTallyIndex].VoteCount)
				{
					RankingList.Insert(RankingIndex, 1);
					RankingList[RankingIndex] = VoteTallyIndex;
					bFoundEntry = true;
					break;
				}
			}

			if (bFoundEntry)
			{
				continue;
			}

			log("___Ranking - " $ VoteTallyIndex $ " / " $ (RankingList.Length + 1),'MapVoteDebug');
			RankingList[RankingList.Length] = VoteTallyIndex;
		}
	}

	if (PlayersThatVoted == 0 || RankingList.Length == 0)
	{
		GetDefaultMap(TempMapIndex, TempGameConfig);

		if (bDefaultToCurrentDifficulty || DifficultyConfig.Length <= CurrentDifficultyConfig)
		{
			TempGameConfig = Encode(TempGameConfig, InvasionGameReplicationInfo(Level.GRI).BaseDifficulty);
		}
		else
		{
			TempGameConfig = Encode(TempGameConfig, DifficultyConfig[0]);
		}

		TopTallyIndex = 0;
		VoteTallyList.Length = 1;
		VoteTallyList[0].MapIndex = TempMapIndex;
		VoteTallyList[0].GameConfig = TempGameConfig;
		VoteTallyList[0].VoteCount = 1;
	}
	else if (RankingList.Length > 1 && VoteTallyList[RankingList[0]].VoteCount == VoteTallyList[RankingList[1]].VoteCount && VoteTallyList[RankingList[0]].VoteCount != 0)
	{
		log("TIE BREAKING",'MapVoteDebug');
		TieCount = 1;
		for (RankingIndex = 1; RankingIndex < RankingList.Length; RankingIndex++)
		{
			if (VoteTallyList[RankingList[0]].VoteCount != VoteTallyList[RankingList[RankingIndex]].VoteCount)
			{
				break;
			}

			TieCount++;
		}

		TempMapIndex = Rand(TieCount);
		log(" - Time Count "$TieCount,'MapVoteDebug');
		log(" - Index "$TempMapIndex,'MapVoteDebug');
		TopTallyIndex = RankingList[Rand(TieCount)];
	}
	else
	{
		TopTallyIndex = RankingList[0];
	}

	if (bForceMapSwitch || (Level.Game.NumPlayers == PlayersThatVoted && Level.Game.NumPlayers > 0))
	{
		TempMapIndex = VoteTallyList[TopTallyIndex].MapIndex;
		TempGameConfig = VoteTallyList[TopTallyIndex].GameConfig;

		if (MapList[TempMapIndex].MapName == "")
		{
			return;
		}

		Decode(TempGameConfig, TempGameIndex, TempGameDifficulty);
		TurboMapVoteCompleteMessage.static.BroadcastMapVoteMessage(Level.Game, TempMapIndex, TempGameIndex, TempGameDifficulty);

		CloseAllVoteWindows();

		bDecodeDuringSetupGameMap = true;
		ServerTravelString = SetupGameMap(MapList[TempMapIndex], TempGameConfig, History.PlayMap(MapList[TempMapIndex].MapName));
		bDecodeDuringSetupGameMap = false;

		log("ServerTravelString = " $ ServerTravelString ,'MapVoteDebug');

		History.Save();

		if (bEliminationMode)
		{
			RepeatLimit++;
		}

		if (bAccumulationMode)
		{
			SaveAccVotes(TempMapIndex, TempGameIndex);
		}

		CurrentGameConfig = TempGameIndex;
		CurrentDifficultyConfig = TempGameDifficulty;
		
		if (!bAutoDetectMode)
		{
			SaveConfig();
		}

		bLevelSwitchPending = true;
		SetTimer(Level.TimeDilation, true);

		Level.ServerTravel(ServerTravelString, false);
	}
}

function GetDefaultMap(out int MapIndex, out int GameIndex)
{
	Super.GetDefaultMap(MapIndex, GameIndex);
}

static final function int Encode(int GameIndex, int GameDifficulty)
{
	return (GameDifficulty & 15) | (GameIndex << 4);
}

static final function Decode(int GameConfig, out int GameIndex, out int GameDifficulty)
{
	GameIndex = (GameConfig >> 4);
	GameDifficulty = GameConfig & 15;
}

function int GetCorrectedGameDifficulty(int GameDifficulty)
{
	local int Index;
	for (Index = 0; Index < DifficultyConfig.Length; Index++)
	{
		if (DifficultyConfig[Index] == GameDifficulty)
		{
			return GameDifficulty;
		}
	}

	if (bDefaultToCurrentDifficulty)
	{
		return CurrentDifficultyConfig;
	}

	return DefaultDifficultyConfig;
}

defaultproperties
{
	MapListLoaderType="KFTurboMapVote.TurboMapListLoader"
	bCanSpectatorsMapVote=false
	bDefaultToCurrentDifficulty=true
	bDecodeDuringSetupGameMap=false
	

	TurboMapVoteSubmitMessage=class'TurboMapVoteSubmitMessage'
	TurboMapVoteCompleteMessage=class'TurboMapVoteCompleteMessage'
	TurboMapVoteAdminMessage=class'TurboMapVoteAdminMessage'
}