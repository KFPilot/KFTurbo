//Killing Floor Turbo KFTurboLaneTriggerMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboLaneTriggerMessage extends KFTurboLaneLocalMessage;

var localized string ToggleLaneMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return FormatString(default.ToggleLaneMessage);
}

defaultproperties
{
    bUseFullFormatting=false
    bIsConsoleMessage=false
    bFadeMessage=true
    Lifetime=10
    FontSize=-1
    bIsUnique=true
    bIsSpecial=false

    ToggleLaneMessage="Press the %kuse key%d to %ktoggle this lane%d."
}