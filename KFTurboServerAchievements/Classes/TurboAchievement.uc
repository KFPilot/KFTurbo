//Killing Floor Turbo TurboAchievement
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievement extends Object
    instanced
    abstract;

var localized string Title;
var localized string Description;
var Texture Icon;

var protected bool bHasUpdate;
var protected bool bComplete;

var bool bSaveProgress;
var protected bool bRepeatable;
var protected int CompletionCount;

var bool bPendingChange;
var int NotificationIntervalCount;

final function Name GetID()
{
    return Name;
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
    return !IsRepeatable() && IsComplete();
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
    return GetID() != '';
}

final function string Serialize()
{
    return Repl("{%qID%q:%q"$GetID()$"%q,%qC%q:%q"$string(CompletionCount)$"%q,%qV%q:"$ValueToJSON()$"}", "%q", Chr(34));
}

//These need to be implemented per achievement type:

function Initialize()
{
    log("ERROR: TurboAchievement::Initialize was not implemented for the achievement "$Self, 'TurboAchievement');
}

//Override to provide JSON version of value. Values must either be JSON objects or appropriately wrapped with ".
//Can use %q to represent ". The caller of this function TurboAchievement::Serialize does a Repl pass on strings to replace %q with ".
function string ValueToJSON()
{
    log("ERROR: TurboAchievement::ValueToJSON was not implemented for the achievement "$Self, 'TurboAchievement');
    return "false";
}

function PopulateFromJSON(string JSON)
{
    log("ERROR: TurboAchievement::PopulateFromJSON was not implemented for the achievement "$Self, 'TurboAchievement');
}

function float GetProgress()
{
    log("ERROR: TurboAchievement::GetProgress was not implemented for the achievement "$Self, 'TurboAchievement');
    return 0.f;
}

defaultproperties
{
    bSaveProgress=true
    bHasUpdate=false
    bComplete=false

    bRepeatable=true
    CompletionCount=0

    bPendingChange=false
    NotificationIntervalCount=0
}