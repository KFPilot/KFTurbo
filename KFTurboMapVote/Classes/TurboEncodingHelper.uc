//Killing Floor Turbo TurboEncodingHelper
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboEncodingHelper extends Object
    abstract;

var array<string> HexArray;
var int ZeroCharOffset;
var int ACharOffset;

static final function string IntToHex(int Number)
{
    local string Result;
    local int HexDigit;

    if (Number == 0)
    {
        return "0";
    }

    Result = "";
    while (Number != 0)
    {
        HexDigit = Number & 0xF;
        Result = default.HexArray[HexDigit] $ Result;
        Number = Number >> 4;
    }

    return Result;
}

static final function int HexToInt(string Hex)
{
    local int HexIndex, HexLength, Value, Digit;
    local string HexChar;

    HexLength = Len(Hex);
    Value = 0;

    for (HexIndex = 0; HexIndex < HexLength; HexIndex++)
    {
        HexChar = Mid(Hex, HexIndex, 1);

        if (HexChar >= "0" && HexChar <= "9")
        {
            Digit = Asc(HexChar) - default.ZeroCharOffset;
        }
        else if (HexChar >= "A" && HexChar <= "F")
        {
            Digit = (Asc(HexChar) - default.ACharOffset) + 10;
        }
        else
        {
            continue;
        }

        Value = (Value << 4) + Digit;
    }

    return Value;
}

defaultproperties
{
    HexArray(0)="0";
    HexArray(1)="1";
    HexArray(2)="2";
    HexArray(3)="3";
    HexArray(4)="4";
    HexArray(5)="5";
    HexArray(6)="6";
    HexArray(7)="7";
    HexArray(8)="8";
    HexArray(9)="9";
    HexArray(10)="A";
    HexArray(11)="B";
    HexArray(12)="C";
    HexArray(13)="D";
    HexArray(14)="E";
    HexArray(15)="F";

    ZeroCharOffset=48
    ACharOffset=65
}