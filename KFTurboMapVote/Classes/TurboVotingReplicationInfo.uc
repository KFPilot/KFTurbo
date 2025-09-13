//Killing Floor Turbo TurboVotingReplicationInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVotingReplicationInfo extends KFVotingReplicationInfo
	config(KFMapVote);

var class<TurboVotingHandler> TurboVotingHandlerClass;
var TurboVotingHandler TurboVotingHandler;

var float NextQueueSendTime;
var int PendingAckSendCount; //Number of sent voting data that has yet to be acknowledged.

struct MapVoteDifficultyConfig
{
	var int DifficultyIndex;
};

var array<MapVoteDifficultyConfig> GameDifficultyConfig;
var int GameDifficultyCount;
var int CurrentDifficultyConfig;
struct DifficultyConfigTickedReplication
{
	var int Index;
	var int Last;
};
var DifficultyConfigTickedReplication DifficultyTickedReplicationQueue;

var globalconfig bool bBatchMapListData; //Enables MapInfo batching.
var globalconfig int MaxBatchCount; //Max number of MapInfos to try to fit in MaxBatchSizeBytes.
var globalconfig int MaxBatchSizeBytes; //Maximum size a batch payload can be. This really shouldn't be anywhere close to 512 (max packet size).

var string BatchMapDataFormat;

//Assumed worst case size of a MapVoteMapList entry in a MapInfoBatch.
// PlayCount - 8
// Sequence - 8
// bEnabled - 8
// Rep Positive - 8
// Rep Negative - 8
// Encoding Overhead - 8
const MAPINFO_SIZE_BYTES = 48;

struct MapInfoBatch
{
	var string Data;
};
replication
{
	reliable if (Role == ROLE_Authority && bNetInitial)
		TurboVotingHandlerClass, GameDifficultyCount, CurrentDifficultyConfig;
	reliable if (Role == ROLE_Authority && bMapVote)
		ReceiveMapInfoBatch, ReceiveDifficulty;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Role == ROLE_Authority)
	{
		MaxBatchSizeBytes = Min(MaxBatchSizeBytes, 400); //Safety to prevent this from being set too high.
		TurboVotingHandler = TurboVotingHandler(VH);
		TurboVotingHandlerClass = TurboVotingHandler.Class;
	}
}

simulated function GetServerData()
{
	if (Level.NetMode == NM_Client)
	{
		return;
	}

	Super.GetServerData();
	GameDifficultyCount = TurboVotingHandler.DifficultyConfig.Length;
	CurrentDifficultyConfig = TurboVotingHandler.CurrentDifficultyConfig;
	SetupDifficultyTickedReplication(GameDifficultyCount);
}

simulated final function InitTurboClient()
{
	local PlayerController PC;

	bClientHasInit = true;
	PC = Level.GetLocalPlayerController();
	if (PC != None)
	{
		class'TurboMapVoteInteraction'.Static.AddVotingReplacement(PC);
	}
}

simulated function Tick(float DeltaTime)
{
	local int i;
	local bool bDedicated, bListening;
	local bool bWasBatched;
	
	if (!bClientHasInit)
	{
		InitTurboClient();
	}

	if (!bBatchMapListData)
	{
		Super.Tick(DeltaTime);
		return;
	}

	if (TickedReplicationQueue.Length == 0)
	{
		return;
	}

	//Consume bWaitingForReply and convert it into a time delay.
	if (bWaitingForReply)
	{
		bWaitingForReply = false;
		NextQueueSendTime = Level.TimeSeconds + 0.1f;

		if (bSendingMatchSetup && TickedReplicationQueue.Length == 0)
		{
			SendClientResponse(StatusID, CompleteID);
			bSendingMatchSetup = false;
		}
		return;
	}

	if (NextQueueSendTime > Level.TimeSeconds)
	{
		return;
	}

	bDedicated = Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && PlayerOwner != None && PlayerOwner.Player.Console == None);
  	bListening = Level.NetMode == NM_ListenServer && PlayerOwner != None && PlayerOwner.Player.Console != None;

	if (!bDedicated && !bListening)
	{
		return;
	}

	if (bDedicated && PendingAckSendCount > 5)
	{
		return;
	}

	if (DifficultyTickedReplicationQueue.Index < DifficultyTickedReplicationQueue.Last)
	{
		TickedReplication_DifficultyList(DifficultyTickedReplicationQueue.Index, bDedicated);
		DifficultyTickedReplicationQueue.Index++;
		PendingAckSendCount++;
		return;
	}

	i = TickedReplicationQueue.Length - 1;

	bWasBatched = false;
	switch (TickedReplicationQueue[i].DataType)
	{
		case REPDATATYPE_GameConfig:
			TickedReplication_GameConfig(TickedReplicationQueue[i].Index, bDedicated);
 			break;
		//Try to batch these...
		case REPDATATYPE_MapList:
			if (bBatchMapListData)
			{
				TickedReplicationQueue[i].Index += TickedReplication_BatchMapList(TickedReplicationQueue[i].Index, TickedReplicationQueue[i].Last, bDedicated);
				bWasBatched = true;
			}
			else
			{
				TickedReplication_MapList(TickedReplicationQueue[i].Index, bDedicated);
			}
			break;
		case REPDATATYPE_MapVoteCount:
			TickedReplication_MapVoteCount(TickedReplicationQueue[i].Index, bDedicated);
			break;
		case REPDATATYPE_KickVoteCount:
			TickedReplication_KickVoteCount(TickedReplicationQueue[i].Index, bDedicated);
			break;
		case REPDATATYPE_MatchConfig:
			TickedReplication_MatchConfig(TickedReplicationQueue[i].Index, bDedicated);
			break;
		case REPDATATYPE_Maps:
			TickedReplication_Maps(TickedReplicationQueue[i].Index, bDedicated);
			break;
		case REPDATATYPE_Mutators:
			TickedReplication_Mutators(TickedReplicationQueue[i].Index, bDedicated);
			break;
	}

	if (!bWasBatched)
	{
		TickedReplicationQueue[i].Index++;
	}

	//Track the number of options we've sent so we can track how many unacknowledged sends have occurred.
	PendingAckSendCount++;
	
	if (TickedReplicationQueue[i].Index > TickedReplicationQueue[i].Last)
	{
		TickedReplicationQueue.Remove(i, 1);
	}
}

