class KFTurboGameTypePlus extends KFTurboGameType;

// Constants for initial game setup
const INITIAL_CASH = 42069;
const SPAWN_TIME = 1.0;
const WAVE_COUNTDOWN = 60;
const STD_MAX_ZOMBIES = 48;
const FAKED_P_HEALTH = 0;

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
    // Squads: 0-5
    // Wave 2-7
    // Squads: 6-11
    // Wave 8-9
    // Squads: 12-17
    // Wave 10
    // Squads: 18-22

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

    // Not using those for now
    // LongSpecialSquads(4)=(ZedClass=("KFTurbo.P_Crawler_STA","KFTurbo.P_Gorefast_XMA","KFTurbo.P_Stalker_STA"),NumZeds=(2,2,1))
    // LongSpecialSquads(6)=(ZedClass=("KFTurbo.P_FP_HAL"),NumZeds=(1))
    // LongSpecialSquads(7)=(ZedClass=("KFTurbo.P_Bloat_STA","KFTurbo.P_Siren_STA","KFTurbo.P_FP_STA"),NumZeds=(1,1,1))
    // LongSpecialSquads(8)=(ZedClass=("KFTurbo.P_Bloat_STA","KFTurbo.P_Siren_STA","KFTurbo.P_SC_STA","KFTurbo.P_FP_STA"),NumZeds=(1,1,1,1))
    // LongSpecialSquads(9)=(ZedClass=("KFTurbo.P_Bloat_STA","KFTurbo.P_Siren_STA","KFTurbo.P_SC_STA","KFTurbo.P_FP_STA"),NumZeds=(1,1,1,1))

    FinalSquads(0)=(ZedClass=("KFTurbo.P_Crawler_HAL","KFTurbo.P_Clot_STA","KFTurbo.P_Siren_HAL"),NumZeds=(3,3,1))
    FinalSquads(1)=(ZedClass=("KFTurbo.P_SC_HAL","KFTurbo.P_Crawler_STA","KFTurbo.P_Clot_STA","KFTurbo.P_Husk_STA"),NumZeds=(1,3,3,1))
    FinalSquads(2)=(ZedClass=("KFTurbo.P_Siren_XMA","KFTurbo.P_Stalker_STA","KFTurbo.P_FP_HAL","KFTurbo.P_SC_HAL","KFTurbo.P_Clot_STA","KFTurbo.P_Bloat_HAL"),NumZeds=(1,3,1,1,3,1))

    SpecialEventMonsterCollections(0) = Class'KFTurbo.MC_DEF'
    SpecialEventMonsterCollections(1) = Class'KFTurbo.MC_SUM'
    SpecialEventMonsterCollections(2) = Class'KFTurbo.MC_HAL'
    SpecialEventMonsterCollections(3) = Class'KFTurbo.MC_XMA'

    GameName = "Killing Floor Turbo+ Game Type"
    Description = "Turbo+ mode of the vanilla Killing Floor Game Type."
    ScreenShotName = "KFTurbo.Generic.KFTurbo_FB"
}
