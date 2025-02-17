//Killing Floor Turbo TurboAccoladePerkLocalMessage
//Player perk level notification class.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAccoladePerkLocalMessage extends TurboAccoladeLocalMessage;

var localized string OtherPlayerEarnedPerkLevelString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    local class<TurboVeterancyTypes> PlayerPerk;
    local string Result, TextColorCode, PerkColorCode;

    PlayerPerk = class<TurboVeterancyTypes>(OptionalObject);
    if (RelatedPRI_1 == None || PlayerPerk == None)
    {
        return "";
    }

    TextColorCode = class'GameInfo'.static.MakeColorCode(default.DrawColor);
    PerkColorCode = class'GameInfo'.static.MakeColorCode(PlayerPerk.static.GetPerkTierColor(PlayerPerk.static.GetPerkTier(Switch)));

    Result = default.OtherPlayerEarnedPerkLevelString;
    Result = Repl(Result, "%player", PerkColorCode $ RelatedPRI_1.PlayerName $ TextColorCode);
    Result = Repl(Result, "%level", PerkColorCode $ Switch $ TextColorCode);
    Result = Repl(Result, "%perk", PerkColorCode $ PlayerPerk.default.VeterancyName $ TextColorCode);
    return Result;
}

defaultproperties
{
    bDisplayForAccoladeEarner=false

    OtherPlayerEarnedPerkLevelString="%player has earned level %level %perk!"
    
    DrawColor=(R=255,G=255,B=255,A=255)
}