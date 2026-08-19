//Killing Floor Turbo TurboServerSaturationMessage
//Message used to notify clients the server has paused due to network saturation.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboServerSaturationMessage extends TurboLocalMessage;

enum ENotificationType
{
    Start,
    Continue,
    Restart,
    End,
    Unpaused,
    TMinusThree,
    TMinusTwo,
    TMinusOne
};

var localized string SaturationStartMessage;
var localized string SaturationContinueMessage;
var localized string SaturationRestartMessage;
var localized string SaturationEndMessage;
var localized string UnpausedMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    switch(ENotificationType(Switch))
    {
        case Start:
            return FormatString(default.SaturationStartMessage);
        case Continue:
            return FormatString(default.SaturationContinueMessage);
        case Restart:
            return FormatString(default.SaturationRestartMessage);
        case End:
            return FormatString(default.SaturationEndMessage);
        case Unpaused:
            return FormatString(default.UnpausedMessage);
        case TMinusThree:
            return "3...";
        case TMinusTwo:
            return "2...";
        case TMinusOne:
            return "1...";
    }

}

static function bool IsRelevantToInGameChat(TurboPlayerController PlayerController, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    switch(ENotificationType(Switch))
    {
        case TMinusThree:
        case TMinusTwo:
        case TMinusOne:
            return false;
    }

    return default.bRelevantToInGameChat;
}

static function bool IsConsoleMessage(int Switch)
{
    switch(ENotificationType(Switch))
    {
        case TMinusThree:
        case TMinusTwo:
        case TMinusOne:
            return false;
    }

    return default.bIsConsoleMessage;
}

defaultproperties
{
    SaturationStartMessage="%nkNetwork saturation %ddetected on the %nkserver%d. %akPausing until it subsides%d."
    SaturationContinueMessage="%nkNetwork saturation continues%d. %dPlayers may unpause the game manually using %kVOTE UNPAUSE%d."
    SaturationRestartMessage="%nkNetwork saturation detected%d. %akCancelling count down%d."
    SaturationEndMessage="%nkNetwork saturation %dhas %pkstopped%d. %akUnpausing the game in 3 seconds%d."
    UnpausedMessage="%pkUnpaused game%d."
    bUseFullFormatting=true
    bRelevantToInGameChat=true

    Lifetime=10
    bIsSpecial=false
    bIsConsoleMessage=true
}
