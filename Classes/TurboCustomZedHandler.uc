class TurboCustomZedHandler extends Info;

struct MonsterReplacement
{
    var class<KFMonster> TargetParentClass;
    var class<KFMonster> ReplacementClass;
    var float ChanceToReplace;
};

var array<MonsterReplacement> ReplacementList; //List of KFMonster parent classes, their replacement, and individual chance to be applied.

var KFGameType KFGT;
var float LastCheckedNextMonsterTime;

var bool bDebugReplacement;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    SetTimer(0.15f, true); //Relatively frequently. We're watching for squad changes via Invasion::NextMonsterTime.

    KFGT = KFGameType(Level.Game);
    LastCheckedNextMonsterTime = -1.f;
}

static final function DebugLog(string String)
{
    if (default.bDebugReplacement)
    {
        Log(String, 'KFTurbo');
    }
}

event Timer()
{
    if (KFGT == None || !KFGT.bWaveInProgress)
    {
        return;
    }

    //We detect new squads by asking when was the last time a squad was generated.
    if (LastCheckedNextMonsterTime >= KFGT.NextMonsterTime)
    {
        return;
    }

    LastCheckedNextMonsterTime = KFGT.NextMonsterTime + 0.15f;

    DebugLog("Applying Replacement");
    ApplyReplacementList(KFGT.NextSpawnSquad);
}

function bool ApplyReplacementList(out array< class<KFMonster> > NextSpawnSquad)
{
    local int SquadIndex;
    local bool bReplacedAnyMonsters;
    for (SquadIndex = 0; SquadIndex < NextSpawnSquad.Length; SquadIndex++)
    {
        bReplacedAnyMonsters = AttemptReplaceMonster(NextSpawnSquad[SquadIndex]) || bReplacedAnyMonsters;
    }

    return bReplacedAnyMonsters;
}

function bool AttemptReplaceMonster(out class<KFMonster> Monster)
{
    local int ReplacementIndex;
    local bool bReplacedMonster;

    for (ReplacementIndex = 0; ReplacementIndex < ReplacementList.Length; ReplacementIndex++)
    {
        if ((FRand() < ReplacementList[ReplacementIndex].ChanceToReplace) && ClassIsChildOf(Monster, ReplacementList[ReplacementIndex].TargetParentClass))
        {
            Monster = ReplacementList[ReplacementIndex].ReplacementClass;
            DebugLog("- Successful Replacement"@ReplacementList[ReplacementIndex].ReplacementClass);
            bReplacedMonster = true;
            break;
        }
    }

    return bReplacedMonster;
}

defaultproperties
{
    bDebugReplacement = false

    ReplacementList(0)=(TargetParentClass=class'P_Gorefast',ReplacementClass=class'P_Gorefast_Classy',ChanceToReplace=0.2f)
    ReplacementList(1)=(TargetParentClass=class'P_Gorefast',ReplacementClass=class'P_Gorefast_Assassin',ChanceToReplace=0.1f)
    ReplacementList(2)=(TargetParentClass=class'P_Crawler',ReplacementClass=class'P_Crawler_Jumper',ChanceToReplace=0.1f)
    ReplacementList(3)=(TargetParentClass=class'P_Bloat',ReplacementClass=class'P_Bloat_Fathead',ChanceToReplace=0.1f)
    ReplacementList(4)=(TargetParentClass=class'P_Siren',ReplacementClass=class'P_Siren_Caroler',ChanceToReplace=0.1f)
}