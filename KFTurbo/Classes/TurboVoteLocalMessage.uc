//Killing Floor Turbo TurboVoteLocalMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVoteLocalMessage extends TurboLocalMessage
    dependson(TurboGameVoteBase);

var localized string GenericInitiatedVoteString;
var localized string GenericSucceededVoteString;
var localized string GenericFailedVoteString;
var localized string GenericExpiredVoteString;
var localized string AnonymousUserString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    local TurboGameVoteBase.EVotingState VotingState;
    local string ResolvedString;
    
    VotingState = EVotingState(Switch & 255);

    if (class<TurboGameVoteBase>(OptionalObject) != None)
    {
        switch(VotingState)
        {
            case Started:
                ResolvedString = class<TurboGameVoteBase>(OptionalObject).static.GetVoteInitiatedString();
                break;
            case Succeeded:
                ResolvedString = class<TurboGameVoteBase>(OptionalObject).static.GetVoteSucceededString();
                break;
            case Failed:
                ResolvedString = class<TurboGameVoteBase>(OptionalObject).static.GetVoteFailedString();
                break;
            case Expired:
                ResolvedString = class<TurboGameVoteBase>(OptionalObject).static.GetVoteExpiredString();
                break;
        }
    }

    if (ResolvedString == "")
    {
        switch(VotingState)
        {
            case Started:
                ResolvedString = default.GenericInitiatedVoteString;
                break;
            case Succeeded:
                ResolvedString = default.GenericSucceededVoteString;
                break;
            case Failed:
                ResolvedString = default.GenericFailedVoteString;
                break;
            case Expired:
                ResolvedString = default.GenericExpiredVoteString;
                break;
        }
    }

    if (ResolvedString == "")
    {
        return ResolvedString;
    }

    return FormatVoteString(ResolvedString, Eval(RelatedPRI_1 == None || RelatedPRI_1.PlayerName == "", default.AnonymousUserString, RelatedPRI_1.PlayerName));
}

static final function string FormatVoteString(string Input, optional string PlayerName)
{
    return Repl(FormatString(Input), "%p", PlayerName);
}

defaultproperties
{
    GenericInitiatedVoteString="%k%p%d has started %ka vote%d."
    GenericSucceededVoteString="The %kvote%d has %ksucceeded%d."
    GenericFailedVoteString="The %kvote%d has %kfailed%d."
    GenericExpiredVoteString="The %kvote%d has %kexpired%d."
    AnonymousUserString="Someone"

    Lifetime=10
    bIsSpecial=false
    bIsConsoleMessage=true

    bUseFullFormatting=true
    bRelevantToInGameChat=true
}