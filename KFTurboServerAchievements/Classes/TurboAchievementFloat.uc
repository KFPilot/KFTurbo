//Killing Floor Turbo TurboAchievementInt
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievementFloat extends TurboAchievement
    instanced;

var protected float Value, MaxValue;

function bool SetValue(float NewValue)
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

function bool AddValue(float Delta)
{
    local float NewValue;
    
    if (!CanBeUpdated())
    {
        return false;
    }

    NewValue = FMax(0, Value + Delta);

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

simulated final function InitializeData(float NewValue, int NewCompletionCount)
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
simulated final function bool UpdateData(float NewValue, int NewCompletionCount)
{
    local bool bValueUpdate, bCompletionCountUpdate, bShouldNotifyPlayer;
    local int NewNotificationInterval;
    bValueUpdate = NewValue > 0.f && NewValue != Value;
    bCompletionCountUpdate = NewCompletionCount != CompletionCount;

    NewNotificationInterval = GetNewValueNotificationInterval(NewValue / MaxValue);

    //Only notify the player of an achievement value changing if the value changed, this didn't cause an achievement completion, this achievement has notification intervals, and we're at a new notification interval that isn't 0.
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

function PopulateFromJSON(string JSON)
{
    local string LeftPart, RightPart;
    Divide(JSON, "V", LeftPart, RightPart);
    LeftPart = Mid(RightPart, 1, Len(RightPart) - 2);
    Value = float(LeftPart);
}

function float GetProgress()
{
    local float Progress;
    Progress = Value / MaxValue;
    return FClamp(Progress - float(int(Progress)), 0.f, 1.f);
}

function string GetProgressText()
{
    return int(Value)@"/"@int(Round(MaxValue));
}

defaultproperties
{
    Value=0.f
    MaxValue=1.f
}