function SetupDifficultyTickedReplication(int Last)
{
	DifficultyTickedReplicationQueue.Last = Last;
}

function TickedReplication_DifficultyList(int Index, bool bDedicated)
{
	DebugLog("___Sending Difficulty" $ Index $ " - " $ TurboVotingHandler.DifficultyConfig[Index]);

	if (bDedicated)
	{
		ReceiveDifficulty(TurboVotingHandler.DifficultyConfig[Index]);
		bWaitingForReply = True;
	}
	else
	{
		GameDifficultyConfig.Length = GameDifficultyConfig.Length + 1;
		GameDifficultyConfig[GameDifficultyConfig.Length - 1].DifficultyIndex = TurboVotingHandler.DifficultyConfig[Index];
	}
}

simulated function ReceiveDifficulty(int Difficulty)
{
	DebugLog("___Difficulty Received: "$Difficulty);
	GameDifficultyConfig.Length = GameDifficultyConfig.Length + 1;
	GameDifficultyConfig[GameDifficultyConfig.Length - 1].DifficultyIndex = Difficulty;

	ReplicationReply();
}

function int TickedReplication_BatchMapList(int Index, int Last, bool bDedicated)
{
 	local array<VotingHandler.MapVoteMapList> MapInfoList;
 	local array<KFVotingHandler.FMapRepType> MapRepList;
	local VotingHandler.MapVoteMapList MapInfo;
	local int BatchIndex;
	local int CountedBytes;

	BatchIndex = 0;

	MapInfoList[BatchIndex] = TurboVotingHandler.GetMapList(Index);
	MapRepList[BatchIndex] = TurboVotingHandler.RepArray[Index];
	CountedBytes += MAPINFO_SIZE_BYTES + (Len(MapInfoList[BatchIndex].MapName) * 4); //Assumes worst case for UTF8 map name - 4 bytes per character.

	DebugLog("___Batch Sending ");
	DebugLog("___ - " $ Index + BatchIndex $ " - " $ MapInfoList[BatchIndex].MapName);
	while (MapInfoList.Length < MaxBatchCount)
	{
		BatchIndex++;
		if (Index + BatchIndex >= Last)
		{
			break;
		}

		MapInfo = TurboVotingHandler.GetMapList(Index + BatchIndex);
		CountedBytes += MAPINFO_SIZE_BYTES + (Len(MapInfo.MapName) * 4);
		if (CountedBytes > MaxBatchSizeBytes)
		{
			break;
		}

		MapInfoList[BatchIndex] = MapInfo;
		MapRepList[BatchIndex] = TurboVotingHandler.RepArray[Index + BatchIndex];
		DebugLog("___ - " $ Index + BatchIndex $ " - " $ MapInfoList[BatchIndex].MapName);
	}

	if (bDedicated)
	{
		ReceiveMapInfoBatch(EncodeMapInfoBatch(MapInfoList, MapRepList));
		bWaitingForReply = True;
	}
	else
	{
		for (BatchIndex = 0; BatchIndex < MapInfoList.Length; BatchIndex++)
		{
			MapList[MapList.Length] = MapInfoList[BatchIndex];
			InitRepStr(MapList.Length - 1, TurboVotingHandler.RepArray[Index]);
		}
	}

	return MapInfoList.Length;
}

simulated function ReceiveMapInfo(VotingHandler.MapVoteMapList MapInfo)
{
	Super.ReceiveMapInfo(MapInfo);
}

