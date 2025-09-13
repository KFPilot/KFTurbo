class TurboCountColumnList extends MVCountColumnList;

var TurboVotingReplicationInfo TurboVRI;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController,MyOwner);
	
	UpdateFontScale();
}

function LoadList(VotingReplicationInfo LoadVRI)
{
	Super.LoadList(LoadVRI);

	TurboVRI = TurboVotingReplicationInfo(LoadVRI);
}

function ResolutionChanged(int ResX, int ResY)
{
	Super.ResolutionChanged(ResX, ResY);

	UpdateFontScale();
}

function UpdateFontScale()
{
	if (Controller.ResY <= 720)
	{
		FontScale = eFontScale.FNS_Small;
	}
	else if (Controller.ResY < 2160)
	{
		FontScale = eFontScale.FNS_Medium;
	}
	else
	{
		FontScale = eFontScale.FNS_Large;
	}
}

function DrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
	local float CellLeft, CellWidth;
	local GUIStyles DrawStyle;
    local int GameIndex, DifficultyIndex;

	if (VRI == None)
    {
        return;
    }

	if (bSelected)
	{
		SelectedStyle.Draw(Canvas,MenuState, X, Y-2, W, H+2 );
		DrawStyle = SelectedStyle;
	}
	else
    {
        DrawStyle = Style;
    }

    class'TurboVotingHandler'.static.Decode(VRI.MapVoteCount[SortData[i].SortItem].GameConfigIndex, GameIndex, DifficultyIndex);
	GetCellLeftWidth( 0, CellLeft, CellWidth );
	DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, VRI.GameConfig[GameIndex].GameName $ " - " $ TurboVRI.GetDifficultyName(DifficultyIndex), FontScale);

	GetCellLeftWidth( 1, CellLeft, CellWidth );
	DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, VRI.MapList[VRI.MapVoteCount[SortData[i].SortItem].MapIndex].MapName, FontScale);

	GetCellLeftWidth( 2, CellLeft, CellWidth );
	DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(VRI.MapVoteCount[SortData[i].SortItem].VoteCount), FontScale);

	GetCellLeftWidth( 3, CellLeft, CellWidth );
	DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, KFVotingReplicationInfo(VRI).RepArray[VRI.MapVoteCount[SortData[i].SortItem].MapIndex], FontScale);
}

defaultproperties
{
    InitColumnPerc(0)=0.500000
    InitColumnPerc(1)=0.250000
    InitColumnPerc(2)=0.100000
    InitColumnPerc(3)=0.150000
}