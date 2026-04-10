//Killing Floor Turbo CardFlag
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardFlag extends Object
    instanced;

var string FlagID;
var protected bool bFlagSet;
var array<string> IDList;

delegate OnFlagSetChanged(CardFlag Flag, bool bIsEnabled);

final function bool IsFlagSet()
{
    return bFlagSet;
}

final function bool IsFlagSetDefault()
{
    return default.bFlagSet;
}

final function bool IsFlagSetToDefault()
{
    return bFlagSet == default.bFlagSet;
}

final function string Describe()
{
    local int Index;
    local string Result;

    if (IDList.Length == 0)
    {
        return "";
    }

    Result = IDList[0];
    for (Index = 1; Index < IDList.Length; Index++)
    {
        Result $= ","@IDList[Index];
    }

    return Result;
}

final function SetFlag(TurboCard Card)
{
    local string ID;

    if (Card != None && Card.CardID != "")
    {
        ID = Card.CardID;
    }
    else
    {
        ID = "NONE";
    }

    IDList[IDList.Length] = ID;
    bFlagSet = true;
    UpdateFlagSetChange();
}

final function ClearFlag(TurboCard Card)
{
    local string ID;
    local int Index;

    if (Card != None && Card.CardID != "")
    {
        ID = Card.CardID;
    }
    else
    {
        ID = "NONE";
    }

    for (Index = IDList.Length - 1; Index >= 0; Index--)
    {
        if (IDList[Index] == ID)
        {
            IDList.Remove(Index, 1);
            bFlagSet = IDList.Length != 0;
            UpdateFlagSetChange();
            return;
        }
    }
}

final function UpdateFlagSetChange()
{
    OnFlagSetChanged(Self, bFlagSet);
}

defaultproperties
{
    bFlagSet = false
}