//Killing Floor Turbo TurboEndTraderVoteMessage
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboEndTraderVoteMessage extends LocalMessage;

var localized string EndTraderVoteString;
var localized string AnonymousVoteUserString;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	if (RelatedPRI_1 == None || RelatedPRI_1.PlayerName == "")
    {
        return Repl(default.EndTraderVoteString, "%p", default.AnonymousVoteUserString);
    }

    return Repl(default.EndTraderVoteString, "%p", RelatedPRI_1.PlayerName);
}

defaultproperties
{
    EndTraderVoteString = "%p started a vote to end trader! Type 'EndTrader' in console to vote!"
    AnonymousVoteUserString = "Someone"

    Lifetime=10
    bIsUnique=true
    bFadeMessage=true
    StackMode=SM_None
    PosY=0.75000
    FontSize=-2
}
