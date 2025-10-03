//Killing Floor Turbo TurboCustomZedHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCustomZedHandler extends Info
    dependson(PawnHelper);

enum EReplacementIndex
{
    Assassin, //0
    Jumper,
    Fathead,
    Caroler,
    Classy,
    Shotgun //5
};

struct MonsterReplacement
{
    var class<KFMonster> ReplacementClass;
    var float ReplacementRate;
    var float ReplacementProgress;
};

var array<MonsterReplacement> ReplacementList; //List of KFMonster parent classes, their replacement, and individual chance to be applied.
var bool bRandomizeProgressAtWaveStart;
var float ReplacementRateMultiplier;

var bool bDebugReplacement;
var bool bAllowRandomness;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    TurboWaveEventHandler(class'TurboWaveEventHandler'.static.CreateHandler(Self)).OnWaveStarted = WaveStarted;
    TurboWaveSpawnEventHandler(class'TurboWaveSpawnEventHandler'.static.CreateHandler(Self)).OnNextSpawnSquadGenerated = NextSpawnSquadGenerated;

    if (!bDebugReplacement)
    {
        ConsoleCommand("Suppress KFTurboCustomZedHandler");
    }

    if (bAllowRandomness)
    {
        ReplacementRateMultiplier *= 0.5f;
    }
}

function WaveStarted(KFTurboGameType GameType, int StartedWave)
{
    local int Index;
    
    bAllowRandomness = !GameType.IsHighDifficulty();
    bRandomizeProgressAtWaveStart = bAllowRandomness;

    if (bRandomizeProgressAtWaveStart)
    {
        for (Index = 0; Index < ReplacementList.Length; Index++)
        {
            ReplacementList[Index].ReplacementProgress = FRand() * 0.75f;
        } 
    }
    else
    {
        for (Index = 0; Index < ReplacementList.Length; Index++)
        {
            ReplacementList[Index].ReplacementProgress = 0.f;
        }        
    }
}

function NextSpawnSquadGenerated(KFTurboGameType GameType, out array < class<KFMonster> > NextSpawnSquad)
{
    local int SquadIndex;
    for (SquadIndex = 0; SquadIndex < NextSpawnSquad.Length; SquadIndex++)
    {
        if (AttemptReplaceMonster(NextSpawnSquad[SquadIndex]))
        {
            break;
        }
    }
}

final function bool IncrementMonsterProgress(int Index)
{
    if (bAllowRandomness)
    {
        ReplacementList[Index].ReplacementProgress += (0.95f + (FRand() * 0.1f)) * ReplacementList[Index].ReplacementRate * ReplacementRateMultiplier;
    }
    else
    {
        ReplacementList[Index].ReplacementProgress += ReplacementList[Index].ReplacementRate * ReplacementRateMultiplier;
    }

    log("Incremented progress for monster replacement index"@Index@"to"@ReplacementList[Index].ReplacementProgress, 'KFTurboCustomZedHandler');
    if (ReplacementList[Index].ReplacementProgress < 1.f)
    {
        return false;
    }
    
    log(" - Requesting replacement with"@ReplacementList[Index].ReplacementClass, 'KFTurboCustomZedHandler');
    ReplacementList[Index].ReplacementProgress -= 1.f;
    return true;
}

function bool AttemptReplaceMonster(out class<KFMonster> Monster)
{
    local class<CoreMonster> CoreMonster;
    CoreMonster = class<CoreMonster>(CoreMonster);

    switch(CoreMonster.default.MonsterArchetypeClass)
    {
        case class'MonsterCrawlerBase':
            if (IncrementMonsterProgress(int(EReplacementIndex.Jumper)))
            {
                Monster = ReplacementList[int(EReplacementIndex.Jumper)].ReplacementClass;
                return true;
            }
            break;
        case class'MonsterGorefastBase':
            if (IncrementMonsterProgress(int(EReplacementIndex.Assassin)))
            {
                Monster = ReplacementList[int(EReplacementIndex.Assassin)].ReplacementClass;
                return true;
            }
            else if(IncrementMonsterProgress(int(EReplacementIndex.Classy)))
            {
                Monster = ReplacementList[int(EReplacementIndex.Classy)].ReplacementClass;
                return true;
            }
            break;
        case class'MonsterBloatBase':
            if (IncrementMonsterProgress(int(EReplacementIndex.Fathead)))
            {
                Monster = ReplacementList[int(EReplacementIndex.Fathead)].ReplacementClass;
                return true;
            }
            break;
        case class'MonsterSirenBase':
            if (IncrementMonsterProgress(int(EReplacementIndex.Caroler)))
            {
                Monster = ReplacementList[int(EReplacementIndex.Caroler)].ReplacementClass;
                return true;
            }
            break;
        case class'MonsterHuskBase':
            if (IncrementMonsterProgress(int(EReplacementIndex.Shotgun)))
            {
                Monster = ReplacementList[int(EReplacementIndex.Shotgun)].ReplacementClass;
                return true;
            }
            break;
    }

    return false;
}

defaultproperties
{
    bDebugReplacement=false

    ReplacementList(0)=(ReplacementClass=class'P_Gorefast_Assassin',ReplacementRate=0.075f)
    ReplacementList(1)=(ReplacementClass=class'P_Crawler_Jumper',ReplacementRate=0.075f)
    ReplacementList(2)=(ReplacementClass=class'P_Bloat_Fathead',ReplacementRate=0.075f)
    ReplacementList(3)=(ReplacementClass=class'P_Siren_Caroler',ReplacementRate=0.075f)
    ReplacementList(4)=(ReplacementClass=class'P_Gorefast_Classy',ReplacementRate=0.025f)
    ReplacementList(5)=(ReplacementClass=class'P_Husk_Shotgun',ReplacementRate=0.075f)

    bRandomizeProgressAtWaveStart=true
    ReplacementRateMultiplier=1.f
}