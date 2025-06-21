//Killing Floor Turbo TurboTab_EmoteList
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTab_EmoteList extends SRTab_Base;

var automated GUISectionBackground ContainerTitle;
var	automated TurboTab_EmoteList_ListBox ListBox;

function ShowPanel(bool bShow)
{
	local ClientPerkRepLink CPRL;

	super.ShowPanel(bShow);

	if (!bShow)
	{
        return;
	}

    CPRL = Class'ClientPerkRepLink'.Static.FindStats(PlayerOwner());

    if (CPRL != None)
    {
        ListBox.List.InitList(CPRL);
    }
}

defaultproperties
{
    Begin Object Class=GUISectionBackground Name=EmoteContainerTitle
        bFillClient=True
        Caption="Emotes"
        WinTop=0.012063
        WinLeft=0.019240
        WinWidth=0.961520
        WinHeight=0.796032
        OnPreDraw=EmoteContainerTitle.InternalPreDraw
    End Object
    ContainerTitle=GUISectionBackground'EmoteContainerTitle'

     Begin Object Class=TurboTab_EmoteList_ListBox Name=EmoteListBox
        OnCreateComponent=EmoteListBox.InternalOnCreateComponent
        WinTop=0.057760
        WinLeft=0.029240
        WinWidth=0.941520
        WinHeight=0.742836
     End Object
     ListBox=TurboTab_EmoteList_ListBox'EmoteListBox'

}