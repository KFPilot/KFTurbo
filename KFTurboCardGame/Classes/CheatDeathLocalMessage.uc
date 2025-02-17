//Killing Floor Turbo CheatDeathLocalMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CheatDeathLocalMessage extends TurboLocalMessage;

var localized string CheatDeathString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    local string Result;
    Result = FormatString(default.CheatDeathString);
    Result = Repl(Result, "%player", RelatedPRI_1.PlayerName);
    return Result;
}

defaultproperties
{
    bIsSpecial=false
    bIsConsoleMessage=true
    Lifetime=10

    CheatDeathString="%k%player%d has %kcheated death%d!"
    bRelevantToInGameChat=true
}