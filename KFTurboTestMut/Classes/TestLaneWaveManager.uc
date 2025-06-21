class TestLaneWaveManager extends Info
	hidecategories(Advanced,Force,Karma,LightColor,Lighting,Sound,UseTrigger)
	placeable;

var TurboMonsterCollectionWaveBase TurboMonsterCollection;

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
		bIsActive = true;

		TurboMonsterCollection.Reset();
		TurboMonsterCollection.InitializeForWave(WaveNumber);

		TotalMonsters = TurboMonsterCollection.GetWaveTotalMonsters(WaveNumber, Level.Game.GameDifficulty, PlayerCount);
		MaxMonsters = TurboMonsterCollection.GetWaveMaxMonsters(WaveNumber, Level.Game.GameDifficulty, PlayerCount);
		NextSpawnTime = TurboMonsterCollection.GetNextSquadSpawnTime(WaveNumber, PlayerCount);
		SpawnTimer = NextSpawnTime;

		CurrentSquad.Length = 0;
		CurrentVolumeList.Length = 0;

		Enable('Tick');
		ForceNetUpdate();
	}

	function EndState()
	{
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

	Volume = CurrentVolumeList[0];
	CurrentVolumeList.Remove(0, 1);

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
	}

	Monster.Health = Monster.default.Health * Monster.DifficultyHealthModifer() * GetPlayerHealthModifier(Monster.PlayerCountHealthScale);
	Monster.HealthMax = Monster.Health;

	Monster.HeadHealth = Monster.default.HeadHealth * Monster.DifficultyHeadHealthModifer() * GetPlayerHealthModifier(Monster.PlayerNumHeadHealthScale);
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
