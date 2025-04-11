//Killing Floor Turbo TurboAchievementInt
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievementInt extends TurboAchievement
    instanced;

var protected int Value, MaxValue;

function bool SetValue(int NewValue)
{
    if (!CanBeUpdated())
    {
        return false;
    }

    if (Value == NewValue)
    {
        return false;
    }

    Value = NewValue;
    MarkUpdate();

    return CheckCompletion();
}

function bool AddValue(int Delta)
{
    local int NewValue;

    if (!CanBeUpdated())
    {
        return false;
    }

    NewValue = Max(0, Value + Delta);

    if (Value == NewValue)
    {
        return false;
    }

    Value = NewValue;
    MarkUpdate();

    return CheckCompletion();
}

function bool CheckCompletion()
{
    if (Value < MaxValue)
    {
        return false;
    }

    if (bRepeatable)
    {
        while (Value > MaxValue)
        {
            Value -= MaxValue;
            CompletionCount++;
        }
    }
    else
    {
        Value = 0;
        CompletionCount = 1;
    }

    return true;
}

simulated final function InitializeData(int NewValue, int NewCompletionCount)
{
    if (bHasInitialized)
    {
        return;
    }

    bHasInitialized = true;

    Value = NewValue;
    CompletionCount = NewCompletionCount;
    bComplete = CompletionCount > 0;
}

//Returns true if we should notify the player of the progress update. Never call this to set the authoritative value.
simulated final function bool UpdateData(int NewValue, int NewCompletionCount)
{
    local bool bValueUpdate, bCompletionCountUpdate, bShouldNotifyPlayer;
    local int NewNotificationInterval;
    bValueUpdate = NewValue > 0 && NewValue != Value;
    bCompletionCountUpdate = NewCompletionCount != CompletionCount;

    NewNotificationInterval = GetNewValueNotificationInterval(float(NewValue) / float(MaxValue));

    //Only notify the player of an achievement value changing if the value changed, this didn't cause an achievement completion, this achievement has notification intervals, and we're at a new notification interval.
    bShouldNotifyPlayer = bHasInitialized && bValueUpdate && !bCompletionCountUpdate && NotificationIntervalCount != 0 && LastNotificationInterval != NewNotificationInterval && NewNotificationInterval != 0;

    bHasInitialized = true;

    Value = NewValue;
    CompletionCount = NewCompletionCount;
    bComplete = CompletionCount > 0;
    LastNotificationInterval = NewNotificationInterval;

    return bShouldNotifyPlayer;
}

function Initialize() {}

function string ValueToJSON()
{
    return "%q"$string(Value)$"%q";
}

function Deserialize(string Data, int CompletionCount)
{
    
}

function float GetProgress()
{
    local float Progress;
    Progress = float(Value) / float(MaxValue);
    return FClamp(Progress - float(int(Progress)), 0.f, 1.f);
}

function string GetProgressText()
{
    return Value@"/"@MaxValue;
}

defaultproperties
{
    Value=0
    MaxValue=10
    NotificationIntervalCount=0
}