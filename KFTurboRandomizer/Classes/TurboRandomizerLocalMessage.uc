//Killing Floor Turbo TurboRandomizerLocalMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboRandomizerLocalMessage extends TurboLocalMessage;

var localized string LoadoutString;
var localized string AnonymousUserString;

var localized string ProvidingLoadoutString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    local class<KFTurboRandomizerLoadoutCollection> RandomizerLoadoutCollectionClass;
    local KFTurboRandomizerLoadout Loadout;
    local int Index;
    local string InventoryString;

    if (Switch == -1)
    {
        return FormatString(default.ProvidingLoadoutString);
    }

    RandomizerLoadoutCollectionClass = class<KFTurboRandomizerLoadoutCollection>(OptionalObject);
    Loadout = RandomizerLoadoutCollectionClass.default.LoadoutList[Switch];
    InventoryString = "";

    for (Index = Loadout.WeaponList.Length - 1; Index >= 0; Index--)
    {
        if (Index != 0)
        {
            InventoryString $= Loadout.WeaponList[Index].default.ItemName $ "%d, %k";
        }
        else
        {
            InventoryString $= Loadout.WeaponList[Index].default.ItemName;
        }
    }
    
    InventoryString = Repl(default.LoadoutString, "%w", InventoryString);
    InventoryString = Repl(InventoryString, "%v", Loadout.Perk.default.VeterancyName);
    InventoryString = Repl(InventoryString, "%p", Eval(RelatedPRI_1 != None, RelatedPRI_1.PlayerName, default.AnonymousUserString));
    return FormatString(InventoryString);
}

static final function string FormatVoteString(string Input, optional string PlayerName)
{
    return Repl(FormatString(Input), "%p", PlayerName);
}

defaultproperties
{
    LoadoutString="%k%p%d: (%k%v%d) %k%w"
    AnonymousUserString="Someone"
    ProvidingLoadoutString="Providing %knew loadouts%d to players..."

    Lifetime=10
    bIsSpecial=false
    bIsConsoleMessage=true
    bUseFullFormatting=true
    
    bRelevantToInGameChat=true
}