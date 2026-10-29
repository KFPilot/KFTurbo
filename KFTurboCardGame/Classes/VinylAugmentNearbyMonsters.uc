//Killing Floor Turbo VinylAugmentNearbyMonsters
//Scales its augment list by the number of zeds near the player.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentNearbyMonsters extends VinylAugmentBasicScaled;

var const float NearbyRadius;
var const int FullBonusCount;
var const float UpdateInterval;

var int CachedNearbyCount;
var float NextUpdateTime;

//Zeds within the radius are relevant to the owning client, so both sides can count them.
simulated function float GetScaleRatio()
{
    if (Level.TimeSeconds >= NextUpdateTime)
    {
        UpdateNearbyCount();
    }

    if (FullBonusCount <= 0)
    {
        return 0.f;
    }

    return FClamp(float(CachedNearbyCount) / float(FullBonusCount), 0.f, 1.f);
}

simulated final function UpdateNearbyCount()
{
    local Pawn OwnerPawn;
    local KFMonster Monster;
    local int NearbyCount;

    NextUpdateTime = Level.TimeSeconds + UpdateInterval + (FRand() * 0.1f);
    CachedNearbyCount = 0;

    if (OwningCardInfo == None)
    {
        return;
    }

    OwnerPawn = OwningCardInfo.GetOwnerPawn();

    if (OwnerPawn == None || OwnerPawn.Health <= 0)
    {
        return;
    }

    foreach OwnerPawn.RadiusActors(class'KFMonster', Monster, NearbyRadius)
    {
        if (Monster.Health > 0)
        {
            NearbyCount++;
        }
    }

    CachedNearbyCount = NearbyCount;
}

defaultproperties
{
    NearbyRadius=250.f
    FullBonusCount=5
    UpdateInterval=0.25f
}
