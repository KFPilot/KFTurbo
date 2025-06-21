//Killing Floor Turbo CardModifierStack
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardModifierStack extends Object
	instanced;

var string ModifierStackID;

struct CardModifierEntry
{
    var float Modifier;
    var string ID;
};

var protected array<CardModifierEntry> ModifierList;
var protected float CachedModifier;

delegate OnModifierChanged(CardModifierStack ModifiedStack, float Modifier);

function float GetModifier()
{
    return CachedModifier;
}

final function bool HasModifiers()
{
    return ModifierList.Length != 0;
}

final function AddModifier(float Modifier, TurboCard Card)
{
    local string ID;

    ID = "";
    if (Card != None)
    {
        ID = Card.CardID;
    }

    log(ModifierStackID$": Applying modifier"@Modifier@"from"@Eval(ID != "", ID, "(NO ID)")@".", 'KFTurboCardGame');
    ModifierList.Length = ModifierList.Length + 1;
    ModifierList[ModifierList.Length - 1].ID = ID;
    ModifierList[ModifierList.Length - 1].Modifier = Modifier;
    UpdateModifier();
}

final function RemoveModifier(TurboCard Card)
{
    local int Index;

    if (Card == None)
    {
        return;
    }

    for (Index = ModifierList.Length - 1; Index >= 0; Index--)
    {
        if (ModifierList[Index].ID == Card.CardID)
        {
            log(ModifierStackID$": Removing modifier applied by"@Card.CardID@".", 'KFTurboCardGame');
            ModifierList.Remove(Index, 1);
            UpdateModifier();
            return;
        }
    }

    log(ModifierStackID$": Failed to remove any modifiers applied by"@Card.CardID@".", 'KFTurboCardGame');
}

final function ClearModifiers()
{
    ModifierList.Length = 0;
    UpdateModifier();
}

function UpdateModifier()
{
    local int Index;
    CachedModifier = default.CachedModifier;
    for (Index = ModifierList.Length - 1; Index >= 0; Index--)
    {
        CachedModifier *= ModifierList[Index].Modifier;
    }

    log(ModifierStackID$": New modifier value is"@CachedModifier@".", 'KFTurboCardGame');
    OnModifierChanged(Self, CachedModifier);
}

defaultproperties
{
    CachedModifier = 1.f
}