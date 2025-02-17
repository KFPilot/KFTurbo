//Killing Floor Turbo CurseOfRaManager
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CurseOfRaManager extends Engine.Info;

var int NumExtraToSpawn;
var bool bSpawnedExtra;

struct RatedSpawner
{
    var ZombieVolume Volume;
    var float Score;
};

function PostBeginPlay()
{
    Super.PostBeginPlay();

    SetTimer(17.f, true);
}

function OnBossSpawned()
{
    AddBosses();
}

function AddBosses()
{
    local KFGameType KFGT;
    local int Index, ScoredIndex;
    local float Score;
    local bool bFoundPlace;

    local int MaxMonsters;
    local int ZombiesAtOnceLeft;
    local int NumSpawned;
    local array<RatedSpawner> SpawnerList;

    local array< class<KFMonster> > NextSpawnSquad;

    local ZombieBoss ZombieBoss;

    if (bSpawnedExtra)
    {
        return;
    }

    bSpawnedExtra = true;
    KFGT = KFGameType(Level.Game);
    KFGT.NextSpawnSquad.Length = 1;

    if(KFGT.KFGameLength != KFGT.GL_Custom)
    {
        KFGT.NextSpawnSquad[0] = Class<KFMonster>(DynamicLoadObject(KFGT.MonsterCollection.default.EndGameBossClass, Class'Class'));
    }
    else
    {
        KFGT.NextSpawnSquad[0] = Class<KFMonster>(DynamicLoadObject(KFGT.EndGameBossClass, Class'Class'));
    }

    NextSpawnSquad = KFGT.NextSpawnSquad;

    for(Index = KFGT.ZedSpawnList.Length - 1; Index >= 0; Index--)
    {
        Score = KFGT.ZedSpawnList[Index].RateZombieVolume(KFGT, KFGT.LastSpawningVolume, None, false, true);
        KFGT.ZedSpawnList[Index].LastFailedSpawnTime = Level.TimeSeconds;
        
        if (Score < 0.f)
        {
            continue;
        }

        bFoundPlace = false;
        for (ScoredIndex = 0; ScoredIndex < SpawnerList.Length; ScoredIndex++)
        {
            if (Score > SpawnerList[ScoredIndex].Score)
            {
                bFoundPlace = true;
                SpawnerList.Insert(ScoredIndex, 1);
                AddSpawner(SpawnerList[ScoredIndex], KFGT.ZedSpawnList[Index], Score);
                break;
            }
        }

        if (bFoundPlace || SpawnerList.Length >= NumExtraToSpawn)
        {
            continue;
        }

        SpawnerList.Length = SpawnerList.Length + 1;
        AddSpawner(SpawnerList[SpawnerList.Length - 1], KFGT.ZedSpawnList[Index], Score);
    }

    for(Index = 0; Index < SpawnerList.Length; Index++)
    {
        NumExtraToSpawn--;
        KFGT.NextSpawnSquad = NextSpawnSquad;
        MaxMonsters = 1;
        ZombiesAtOnceLeft = 1;
        SpawnerList[Index].Volume.SpawnInHere(KFGT.NextSpawnSquad, false, NumSpawned, MaxMonsters, ZombiesAtOnceLeft);

        if (NumExtraToSpawn <= 0)
        {
            break;
        }
    }
 
    foreach DynamicActors(class'ZombieBoss', ZombieBoss)
    {
        if (!ZombieBoss.IsInState('MakingEntrance'))
        {
            ZombieBoss.MakeGrandEntry();
        }
    }
}

function AddSpawner(out RatedSpawner Entry, ZombieVolume Volume, float Score)
{
    Entry.Volume = Volume;
    Entry.Score = Score;
}

//Randomly do something strange sometimes.
function Timer()
{
    local float Random;

    SetTimer(15.f + (FRand() * 4.f), true);

    if (KFGameType(Level.Game) != None && !KFGameType(Level.Game).bWaveInProgress)
    {
        return;
    }

    if (FRand() < 0.8f)
    {
        return;
    }

    Random = FRand();

    if (Random < 0.1f)
    {
        RandomlyRageScrake();
    }
    else if (Random < 0.2f)
    {
        RandomlyRageFleshpound();
    }
    else if (Random < 0.3f)
    {
        RandomlySetOffNearbyPipebomb();
    }
    else if (Random < 0.4f)
    {
        ForceAReload();
    }
    else if (Random < 0.5f)
    {
        ForceDropCash();
    }
    else if (Random < 0.6f)
    {
        KillRandomMonster();
    }
}

