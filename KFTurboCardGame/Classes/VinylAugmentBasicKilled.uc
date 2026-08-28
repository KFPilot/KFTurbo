//Killing Floor Turbo VinylAugmentBasicKilled
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentBasicKilled extends VinylAugmentBasicConditional;

var float KillEndTime;
var const float KillDuration;

replication
{
	reliable if (Role == ROLE_Authority)
		KillEndTime;
}

function NotifyPlayerKilledMonster(TurboPlayerController Player, KFMonster Target, class<DamageType> DamageType)
{
    KillEndTime = Level.TimeSeconds + KillDuration;
    ForceNetUpdate();
}

simulated final function bool HasRecentlyKilled()
{
    local ServerTimeActor TimeActor;

    if (TurboGameReplicationInfo(Level.GRI) == None)
    {
        return false;
    }

    TimeActor = TurboGameReplicationInfo(Level.GRI).ServerTimeActor;
    if (TimeActor == None)
    {
        return false;
    }

    return KillEndTime > TimeActor.GetServerTimeSeconds();
}

simulated function bool IsAugmentActive()
{
    return HasRecentlyKilled();
}

defaultproperties
{
    bWantsPlayerKilledMonsterEvents=true
    KillDuration=5.f
}
