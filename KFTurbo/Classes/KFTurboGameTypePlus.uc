// Killing Floor Turbo KFTurboGameTypePlus
// Distributed under the terms of the GPL-2.0 License.
// For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboGameTypePlus extends KFTurboGameType;

var TurboMonsterCollection TurboMonsterCollection;

// Refers to the last squad we used to fill out NextSpawnSquad.
var TurboMonsterSquad CurrentSquad;
var float WaveNextSquadSpawnTime;

// Constants for initial game setup
const INITIAL_CASH = 42069;
const SPAWN_TIME = 1.0;
const WAVE_COUNTDOWN = 60;
const STD_MAX_ZOMBIES = 48;
const FAKED_P_HEALTH = 0; // Currently not being used but maybe in the future? Force to 6p?

// Function called before the game begins
function PreBeginPlay()
{
    local ZombieVolume ZV;
	local ShopVolume Shop;
    Super.PreBeginPlay();

    // Adjust respawn time for each zombie volume
    foreach AllActors(Class'ZombieVolume', ZV)
    {
        if (ZV != None)
        {
            ZV.CanRespawnTime = FMin(ZV.CanRespawnTime, SPAWN_TIME);
        }
    }

    // Close all shops! We don't use them at this difficulty.
	foreach AllActors(Class'ShopVolume',Shop) 
	{
		Shop.bAlwaysClosed = true;
        Shop.bAlwaysEnabled = false;
	}
}

// Function called after the game begins
function PostBeginPlay()
{
    local KFLevelRules KFLR;

    Super.PostBeginPlay();

    // Find or spawn level rules
    foreach AllActors(class'KFLevelRules', KFLR)
    {
        break;
    }

    if (KFLR == None)
    {
        KFLR = Spawn(class'KFLevelRules');
    }

    // Set wave spawn period
    KFLR.WaveSpawnPeriod = SPAWN_TIME;

    StartingCash = INITIAL_CASH;
    MinRespawnCash = INITIAL_CASH;
    StandardMaxZombiesOnce = STD_MAX_ZOMBIES;
    WaveNextSquadSpawnTime = SPAWN_TIME;
}

// State to handle match progress
State MatchInProgress
{
    function BeginState()
    {
        Super.BeginState();

        WaveCountDown = WAVE_COUNTDOWN;
    }

    // Don't select shops.
    function SelectShop() {}
    
    function float CalcNextSquadSpawnTime()
    {
        return WaveNextSquadSpawnTime / WaveSpawnRateModifier;
    }

    function OpenShops()
    {
        local Controller C;

        if (bTradingDoorsOpen)
        {
            return;
        }
    
        bTradingDoorsOpen = True;

        for( C=Level.ControllerList; C!=None; C=C.NextController )
        {
            if( C.Pawn!=None && C.Pawn.Health>0 )
            {
                if( KFPlayerController(C) !=None )
                {
                    if ( WaveNum < FinalWave )
                    {
                        KFPlayerController(C).ClientLocationalVoiceMessage(C.PlayerReplicationInfo, none, 'TRADER', 2);
                    }
                    else
                    {
                        KFPlayerController(C).ClientLocationalVoiceMessage(C.PlayerReplicationInfo, none, 'TRADER', 3);
                    }

                    KFPlayerController(C).CheckForHint(31);
                    HintTime_1 = Level.TimeSeconds + 11;
                }
            }
        }
    }

    // It's ok to call this I think.
    function CloseShops()
    {
        Super.CloseShops();
    }
}

function ResetZombieVolumes()
{
    local int Index;
    for(Index = ZedSpawnList.Length - 1; Index >= 0; Index-- )
    {
        ZedSpawnList[Index].Reset();
    }
}

function LoadUpMonsterList()
{
    local int Index;
    for( Index = Index; Index < MonsterCollection.default.MonsterClasses.Length; Index++ )
    {
        TurboMonsterCollection.LoadedMonsterList[TurboMonsterCollection.LoadedMonsterList.Length] = Class<KFMonster>(DynamicLoadObject(MonsterCollection.default.MonsterClasses[Index].MClassName,Class'Class', false));
        TurboMonsterCollection.LoadedMonsterList[TurboMonsterCollection.LoadedMonsterList.Length - 1].static.PreCacheAssets(Level);
    }

    TurboMonsterCollection.InitializeCollection();
}

function SetupWave()
{
    TraderProblemLevel = 0;
    ZombiesKilled = 0;
    WaveMonsters = 0;
    WaveNumClasses = 0;

    MaxMonsters = TurboMonsterCollection.GetWaveMaxMonsters(WaveNum, GameDifficulty, NumPlayers + NumBots);
    TotalMaxMonsters = TurboMonsterCollection.GetWaveTotalMonsters(WaveNum, GameDifficulty, NumPlayers + NumBots);

    WaveNextSquadSpawnTime = TurboMonsterCollection.GetNextSquadSpawnTime(WaveNum);
    if (WaveNextSquadSpawnTime < SPAWN_TIME)
    {
        WaveNextSquadSpawnTime = SPAWN_TIME;
    }

    KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonsters = TotalMaxMonsters;
    KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonstersOn = true;

    WaveEndTime = Level.TimeSeconds + 255;
    AdjustedDifficulty = GameDifficulty + TurboMonsterCollection.GetWaveDifficulty(WaveNum);

    ResetZombieVolumes();
    SquadsToUse.Length = 0;

    TurboMonsterCollection.InitializeForWave(WaveNum);

    BuildNextSquad();
    
	class'TurboWaveEventHandler'.static.BroadcastWaveStarted(Self, WaveNum);
}

function AddSpecialSquad()
{
    BuildNextSquad();
}

