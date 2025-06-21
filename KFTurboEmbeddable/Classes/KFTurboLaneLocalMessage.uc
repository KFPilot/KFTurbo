//Killing Floor Turbo KFTurboLaneLocalMessage
//Duplicate of TurboLocalMessage because KFTurboEmbeddable isn't supposed to depend on KFTurbo.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboLaneLocalMessage extends LocalMessage;

//Applied by %k
var Color KeywordColor;
//Applied by %pk
var Color PositiveKeywordColor;
//Applied by %nk
var Color NegativeKeywordColor;
//Applied by %ak
var Color AlertKeywordColor;

//If true, will attempt to apply positive, negative and alert keyword color formatting.
var bool bUseFullFormatting;

//Only does formatting for default (%d) coloring and regular keyword (%k) coloring.
static final function string FormatString(string Input)
{
    Input = Repl(Input, "%d", class'GameInfo'.static.MakeColorCode(default.DrawColor));
    Input = Repl(Input, "%k", class'GameInfo'.static.MakeColorCode(default.KeywordColor));
    
    if (default.bUseFullFormatting)
    {
        Input = Repl(Input, "%pk", class'GameInfo'.static.MakeColorCode(default.PositiveKeywordColor));
        Input = Repl(Input, "%nk", class'GameInfo'.static.MakeColorCode(default.NegativeKeywordColor));
        Input = Repl(Input, "%ak", class'GameInfo'.static.MakeColorCode(default.AlertKeywordColor));
    }
    return Input;
}

defaultproperties
{
    DrawColor=(B=255,G=255,R=255,A=255)
    KeywordColor=(R=120,G=145,B=255,A=255)
    PositiveKeywordColor=(R=135,G=255,B=120,A=255)
    NegativeKeywordColor=(R=255,G=147,B=120,A=255)
    AlertKeywordColor=(R=255,G=215,B=120,A=255)

    bUseFullFormatting=false
}