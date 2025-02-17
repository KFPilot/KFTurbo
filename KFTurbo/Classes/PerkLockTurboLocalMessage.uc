//Killing Floor Turbo PerkLockTurboLocalMessage
//Represents a reason why perk selection is locked for a player.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PerkLockTurboLocalMessage extends TurboLocalMessage;

//By default all perks are locked.
static function bool CanSelectPerk(class<TurboVeterancyTypes> VeterancyClass)
{
    return false;
}

static function bool IgnoreLocalMessage(TurboPlayerController PlayerController, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return PlayerController.PlayerReplicationInfo != RelatedPRI_1;
}

defaultproperties
{
    bUseFullFormatting=true

    bIsSpecial=false
    bIsConsoleMessage=true
    Lifetime=10
}