//Killing Floor Turbo CardFlag
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardFlag extends Object
    instanced;

var string FlagID;
var protected bool bFlagSet;

delegate OnFlagSetChanged(CardFlag Flag, bool bIsEnabled);

final function bool IsFlagSet()
{
    return bFlagSet;
}

final function SetFlag(TurboCard Card)
{
    local string ID;

    if (Card != None)
    {
        ID = Card.CardID;
    }
    else
    {
        ID = "NONE";
    }

    bFlagSet = true;
    log(FlagID$": Flag set by"@ID@".", 'KFTurboCardGame');
    UpdateFlagSetChange();
}

final function ClearFlag()
{
    bFlagSet = false;
    UpdateFlagSetChange();
}

final function UpdateFlagSetChange()
{
    OnFlagSetChanged(Self, bFlagSet);
}

defaultproperties
{
    bFlagSet = false
}