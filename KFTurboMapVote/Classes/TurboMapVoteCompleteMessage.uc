//Killing Floor Turbo TurboMapVoteCompleteMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMapVoteCompleteMessage extends TurboMapVoteMessage;

var localized string MapVoteCompleteString;
var localized string UnknownMapVoteCompleteString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    local int MapIndex, GameIndex, Difficulty;
    local TurboVotingReplicationInfo TurboVRI;

    TurboVRI = ResolveTurboVRI(OptionalObject);
    if (TurboVRI == None)
    {
        return default.UnknownMapVoteCompleteString;
    }
    
    Decode(Switch, MapIndex, GameIndex, Difficulty);
    return FormatString(Repl(class'xVotingHandler'.default.lmsgMapWon, "%mapname%", TurboVRI.MapList[MapIndex].MapName $ " ("$TurboVRI.GameConfig[GameIndex].GameName$ " - "$ResolveDifficultyName(Difficulty)$")"));
}

defaultproperties
{   
    MapVoteCompleteString="%k%player%%d voted for %k%mapname%%d (%k%gameconfig%%d - %k%difficulty%%d)."
    UnknownMapVoteCompleteString="A player voted for a map."
}