//Killing Floor Turbo TurboTcpLink
//Base class for KFTurbo's TcpLink classes. Adds basic JSON operations.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTcpLink extends TcpLink
    abstract;

const ValueReplacement = "%v";

const StringValue = "\"%v\"";

const CommaValue = ",%v";
const CommaStringValue = ",\"%v\"";

static final function string StringToJSON(string Key, coerce string Value)
{
    return Repl(StringValue, ValueReplacement, Key)$":"$Repl(StringValue, ValueReplacement, Value);
}

static final function string DataToJSON(string Key, coerce string Value)
{
    return Repl(StringValue, ValueReplacement, Key)$":"$Value;
}

//Will encase values in quotes before adding them into the JSON array.
static final function string StringArrayToJSON(string Key, array<string> ValueList)
{
    local string Result;
    local int Index;
    
    if (ValueList.Length == 0)
    {
        return Repl(StringValue, ValueReplacement, Key)$":[]";
    }

    if (ValueList.Length == 1)
    {
        return Repl(StringValue, ValueReplacement, Key)$":["$Repl(StringValue, ValueReplacement, ValueList[0])$"]";
    }

    Result = Repl(StringValue, ValueReplacement, Key)$":["$Repl(StringValue, ValueReplacement, ValueList[0]);
    for (Index = 1; Index < ValueList.Length; Index++)
    {
        Result $= Repl(CommaStringValue, ValueReplacement, ValueList[Index]);
    }

    return Result$"]";
}

//Will not encase values in quotes before adding them into the JSON array.
static final function string DataArrayToJSON(string Key, array<string> ValueList)
{
    local string Result;
    local int Index;
    
    if (ValueList.Length == 0)
    {
        return Repl(StringValue, ValueReplacement, Key)$":[]";
    }

    if (ValueList.Length == 1)
    {
        return Repl(StringValue, ValueReplacement, Key)$":["$ValueList[0]$"]";
    }

    Result = Repl(StringValue, ValueReplacement, Key)$":["$ValueList[0];
    for (Index = 1; Index < ValueList.Length; Index++)
    {
        Result $= Repl(CommaValue, ValueReplacement, ValueList[Index]);
    }

    return Result$"]";
}

//Used to sanitize strings.
static final function string Sanitize(string InString)
{
    return Repl(Repl(InString, "\\", "\\\\"), "\"", "\\\"");
}