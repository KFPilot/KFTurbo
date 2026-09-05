//Killing Floor Turbo VinylAugmentAbusementPark
//Treats its augment list as a pool and rolls RollCount of them at the start of every wave.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentAbusementPark extends VinylAugmentBasic;

var int RolledEntryMask;
var const int RollCount;

replication
{
	reliable if (Role == ROLE_Authority)
		RolledEntryMask;
}

simulated function PostNetReceive()
{
    if (Role == ROLE_Authority && RolledEntryMask == 0)
    {
        RollEntries();
        return;
    }

    ApplyRolledEntries();
}

function NotifyWaveStarted(int Wave)
{
    RollEntries();
}

function RollEntries()
{
    local int CandidateList[3];
    local int CandidateCount, Index, PickIndex;

    for (Index = 0; Index < ArrayCount(AugmentList); Index++)
    {
        if (AugmentList[Index].Type == Invalid)
        {
            continue;
        }

        CandidateList[CandidateCount] = Index;
        CandidateCount++;
    }

    RolledEntryMask = 0;

    while (CandidateCount > 0 && CountRolledEntries() < RollCount)
    {
        PickIndex = Rand(CandidateCount);
        RolledEntryMask = RolledEntryMask | (1 << CandidateList[PickIndex]);

        CandidateCount--;
        CandidateList[PickIndex] = CandidateList[CandidateCount];
    }

    ApplyRolledEntries();
    ForceNetUpdate();
}

simulated final function int CountRolledEntries()
{
    local int Index, Count;

    for (Index = 0; Index < ArrayCount(AugmentList); Index++)
    {
        if ((RolledEntryMask & (1 << Index)) != 0)
        {
            Count++;
        }
    }

    return Count;
}

simulated final function ApplyRolledEntries()
{
    local int Index;

    ResetAugmentMultipliers();

    for (Index = 0; Index < ArrayCount(AugmentList); Index++)
    {
        if (AugmentList[Index].Type == Invalid || (RolledEntryMask & (1 << Index)) == 0)
        {
            continue;
        }

        ApplyAugmentEntry(Index);
    }
}

defaultproperties
{
    bWantsWaveStartedEvents=true
    RollCount=1
}
