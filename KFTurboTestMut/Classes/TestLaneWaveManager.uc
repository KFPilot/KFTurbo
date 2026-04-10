class TestLaneWaveManager extends Info
	dependson(PawnHelper)
	hidecategories(Advanced,Force,Karma,LightColor,Lighting,Sound,UseTrigger)
	placeable;

var(LaneManager) editinline TurboMonsterCollectionWaveBase TurboMonsterCollection;

var(LaneManager) Name VolumeTag;
var array<ZombieVolume> VolumeList;

var bool bIsActive;
var int WaveNumber;
var int PlayerCount;
var int PlayerHealth;

//Properties that need to be reset when we start a wave.
var int TotalMonsters, MaxMonsters, RemainingMaxMonsters;
var float NextSpawnTime, SpawnTimer;
var array< class<KFMonster> > CurrentSquad;
var array<ZombieVolume> CurrentVolumeList;
var TurboHumanPawn WaveInstigator;

//If true, we track how fast things spawned (and how much was spawned).
var(LaneManager) bool bDebugSpawning;
const MAX_MONSTER_TYPE = 9;
var int MonsterList[MAX_MONSTER_TYPE];
var float WaveStartTime;
var float WaveEndTime;

replication
{
	reliable if (Role == ROLE_Authority)
		WaveNumber, PlayerCount, PlayerHealth, bIsActive;
}

simulated function PostBeginPlay()
{
	local class<KFMonstersCollection> MonsterCollection;
    local int Index;
	local ZombieVolume Volume;

	Super.PostBeginPlay();

	if (Level.Game == None)
	{
		return;
	}

	MonsterCollection = KFTurboGameType(Level.Game).MonsterCollection;

    for(Index = Index; Index < MonsterCollection.default.MonsterClasses.Length; Index++)
    {
        TurboMonsterCollection.LoadedMonsterList[TurboMonsterCollection.LoadedMonsterList.Length] = Class<KFMonster>(DynamicLoadObject(MonsterCollection.default.MonsterClasses[Index].MClassName,Class'Class', false));
        TurboMonsterCollection.LoadedMonsterList[TurboMonsterCollection.LoadedMonsterList.Length - 1].static.PreCacheAssets(Level);
    }

	TurboMonsterCollection.InitializeCollection();

	foreach AllActors(class'ZombieVolume', Volume, VolumeTag)
	{
		VolumeList[VolumeList.Length] = Volume;
	}
}

simulated function ForceNetUpdate()
{
	NetUpdateTime = FMax(Level.TimeSeconds - (1.f / NetUpdateFrequency), 0.1f);
}

function SetWaveConfig(int NewWaveNumber, int NewPlayerCount, int NewPlayerHealth)
{
	WaveNumber = NewWaveNumber;
	PlayerCount = NewPlayerCount;
	PlayerHealth = NewPlayerHealth;
	Deactivate();
	ForceNetUpdate();
}

function Activate(TurboHumanPawn NewWaveInstigator)
{
	WaveInstigator = NewWaveInstigator;
	GotoState('ActiveWave');
}

function Deactivate() {} //Does nothing if not activated.

function int GetMonsterCount()
{
	local int Index;
	local int Count;
	
	Count = 0;

	for (Index = 0; Index < VolumeList.Length; Index++)
	{
		Count += VolumeList[Index].ZEDList.Length;
	}	

	return Count;
}

