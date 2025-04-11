//Killing Floor Turbo TurboAchievementPack
//Base class for all achievement packs.
//Inspired by etsai (Scary Ghost)'s Server Achievements AchievementPack.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievementPack extends ReplicationInfo
    abstract;

var string ID; //Must be assigned. Used to lookup achievement data.
var int ListPriority; //Determines order in achievement pack list UI. Higher number means top of the list.
var localized string PackName;
var localized string PackDescription;
var protected array<TurboAchievement> AchievementList;

var TurboAchievementLRI AchievementLRI; //Related LRI for this achievement pack.

delegate OnAchievementComplete(TurboAchievementPack Pack, TurboAchievement Achievement);

replication
{
    reliable if(Role == ROLE_Authority)
        AchievementLRI;

    reliable if(Role == ROLE_Authority)
        SendIntStatus, SendFloatStatus, SendFlagStatus;
}

simulated function PreBeginPlay()
{
    local int Index;

    Super.PreBeginPlay();

    if (AchievementLRI == None && TurboAchievementLRI(Owner) != None)
    {
        AchievementLRI = TurboAchievementLRI(Owner);
    }
    
    for (Index = 0; Index < AchievementList.Length; Index++)
    {
        AchievementList[Index].SetIndex(Index);
    }
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    AchievementLRI.RegisterPack(Self);
    Disable('Tick');
    SetTimer(10, false);
}

function Timer()
{
    NetUpdateFrequency = 0.001f;
}

simulated final function TurboAchievement GetAchievement(int Index)
{
    if (Index <= -1 || Index >= AchievementList.Length)
    {
        return None;
    }

    return AchievementList[Index]; 
}

simulated final function int GetAchievementCount()
{
    return AchievementList.Length;
}

simulated final function int GetCompletedAchievementCount()
{
    local int Index;
    local int CompletedCount;

    Index = GetAchievementCount() - 1;
    CompletedCount = 0;
    
    while (Index >= 0)
    {
        if (AchievementList[Index] != None && AchievementList[Index].IsComplete())
        {
            CompletedCount++;
        }

        Index--;
    }

    return CompletedCount;
}

final function bool HasUpdate()
{
    local int Index;
    Index = GetAchievementCount() - 1;
    while (Index >= 0)
    {
        if (AchievementList[Index] != None && AchievementList[Index].HasUpdate())
        {
            return true;
        }

        Index--;
    }

    return false;
}

final function bool IsSerializable()
{
    return default.ID != "" && GetPlayerID() != "";
}

final function string GetPlayerID()
{
    return AchievementLRI.GetPlayerID();
}

final function string Serialize()
{
    local string Data;
    local int Index, AchievementCount;
    local bool bHasEntry;

    local TurboAchievement Achievement;

    if (!IsSerializable())
    {
        return "";
    }

    Data = Repl("{%qPlayerID%q:%q"$GetPlayerID()$"%q,%qPackID%q:%q"$ID$"%q,%qData%q:[", "%q", Chr(34));

    Index = 0;
    AchievementCount = GetAchievementCount();
    bHasEntry = false;
    
    while (Index < AchievementCount)
    {
        Achievement = AchievementList[Index];

        if (Achievement != None && Achievement.IsSerializable() && Achievement.HasUpdate())
        {
            if (bHasEntry)
            {
                Data $= ","$Achievement.Serialize();
            }
            else
            {
                Data $= Achievement.Serialize();
            }

            Achievement.ConsumeUpdate();
            bHasEntry = true;
        }

        Index++;
    }
    
    Data $= "]}";
    return Data;
}

