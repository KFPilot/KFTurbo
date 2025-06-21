//Killing Floor Turbo LockedInTurboLocalMessage
//Represents a reason why perk selection is locked for a player.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class LockedInTurboLocalMessage extends PerkLockTurboLocalMessage;

var string LockedInString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return FormatString(default.LockedInString);
}

defaultproperties
{
    LockedInString="You are %nknot allowed%d to %nkchange perk%d due to the %nkLocked In%d card."
    bUseFullFormatting=true
    
    bRelevantToInGameChat=true
}