state ActiveWave
{
	function BeginState()
	{
		if (bDebugSpawning)
		{
			ResetMonsterList();
			WaveEndTime = -1.f;
			WaveStartTime = Level.TimeSeconds;
		}

		bIsActive = true;

		TurboMonsterCollection.Reset();
		TurboMonsterCollection.InitializeForWave(WaveNumber);

		TotalMonsters = TurboMonsterCollection.GetWaveTotalMonsters(WaveNumber, Level.Game.GameDifficulty, PlayerCount);
		MaxMonsters = TurboMonsterCollection.GetWaveMaxMonsters(WaveNumber, Level.Game.GameDifficulty, PlayerCount);
		NextSpawnTime = TurboMonsterCollection.GetNextSquadSpawnTime(WaveNumber, PlayerCount);

		if (bDebugSpawning)
		{
			log("Starting spawn: TotalMonsters:"$TotalMonsters$" MaxMonsters:"$MaxMonsters$" NextSpawnTime:"$NextSpawnTime);
		}

		SpawnTimer = NextSpawnTime;

		CurrentSquad.Length = 0;
		CurrentVolumeList.Length = 0;

		Enable('Tick');
		ForceNetUpdate();
	}

	function EndState()
	{
		if (bDebugSpawning)
		{
			WaveEndTime = Level.TimeSeconds;
			DumpDebugSpawnResults();
		}

		ClearAllZeds();
		WaveInstigator = None;
		Disable('Tick');
		TurboMonsterCollection.Reset();
		bIsActive = false;
		ForceNetUpdate();
	}

	function Tick(float DeltaTime)
	{
		if (WaveInstigator == None || WaveInstigator.Health <= 0)
		{
			Deactivate();
			return;
		}

		UpdateCurrentSquad(DeltaTime);

		PerformSpawn();

		CheckIfWaveComplete();
	}

	function Activate(TurboHumanPawn NewWaveInstigator) {} //Does nothing if already activated.

	function Deactivate()
	{
		GotoState('');
	}
}

function UpdateCurrentSquad(float DeltaTime)
{
	local TurboMonsterSquad Squad;
	SpawnTimer -= DeltaTime;
	
	if (SpawnTimer > 0.f)
	{
		return;
	}

	if (CurrentSquad.Length != 0)
	{
		return;
	}

	Squad = TurboMonsterCollection.GetNextMonsterSquad();

	if (Squad == None)
	{
		return;
	}

	CurrentSquad = Squad.MonsterList;
	SpawnTimer += NextSpawnTime;
}

function PerformSpawn()
{
	local ZombieVolume Volume;
	local int NumSpawned;
	local int ZedIndex;

	if (CurrentSquad.Length == 0)
	{
		return;
	}
	
	if (CurrentVolumeList.Length == 0)
	{
		CurrentVolumeList = VolumeList;
	}

	if (CurrentVolumeList.Length == 0)
	{
		return;
	}

	RemainingMaxMonsters = Max(MaxMonsters - GetMonsterCount(), 0);

	ZedIndex = Rand(CurrentVolumeList.Length);
	Volume = CurrentVolumeList[ZedIndex];
	CurrentVolumeList.Remove(ZedIndex, 1);

	ZedIndex = Volume.ZEDList.Length;

	Volume.SpawnInHere(CurrentSquad, false, NumSpawned, TotalMonsters, RemainingMaxMonsters);
	CurrentSquad.Remove(0, NumSpawned);

	for (ZedIndex = ZedIndex; ZedIndex < Volume.ZEDList.Length; ZedIndex++)
	{
		OnMonsterSpawned(Volume.ZEDList[ZedIndex]);
	}
}

final function float GetPlayerHealthModifier(float HealthScale)
{
	return 1.0 + (PlayerHealth - 1) * HealthScale;
}

function OnMonsterSpawned(KFMonster Monster)
{
	if (KFMonsterController(Monster.Controller) != None)
	{
		KFMonsterController(Monster.Controller).SetEnemy(WaveInstigator);
		KFMonsterController(Monster.Controller).PathFindState = 2;
	}

	Monster.Health = Monster.default.Health * Monster.DifficultyHealthModifer() * GetPlayerHealthModifier(Monster.PlayerCountHealthScale);
	Monster.HealthMax = Monster.Health;

	Monster.HeadHealth = Monster.default.HeadHealth * Monster.DifficultyHeadHealthModifer() * GetPlayerHealthModifier(Monster.PlayerNumHeadHealthScale);

	if (bDebugSpawning)
	{
		MonsterList[class'PawnHelper'.static.GetMonsterType(Monster.Class)]++;
	}
}

