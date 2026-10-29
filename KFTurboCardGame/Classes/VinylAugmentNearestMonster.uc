//Killing Floor Turbo VinylAugmentNearestMonster
//Scales its augment list by how far away the closest zed is.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentNearestMonster extends VinylAugmentBasicScaled;

var const float FullBonusDistance;
var const float UpdateInterval;

var float CachedNearestDistance;
var float NextUpdateTime;

simulated function float GetScaleRatio()
{
    if (Level.TimeSeconds >= NextUpdateTime)
    {
        UpdateNearestDistance();
    }

    if (FullBonusDistance <= 0.f)
    {
        return 0.f;
    }

    return FClamp(CachedNearestDistance / FullBonusDistance, 0.f, 1.f);
}

simulated final function UpdateNearestDistance()
{
    local Pawn OwnerPawn;
    local KFMonster Monster;
    local float DistanceSquared, NearestDistanceSquared;

    NextUpdateTime = Level.TimeSeconds + UpdateInterval + (FRand() * 0.1f);
    CachedNearestDistance = 0.f;

    if (OwningCardInfo == None)
    {
        return;
    }

    OwnerPawn = OwningCardInfo.GetOwnerPawn();

    if (OwnerPawn == None || OwnerPawn.Health <= 0)
    {
        return;
    }

    NearestDistanceSquared = -1.f;

    foreach DynamicActors(class'KFMonster', Monster)
    {
        if (Monster.Health <= 0)
        {
            continue;
        }

        DistanceSquared = VSizeSquared(Monster.Location - OwnerPawn.Location);

        if (NearestDistanceSquared < 0.f || DistanceSquared < NearestDistanceSquared)
        {
            NearestDistanceSquared = DistanceSquared;
        }
    }

    if (NearestDistanceSquared < 0.f)
    {
        return;
    }

    CachedNearestDistance = Sqrt(NearestDistanceSquared);
}

defaultproperties
{
    FullBonusDistance=500.f
    UpdateInterval=0.5f
}
