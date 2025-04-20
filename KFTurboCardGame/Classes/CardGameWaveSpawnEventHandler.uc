//Killing Floor Turbo CardGameWaveSpawnEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardGameWaveSpawnEventHandler extends KFTurbo.TurboWaveSpawnEventHandler;

var KFTurboCardGameMut Mutator;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    Mutator = KFTurboCardGameMut(Owner);

    OnNextSpawnSquadGenerated = NextSpawnSquadGenerated;
    OnBossSpawned = BossSpawned;
}

final function NextSpawnSquadGenerated(KFTurboGameType GameType, out array < class<KFMonster> > NextSpawnSquad)
{
    if (Mutator == None)
    {
        return;
    }

    Mutator.TurboCardGameplayManagerInfo.OnNextSpawnSquadGenerated(NextSpawnSquad);
}

final function BossSpawned(KFTurboGameType GameType)
{
    if (Mutator == None)
    {
        return;
    }

    Mutator.TurboCardGameplayManagerInfo.OnBossSpawned();
}