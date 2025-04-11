//Killing Floor Turbo TurboAchievement
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievement extends Object
    instanced
    abstract;

var protected int AchievementIndex; //Set during TurboAchievementPack::PreBeginPlay().

var localized string Title;
var localized string Description;
var Texture Icon;

var protected bool bHasInitialized; //Must be set to true once initialized.
var protected bool bHasUpdate;
var protected bool bComplete;

var bool bSaveProgress;
var protected bool bRepeatable;
var protected int CompletionCount;

var bool bPendingChange;

var protected int NotificationIntervalCount; //How many intervals to notify the player of progress updates (1 would be once at 50%, 2 would be twice at 33% and 66%, etc...).
var protected int LastNotificationInterval; //Last interval we notified at.

delegate OnAchievementComplete(TurboAchievementPack AchievementPack, TurboAchievement Achievement);


final function SetIndex(int NewIndex)
{
    if (AchievementIndex != -1)
    {
        log("ERROR - SetIndex was called on "$GetID()$" after already setting the achievement's index!", 'KFTurboServerAchievements');
        return;
    }

    AchievementIndex = NewIndex;
}

final function int GetIndex()
{
    return AchievementIndex;
}

final function string GetID()
{
    return Caps(string(Name));
}

final function string GetTitle()
{
    return Title;
}

final function string GetDescription()
{
    return Description;
}

final function Texture GetIcon()
{
    return Icon;
}

final function bool CanBeUpdated()
{
    return IsReady() && (!IsComplete() || IsRepeatable());
}

final function bool HasUpdate()
{
    return bHasUpdate;
}

final function MarkUpdate()
{
    bHasUpdate = true;
}

final function ConsumeUpdate()
{
    bHasUpdate = false;
}

final function bool IsReady()
{
    return bHasInitialized;
}

final function bool IsComplete()
{
    return bComplete;
}

final function bool IsRepeatable()
{
    return bRepeatable;
}

final function bool IsSerializable()
{
    return GetID() != "";
}

simulated final function int GetNewValueNotificationInterval(float NewProgress)
{
    local float NotificationInterval;
    
    if (NotificationIntervalCount <= 0 || NewProgress <= 0.f || NewProgress >= 1.f)
    {
        return 0;
    }

    NotificationInterval = 1.f / float(NotificationIntervalCount + 1);
    return NewProgress / NotificationInterval;
}

final function string Serialize()
{
    return Repl("{%qI%q:%q"$GetID()$"%q,%qC%q:%q"$string(CompletionCount)$"%q,%qV%q:"$ValueToJSON()$"}", "%q", Chr(34));
}

//Called when an achievement is initialized without data. Can be overriden by a child type if needed.
function InitializeDefault()
{
    bHasInitialized = true;
}

//These need to be implemented per achievement type:

//Override to provide JSON version of value. Values must be appropriately wrapped with the " character.
//DO NOT NEST A JSON OBJECT OR USE THE CHARACTERS [ OR ]. The parser is bespoke and is expecting those character to demarkate array bounds.
//Can use %q to represent the " character. The caller of this function TurboAchievement::Serialize does a Repl pass on strings to replace %q.]
function string ValueToJSON()
{
    log("ERROR: TurboAchievement::ValueToJSON was not implemented for the achievement "$Self, 'KFTurboServerAchievements');
    return "false";
}

function Deserialize(string Data, int CompletionCount)
{
    log("ERROR: TurboAchievement::Deserialize was not implemented for the achievement "$Self, 'KFTurboServerAchievements');
}

function float GetProgress()
{
    log("ERROR: TurboAchievement::GetProgress was not implemented for the achievement "$Self, 'KFTurboServerAchievements');
    return 0.f;
}

function string GetProgressText()
{
    log("ERROR: TurboAchievement::GetProgressText was not implemented for the achievement "$Self, 'KFTurboServerAchievements');
    return "";
}

static final function bool IsNumeric(string String)
{
    local int p;

	p = 0;
	while (Mid(String, p, 1) >= "0" && Mid(String, p, 1) <= "9") p++;

	if (Mid(String, p) != "")
		return false;

	return true;
}

defaultproperties
{
    AchievementIndex=-1

    bSaveProgress=true
    bHasUpdate=false
    bComplete=false

    bRepeatable=true
    CompletionCount=0

    bPendingChange=false
}