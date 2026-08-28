//Killing Floor Turbo VinylAugmentBasicDamaged
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentBasicDamaged extends VinylAugmentBasicConditional;

var float DamageTakenEndTime;
var const float DamageTakenDuration;

replication
{
	reliable if (Role == ROLE_Authority)
		DamageTakenEndTime;
}

function NotifyPlayerReceivedDamage(TurboPlayerController Player, KFMonster DamageInstigator, int Damage, class<DamageType> DamageType)
{
    DamageTakenEndTime = Level.TimeSeconds + DamageTakenDuration;
    ForceNetUpdate();
}

simulated final function bool WasRecentlyDamaged()
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

    return DamageTakenEndTime > TimeActor.GetServerTimeSeconds();
}

simulated function bool IsAugmentActive()
{
    return WasRecentlyDamaged();
}

defaultproperties
{
    bWantsPlayerReceivedDamageEvents=true
    DamageTakenDuration=5.f
}