function BuildNextSquad()
{
    local TurboMonsterSquad Squad;

    if (NextSpawnSquad.Length != 0)
    {
        return;
    }

    Squad = TurboMonsterCollection.GetNextMonsterSquad();

    if (Squad == None)
    {
        return;
    }

    NextSpawnSquad = Squad.MonsterList;
    CurrentSquad = Squad;
    
	class'TurboWaveEventHandler'.static.BroadcastNextSpawnSquadGenerated(Self, NextSpawnSquad);
}

function AddBossBuddySquad()
{
    local int TempMaxMonsters, NumMonstersSpawned, TotalZombiesValue;
    local int MaxAttemptCount;

    TurboMonsterCollection.ApplyFinalSquad(FinalSquadNum, NumPlayers + NumBots, NextSpawnSquad);
    FinalSquadNum++;

    LastZVol = FindSpawningVolume();

    if(LastZVol != None)
    {
        LastSpawningVolume = LastZVol;
    }

    if(LastZVol == None)
    {
        LastZVol = FindSpawningVolume();

        if(LastZVol != None)
        {
            LastSpawningVolume = LastZVol;
        }
    }

    if (LastZVol == None)
    {
        return;
    }

    NumMonstersSpawned = 0;
    TempMaxMonsters = 999;
    MaxAttemptCount = NextSpawnSquad.Length;

    while (MaxAttemptCount >= 0 && NextSpawnSquad.Length > 0)
    {
        MaxAttemptCount--;

        if(LastZVol.SpawnInHere(NextSpawnSquad,,NumMonstersSpawned, TempMaxMonsters, 999, TotalZombiesValue))
        {
            NumMonsters += NumMonstersSpawned;
            WaveMonsters += NumMonstersSpawned;
            NextSpawnSquad.Remove(0, NumMonstersSpawned);
        }
    }
}

// Default properties for the game type
defaultproperties
{
    bIsHighDifficulty = true

	Begin Object Class=TurboMonsterCollectionWaveImpl Name=TurboMonsterCollection0
	End Object
    TurboMonsterCollection=TurboMonsterCollectionWaveImpl'KFTurbo.KFTurboGameTypePlus.TurboMonsterCollection0'

    LongWaves(0)=(WaveMask=63,WaveMaxMonsters=35,WaveDifficulty=2.000000)
    LongWaves(1)=(WaveMask=4032,WaveMaxMonsters=35,WaveDifficulty=2.000000)
    LongWaves(2)=(WaveMask=4032,WaveMaxMonsters=40,WaveDifficulty=2.000000)
    LongWaves(3)=(WaveMask=4032,WaveMaxMonsters=40,WaveDifficulty=2.000000)
    LongWaves(4)=(WaveMask=4032,WaveMaxMonsters=45,WaveDifficulty=2.000000)
    LongWaves(5)=(WaveMask=4032,WaveMaxMonsters=45,WaveDifficulty=2.000000)
    LongWaves(6)=(WaveMask=4032,WaveMaxMonsters=50,WaveDifficulty=2.000000)
    LongWaves(7)=(WaveMask=258048,WaveMaxMonsters=50,WaveDifficulty=2.000000)
    LongWaves(8)=(WaveMask=258042,WaveMaxMonsters=55,WaveDifficulty=2.000000)
    LongWaves(9)=(WaveMask=16515072,WaveMaxMonsters=60,WaveDifficulty=2.000000)

    MonsterCollection = Class'KFTurbo.MC_DEF'
    StandardMonsterSquads(0) = "4A4B4C"
    StandardMonsterSquads(1) = "2G4D1H"
    StandardMonsterSquads(2) = "2A2B2C1E"
    StandardMonsterSquads(3) = "2A2B2C1I"
    StandardMonsterSquads(4) = "4D1H1I1G"
    StandardMonsterSquads(5) = "2A5C2D2G"
    StandardMonsterSquads(6) = "4A4B4C"
    StandardMonsterSquads(7) = "1C2D2H1I1E1F"
    StandardMonsterSquads(8) = "2A2B2C2I1I"
    StandardMonsterSquads(9) = "1D1H1I1G2E1F"
    StandardMonsterSquads(10) = "4D1H2I2G"
    StandardMonsterSquads(11) = "2A2D1H1I1E2F"
    StandardMonsterSquads(12) = "4A4B4C"
    StandardMonsterSquads(13) = "1C2D2H1I1E2F"
    StandardMonsterSquads(14) = "2A2B2C2I2I"
    StandardMonsterSquads(15) = "1D1H1I1G2E1F"
    StandardMonsterSquads(16) = "2B4D1H2I1G"
    StandardMonsterSquads(17) = "2A2D1H1I2E3F"
    StandardMonsterSquads(18) = "4A4B4C"
    StandardMonsterSquads(19) = "1C2D2H1I2E1F"
    StandardMonsterSquads(20) = "2A2B2C2I2I1F"
    StandardMonsterSquads(21) = "1D1H1I1G2E2F"
    StandardMonsterSquads(22) = "2B4D2H2I1G"
    StandardMonsterSquads(23) = "2A2D2H1I2E3F"

    StandardMonsterSquads=()
    MonsterSquad=()
    FinalSquads=()
    MonsterClasses=()

    SpecialEventMonsterCollections(0) = Class'KFTurbo.MC_Turbo'
    SpecialEventMonsterCollections(1) = Class'KFTurbo.MC_Turbo'
    SpecialEventMonsterCollections(2) = Class'KFTurbo.MC_Turbo'
    SpecialEventMonsterCollections(3) = Class'KFTurbo.MC_Turbo'

    GameName = "Killing Floor Turbo+ Game Type"
    Description = "Turbo+ mode of the vanilla Killing Floor Game Type."
    ScreenShotName = "KFTurbo.Generic.KFTurbo_FB"
}
