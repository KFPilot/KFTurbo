//Killing Floor Turbo TurboAchievementFlag
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievementFlag extends TurboAchievement
    instanced;

var localized string ProgressCompleteString;
var localized string ProgressIncompleteString;

function SetFlag()
{
    if (!CanBeUpdated())
    {
        return;
    }

    if (!bComplete)
    {
        bComplete = true;
    }

    CompletionCount++;
    MarkUpdate();
}

simulated final function InitializeData(int NewCompletionCount)
{
    if (bHasInitialized)
    {
        return;
    }

    bHasInitialized = true;

    CompletionCount = NewCompletionCount;
    bComplete = CompletionCount > 0;
}

simulated final function UpdateData(int NewCompletionCount)
{
    CompletionCount = NewCompletionCount;
    bComplete = CompletionCount > 0;
}

function Initialize() {}

function string ValueToJSON()
{
    return string((CompletionCount > 0));
}

function PopulateFromJSON(string JSON)
{
    local string LeftPart, RightPart;
    Divide(JSON, "V", LeftPart, RightPart);
    LeftPart = Mid(RightPart, 1, Len(RightPart) - 2);
    CompletionCount = float(LeftPart);
}

function float GetProgress()
{
    if (CompletionCount > 0)
    {
        return 1.f;
    }
    else
    {
        return 0.f;
    }
}

function string GetProgressText()
{
    return Eval(IsComplete(), ProgressCompleteString, ProgressIncompleteString);
}

defaultproperties
{
    bComplete=false
}