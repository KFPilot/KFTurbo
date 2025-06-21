//Killing Floor Turbo PlainSightSpawningActor
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PlainSightSpawningActor extends Engine.Info;

struct OriginalSpawnerConfig
{
    var ZombieVolume Spawner;
    var float OriginalMinDistanceToPlayer;
    var bool bOriginalAllowPlainSightSpawns;
};

var array<OriginalSpawnerConfig> SpawnerList;

function PostBeginPlay()
{
    local int Index;
    local int NumSpawners;
    local KFGameType KFGT;
    KFGT = KFGameType(Level.Game);

    Super.PostBeginPlay();

    SpawnerList.Length = KFGT.ZedSpawnList.Length;

    for (Index = 0; Index < KFGT.ZedSpawnList.Length; Index++)
    {
        if (KFGT.ZedSpawnList[Index].bAllowPlainSightSpawns)
        {
            continue;
        }

        SpawnerList[NumSpawners].Spawner = KFGT.ZedSpawnList[Index];
        SpawnerList[NumSpawners].OriginalMinDistanceToPlayer = KFGT.ZedSpawnList[Index].MinDistanceToPlayer;
        SpawnerList[NumSpawners].bOriginalAllowPlainSightSpawns = KFGT.ZedSpawnList[Index].bAllowPlainSightSpawns;
        NumSpawners++;

        KFGT.ZedSpawnList[Index].MinDistanceToPlayer = FMax(620.f, KFGT.ZedSpawnList[Index].MinDistanceToPlayer);
        KFGT.ZedSpawnList[Index].bAllowPlainSightSpawns = true;
    }

    SpawnerList.Length = NumSpawners;
}

function Revert()
{
    local int Index;
    for (Index = 0; Index < SpawnerList.Length; Index++)
    {
        SpawnerList[Index].Spawner.MinDistanceToPlayer = SpawnerList[Index].OriginalMinDistanceToPlayer;
        SpawnerList[Index].Spawner.bAllowPlainSightSpawns = SpawnerList[Index].bOriginalAllowPlainSightSpawns;
    }

    SpawnerList.Length = 0;
}

defaultproperties
{
    
}