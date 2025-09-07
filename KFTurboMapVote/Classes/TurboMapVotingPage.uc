//Killing Floor Turbo TurboMapVotingPage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMapVotingPage extends KFMapVotingPageX;

var automated moComboBox co_GameDifficulty;

simulated function GetVoteSelection(GUIComponent Sender, out int MapIndex, out int GameConfig)
{
    if (Sender == lb_VoteCountListBox.List)
    {
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
			GameConfig = class'TurboVotingHandler'.static.Encode(int(co_GameType.GetExtra()), 7);
        }
    }
}

simulated function SendAdminVote(GUIComponent Sender)
{
	local int MapIndex, GameConfig;
    GetVoteSelection(Sender, MapIndex, GameConfig);

    log("MapIndex: "$MapIndex$" GameConfig: "$GameConfig);
	if (MapIndex >= 0)
    {
		MVRI.SendMapVote(MapIndex, -GameConfig); //Send with negative game index to indicate admin switch.
    }
}

simulated function SendVote(GUIComponent Sender)
{
	local int MapIndex, GameConfig;
    GetVoteSelection(Sender, MapIndex, GameConfig);

    log("MapIndex: "$MapIndex$" GameConfig: "$GameConfig);
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
     Begin Object class=TurboMultiColumnListBox Name=TurboMapListBox
         HeaderColumnPerc(0)=0.500000
         HeaderColumnPerc(1)=0.150000
         HeaderColumnPerc(2)=0.150000
         HeaderColumnPerc(3)=0.200000
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
         HeaderColumnPerc(0)=0.300000
         HeaderColumnPerc(1)=0.300000
         HeaderColumnPerc(2)=0.200000
         HeaderColumnPerc(3)=0.200000
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
