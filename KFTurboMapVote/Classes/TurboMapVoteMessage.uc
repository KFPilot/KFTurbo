//Killing Floor Turbo TurboMapVoteMessage
//Base class for KFTurboMapVote local messages.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMapVoteMessage extends LocalMessage;

//Applied by %k
var Color KeywordColor;

//Helps keep track of what difficulty we're actually talking about.
enum EDefaultDifficulty
{
	Skip0,
	Beginner,	//1
	Normal,		//2
	Skip3,
	Hard,		//4
	Suicidal,	//5
	Skip6,
	HellOnEarth	//7
};

//Only does formatting for default (%d) coloring and regular keyword (%k) coloring.
static final function string FormatString(string Input)
{
    Input = Repl(Input, "%d", class'GameInfo'.static.MakeColorCode(default.DrawColor));
    Input = Repl(Input, "%k", class'GameInfo'.static.MakeColorCode(default.KeywordColor));
    return Input;
}

static function BroadcastMapVoteMessage(GameInfo GameInfo, int MapIndex, int GameIndex, int Difficulty, optional PlayerReplicationInfo Player)
{
    if (GameInfo == None)
    {
        return;
    }

    GameInfo.BroadcastLocalizedMessage(default.Class, Encode(MapIndex, GameIndex, Difficulty), Player, None, GameInfo.Level.GRI);
}

static final function TurboVotingReplicationInfo ResolveTurboVRI(Object Object)
{
    local PlayerController LocalPlayerController;

    if (GameReplicationInfo(Object) == None)
    {
        return None;
    }

    LocalPlayerController = GameReplicationInfo(Object).Level.GetLocalPlayerController();

    if (LocalPlayerController == None)
    {
        return None;
    }

    return TurboVotingReplicationInfo(LocalPlayerController.VoteReplicationInfo);
}

// Layout for the encoding is;
// | Map Index (16 bits)             | Game Config (12 bits)   | Difficulty (8 bits)
// | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 | 0 0 0 0 0 0 0 0 0 0 0 0 | 0 0 0 0
static function int Encode(int MapIndex, int GameIndex, int Difficulty)
{
    return ((MapIndex & 65535) << 16) | ((GameIndex & 4095) << 4) | (Difficulty & 15);
}

static function Decode(int Data, out int MapIndex, out int GameIndex, out int Difficulty)
{
    MapIndex = (Data >> 16) & 65535;
    GameIndex = (Data >> 4) & 4095;
    Difficulty = (Data & 15);
}

//Can be overridden to handle custom difficulty names.
static simulated function string ResolveDifficultyName(int Difficulty)
{
    switch (EDefaultDifficulty(Difficulty))
    {
        case Beginner:
            return class'LobbyMenu'.default.BeginnerString;
        case Normal:
            return class'LobbyMenu'.default.NormalString;
        case Hard:
            return class'LobbyMenu'.default.HardString;
        case Suicidal:
            return class'LobbyMenu'.default.SuicidalString;
        case HellOnEarth:
            return class'LobbyMenu'.default.HellOnEarthString;
    }

    return "UNKNOWN";
}

defaultproperties
{
    DrawColor=(B=255,G=255,R=255,A=255)
    KeywordColor=(R=120,G=145,B=255,A=255)
    bIsSpecial=false
}