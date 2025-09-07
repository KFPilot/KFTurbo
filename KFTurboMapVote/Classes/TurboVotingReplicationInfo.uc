//Killing Floor Turbo TurboVotingReplicationInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVotingReplicationInfo extends KFVotingReplicationInfo
	config(KFMapVote);

var TurboVotingHandler TurboVotingHandler;

var globalconfig bool bBatchMapListData; //Enables MapInfo batching.
var globalconfig int MaxBatchCount; //Max number of MapInfos to try to fit in MaxBatchSizeBytes.
var globalconfig int MaxBatchSizeBytes; //Maximum size a batch payload can be. This really shouldn't be anywhere close to 512 (max packet size).

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
	reliable if(Role == ROLE_Authority && bMapVote)
		ReceiveMapInfoBatch;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	MaxBatchSizeBytes = Min(MaxBatchSizeBytes, 400); //Safety to prevent this from being set too high.
	TurboVotingHandler = TurboVotingHandler(VH);
}

simulated function Tick(float DeltaTime)
{
	local int i;
	local bool bDedicated, bListening;
	local bool bWasBatched;
	
	if (!bClientHasInit)
	{
		InitClient();
	}

	if (!bBatchMapListData)
	{
		Super.Tick(DeltaTime);
		return;
	}

	if (TickedReplicationQueue.Length == 0 || bWaitingForReply)
	{
		return;
	}

	bDedicated = Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && PlayerOwner != None && PlayerOwner.Player.Console == None);
  	bListening = Level.NetMode == NM_ListenServer && PlayerOwner != None && PlayerOwner.Player.Console != None;

	if (!bDedicated && !bListening)
	{
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
	
	if( TickedReplicationQueue[i].Index > TickedReplicationQueue[i].Last )
		TickedReplicationQueue.Remove(i,1);
}

function TickedReplication_MapList(int Index, bool bDedicated)
{
	Super.TickedReplication_MapList(Index, bDedicated);
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

static final function MapInfoBatch EncodeMapInfoBatch(array<VotingHandler.MapVoteMapList> InMapInfoList,  array<KFVotingHandler.FMapRepType> InMapRepList)
{
	local int Index;
	local MapInfoBatch Batch;
	for (Index = 0; Index < InMapInfoList.Length; Index++)
	{
		if (Index > 0)
		{
			Batch.Data $= "," $ InMapInfoList[Index].MapName $
				"|" $ class'TurboEncodingHelper'.static.IntToHex(InMapInfoList[Index].PlayCount) $
				"|"$ class'TurboEncodingHelper'.static.IntToHex(InMapInfoList[Index].Sequence) $
				"|"$ Eval(InMapInfoList[Index].bEnabled, "1", "0") $
				"|" $ class'TurboEncodingHelper'.static.IntToHex(InMapInfoList[Index].PlayCount) $
				"|"$ class'TurboEncodingHelper'.static.IntToHex(InMapInfoList[Index].Sequence);
		}
		else
		{
			Batch.Data $= InMapInfoList[Index].MapName $
				"|" $ class'TurboEncodingHelper'.static.IntToHex(InMapInfoList[Index].PlayCount) $
				"|"$ class'TurboEncodingHelper'.static.IntToHex(InMapInfoList[Index].Sequence) $
				"|"$ Eval(InMapInfoList[Index].bEnabled, "1", "0") $
				"|" $ class'TurboEncodingHelper'.static.IntToHex(InMapRepList[Index].Positive) $
				"|"$ class'TurboEncodingHelper'.static.IntToHex(InMapRepList[Index].Negative);
		}
	}

	return Batch;
}

static final function DecodeMapInfoBatch(MapInfoBatch InMapInfoBatch, out array<VotingHandler.MapVoteMapList> MapVoteList, out array<KFVotingHandler.FMapRepType> MapRepList)
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

defaultproperties
{
	bBatchMapListData=true
	MaxBatchCount=5
	MaxBatchSizeBytes=320
}