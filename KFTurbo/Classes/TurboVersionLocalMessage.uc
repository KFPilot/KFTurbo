//Killing Floor Turbo TurboVersionLocalMessage
//Message to say there's an update available.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVersionLocalMessage extends TurboLocalMessage;

var localized string VersionChangeString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return FormatString(default.VersionChangeString);
}

defaultproperties
{
    VersionChangeString="A %knew version%d of %kKilling Floor Turbo%d is available! The %klatest build%d can be found at %kgithub.com/KFPilot/KFTurbo/releases%d."

    Lifetime=20
    bIsSpecial=false
    bIsConsoleMessage=true
    DrawColor=(B=255,G=255,R=255,A=255)
}