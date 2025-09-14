//Killing Floor Turbo TurboTab_MidGamePerks
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTab_MidGamePerks extends SRTab_MidGamePerks;

function bool OnSaveButtonClicked(GUIComponent Sender)
{
	local TurboPlayerController TurboPlayerController;

	TurboPlayerController = TurboPlayerController(PlayerOwner());

	if (lb_PerkSelect.GetIndex() >= 0 && TurboPlayerController != None && TurboPlayerController.GetClientPerkRepLink() != None)
	{
		TurboPlayerController.SelectVeterancy(TurboPlayerController.GetClientPerkRepLink().CachePerks[lb_PerkSelect.GetIndex()].PerkClass);
	}
	
	return true;
}

function OnPerkSelected(GUIComponent Sender)
{
	local ClientPerkRepLink ST;
	local byte Index;

	ST = Class'ClientPerkRepLink'.Static.FindStats(PlayerOwner());

	if (ST == None || ST.CachePerks.Length == 0)
	{
		if (ST != None)
        {
			ST.ServerRequestPerks();
        }

		lb_PerkEffects.SetContent(PleaseWaitStr);
        return;
	}

    Index = lb_PerkSelect.GetIndex();
    lb_PerkEffects.SetContent(ST.CachePerks[Index].PerkClass.Static.GetVetInfoText(ST.CachePerks[Index].CurrentLevel - 1, 1));
    lb_PerkProgress.List.PerkChanged(None, Index);
}

defaultproperties
{
	Begin Object Class=TurboPerkSelectListBox Name=PerkSelectList
		OnCreateComponent=PerkSelectList.InternalOnCreateComponent
		WinTop=0.057760
		WinLeft=0.029240
		WinWidth=0.437166
		WinHeight=0.742836
	End Object
	lb_PerkSelect=TurboPerkSelectListBox'KFTurbo.TurboTab_MidGamePerks.PerkSelectList'

	Begin Object Class=TurboPerkProgressListBox Name=PerkProgressList
		OnCreateComponent=PerkProgressList.InternalOnCreateComponent
		WinTop=0.476850
		WinLeft=0.499269
		WinWidth=0.463858
		WinHeight=0.341256
	End Object
	lb_PerkProgress=TurboPerkProgressListBox'PerkProgressList'
}
