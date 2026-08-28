//Killing Floor Turbo KFTurboGameTypeHelper
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboGameTypeHelper extends Object
    abstract;

//Reverses the Windows-1252 -> Unicode encoding
static final function int CodepointToCP1252Byte(int Codepoint)
{
    if (Codepoint < 0x80)
    {
        return Codepoint;
    }

    switch (Codepoint)
    {
        case 0x20AC: return 0x80;
        case 0x201A: return 0x82;
        case 0x0192: return 0x83;
        case 0x201E: return 0x84;
        case 0x2026: return 0x85;
        case 0x2020: return 0x86;
        case 0x2021: return 0x87;
        case 0x02C6: return 0x88;
        case 0x2030: return 0x89;
        case 0x0160: return 0x8A;
        case 0x2039: return 0x8B;
        case 0x0152: return 0x8C;
        case 0x017D: return 0x8E;
        case 0x2018: return 0x91;
        case 0x2019: return 0x92;
        case 0x201C: return 0x93;
        case 0x201D: return 0x94;
        case 0x2022: return 0x95;
        case 0x2013: return 0x96;
        case 0x2014: return 0x97;
        case 0x02DC: return 0x98;
        case 0x2122: return 0x99;
        case 0x0161: return 0x9A;
        case 0x203A: return 0x9B;
        case 0x0153: return 0x9C;
        case 0x017E: return 0x9E;
        case 0x0178: return 0x9F;
    }

    if (Codepoint < 0x100)
    {
        return Codepoint;
    }

    return -1;
}

//Does a pass to fix the encoding of a player's name.
static final function string FixUTFEncoding(string InString)
{
    local int Index, Length, CodepointLength, C0, C1, C2, C3, Codepoint;
    local array<int> Bytes;
    local string Result;

    CodepointLength = Len(InString);
    for (Index = 0; Index < CodepointLength; Index++)
    {
        Bytes[Bytes.Length] = CodepointToCP1252Byte(Asc(Mid(InString, Index, 1)));
    }

    Length = Bytes.Length;
    Index = 0;

    while (Index < Length)
    {
        C0 = Bytes[Index];

        if (C0 == -1)
        {
            //Non-CP1252 codepoint - preserve original.
            Result $= Mid(InString, Index, 1);
            Index += 1;
            continue;
        }

        //4-byte UTF-8 sequence.
        if (C0 >= 0xF0 && C0 <= 0xF4 && Index + 3 < Length)
        {
            C1 = Bytes[Index + 1];
            C2 = Bytes[Index + 2];
            C3 = Bytes[Index + 3];
            if (C1 >= 0x80 && C1 <= 0xBF && C2 >= 0x80 && C2 <= 0xBF && C3 >= 0x80 && C3 <= 0xBF)
            {
                Codepoint = ((C0 & 0x07) << 18) | ((C1 & 0x3F) << 12) | ((C2 & 0x3F) << 6) | (C3 & 0x3F);
                Result $= Chr(Codepoint);
                Index += 4;
                continue;
            }
        }

        //3-byte UTF-8 sequence.
        if (C0 >= 0xE0 && C0 <= 0xEF && Index + 2 < Length)
        {
            C1 = Bytes[Index + 1];
            C2 = Bytes[Index + 2];
            if (C1 >= 0x80 && C1 <= 0xBF && C2 >= 0x80 && C2 <= 0xBF)
            {
                Codepoint = ((C0 & 0x0F) << 12) | ((C1 & 0x3F) << 6) | (C2 & 0x3F);
                Result $= Chr(Codepoint);
                Index += 3;
                continue;
            }
        }

        //2-byte UTF-8 sequence.
        if (C0 >= 0xC2 && C0 <= 0xDF && Index + 1 < Length)
        {
            C1 = Bytes[Index + 1];
            if (C1 >= 0x80 && C1 <= 0xBF)
            {
                Codepoint = ((C0 & 0x1F) << 6) | (C1 & 0x3F);
                Result $= Chr(Codepoint);
                Index += 2;
                continue;
            }
        }

        //No valid UTF-8 sequence starts here. Pass the codepoint through.
        Result $= Mid(InString, Index, 1);
        Index += 1;
    }

    return Result;
}

static final function FixUpClientMovers(GameInfo Game)
{
    local ClientMover Mover;
    foreach Game.DynamicActors(class'ClientMover', Mover)
    {
        Mover.InitialState = 'ServerIdle';
        Mover.GotoState('ServerIdle');
    }
}
