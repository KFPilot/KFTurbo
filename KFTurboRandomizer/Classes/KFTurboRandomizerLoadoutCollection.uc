//Killing Floor Turbo KFTurboRandomizerLoadoutCollection
//Represents a collection of loadouts.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboRandomizerLoadoutCollection extends Object;

var editinline array<KFTurboRandomizerLoadout> LoadoutList;
var array<KFTurboRandomizerLoadout> OriginalLoadoutList;

function int GetRandomIndex()
{
    return Rand(LoadoutList.Length);
}

function KFTurboRandomizerLoadout GetRandomLoadout()
{
    local int Index;
    local KFTurboRandomizerLoadout Loadout;

    if (LoadoutList.Length == 0)
    {
        LoadoutList = OriginalLoadoutList;
    }

    Index = GetRandomIndex();
    Loadout = LoadoutList[Index];
    LoadoutList.Remove(Index, 1);
    return Loadout;
}

function InitializeCollection()
{
    local int Index;

    for (Index = 0; Index < LoadoutList.Length; Index++)
    {
        LoadoutList[Index].DefaultIndex = Index;
    }

    OriginalLoadoutList = LoadoutList;
}

defaultproperties
{
    
}