simulated function ReceiveMapInfoBatch(MapInfoBatch MapInfoBatch)
{
	local int Index;
	local array<VotingHandler.MapVoteMapList> MapInfoList;
	local array<KFVotingHandler.FMapRepType> MapRepList;
	DecodeMapInfoBatch(MapInfoBatch, MapInfoList, MapRepList);

	DebugLog("___Batch Receiving: ");
	for (Index = 0; Index < MapInfoList.Length; Index++)
	{
		MapList[MapList.Length] = MapInfoList[Index];
		InitRepStr(MapList.Length - 1, MapRepList[Index]);
		DebugLog("___ - " $ MapInfoList[Index].MapName);
	}

	ReplicationReply();
}

static function MapInfoBatch EncodeMapInfoBatch(array<VotingHandler.MapVoteMapList> InMapInfoList,  array<KFVotingHandler.FMapRepType> InMapRepList)
{
	local int Index;
	local MapInfoBatch Batch;
	for (Index = 0; Index < InMapInfoList.Length; Index++)
	{
		if (Index > 0)
		{
			Batch.Data $= "," $ Repl(Repl(Repl(Repl(Repl(Repl(default.BatchMapDataFormat, "%m", InMapInfoList[Index].MapName),
				"%p", class'TurboEncodingHelper'.static.IntToHex(InMapInfoList[Index].PlayCount)),
				"%s", class'TurboEncodingHelper'.static.IntToHex(InMapInfoList[Index].Sequence)),
				"%e", Eval(InMapInfoList[Index].bEnabled, "1", "0")),
				"%rp", class'TurboEncodingHelper'.static.IntToHex(InMapRepList[Index].Positive)),
				"%rn", class'TurboEncodingHelper'.static.IntToHex(InMapRepList[Index].Negative));
		}
		else
		{
			Batch.Data = Repl(Repl(Repl(Repl(Repl(Repl(default.BatchMapDataFormat, "%m", InMapInfoList[Index].MapName),
				"%p", class'TurboEncodingHelper'.static.IntToHex(InMapInfoList[Index].PlayCount)),
				"%s", class'TurboEncodingHelper'.static.IntToHex(InMapInfoList[Index].Sequence)),
				"%e", Eval(InMapInfoList[Index].bEnabled, "1", "0")),
				"%rp", class'TurboEncodingHelper'.static.IntToHex(InMapRepList[Index].Positive)),
				"%rn", class'TurboEncodingHelper'.static.IntToHex(InMapRepList[Index].Negative));
		}
	}

	return Batch;
}

static function DecodeMapInfoBatch(MapInfoBatch InMapInfoBatch, out array<VotingHandler.MapVoteMapList> MapVoteList, out array<KFVotingHandler.FMapRepType> MapRepList)
{
	local int Index;
	local array<string> EntryList;
	local array<string> ItemList;
	local VotingHandler.MapVoteMapList Entry;
	local KFVotingHandler.FMapRepType Rep;
	
	MapVoteList.Length = 0;
	Split(InMapInfoBatch.Data, ",", EntryList);

	for (Index = 0; Index < EntryList.Length; Index++)
	{
		Split(EntryList[Index], "|", ItemList);
		Entry.MapName = ItemList[0];
		Entry.PlayCount = class'TurboEncodingHelper'.static.HexToInt(ItemList[1]);
		Entry.Sequence = class'TurboEncodingHelper'.static.HexToInt(ItemList[2]);
		Entry.bEnabled = ItemList[3] == "1";
		MapVoteList[MapVoteList.Length] = Entry;

		Rep.Positive = class'TurboEncodingHelper'.static.HexToInt(ItemList[4]);
		Rep.Negative = class'TurboEncodingHelper'.static.HexToInt(ItemList[5]); 
		MapRepList[MapRepList.Length] = Rep;
	}
}

function ReplicationReply()
{
	PendingAckSendCount = Max(PendingAckSendCount - 1, 0);

	Super.ReplicationReply();
}

function SendMapVote(int MapIndex, int p_GameIndex)
{
	DebugLog("MVRI.SendMapVote(" $ MapIndex $ ", " $ p_GameIndex $ ")");
	VH.SubmitMapVote(MapIndex,p_GameIndex,Owner);
}

simulated function string GetDifficultyName(int Difficulty)
{
	if (TurboVotingHandlerClass == None || TurboVotingHandlerClass.default.TurboMapVoteSubmitMessage == None)
	{
		return class'TurboMapVoteMessage'.static.ResolveDifficultyName(Difficulty);
	}

	return TurboVotingHandlerClass.default.TurboMapVoteSubmitMessage.static.ResolveDifficultyName(Difficulty);
}

simulated function OpenWindow()
{
	if (GetController().FindMenuByClass(Class'TurboMapVotingPage') == None)
	{
		GetController().OpenMenu(string(Class'TurboMapVotingPage'));
		GetController().OpenMenu(string(Class'MVLikePage'));
	}
}

defaultproperties
{
	bDebugLog=false

	TurboVotingHandlerClass=class'TurboVotingHandler'

	bBatchMapListData=true
	MaxBatchCount=5
	MaxBatchSizeBytes=320

	BatchMapDataFormat="%m|%p|%s|%e|%rp|%rn"
}