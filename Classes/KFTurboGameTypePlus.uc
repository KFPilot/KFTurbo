class KFTurboGameTypePlus extends KFTurboGameType;

// Constants for initial game setup
const int INITIAL_CASH = 42069;
const float SPAWN_TIME = 1.0;
const int WAVE_COUNTDOWN = 60;
const int STD_MAX_ZOMBIES = 48;
const int FAKED_P_HEALTH = 0;

// Function called before the game begins
function PreBeginPlay()
{
    local ZombieVolume ZV;
    Super.PreBeginPlay();

    // Adjust respawn time for each zombie volume
    foreach AllActors(Class'ZombieVolume', ZV)
    {
        if (ZV != None)
        {
            ZV.CanRespawnTime = FMin(ZV.CanRespawnTime, SPAWN_TIME);
        }
    }
}

// Function called after the game begins
function PostBeginPlay()
{
    local KFLevelRules KFLR;
    local KFGameType KFGT;

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

    // Set game type parameters
    KFGT = KFGameType(Level.Game);

    if (KFGT != None)
    {
        KFGT.StartingCash = INITIAL_CASH;
        KFGT.MinRespawnCash = INITIAL_CASH;
        KFGT.StandardMaxZombiesOnce = STD_MAX_ZOMBIES;
    }
}

// State to handle match progress
State MatchInProgress
{
    function BeginState()
    {
        Super.BeginState();

        WaveCountDown = WAVE_COUNTDOWN;
        OpenShops();
    }

    function CloseShops()
    {
        local Controller C;
        Super.CloseShops();

        // Close buy menu for all players
        for (C = Level.ControllerList; C != None; C = C.NextController)
        {
            if (KFPPlayerController(C) != None)
            {
                KFPPlayerController(C).ClientCloseBuyMenu();
            }
        }
    }
}

// Calculate next squad spawn time
simulated function float CalcNextSquadSpawnTime()
{
    return SPAWN_TIME;
}

// Default properties for the game type
defaultproperties
{
    bIsHighDifficulty = true

    // Wave 1
    // Squads: 0, 1, 2, 6, 7, 8, 10, 11, 12
    // Wave 2-7
    // Squads: 2, 5, 6, 7, 9, 10, 11, 12, 13
    // Wave 8-9
    // Squads: 1, 2, 3, 4, 8, 14, 15, 16, 17, 18
    // Wave 10
    // Squads: 1, 2, 3, 4, 8, 14, 15, 16, 17, 18, 19, 20

    LongWaves(0) = (WaveMask = 7614, WaveMaxMonsters = 35, WaveDifficulty = 2.000000)
    LongWaves(1) = (WaveMask = 16091, WaveMaxMonsters = 35, WaveDifficulty = 2.000000)
    LongWaves(2) = (WaveMask = 16091, WaveMaxMonsters = 40, WaveDifficulty = 2.000000)
    LongWaves(3) = (WaveMask = 16091, WaveMaxMonsters = 40, WaveDifficulty = 2.000000)
    LongWaves(4) = (WaveMask = 16091, WaveMaxMonsters = 45, WaveDifficulty = 2.000000)
    LongWaves(5) = (WaveMask = 16091, WaveMaxMonsters = 45, WaveDifficulty = 2.000000)
    LongWaves(6) = (WaveMask = 16091, WaveMaxMonsters = 50, WaveDifficulty = 2.000000)
    LongWaves(7) = (WaveMask = 508180, WaveMaxMonsters = 50, WaveDifficulty = 2.000000)
    LongWaves(8) = (WaveMask = 508180, WaveMaxMonsters = 55, WaveDifficulty = 2.000000)
    LongWaves(9) = (WaveMask = 2081042, WaveMaxMonsters = 60, WaveDifficulty = 2.000000)

    MonsterCollection = Class'KFTurbo.MC_DEF'
    StandardMonsterSquads(0) = "2B2I"
    StandardMonsterSquads(1) = "3A2B2C"
    StandardMonsterSquads(2) = "1A3C2H"
    StandardMonsterSquads(3) = "4A4C1H1G"
    StandardMonsterSquads(4) = "3A1B2D1G1H"
    StandardMonsterSquads(5) = "3A"
    StandardMonsterSquads(6) = "2A1E"
    StandardMonsterSquads(7) = "2A3C1E"
    StandardMonsterSquads(8) = "2B3D1G1H"
    StandardMonsterSquads(9) = "4A1C"
    StandardMonsterSquads(10) = "4A"
    StandardMonsterSquads(11) = "4D"
    StandardMonsterSquads(12) = "2G"
    StandardMonsterSquads(13) = "2E"
    StandardMonsterSquads(14) = "2I3H4B"
    StandardMonsterSquads(15) = "2F"
    StandardMonsterSquads(16) = "3F"
    StandardMonsterSquads(17) = "3H"
    StandardMonsterSquads(18) = "2I"
    StandardMonsterSquads(19) = "2F2H"
    StandardMonsterSquads(20) = "2E2I"

    LongSpecialSquads(4) = (ZedClass = ("KFTurbo.P_Crawler_STA", "KFTurbo.P_Gorefast_XMA", "KFTurbo.P_Stalker_STA", "KFTurbo.P_SC_HAL"), NumZeds = (2, 2, 1, 1))
    LongSpecialSquads(6) = (ZedClass = ("KFTurbo.P_FP_HAL"), NumZeds = (1))
    LongSpecialSquads(7) = (ZedClass = ("KFTurbo.P_Bloat_STA", "KFTurbo.P_Siren_STA", "KFTurbo.P_FP_STA"), NumZeds = (1, 1, 1))
    LongSpecialSquads(8) = (ZedClass = ("KFTurbo.P_Bloat_STA", "KFTurbo.P_Siren_STA", "KFTurbo.P_SC_STA", "KFTurbo.P_FP_STA"), NumZeds = (1, 2, 1, 1))
    LongSpecialSquads(9) = (ZedClass = ("KFTurbo.P_Bloat_STA", "KFTurbo.P_Siren_STA", "KFTurbo.P_SC_STA", "KFTurbo.P_FP_STA"), NumZeds = (1, 2, 1, 2))

    FinalSquads(0) = (ZedClass = ("KFTurbo.P_Siren_HAL"), NumZeds = (4))
    FinalSquads(1) = (ZedClass = ("KFTurbo.P_SC_HAL", "KFTurbo.P_Crawler_STA"), NumZeds = (3, 1))
    FinalSquads(2) = (ZedClass = ("KFTurbo.P_Siren_XMA", "KFTurbo.P_Stalker_STA", "KFTurbo.P_FP_HAL"), NumZeds = (3, 1, 1))

    SpecialEventMonsterCollections(0) = Class'KFTurbo.MC_DEF'
    SpecialEventMonsterCollections(1) = Class'KFTurbo.MC_SUM'
    SpecialEventMonsterCollections(2) = Class'KFTurbo.MC_HAL'
    SpecialEventMonsterCollections(3) = Class'KFTurbo.MC_XMA'

    GameName = "Killing Floor Turbo+ Game Type"
    Description = "Turbo+ mode of the vanilla Killing Floor Game Type."
    ScreenShotName = "KFTurbo.Generic.KFTurbo_FB"
}