function CheckIfWaveComplete()
{
	if (TotalMonsters > 0 || GetMonsterCount() > 0)
	{
		return;
	}

	Deactivate();
}

function ClearAllZeds()
{
	local int Index, ZedIndex;
	local Controller DeathInstigator;
	
	DeathInstigator = None;
	if (WaveInstigator != None)
	{
		DeathInstigator = WaveInstigator.Controller;
	}

	for (Index = 0; Index < VolumeList.Length; Index++)
	{
		for (ZedIndex = VolumeList[Index].ZEDList.Length - 1; ZedIndex >= 0; ZedIndex--)
		{
			if (VolumeList[Index].ZEDList[ZedIndex] != None)
			{
				VolumeList[Index].ZEDList[ZedIndex].Died(DeathInstigator, class'KFMod.DamTypeDwarfAxe', VolumeList[Index].ZEDList[ZedIndex].Location);
			}
		}
	}	
}

static final function int GetEnumAsInt(PawnHelper.EMonster Monster)
{
	return int(Monster);
}

function ResetMonsterList()
{
	local int Index;
	for (Index = 0; Index < ArrayCount(MonsterList); Index++)
	{
		MonsterList[Index] = 0;
	}
}

function DumpDebugSpawnResults()
{
	local float ElapsedTime;
	local int TrashCount;
	local int SpecialCount;
	local int ScrakeCount;
	local int FleshpoundCount;
	
	ElapsedTime = WaveEndTime - WaveStartTime;

	TrashCount = MonsterList[GetEnumAsInt(Clot)] + MonsterList[GetEnumAsInt(Crawler)] + MonsterList[GetEnumAsInt(Gorefast)] + MonsterList[GetEnumAsInt(Stalker)];
	SpecialCount = MonsterList[GetEnumAsInt(Bloat)] + MonsterList[GetEnumAsInt(Siren)] + MonsterList[GetEnumAsInt(Husk)];
	ScrakeCount = MonsterList[GetEnumAsInt(Scrake)];
	FleshpoundCount = MonsterList[GetEnumAsInt(Fleshpound)];
	log("====================== WAVE ENDED =============================");
	log("- Total Monsters: "$TrashCount+SpecialCount+ScrakeCount+FleshpoundCount);
	log("- Elapsed Time: "$ElapsedTime);
	log("- Trash Per Second: "$GetPerSecondAsString(TrashCount, ElapsedTime)$" ("$TrashCount$")");
	log("- Special Per Second: "$GetPerSecondAsString(SpecialCount, ElapsedTime)$" ("$SpecialCount$")");
	log("- Scrake Per Second: "$GetPerSecondAsString(ScrakeCount, ElapsedTime)$" ("$ScrakeCount$")");
	log("- Fleshpound Per Second: "$GetPerSecondAsString(FleshpoundCount, ElapsedTime)$" ("$FleshpoundCount$")");
	log("===============================================================");
}

static final function string GetPerSecondAsString(int Count, float Time)
{
	return (float(Count)/FMax(Time, 0.1f))$"/s";
}

defaultproperties
{
	bAlwaysRelevant=true
	bReplicateMovement=false
	NetUpdateFrequency=0.1f
	RemoteRole=ROLE_SimulatedProxy

	Texture=Texture'Engine.SubActionGameSpeed'
	DrawScale=2.f

	Begin Object Name=TurboPlusMonsterCollectionWaveImpl0 Class=TurboPlusMonsterCollectionWaveImpl
	End Object
    TurboMonsterCollection=TurboPlusMonsterCollectionWaveImpl'TurboPlusMonsterCollectionWaveImpl0'

	WaveNumber=0
	PlayerCount=1
	PlayerHealth=1
}
