//Killing Floor Turbo TurboTab_ServerNews
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTab_ServerNews extends ServerPerks.SRTab_ServerNews;

var array<string> NewsText;
var bool bHasInitialized;

//Skip loading from a webpage for now.
function Timer()
{
    local string Text;
    local string ParsedText;
    local int Index;

    if (bHasInitialized)
    {
        return;
    }

    bHasInitialized = true;

    NewsText[3] @= class'KFTurboMut'.static.GetTurboVersionID() $ "<br>";
    for (Index = 0; Index < NewsText.Length; Index++)
    {
        ParsedText = Repl(NewsText[Index], "%dq", "\"");
        ParsedText = Repl(ParsedText, "%sq", "\'");
        Text $= ParsedText;
    }

	SetNewsText(Text);
}

defaultproperties
{   
    Begin Object Class=TurboGUIHTMLTextBox Name=TurboHTMLInfoText
        LaunchKFURL=TurboTab_ServerNews.SwitchPage
        WinTop=0.052000
        WinLeft=0.030000
        WinWidth=0.945000
        WinHeight=0.760000
        bBoundToParent=True
        bScaleToParent=True
        bNeverFocus=True
        OnDraw=TurboHTMLInfoText.RenderHTMLText
        OnClick=TurboHTMLInfoText.LaunchURL
    End Object
    HTMLText=TurboGUIHTMLTextBox'TurboHTMLInfoText'

    bHasInitialized=false
    NewsText(0)="<BODY LINK=#f44336 ALINK=#cc0000>"
    NewsText(1)="<TITLE>Information</TITLE><TAB X=20><FONT SIZE=-8 COLOR=grey>KILLING FLOOR TURBO<FONT SIZE=-2 COLOR=grey><br>"
    NewsText(3)="<TAB X=40><FONT SIZE=-4 COLOR=grey>Version"
    NewsText(2)="<TAB X=40><FONT SIZE=-6 COLOR=grey>Welcome to Killing Floor Turbo!<br>"
    NewsText(4)="<FONT SIZE=-4 COLOR=grey>KFTurbo is a balance overhaul mod for Killing Floor that includes a lot of QoL improvements.<br><br>"
    NewsText(5)="Try the KFTurbo challenge modes: KFTurbo Card Game, KFTurbo Randomizer and KFTurbo+.<br>"
    NewsText(6)="Text chat has emote autocomplete - type %dq:%dq to start and press tab to autocomplete.<br>"
    NewsText(7)="A full list of emotes can be found in the %sqEmotes%sq tab.<br><br>"
    NewsText(8)="KFTurbo now has a discord. Click <A HREF=%dqhttp://discord.gg/9TJDP3Wv9y%dq>here</A> <FONT SIZE=-4 COLOR=grey> to join.<br>"
    NewsText(9)="More information about the KFTurbo mod can be found on the github <A HREF=%dqhttp://github.com/KFPilot/KFTurbo%dq>here</A> <FONT SIZE=-4 COLOR=grey>.<br>"
    NewsText(10)="<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><FONT SIZE=-4 COLOR=grey>Number one. That%sqs terror.<br>Number two. That%sqs terror.<br>"
    NewsText(11)="</BODY>"
}