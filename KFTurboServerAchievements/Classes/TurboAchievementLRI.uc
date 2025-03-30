//Killing Floor Turbo TurboAchievementLRI
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievementLRI extends LinkedReplicationInfo;

var array<TurboAchievementPack> AchievementPackList;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    Disable('Tick');
}

simulated function RegisterPack(TurboAchievementPack Pack)
{
    AchievementPackList[AchievementPackList.Length] = Pack;
}

function string GetPlayerID()
{
    return "";
}

defaultproperties
{
    bAlwaysRelevant=false
    bOnlyRelevantToOwner=true
    bOnlyDirtyReplication=true
    bSkipActorPropertyReplication=true

    bStatic=false
    bNoDelete=false
    bHidden=true
}