final function Deserialize(TurboAchievementPackDataParser Parser)
{
    local int Index, DataIndex;

    if (Parser.ParserResult == Failure || Parser.PackID != ID)
    {
        InitializeAllDefault(); //Tell all packs to initialize new.
        return;
    }

    DataIndex = 0;
    for (Index = 0; Index < AchievementList.Length; Index++)
    {
        if (AchievementList[Index].GetID() != Parser.AchievementDataList[DataIndex].ID)
        {
            continue;
        }
        
        AchievementList[Index].Deserialize(Parser.AchievementDataList[DataIndex].Value, Parser.AchievementDataList[DataIndex].CompletionCount);

        DataIndex++;
    }
}

final function InitializeAllDefault()
{
    local int Index;
    Index = GetAchievementCount() - 1;

    while (Index >= 0)
    {
        if (AchievementList[Index].IsReady())
        {
            continue;
        }

        AchievementList[Index].InitializeDefault();
        Index--;
    }
}

final function AddProgressInt(TurboAchievementInt Achievement, int Delta)
{
    if (Delta == 0)
    {
        return;
    }

    if (!Achievement.AddValue(Delta))
    {
        return;
    }

    OnAchievementComplete(Self, Achievement);
    SendAchievementCompleted(Achievement.GetIndex());
}

final function AddProgressFloat(TurboAchievementFloat Achievement, float Delta)
{
    if (Delta == 0)
    {
        return;
    }

    if (!Achievement.AddValue(Delta))
    {
        return;
    }

    OnAchievementComplete(Self, Achievement);
    SendAchievementCompleted(Achievement.GetIndex());
}

final function SetFlag(TurboAchievementFlag Achievement)
{
    if (!Achievement.SetFlag())
    {
        return;
    }

    OnAchievementComplete(Self, Achievement);
    SendAchievementCompleted(Achievement.GetIndex());
}

simulated function Tick(float DeltaTime)
{
    if (AchievementLRI == None)
    {
        return;
    }

    AchievementLRI.RegisterPack(Self);
    Disable('Tick');
}

simulated function SendAchievementCompleted(int Index)
{
    if (Role == ROLE_Authority)
    {
        return;
    }

    OnAchievementComplete(Self, AchievementList[Index]);
}

simulated function SendIntStatus(int Index, int Value, int CompletionCount)
{
    local TurboAchievementInt Achievement;

    if (Role == ROLE_Authority)
    {
        return;
    }

    Achievement = TurboAchievementInt(AchievementList[Index]);

    if (Achievement == None)
    {
        log("Error - Received a SentIntStatus for achievement pack"@Self@"at index"@Index@"but the achievement was of type"@AchievementList[Index]$". Ignoring.", 'KFTurboServerAchievements');
        return;
    }

    Achievement.UpdateData(Value, CompletionCount);
}

simulated function SendFloatStatus(int Index, float Value, int CompletionCount)
{
    local TurboAchievementFloat Achievement;

    if (Role == ROLE_Authority)
    {
        return;
    }

    Achievement = TurboAchievementFloat(AchievementList[Index]);

    if (Achievement == None)
    {
        log("Error - Received a SendFloatStatus for achievement pack"@Self@"at index"@Index@"but the achievement was of type"@AchievementList[Index]$". Ignoring.", 'KFTurboServerAchievements');
        return;
    }
    
    Achievement.UpdateData(Value, CompletionCount);
}

simulated function SendFlagStatus(int Index, int CompletionCount)
{
    local TurboAchievementFlag Achievement;

    if (Role == ROLE_Authority)
    {
        return;
    }

    Achievement = TurboAchievementFlag(AchievementList[Index]);

    if (Achievement == None)
    {
        log("Error - Received a SendFlagStatus for achievement pack"@Self@"at index"@Index@"but the achievement was of type"@AchievementList[Index]$". Ignoring.", 'KFTurboServerAchievements');
        return;
    }
    
    Achievement.UpdateData(CompletionCount);
}

defaultproperties
{
    ID=""

    bAlwaysRelevant=false
    bOnlyRelevantToOwner=true
    bOnlyDirtyReplication=true
    bSkipActorPropertyReplication=true

    bStatic=false
    bNoDelete=false
    bHidden=true
}