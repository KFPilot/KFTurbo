//Killing Floor Turbo TurboKillsMessage
//Base class for kill messages. Allows for special kill notifications.
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboKillsMessage extends KFMod.KillsMessage
    DependsOn(TurboHUDWaveInfo);

var bool bOverrideTextColor;
var bool bOverrideMonsterTextColor;

//Not used by kill feed! See GetKillString().
static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	return "";
}

//Not used by kill feed! See TurboHUDWaveInfo::GetLifeTimeForMonster().
static function float GetLifeTime(int Switch)
{
	return 0;
}

//Not used by kill feed! See ShouldOverrideTextColor() and ShouldOverrideMonsterTextColor().
static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return class'HUD'.default.WhiteColor;
}

//Generates a kill string. Player name should be omitted if this kill string is for the local player.
//Modifying KillFeedEntry WILL effect the entry in the TurboHUDWaveInfo list!
static function string GetKillCountString(out TurboHUDWaveInfo.KillFeedEntry KillFeedEntry)
{
    return KillFeedEntry.Count$"x";
}

static function string GetKillString(out TurboHUDWaveInfo.KillFeedEntry KillFeedEntry)
{
	return GetNameOf(KillFeedEntry.KilledMonster);
}

//Should this kill message override the entry text's color?
static final function bool ShouldOverrideTextColor()
{
    return default.bOverrideTextColor;
}

static function color GetTextColorOverride(class<Monster> Monster, int Count)
{
	return class'HUD'.default.WhiteColor;
}

//Should this kill message override the monster's name text's color?
static final function bool ShouldOverrideMonsterTextColor()
{
    return default.bOverrideMonsterTextColor;
}

static function color GetMonsterTextColorOverride(class<Monster> Monster, int Count)
{
	return class'HUD'.default.WhiteColor;
}

defaultproperties
{
    //This local message is not responsible for drawing things!
    MessageShowTime=0.000000
    bIsConsoleMessage=False
    bFadeMessage=False
    DrawColor=(R=0,B=0,G=0,A=0)
    DrawPivot=DP_UpperLeft
    StackMode=SM_None
    PosX=-1;
    PosY=-1;
    FontSize=0

    bOverrideTextColor=false
    bOverrideMonsterTextColor=false
}
