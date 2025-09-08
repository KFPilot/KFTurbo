//Killing Floor Turbo TurboMapVotingPage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMapVotingPage extends KFMapVotingPageX;

var() editconst noexport TurboVotingReplicationInfo TurboVRI;
var automated moComboBox co_GameDifficulty;


//Helps keep track of what difficulty we're actually talking about.
enum EDifficultyConfig
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

simulated function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    TurboVRI = TurboVotingReplicationInfo(MVRI);
}

simulated function InternalOnOpen()
{
    local int Index;

    if (MVRI == None || (MVRI != None && !MVRI.bMapVote))
    {
        Super.InternalOnOpen();
        return;
    }

    if (TurboVRI.GameDifficultyConfig.Length < TurboVRI.GameDifficultyCount)
    {
		Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
		GUIQuestionPage(Controller.TopPage()).SetupQuestion(lmsgReplicationNotFinished, QBTN_Ok, QBTN_Ok);
		GUIQuestionPage(Controller.TopPage()).OnButtonClick = OnOkButtonClick;
		return;
    }

    if (TurboVRI.GameDifficultyConfig.Length == 0)
    {
        co_GameDifficulty.SetVisibility(false);
    }

    for (Index = 0; Index < TurboVRI.GameDifficultyConfig.Length; Index++)
    {
    	co_GameDifficulty.AddItem(ResolveDifficultyName(TurboVRI.GameDifficultyConfig[Index].DifficultyIndex), None, string(Index));
    }

    Super.InternalOnOpen();
}

simulated function GetVoteSelection(GUIComponent Sender, out int MapIndex, out int GameConfig)
{
    local int Difficulty;
    MapIndex = -1;
    GameConfig = -1;
    if (Sender == lb_VoteCountListBox.List)
    {
        if (lb_VoteCountListBox.List.ItemCount == 0)
        {
            return;
        }

        MapIndex = MapVoteCountMultiColumnList(lb_VoteCountListBox.List).GetSelectedMapIndex();
        if (MapIndex >= 0)
        {
            GameConfig = MapVoteCountMultiColumnList(lb_VoteCountListBox.List).GetSelectedGameConfigIndex();
        }
    }
    else
    {
        MapIndex = MapVoteMultiColumnList(lb_MapListBox.List).GetSelectedMapIndex();
		if (MapIndex >= 0)
        {
            if (co_GameDifficulty.bVisible)
            {
                Difficulty = TurboVRI.GameDifficultyConfig[int(co_GameDifficulty.GetExtra())].DifficultyIndex;
            }
            else
            {
                Difficulty = InvasionGameReplicationInfo(PlayerOwner().Level.GRI).BaseDifficulty; //Just pass in current difficulty.
            }

			GameConfig = class'TurboVotingHandler'.static.Encode(int(co_GameType.GetExtra()), Difficulty);
        }
    }
}

simulated function SendAdminVote(GUIComponent Sender)
{
	local int MapIndex, GameConfig;
    GetVoteSelection(Sender, MapIndex, GameConfig);

    log("MapIndex: "$MapIndex$" GameConfig: "$GameConfig, 'MapVoteDebug');
	if (MapIndex >= 0)
    {
		MVRI.SendMapVote(MapIndex, -GameConfig); //Send with negative game index to indicate admin switch.
    }
}

simulated function SendVote(GUIComponent Sender)
{
	local int MapIndex, GameConfig;
    GetVoteSelection(Sender, MapIndex, GameConfig);

    log("MapIndex: "$MapIndex$" GameConfig: "$GameConfig, 'MapVoteDebug');
	if (MapIndex >= 0)
	{
		if(MVRI.MapList[MapIndex].bEnabled)
        {
			MVRI.SendMapVote(MapIndex, GameConfig);
        }
        else
        {
		    PlayerOwner().ClientMessage(lmsgMapDisabled);
        }
	}
}

static simulated function string ResolveDifficultyName(int Index)
{
    switch (EDifficultyConfig(Index))
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
     Begin Object class=TurboMultiColumnListBox Name=TurboMapListBox
         HeaderColumnPerc(0)=0.450000
         HeaderColumnPerc(1)=0.150000
         HeaderColumnPerc(2)=0.150000
         HeaderColumnPerc(3)=0.250000
         bVisibleWhenEmpty=True
         OnCreateComponent=TurboMapListBox.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.371020
         WinLeft=0.020000
         WinWidth=0.960000
         WinHeight=0.293104
         bBoundToParent=True
         bScaleToParent=True
         OnRightClick=TurboMapListBox.InternalOnRightClick
     End Object
     lb_MapListBox=TurboMultiColumnListBox'TurboMapListBox'

     Begin Object class=TurboCountColumnListBox Name=TurboVoteCountListBox
         HeaderColumnPerc(0)=0.450000
         HeaderColumnPerc(1)=0.300000
         HeaderColumnPerc(2)=0.100000
         HeaderColumnPerc(3)=0.150000
         bVisibleWhenEmpty=True
         OnCreateComponent=TurboVoteCountListBox.InternalOnCreateComponent
         WinTop=0.052930
         WinLeft=0.020000
         WinWidth=0.960000
         WinHeight=0.223770
         bBoundToParent=True
         bScaleToParent=True
         OnRightClick=TurboVoteCountListBox.InternalOnRightClick
     End Object
     lb_VoteCountListBox=TurboCountColumnListBox'TurboVoteCountListBox'

    Begin Object Class=moComboBox Name=TurboGameTypeCombo
        CaptionWidth=0.2
        Caption="Game Type:"
        OnCreateComponent=TurboGameTypeCombo.InternalOnCreateComponent
        WinTop=0.3
        WinLeft=0.05
        WinWidth=0.5
        WinHeight=0.037500
        bBoundToParent=True
        bScaleToParent=True
    End Object
    co_GameType=moComboBox'TurboGameTypeCombo'

    Begin Object Class=moComboBox Name=TurboGameDifficultyCombo
        CaptionWidth=0.3
        Caption="Difficulty:"
        OnCreateComponent=TurboGameDifficultyCombo.InternalOnCreateComponent
        WinTop=0.3
        WinLeft=0.65
        WinWidth=0.3
        WinHeight=0.037500
        bBoundToParent=True
        bScaleToParent=True
    End Object
    co_GameDifficulty=moComboBox'TurboGameDifficultyCombo'
}
