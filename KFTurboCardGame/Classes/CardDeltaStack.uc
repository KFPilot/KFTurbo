//Killing Floor Turbo CardDeltaStack
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardDeltaStack extends Object
	instanced;

var string DeltaStackID;

struct CardDeltaEntry
{
    var int Delta;
    var string ID;
};

var array<CardDeltaEntry> DeltaList;
var int CachedDelta;

delegate OnDeltaChanged(CardDeltaStack ChangedDelta, int Delta);

function float GetDelta()
{
    return CachedDelta;
}

final function float GetDefaultDelta()
{
    return default.CachedDelta;
}

final function bool HasDeltaChanges()
{
    return DeltaList.Length != 0;
}

final function bool IsDefaultValue()
{
    return CachedDelta == default.CachedDelta;
}

final function string Describe()
{
    local int Index;
    local string Result;

    if (DeltaList.Length == 0)
    {
        return "";
    }

    Result = DeltaList[0].ID@":"@DeltaList[0].Delta;
    for (Index = 1; Index < DeltaList.Length; Index++)
    {
        Result $= ","@DeltaList[Index].ID@":"@DeltaList[Index].Delta;
    }

    return Result;
}

final function AddDelta(int Delta, TurboCard Card)
{
    local string ID;

    ID = "NONE";
    if (Card != None)
    {
        ID = Card.CardID;
    }

    log(DeltaStackID$": Adding delta"@Delta@"applied by"@ID@".", 'KFTurboCardGame');
    DeltaList.Length = DeltaList.Length + 1;
    DeltaList[DeltaList.Length - 1].ID = ID;
    DeltaList[DeltaList.Length - 1].Delta = Delta;
    UpdateDeltaChange();
}

final function RemoveDelta(TurboCard Card)
{
local string ID;
    local int Index;

    ID = "NONE";
    if (Card != None)
    {
        ID = Card.CardID;
    }

    for (Index = DeltaList.Length - 1; Index >= 0; Index--)
    {
        if (DeltaList[Index].ID == ID)
        {
            log(DeltaStackID$": Removing delta applied by"@ID@".", 'KFTurboCardGame');
            DeltaList.Remove(Index, 1);
            UpdateDeltaChange();
            return;
        }
    }
}

final function ClearDeltaChanges()
{
    DeltaList.Length = 0;
    UpdateDeltaChange();
}

final function UpdateDeltaChange()
{
    local int Index;
    CachedDelta = default.CachedDelta;
    for (Index = DeltaList.Length - 1; Index >= 0; Index--)
    {
        CachedDelta += DeltaList[Index].Delta;
    }

    log(DeltaStackID$": New delta value is"@CachedDelta@".", 'KFTurboCardGame');
    OnDeltaChanged(Self, CachedDelta);
}

defaultproperties
{
    CachedDelta = 0
}
