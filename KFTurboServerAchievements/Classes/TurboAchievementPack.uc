//Killing Floor Turbo TurboAchievementPack
//Inspired by etsai (Scary Ghost)'s Server Achievements AchievementPack.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievementPack extends Info
    abstract;

var string ID; //Must be assigned. Used to lookup achievement data.
var localized string PackName;
var localized string PackDescription;
var protected array<TurboAchievement> AchievementList;

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

    Index = GetAchievementCount();
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

final function bool IsSerializable()
{
    return default.ID != "";
}

final function string GenerateJSONData()
{
    local string Data;
    local int Index;
    local bool bHasEntry;

    local TurboAchievement Achievement;
    Data = Repl("{%qID%q:%q"$ID$"%q,%qData%q:[", "%q", Chr(34));

    Index = GetAchievementCount();
    bHasEntry = false;
    
    while (Index >= 0)
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

        Index--;
    }
    
    Data $= "]}";
    return Data;
}

defaultproperties
{
    ID=""

    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=false
    bOnlyRelevantToOwner=true
    bOnlyDirtyReplication=true
    bSkipActorPropertyReplication=true

    bStatic=false
    bNoDelete=false
    bHidden=true
}