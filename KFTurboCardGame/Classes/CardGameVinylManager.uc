//Killing Floor Turbo CardGameVinylManager
//Manages vinyl spawning during trader time. Each alive player receives their own set of vinyl actors,
//only relevant to them. Sets are spawned one player per tick to spread out the spawn cost.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardGameVinylManager extends KFTurbo.TurboWaveEventHandler;

var KFTurboCardGameMut Mutator;
var array< class<CardGameVinylLabel> > VinylLabelList; //Labels vinyls are selected from.

//Map of labels for each rarity.
struct LabelList
{
    var array< class<CardGameVinylLabel> > LabelList;
    var array< CardGameVinylLabel> LabelInstanceList;
};
const MAX_RARITY = 5;
var LabelList LabelRarityMap[MAX_RARITY];

//Distribution of rarities for each rarity (for a given wave).
struct Weight
{
    var float Weight;
};
struct LabelRarityDistribution
{
    var float TotalWeight; //Cached total weight of RarityWeightList. Do not mutate this at runtime.
    var Weight RarityWeightList[MAX_RARITY];
};
const MAX_WAVE = 14;
var LabelRarityDistribution WaveRarityDistributionMap[MAX_WAVE];

var array<CardGameVinylLabel> VinylLabelInstanceList; //Spawned label instances - their vinyls have activation delegates bound.
var int VinylSpawnCount; //Number of vinyls offered to each player during trader time.
var float VinylSpawnSearchRadius; //Radius around the shop to search for fallback path node spawn locations.
var array<CardGameVinylActor> ActiveVinylList;
var int VinylsDestroyedPerTick; //How many vinyls the DestroyingVinyls state destroys each tick.

//Deferred work state.
var ShopVolume PendingSpawnShop; //Shop the next spawn cycle uses. Set by RequestVinylSpawn, consumed by SpawningVinyls.
var int PendingSpawnWave; //Wave the next spawn cycle selects rarities for.
var array<TurboHumanPawn> PendingSpawnPlayerList;
var array<Vector> SpawnLocationList;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Mutator = KFTurboCardGameMut(Owner);

	OnGameStarted = GameStarted;
	OnWaveStarted = WaveStarted;
	OnWaveEnded = WaveEnded;

	CacheWaveRarityTotalWeights();
	InitializeVinylLabels();
}

final function CacheWaveRarityTotalWeights()
{
	local int WaveIndex, RarityIndex;

	for (WaveIndex = 0; WaveIndex < MAX_WAVE; WaveIndex++)
	{
		WaveRarityDistributionMap[WaveIndex].TotalWeight = 0.f;

		for (RarityIndex = 0; RarityIndex < MAX_RARITY; RarityIndex++)
		{
			WaveRarityDistributionMap[WaveIndex].TotalWeight += WaveRarityDistributionMap[WaveIndex].RarityWeightList[RarityIndex].Weight;
		}
	}
}

//Prototype - offer vinyls at a random trader during the first vote round.
final function GameStarted(KFTurboGameType GameType, int StartedWave)
{
	if (GameType.ShopList.Length == 0)
	{
		return;
	}

	RequestVinylSpawn(GameType.ShopList[Rand(GameType.ShopList.Length)], StartedWave);
}

final function WaveStarted(KFTurboGameType GameType, int StartedWave)
{
	RequestVinylDestroy();
}

final function WaveEnded(KFTurboGameType GameType, int EndedWave)
{
	if (GameType.FinalWave <= EndedWave)
	{
		return;
	}

	if (KFGameReplicationInfo(Level.GRI) == None)
	{
		return;
	}

	//This trader time precedes the wave after the one that just ended.
	RequestVinylSpawn(KFGameReplicationInfo(Level.GRI).CurrentShop, EndedWave + 1);
}

//Destroys any active vinyls, then spawns a fresh set for every alive player at the given shop.
function RequestVinylSpawn(ShopVolume Shop, int Wave)
{
	if (Shop == None)
	{
		return;
	}

	PendingSpawnShop = Shop;
	PendingSpawnWave = Clamp(Wave, 0, MAX_WAVE - 1);
	GotoState('DestroyingVinyls');
}

//Destroys any active vinyls and cancels a pending spawn.
function RequestVinylDestroy()
{
	PendingSpawnShop = None;
	GotoState('DestroyingVinyls');
}

function InitializeVinylLabels()
{
	local CardGameVinylLabel Label;
	local CardGameVinylLabel.ELabelRarity Rarity;
	local int Index;

	if (VinylLabelInstanceList.Length != 0)
	{
		return;
	}

	for (Index = 0; Index < VinylLabelList.Length; Index++)
	{
		Label = Spawn(VinylLabelList[Index], Self);

		if (Label == None)
		{
			continue;
		}

		Label.InitializeLabel();
		VinylLabelInstanceList[VinylLabelInstanceList.Length] = Label;

		//Sort the label into the rarity map.
		Rarity = VinylLabelList[Index].default.LabelRarity;
		LabelRarityMap[Rarity].LabelList[LabelRarityMap[Rarity].LabelList.Length] = VinylLabelList[Index];
		LabelRarityMap[Rarity].LabelInstanceList[LabelRarityMap[Rarity].LabelInstanceList.Length] = Label;
	}
}

