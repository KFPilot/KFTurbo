//Killing Floor Turbo TurboAchievementInt
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievementFloat extends TurboAchievement
    instanced;

var protected float Value, MaxValue;

function float SetValue(float NewValue)
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

function float AddValue(float Delta)
{
    local float NewValue;
    
    if (!CanBeUpdated())
    {
        return Value;
    }

    NewValue = FMax(0, Value + Delta);

    if (Value == NewValue)
    {
        return Value;
    }

    Value = NewValue;
    MarkUpdate();
    return Value;
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

defaultproperties
{
    Value=0.f
    MaxValue=1.f
}