function RandomlyRageScrake()
{
    local P_Scrake Scrake;
    local array<Monster> MonsterPawnList;
    MonsterPawnList = class'TurboGameplayHelper'.static.GetMonsterPawnList(Level, class'P_Scrake');

    if (MonsterPawnList.Length == 0)
    {
        return;
    }

    Scrake = P_Scrake(MonsterPawnList[Rand(MonsterPawnList.Length)]);

    if (Scrake == None)
    {
        return;
    }

	Scrake.HealthRageThreshold = FMax(1.1f, Scrake.HealthRageThreshold);
    Scrake.RangedAttack(None);
}

function RandomlyRageFleshpound()
{
    local P_Fleshpound Fleshpound;
    local array<Monster> MonsterPawnList;
    MonsterPawnList = class'TurboGameplayHelper'.static.GetMonsterPawnList(Level, class'P_Fleshpound');

    if (MonsterPawnList.Length == 0)
    {
        return;
    }

    Fleshpound = P_Fleshpound(MonsterPawnList[Rand(MonsterPawnList.Length)]);

    if (Fleshpound == None)
    {
        return;
    }

    Fleshpound.StartCharging();
    Fleshpound.bFrustrated = true;
    AI_Fleshpound(Fleshpound.Controller).bForcedRage = FRand() > 0.5f;
}

function RandomlySetOffNearbyPipebomb()
{
    local array<TurboHumanPawn> HumanPawnList;
    local TurboHumanPawn HumanPawn;
    local PipeBombProjectile Pipebomb;
    HumanPawnList = class'TurboGameplayHelper'.static.GetPlayerPawnList(Level);

    if (HumanPawnList.Length == 0)
    {
        return;
    }

    HumanPawn = HumanPawnList[Rand(HumanPawnList.Length)];

    if (HumanPawn == None)
    {
        return;
    }

    foreach CollidingActors(class'PipeBombProjectile', Pipebomb, 600.f, HumanPawn.Location)
    {
        break;
    }

    if (Pipebomb == None)
    {
        return;
    }

    Pipebomb.bEnemyDetected = true;
}

function ForceAReload()
{
    local TurboHumanPawn HumanPawn;
    local array<TurboHumanPawn> HumanPawnList;
    
    HumanPawnList = class'TurboGameplayHelper'.static.GetPlayerPawnList(Level);

    if (HumanPawnList.Length == 0)
    {
        return;
    }

    HumanPawn = HumanPawnList[Rand(HumanPawnList.Length)];

    if (HumanPawn == None || KFWeapon(HumanPawn.Weapon) == None)
    {
        return;
    }

    KFWeapon(HumanPawn.Weapon).ReloadMeNow();
}

function ForceDropCash()
{
    local TurboHumanPawn HumanPawn;
    local array<TurboHumanPawn> HumanPawnList;
    HumanPawnList = class'TurboGameplayHelper'.static.GetPlayerPawnList(Level);

    if (HumanPawnList.Length == 0)
    {
        return;
    }

    HumanPawn = HumanPawnList[Rand(HumanPawnList.Length)];

    if (HumanPawn == None)
    {
        return;
    }
    
    HumanPawn.TossCash(50);
}


function KillRandomMonster()
{
    local array<Monster> MonsterPawnList;
    local Monster SelectedMonster;

    MonsterPawnList = class'TurboGameplayHelper'.static.GetMonsterPawnList(Level);

    if (MonsterPawnList.Length < 4)
    {
        return;
    }

    SelectedMonster = MonsterPawnList[Rand(MonsterPawnList.Length)];
    
    if (SelectedMonster == None || ZombieBoss(SelectedMonster) != None)
    {
        return;
    }

    SelectedMonster.Died(None, class'TurboCurseOfRaKillMonster_DT', SelectedMonster.Location);
}

defaultproperties
{
    NumExtraToSpawn=1
    bSpawnedExtra=false
}