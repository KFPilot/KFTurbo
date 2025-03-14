//Killing Floor Turbo TurboAchievementInt
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievementInt extends TurboAchievement
    instanced;

var protected int Value, MaxValue;

function int SetValue(int NewValue)
{
    if (!CanBeUpdated())
    {
        return Value;
    }

    if (Value == NewValue)
    {
        return Value;
    }

    Value = NewValue;
    MarkUpdate();
    return Value;
}

function int AddValue(int Delta)
{
    local int NewValue;

    if (!CanBeUpdated())
    {
        return Value;
    }

    NewValue = Max(0, Value + Delta);

    if (Value == NewValue)
    {
        return Value;
    }

    Value = NewValue;
    MarkUpdate();
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
    Value = int(LeftPart);
}

function float GetProgress()
{
    local float Progress;
    Progress = float(Value) / float(MaxValue);
    return FClamp(Progress - float(int(Progress)), 0.f, 1.f);
}

defaultproperties
{
    Value=0
    MaxValue=10
}