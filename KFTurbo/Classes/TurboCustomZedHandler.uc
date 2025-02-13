//Killing Floor Turbo TurboCustomZedHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCustomZedHandler extends Info;

struct MonsterReplacement
{
    var class<KFMonster> TargetParentClass;
    var class<KFMonster> ReplacementClass;
    var float ReplacementRate;
    var float ReplacementProgress;
};

var array<MonsterReplacement> ReplacementList; //List of KFMonster parent classes, their replacement, and individual chance to be applied.

var KFTurboGameType TurboGT;
var float LastCheckedNextMonsterTime;

var bool bDebugReplacement;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    SetTimer(0.025f, true); //Relatively frequently. We're watching for squad changes via Invasion::NextMonsterTime.

    TurboGT = KFTurboGameType(Level.Game);
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
    if (TurboGT == None || !TurboGT.bWaveInProgress)
    {
        return;
    }

    //We detect new squads by asking when was the last time a squad was generated.
    if (LastCheckedNextMonsterTime >= TurboGT.NextMonsterTime)
    {
        return;
    }

    LastCheckedNextMonsterTime = TurboGT.NextMonsterTime + 0.025f;

    DebugLog("Applying Replacement");
    ApplyReplacementList(TurboGT.NextSpawnSquad);
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

    bReplacedMonster = false;

    for (ReplacementIndex = 0; ReplacementIndex < ReplacementList.Length; ReplacementIndex++)
    {
        if (!ClassIsChildOf(Monster, ReplacementList[ReplacementIndex].TargetParentClass))
        {
            continue;
        }

        ReplacementList[ReplacementIndex].ReplacementProgress += ReplacementList[ReplacementIndex].ReplacementRate;

        if (ReplacementList[ReplacementIndex].ReplacementProgress < 1.f)
        {
            break;
        }

        ReplacementList[ReplacementIndex].ReplacementProgress -= 1.f;
        Monster = ReplacementList[ReplacementIndex].ReplacementClass;
        DebugLog("- Successful Replacement"@ReplacementList[ReplacementIndex].ReplacementClass);
        bReplacedMonster = true;
        break;
    }

    return bReplacedMonster;
}

defaultproperties
{
    bDebugReplacement = false

    ReplacementList(0)=(TargetParentClass=class'P_Gorefast',ReplacementClass=class'P_Gorefast_Assassin',ReplacementRate=0.075f)
    ReplacementList(1)=(TargetParentClass=class'P_Crawler',ReplacementClass=class'P_Crawler_Jumper',ReplacementRate=0.1f)
    ReplacementList(2)=(TargetParentClass=class'P_Bloat',ReplacementClass=class'P_Bloat_Fathead',ReplacementRate=0.05f)
    ReplacementList(3)=(TargetParentClass=class'P_Siren',ReplacementClass=class'P_Siren_Caroler',ReplacementRate=0.075f)
    ReplacementList(4)=(TargetParentClass=class'P_Gorefast',ReplacementClass=class'P_Gorefast_Classy',ReplacementRate=0.05f)
}