//Killing Floor Turbo TurboMapVotingPage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMapVotingPage extends KFMapVotingPageX;

var() editconst noexport TurboVotingReplicationInfo TurboVRI;
var automated moComboBox co_GameDifficulty;

simulated function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    TurboVRI = TurboVotingReplicationInfo(MVRI);
}

simulated function InternalOnOpen()
{
    local int Index;

    if (TurboVRI == None || (TurboVRI != None && !TurboVRI.bMapVote))
    {
        Super.InternalOnOpen();
        f_Chat.SetVisibility(false);
        f_Chat.bAcceptsInput = false;
        return;
    }

    if (TurboVRI.GameDifficultyConfig.Length < TurboVRI.GameDifficultyCount)
    {
		Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
		GUIQuestionPage(Controller.TopPage()).SetupQuestion(lmsgReplicationNotFinished, QBTN_Ok, QBTN_Ok);
		GUIQuestionPage(Controller.TopPage()).OnButtonClick = OnOkButtonClick;
		return;
    }

    for (Index = 0; Index < TurboVRI.GameDifficultyConfig.Length; Index++)
    {
    	co_GameDifficulty.AddItem(TurboVRI.GetDifficultyName(TurboVRI.GameDifficultyConfig[Index].DifficultyIndex), None, string(TurboVRI.GameDifficultyConfig[Index].DifficultyIndex));
    }

    if (TurboVRI.GameDifficultyConfig.Length == 0)
    {
        co_GameDifficulty.SetVisibility(false);
    }
    else
    {
        Index = co_GameDifficulty.MyComboBox.List.FindExtra(string(TurboVRI.CurrentDifficultyConfig));
        if (Index != -1)
        {
            co_GameDifficulty.SetIndex(Index);
        }
    }

    Super.InternalOnOpen();
    f_Chat.SetVisibility(false);
    f_Chat.bAcceptsInput = false;
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
                Difficulty = int(co_GameDifficulty.GetExtra());
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

defaultproperties
{
    WinLeft=0.1
    WinTop=0.05
    WinWidth=0.8
    WinHeight=0.9

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
        WinHeight=0.6
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