function bool SelectVinylRarity(int Wave, out CardGameVinylLabel.ELabelRarity OutRarity)
{
	local float Roll;
	local int RarityIndex;
	local bool bFoundWeightedRarity;

	Wave = Clamp(Wave, 0, MAX_WAVE - 1);

	if (WaveRarityDistributionMap[Wave].TotalWeight <= 0.f)
	{
		return false;
	}

	Roll = FRand() * WaveRarityDistributionMap[Wave].TotalWeight;

	for (RarityIndex = 0; RarityIndex < MAX_RARITY; RarityIndex++)
	{
		if (WaveRarityDistributionMap[Wave].RarityWeightList[RarityIndex].Weight <= 0.f)
		{
			continue;
		}

		OutRarity = ELabelRarity(RarityIndex);
		bFoundWeightedRarity = true;

		Roll -= WaveRarityDistributionMap[Wave].RarityWeightList[RarityIndex].Weight;

		if (Roll < 0.f)
		{
			return true;
		}
	}

	return bFoundWeightedRarity;
}

state SpawningVinyls
{
	function BeginState()
	{
		InitializeVinylLabels();

		SpawnLocationList.Length = 0;

		if (VinylLabelInstanceList.Length != 0 && PendingSpawnShop != None)
		{
			GatherVinylSpawnLocations(PendingSpawnShop, SpawnLocationList);
		}

		PendingSpawnShop = None;

		if (SpawnLocationList.Length == 0)
		{
			GotoState('');
			return;
		}

		PendingSpawnPlayerList = class'TurboGameplayHelper'.static.GetPlayerPawnList(Level);

		if (PendingSpawnPlayerList.Length == 0)
		{
			GotoState('');
			return;
		}

		Enable('Tick');
	}

	function EndState()
	{
		PendingSpawnPlayerList.Length = 0;
		Disable('Tick');
	}

	function Tick(float DeltaTime)
	{
		local TurboHumanPawn Player;

		Player = PendingSpawnPlayerList[PendingSpawnPlayerList.Length - 1];
		PendingSpawnPlayerList.Length = PendingSpawnPlayerList.Length - 1;

		//Skip players that died or left after being collected.
		if (Player != None && Player.Health > 0)
		{
			SpawnVinylsForPlayer(PlayerController(Player.Controller));
		}

		if (PendingSpawnPlayerList.Length == 0)
		{
			GotoState('');
		}
	}
}

//Destroys a few vinyls every tick until none remain, then starts a pending spawn cycle (if any).
state DestroyingVinyls
{
	function BeginState()
	{
		Enable('Tick');
	}

	function EndState()
	{
		Disable('Tick');
	}

	function Tick(float DeltaTime)
	{
		local int Count;

		for (Count = 0; Count < VinylsDestroyedPerTick && ActiveVinylList.Length > 0; Count++)
		{
			if (ActiveVinylList[ActiveVinylList.Length - 1] != None)
			{
				ActiveVinylList[ActiveVinylList.Length - 1].Destroy();
			}

			ActiveVinylList.Length = ActiveVinylList.Length - 1;
		}

		if (ActiveVinylList.Length > 0)
		{
			return;
		}

		if (PendingSpawnShop != None)
		{
			GotoState('SpawningVinyls');
		}
		else
		{
			GotoState('');
		}
	}
}

function SpawnVinylsForPlayer(PlayerController Player)
{
	local array<CardGameVinylLabel> LabelList;
	local CardGameVinylLabel.ELabelRarity Rarity;
	local TurboVinyl Vinyl;
	local CardGameVinylActor VinylActor;
	local int Index, LabelIndex;

	for (Index = 0; Index < SpawnLocationList.Length; Index++)
	{
		if (!SelectVinylRarity(PendingSpawnWave, Rarity))
		{
			continue;
		}

		LabelList = LabelRarityMap[Rarity].LabelInstanceList;
		Vinyl = None;

		while (Vinyl == None && LabelList.Length > 0)
		{
			LabelIndex = Rand(LabelList.Length);

			if (LabelList[LabelIndex] != None)
			{
				Vinyl = LabelList[LabelIndex].GetRandomVinyl(Player);
			}

			LabelList.Remove(LabelIndex, 1);
		}

		if (Vinyl == None)
		{
			continue;
		}

		//Owned by the player so the actor is only relevant to them.
		VinylActor = Spawn(class'CardGameVinylActor', Player,, SpawnLocationList[Index]);

		if (VinylActor != None)
		{
			VinylActor.SetVinyl(Vinyl);
			ActiveVinylList[ActiveVinylList.Length] = VinylActor;
		}
	}
}

