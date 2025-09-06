//Killing Floor Turbo TurboTcpLink
//Base class for KFTurbo's TcpLink classes. Adds basic JSON operations.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTcpLink extends TcpLink
    abstract;

static final function string StringToJSON(string Key, coerce string Value)
{
    return "\""$Key$"\":\""$Value$"\"";
}

static final function string DataToJSON(string Key, coerce string Value)
{
    return "\""$Key$"\":"$Value;
}

//Will encase values in quotes before adding them into the JSON array.
static final function string StringArrayToJSON(string Key, array<string> ValueList)
{
    local string Result;
    local int Index;
    
    Result = "\""$Key$"\":[";
    for (Index = 0; Index < ValueList.Length; Index++)
    {
        Result $= "\""$ValueList[Index]$"\"";
    }

    return Result$"]";
}

//Will not encase values in quotes before adding them into the JSON array.
static final function string DataArrayToJSON(string Key, array<string> ValueList)
{
    local string Result;
    local int Index;
    
    Result = "\""$Key$"\":[";
    for (Index = 0; Index < ValueList.Length; Index++)
    {
        Result $= "\""$ValueList[Index]$"\"";
    }

    return Result$"]";
}

//Used to sanitize strings.
static final function string Sanitize(string InString)
{
    return Repl(Repl(InString, "\\", "\\\\"), "\"", "\\\"");
}