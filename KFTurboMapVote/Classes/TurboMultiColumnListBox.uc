//Killing Floor Turbo TurboMultiColumnListBox
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMultiColumnListBox extends MVMultiColumnListBox;

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