//Killing Floor Turbo VinylAugmentBasicHealer
//Applies its augment list for a while after the player heals a teammate.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentBasicHealer extends VinylAugmentBasicConditional;

var float HealedEndTime;
var const float HealedDuration;

replication
{
	reliable if (Role == ROLE_Authority)
		HealedEndTime;
}

function NotifyPlayerHealed(Pawn Instigator, Pawn Target, int HealingAmount)
{
    if (OwningCardInfo == None || Instigator != OwningCardInfo.GetOwnerPawn())
    {
        return;
    }

    HealedEndTime = Level.TimeSeconds + HealedDuration;
    ForceNetUpdate();
}

simulated function bool IsAugmentActive()
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

    return HealedEndTime > TimeActor.GetServerTimeSeconds();
}

defaultproperties
{
    bWantsPlayerHealedEvents=true
    HealedDuration=5.f
}
