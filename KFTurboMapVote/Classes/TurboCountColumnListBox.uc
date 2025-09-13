//Killing Floor Turbo TurboCountColumnListBox
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCountColumnListBox extends MVCountColumnListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	DefaultListClass = string(Class'TurboCountColumnList');
	
    Super(MapVoteCountMultiColumnListBox).InitComponent(MyController, MyOwner);

	if (PlayerOwner().PlayerReplicationInfo.bAdmin)
    {
		ContextMenu.AddItem("Admin Force Map");
    }
}

function InitBaseList(GUIListBase LocalList)
{
    Super.InitBaseList(LocalList);

    TurboCountColumnList(LocalList).UpdateFontScale();
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
			Controller.OpenMenu(string(Class'MVMapInfoPage'), MapVoteCountMultiColumnList(List).GetSelectedMapName());
            break;
        case 2:
            TurboMapVotingPage(MenuOwner).SendAdminVote(self);
            break;
    }
}