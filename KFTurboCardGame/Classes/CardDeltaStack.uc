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

final function bool HasDeltaChanges()
{
    return DeltaList.Length != 0;
}

final function AddDelta(int Delta, TurboCard Card)
{
    local int Index;
    local string ID;

    ID = "";
    if (Card != None)
    {
        ID = Card.CardID;
    }

    log(DeltaStackID$": Applying delta"@Delta@"from"@Eval(ID != "", ID, "(NO ID)")@".", 'KFTurboCardGame');

    if (ID != "")
    {
        for (Index = DeltaList.Length - 1; Index >= 0; Index--)
        {
            if (DeltaList[Index].ID == Card.CardID)
            {
                log("-"$DeltaStackID$": Found existing entry with matching ID. Replacing value.", 'KFTurboCardGame');
                DeltaList[Index].Delta = Delta;
                UpdateDeltaChange();
                return;
            }
        }
    }

    DeltaList.Length = DeltaList.Length + 1;
    DeltaList[DeltaList.Length - 1].ID = Card.CardID;
    DeltaList[DeltaList.Length - 1].Delta = Delta;
    UpdateDeltaChange();
}

final function RemoveDelta(TurboCard Card)
{
    local int Index;

    if (Card == None)
    {
        return;
    }

    for (Index = DeltaList.Length - 1; Index >= 0; Index--)
    {
        if (DeltaList[Index].ID == Card.CardID)
        {
            log(DeltaStackID$": Removing delta applied by"@Card.CardID@".", 'KFTurboCardGame');
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