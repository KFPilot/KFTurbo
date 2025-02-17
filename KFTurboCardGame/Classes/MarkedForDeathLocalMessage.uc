//Killing Floor Turbo MarkedForDeathLocalMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class MarkedForDeathLocalMessage extends TurboLocalMessage;

var localized string MarkedForDeathString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    local string Result;
    Result = FormatString(default.MarkedForDeathString);
    Result = Repl(Result, "%player", RelatedPRI_1.PlayerName);
    return Result;
}

defaultproperties
{
	bIsSpecial=false
    bIsConsoleMessage=true
    Lifetime=10

    MarkedForDeathString="%k%player%d has been %kmarked for death%d this wave!"
    
    bRelevantToInGameChat=true
}