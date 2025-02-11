//Killing Floor Turbo TurboVoteLocalMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVoteLocalMessage extends TurboLocalMessage;

var localized string GenericInitiatedVoteString;
var localized string AnonymousUserString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    if (class<TurboGameVoteBase>(OptionalObject) != None && class<TurboGameVoteBase>(OptionalObject).static.GetVoteInitiatedString() != "")
    {
        return FormatVoteString(class<TurboGameVoteBase>(OptionalObject).static.GetVoteInitiatedString(), Eval(RelatedPRI_1 == None || RelatedPRI_1.PlayerName == "", default.AnonymousUserString, RelatedPRI_1.PlayerName));
    }
    
    return FormatVoteString(default.GenericInitiatedVoteString, Eval(RelatedPRI_1 == None || RelatedPRI_1.PlayerName == "", default.AnonymousUserString, RelatedPRI_1.PlayerName));
}

static function final string FormatVoteString(string Input, optional string PlayerName)
{
    return Repl(FormatString(Input), "%p", PlayerName);
}

defaultproperties
{
    GenericInitiatedVoteString = "%k%p%d has started %ka vote%d."
    AnonymousUserString = "Someone"

    Lifetime=10
    bIsSpecial=false
    bIsConsoleMessage=true
}