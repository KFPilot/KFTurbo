//Killing Floor Turbo TurboTab_MidGamePerks
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTab_MidGamePerks extends SRTab_MidGamePerks;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	b_Save.StyleName = class'TurboGUIStyleButton'.default.KeyName;
	b_Save.AutoSizePadding.VertPerc += 0.1f;

	Super.InitComponent(MyController, MyOwner);
}

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
		WinHeight=0.742836
		WinWidth=0.437166
	End Object
	lb_PerkSelect=TurboPerkSelectListBox'KFTurbo.TurboTab_MidGamePerks.PerkSelectList'

	Begin Object Class=TurboPerkProgressListBox Name=PerkProgressList
		OnCreateComponent=PerkProgressList.InternalOnCreateComponent
		WinTop=0.476850
		WinLeft=0.499269
		WinHeight=0.341256
		WinWidth=0.463858
	End Object
	lb_PerkProgress=TurboPerkProgressListBox'PerkProgressList'

	Begin Object Class=GUIButton Name=TurboSaveButton
		WinTop=0.815
		WinLeft=0.029240
		WinHeight=0.042757
		WinWidth=0.437166
		TabOrder=2
		AutoSizePadding=(VertPerc=0.1)
		bBoundToParent=True
		OnClick=TurboTab_MidGamePerks.OnSaveButtonClicked
		OnKeyEvent=SaveButton.InternalOnKeyEvent
    	bNeverFocus=true
	End Object
	b_Save=GUIButton'TurboSaveButton'
}
