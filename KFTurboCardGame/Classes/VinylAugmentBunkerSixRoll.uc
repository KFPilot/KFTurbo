//Killing Floor Turbo VinylAugmentBunkerSixRoll
//Rolls a single augment entry when first applied, then ramps it like VinylAugmentBunkerSix.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentBunkerSixRoll extends VinylAugmentBunkerSix;

var int RolledIndex;

replication
{
	reliable if (Role == ROLE_Authority)
		RolledIndex;
}

simulated function PostNetReceive()
{
    if (Role == ROLE_Authority && RolledIndex < 0)
    {
        RollEntry();
    }

    ApplyRolledEntry();
}

function RollEntry()
{
    local int CandidateList[3];
    local int CandidateCount, Index;

    for (Index = 0; Index < ArrayCount(AugmentList); Index++)
    {
        if (AugmentList[Index].Type == Invalid)
        {
            continue;
        }

        CandidateList[CandidateCount] = Index;
        CandidateCount++;
    }

    if (CandidateCount == 0)
    {
        return;
    }

    RolledIndex = CandidateList[Rand(CandidateCount)];
    ForceNetUpdate();
}

simulated final function ApplyRolledEntry()
{
    ResetAugmentMultipliers();

    if (RolledIndex < 0 || RolledIndex >= ArrayCount(AugmentList) || AugmentList[RolledIndex].Type == Invalid)
    {
        return;
    }

    ApplyAugmentEntry(RolledIndex);
}

defaultproperties
{
    RolledIndex=-1
}