//Prefers a row in front of the shop's first exit teleporter. Falls back to path nodes near the shop.
function GatherVinylSpawnLocations(ShopVolume Shop, out array<Vector> OutSpawnLocationList)
{
	local Vector X, Y, Z;
	local int Index;

	Shop.InitTeleports();

	if (Shop.TelList.Length > 0 && Shop.TelList[0] != None)
	{
		GetAxes(Shop.TelList[0].Rotation, X, Y, Z);

		for (Index = 0; Index < VinylSpawnCount; Index++)
		{
			OutSpawnLocationList[OutSpawnLocationList.Length] = Shop.TelList[0].Location + (X * 100.f) + (Y * ((float(Index) - (float(VinylSpawnCount - 1) * 0.5f)) * 120.f));
		}

		return;
	}

	GatherPathNodeSpawnLocations(Shop, OutSpawnLocationList);
}

//Fallback - use the path nodes closest to the shop that aren't inside of it.
function GatherPathNodeSpawnLocations(ShopVolume Shop, out array<Vector> OutSpawnLocationList)
{
	local PathNode PathNode;
	local array<PathNode> NodeList;
	local array<float> NodeDistanceList;
	local float Distance;
	local int Index;

	foreach RadiusActors(class'PathNode', PathNode, VinylSpawnSearchRadius, Shop.Location)
	{
		if (Shop.Encompasses(PathNode))
		{
			continue;
		}

		Distance = VSize(PathNode.Location - Shop.Location);

		for (Index = 0; Index < NodeList.Length; Index++)
		{
			if (Distance < NodeDistanceList[Index])
			{
				break;
			}
		}

		NodeList.Insert(Index, 1);
		NodeList[Index] = PathNode;
		NodeDistanceList.Insert(Index, 1);
		NodeDistanceList[Index] = Distance;
	}

	for (Index = 0; Index < Min(NodeList.Length, VinylSpawnCount); Index++)
	{
		OutSpawnLocationList[OutSpawnLocationList.Length] = NodeList[Index].Location;
	}
}

defaultproperties
{
	VinylLabelList(0)=class'VinylLabelAdvancedGenetics'
	VinylLabelList(1)=class'VinylLabelClassic'
	VinylLabelList(2)=class'VinylLabelHorzine'
	VinylLabelList(3)=class'VinylLabelBedlam'
	VinylLabelList(4)=class'VinylLabelSirensBelch'
	VinylLabelList(5)=class'VinylLabelWestLondon'
	VinylLabelList(6)=class'VinylLabelBiohazard'
	VinylSpawnCount=3
	VinylSpawnSearchRadius=1200.f
	VinylsDestroyedPerTick=3

	WaveRarityDistributionMap(0)=(RarityWeightList=(Weight=1.00f,Weight=0.00f,Weight=0.00f,Weight=0.00f,Weight=0.00f))
	WaveRarityDistributionMap(1)=(RarityWeightList=(Weight=0.80f,Weight=0.20f,Weight=0.00f,Weight=0.00f,Weight=0.00f))
	WaveRarityDistributionMap(2)=(RarityWeightList=(Weight=0.60f,Weight=0.40f,Weight=0.00f,Weight=0.00f,Weight=0.00f))
	WaveRarityDistributionMap(3)=(RarityWeightList=(Weight=0.40f,Weight=0.60f,Weight=0.00f,Weight=0.00f,Weight=0.00f))
	WaveRarityDistributionMap(4)=(RarityWeightList=(Weight=0.20f,Weight=0.80f,Weight=0.00f,Weight=0.00f,Weight=0.00f))
	WaveRarityDistributionMap(5)=(RarityWeightList=(Weight=0.00f,Weight=0.80f,Weight=0.10f,Weight=0.00f,Weight=0.00f)) //No more commons!
	WaveRarityDistributionMap(6)=(RarityWeightList=(Weight=0.00f,Weight=0.60f,Weight=0.20f,Weight=0.00f,Weight=0.00f))
	WaveRarityDistributionMap(7)=(RarityWeightList=(Weight=0.00f,Weight=0.40f,Weight=0.40f,Weight=0.00f,Weight=0.00f))
	WaveRarityDistributionMap(8)=(RarityWeightList=(Weight=0.00f,Weight=0.30f,Weight=0.50f,Weight=0.02f,Weight=0.00f))
	WaveRarityDistributionMap(9)=(RarityWeightList=(Weight=0.00f,Weight=0.20f,Weight=0.60f,Weight=0.04f,Weight=0.01f))
	WaveRarityDistributionMap(10)=(RarityWeightList=(Weight=0.00f,Weight=0.10f,Weight=0.70f,Weight=0.08f,Weight=0.02f))
	WaveRarityDistributionMap(11)=(RarityWeightList=(Weight=0.00f,Weight=0.05f,Weight=0.60f,Weight=0.10f,Weight=0.03f))
	WaveRarityDistributionMap(12)=(RarityWeightList=(Weight=0.00f,Weight=0.00f,Weight=0.60f,Weight=0.12f,Weight=0.04f))
	WaveRarityDistributionMap(13)=(RarityWeightList=(Weight=0.00f,Weight=0.00f,Weight=0.60f,Weight=0.14f,Weight=0.05f))
}
