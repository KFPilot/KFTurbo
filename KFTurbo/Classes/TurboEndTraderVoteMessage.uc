//Killing Floor Turbo TurboEndTraderVoteMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboEndTraderVoteMessage extends TurboLocalMessage;

var localized string EndTraderVoteHintString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{    
    return FormatString(default.EndTraderVoteHintString);
}

defaultproperties
{
    EndTraderVoteHintString = "%kTrader time%d can be %kskipped%d by typing %kEndTrader in console%d."

    Lifetime=10
    bIsSpecial=false
    bIsConsoleMessage=true
}