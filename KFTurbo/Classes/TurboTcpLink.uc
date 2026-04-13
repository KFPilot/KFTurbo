//Killing Floor Turbo TurboTcpLink
//Base class for KFTurbo's TcpLink classes. Adds basic JSON operations.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTcpLink extends TcpLink
    abstract;

var const array<string> Base64Alphabet;

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

//Appends the UTF-8 bytes of a single Unicode codepoint to the byte array.
static final function AppendUTF8Bytes(out array<int> Bytes, int Codepoint)
{
    if (Codepoint < 0x80)
    {
        Bytes[Bytes.Length] = Codepoint;
    }
    else if (Codepoint < 0x800)
    {
        Bytes[Bytes.Length] = 0xC0 | ((Codepoint >> 6) & 0x1F);
        Bytes[Bytes.Length] = 0x80 | ( Codepoint       & 0x3F);
    }
    else if (Codepoint < 0x10000)
    {
        Bytes[Bytes.Length] = 0xE0 | ((Codepoint >> 12) & 0x0F);
        Bytes[Bytes.Length] = 0x80 | ((Codepoint >>  6) & 0x3F);
        Bytes[Bytes.Length] = 0x80 | ( Codepoint        & 0x3F);
    }
    else
    {
        Bytes[Bytes.Length] = 0xF0 | ((Codepoint >> 18) & 0x07);
        Bytes[Bytes.Length] = 0x80 | ((Codepoint >> 12) & 0x3F);
        Bytes[Bytes.Length] = 0x80 | ((Codepoint >>  6) & 0x3F);
        Bytes[Bytes.Length] = 0x80 | ( Codepoint        & 0x3F);
    }
}

static final function string Base64Encode(string InString)
{
    local int Index, Length, B0, B1, B2;
    local array<int> Bytes;
    local string Result;
    
    Length = Len(InString);
    for (Index = 0; Index < Length; Index++)
    {
        AppendUTF8Bytes(Bytes, Asc(Mid(InString, Index, 1)));
    }

    Length = Bytes.Length;
    Index = 0;

    while (Index + 2 < Length)
    {
        B0 = Bytes[Index];
        B1 = Bytes[Index + 1];
        B2 = Bytes[Index + 2];

        Result $= default.Base64Alphabet[ (B0 >> 2) & 0x3F];
        Result $= default.Base64Alphabet[((B0 << 4) & 0x30) | ((B1 >> 4) & 0x0F)];
        Result $= default.Base64Alphabet[((B1 << 2) & 0x3C) | ((B2 >> 6) & 0x03)];
        Result $= default.Base64Alphabet[ B2 & 0x3F];

        Index += 3;
    }

    if (Index < Length)
    {
        B0 = Bytes[Index];
        Result $= default.Base64Alphabet[(B0 >> 2) & 0x3F];

        if (Index + 1 < Length)
        {
            B1 = Bytes[Index + 1];
            Result $= default.Base64Alphabet[((B0 << 4) & 0x30) | ((B1 >> 4) & 0x0F)];
            Result $= default.Base64Alphabet[ (B1 << 2) & 0x3C];
            Result $= "=";
        }
        else
        {
            Result $= default.Base64Alphabet[(B0 << 4) & 0x30];
            Result $= "==";
        }
    }

    return Result;
}

defaultproperties
{
    Base64Alphabet=("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9","+","/")
}