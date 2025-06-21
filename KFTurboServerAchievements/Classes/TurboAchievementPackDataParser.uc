//Killing Floor Turbo TurboAchievementPackDataParser
//Parses JSON achievement data bespokely.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievementPackDataParser extends Object;

enum EDeserializationResult
{
    Failure,
    Success,
    Pending
};

var string JSONData;
var string PlayerID;
var string PackID;
var EDeserializationResult ParserResult;

struct AchievementData
{
    var string ID;
    var int CompletionCount;
    var string Value;
};

var array<AchievementData> AchievementDataList;

/* Data is structured as:
{
    "PlayerID":"<PlayerID>",
    "PackID":"<PackID>",
    "Data":[{"I":"<AchievementID>","C":"<CompletionCount>","V":"<ProgressData>"}, ...]
}
*/

function EDeserializationResult ConvertJSONToData(string InJSONData)
{
    JSONData = InJSONData;
    PlayerID = "";
    PackID = "";
    AchievementDataList.Length = 0;
    ParserResult = Pending;

    if (ResolvePlayerID(InJSONData) == Failure)
    {
        ParserResult = Failure;
    }

    if (ResolvePackID(InJSONData) == Failure)
    {
        ParserResult = Failure;
    }
    
    if (ConvertAchievementData(InJSONData) == Failure)
    {
        ParserResult = Failure;
    }

    if (ParserResult == Pending)
    {
        ParserResult = Success;
    }

    return ParserResult;
}

final function EDeserializationResult ResolvePlayerID(string InJSONData)
{
    local string LeftSide, RightSide;

    if (!Divide(InJSONData, "\"PlayerID\":", LeftSide, RightSide))
    {
        log("ERROR - TurboAchievementPackDataParser::ResolvePlayerID failed to find PlayerID key in JSON data.", 'KFTurboServerAchievements');
        return Failure;
    }

    if (!Divide(RightSide, ",", LeftSide, RightSide))
    {
        log("ERROR - TurboAchievementPackDataParser::ResolvePlayerID failed to find delimiting comma in JSON data.", 'KFTurboServerAchievements');
        return Failure;
    }

    LeftSide = Repl(LeftSide, "\"", "");
    LeftSide = Repl(LeftSide, " ", "");
    PlayerID = LeftSide;

    if (PlayerID == "")
    {
        return Failure;
    }
    
    return Success;
}

final function EDeserializationResult ResolvePackID(string InJSONData)
{
    local string LeftSide, RightSide;

    if (!Divide(InJSONData, "\"PackID\":", LeftSide, RightSide))
    {
        log("ERROR - TurboAchievementPackDataParser::ResolvePackID failed to find PackID key in JSON data.", 'KFTurboServerAchievements');
        return Failure;
    }

    if (!Divide(RightSide, ",", LeftSide, RightSide))
    {
        log("ERROR - TurboAchievementPackDataParser::ResolvePackID failed to find delimiting comma in JSON data.", 'KFTurboServerAchievements');
        return Failure;
    }

    LeftSide = Repl(LeftSide, "\"", "");
    LeftSide = Repl(LeftSide, " ", "");
    PackID = LeftSide;

    if (PackID == "")
    {
        return Failure;
    }
    
    return Success;
}

final function EDeserializationResult ConvertAchievementData(string InJSONData)
{
    local string LeftSide, RightSide;
    local string AchievementDataString;
    local int Index;
    local EDeserializationResult Result;

    local array<string> AchievementDataStringList;

    if (!Divide(JSONData, "[", LeftSide, RightSide))
    {
        log("ERROR - TurboAchievementPackDataParser::ConvertAchievementData failed to find array start character [ in JSON data.", 'KFTurboServerAchievements');
        return Failure;
    }
    
    if (!Divide(RightSide, "]", AchievementDataString, LeftSide))
    {
        log("ERROR - TurboAchievementPackDataParser::ConvertAchievementData failed to find array end character ] in JSON data.", 'KFTurboServerAchievements');
        return Failure;
    }

    Split(AchievementDataString, "},", AchievementDataStringList);

    //Didn't have any items, treat the string as a potential single entry.
    if (AchievementDataStringList.Length == 0)
    {
        return ProcessAchievementEntry(AchievementDataString);
    }

    Result = Success;
    Index = 0;
    while (Index < AchievementDataStringList.Length)
    {
        if (ProcessAchievementEntry(AchievementDataStringList[Index]) == Failure)
        {
            Result = Failure;
        }
        
        Index++;
    }

    return Result;
}

final function EDeserializationResult ProcessAchievementEntry(string AchievementEntryString)
{
    local string LeftSide, RightSide;
    local AchievementData Data;

    if (!Divide(AchievementEntryString, "\"I\":", LeftSide, RightSide))
    {
        log("ERROR - TurboAchievementPackDataParser::ProcessAchievementEntry failed to find ID key in JSON data.", 'KFTurboServerAchievements');
        return Failure;
    }

    if (!Divide(RightSide, ",", LeftSide, RightSide))
    {
        log("ERROR - TurboAchievementPackDataParser::ProcessAchievementEntry failed to find ID key delimiting comma in JSON data.", 'KFTurboServerAchievements');
        return Failure;
    }

    LeftSide = Repl(LeftSide, "\"", "");
    LeftSide = Repl(LeftSide, " ", "");
    Data.ID = LeftSide;

    if (!Divide(AchievementEntryString, "\"C\":", LeftSide, RightSide))
    {
        log("ERROR - TurboAchievementPackDataParser::ProcessAchievementEntry failed to find CompletionCount key in JSON data.", 'KFTurboServerAchievements');
        return Failure;
    }

    if (!Divide(RightSide, ",", LeftSide, RightSide))
    {
        log("ERROR - TurboAchievementPackDataParser::ProcessAchievementEntry failed to find CompletionCount key delimiting comma in JSON data.", 'KFTurboServerAchievements');
        return Failure;
    }

    LeftSide = Repl(LeftSide, "\"", "");
    LeftSide = Repl(LeftSide, " ", "");
    Data.CompletionCount = int(LeftSide);

    if (!Divide(AchievementEntryString, "\"V\":", LeftSide, RightSide))
    {
        log("ERROR - TurboAchievementPackDataParser::ProcessAchievementEntry failed to find Value key in JSON data.", 'KFTurboServerAchievements');
        return Failure;
    }

    if (!Divide(RightSide, ",", LeftSide, RightSide))
    {
        log("ERROR - TurboAchievementPackDataParser::ProcessAchievementEntry failed to find Value key delimiting comma in JSON data.", 'KFTurboServerAchievements');
        return Failure;
    }

    LeftSide = Repl(LeftSide, "\"", "");
    LeftSide = Repl(LeftSide, " ", "");
    Data.Value = LeftSide;

    AchievementDataList[AchievementDataList.Length] = Data;
}

defaultproperties
{

}