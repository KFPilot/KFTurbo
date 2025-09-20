//Killing Floor Turbo TurboMapVoteAdminMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMapVoteAdminMessage extends TurboMapVoteMessage;

var localized string MapVoteString;
var localized string AnonymousMapVoteString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    local int MapIndex, GameIndex, Difficulty;
    local TurboVotingReplicationInfo TurboVRI;

    TurboVRI = ResolveTurboVRI(OptionalObject);
    if (TurboVRI == None)
    {
        return default.AnonymousMapVoteString;
    }
    
    Decode(Switch, MapIndex, GameIndex, Difficulty);
    return FormatString(Repl(Repl(class'xVotingHandler'.default.lmsgAdminMapChange, "%mapname%", "%k" $ TurboVRI.MapList[MapIndex].MapName $ "%d (%k" $ TurboVRI.GameConfig[GameIndex].GameName $ "%d - %k" $ ResolveDifficultyName(Difficulty) $ "%d)"), "%playername%", "%k" $ RelatedPRI_1.PlayerName $ "%d"));
}

defaultproperties
{
    AnonymousMapVoteString="Admin forced a map change."
}