//Killing Floor Turbo TurboMultiColumnListBox
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMultiColumnListBox extends MVMultiColumnListBox;

var automated GUISectionBackground Background;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	DefaultListClass = string(class'TurboMultiColumnList');
	
    Super(MapVoteMultiColumnListBox).InitComponent(MyController, MyOwner);

	if (PlayerOwner().PlayerReplicationInfo.bAdmin)
    {
		ContextMenu.AddItem("Admin Force Map");
    }
}

function InitBaseList(GUIListBase LocalList)
{
    Super.InitBaseList(LocalList);
    
    TurboMultiColumnList(LocalList).UpdateFontScale();
}

function LoadList(VotingReplicationInfo LoadVRI)
{
	local int Index;

	ListArray.Length = LoadVRI.GameConfig.Length;
	for (Index = 0; Index < LoadVRI.GameConfig.Length; Index++)
	{
		ListArray[Index] = new class'TurboMultiColumnList';
		ListArray[Index].LoadList(LoadVRI, Index);
	}

	if (LoadVRI.CurrentGameConfig < ListArray.Length)
    {
		ChangeGameType(LoadVRI.CurrentGameConfig); // Fix for bug in initial maplist selection.
    }
	else
    {
        ChangeGameType(0);
    }
}

function InternalOnClick(GUIContextMenu Sender, int Index)
{
    if (Sender == None || NotifyContextSelect(Sender, Index) || TurboMapVotingPage(MenuOwner) == None)
    {
        return;
    }

    switch (Index)
    {
        case 0:
            TurboMapVotingPage(MenuOwner).SendVote(self);
            break;
        case 1:
			Controller.OpenMenu(string(Class'MVMapInfoPage'), MapVoteMultiColumnList(List).GetSelectedMapName());
            break;
        case 2:
            TurboMapVotingPage(MenuOwner).SendAdminVote(self);
            break;
    }
}

defaultproperties
{
	Begin Object class=GUISectionBackground Name=ListBackground
        HeaderBase=Texture'KF_InterfaceArt_tex.Menu.Thin_border_SlightTransparent'
        WinTop=0.02f
        WinLeft=0.f
        WinWidth=1.f
        WinHeight=0.98f
		RenderWeight=0.001
		bBoundToParent=true
		bScaleToParent=true
	End Object
	Background=GUISectionBackground'ListBackground'
}
