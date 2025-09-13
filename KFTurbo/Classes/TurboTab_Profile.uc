//Killing Floor Turbo TurboTab_Profile
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTab_Profile extends SRTab_Profile;



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

		lb_PerkEffects.SetContent(class'TurboTab_MidGamePerks'.default.PleaseWaitStr);
        return;
	}

    Index = lb_PerkSelect.GetIndex();
    lb_PerkEffects.SetContent(ST.CachePerks[Index].PerkClass.Static.GetVetInfoText(ST.CachePerks[Index].CurrentLevel - 1, 1));
    lb_PerkProgress.List.PerkChanged(None, Index);
}

function SaveSettings()
{
	local TurboPlayerController TurboPlayerController;
	local ClientPerkRepLink CPRL;

	TurboPlayerController = TurboPlayerController(PlayerOwner());

	if (TurboPlayerController != None)
	{
		CPRL = TurboPlayerController.GetClientPerkRepLink();
	}

	if (ChangedCharacter != "")
	{
		if (CPRL != None)
		{
			CPRL.SelectedCharacter(ChangedCharacter);
		}
		else
		{
			TurboPlayerController.ConsoleCommand("ChangeCharacter"@ChangedCharacter);

			if (!TurboPlayerController.IsA('xPlayer'))
			{
				TurboPlayerController.UpdateURL("Character", ChangedCharacter, True);
			}

			if (PlayerRec.Sex ~= "Female")
			{
				TurboPlayerController.UpdateURL("Sex", "F", True);
			}
			else
			{
				TurboPlayerController.UpdateURL("Sex", "M", True);
			}
		}

		ChangedCharacter = "";
	}

	if (lb_PerkSelect.GetIndex() >= 0 && TurboPlayerController != None && CPRL != None)
	{
		TurboPlayerController.SelectVeterancy(CPRL.CachePerks[lb_PerkSelect.GetIndex()].PerkClass);
	}
}

function bool PickModel(GUIComponent Sender)
{
	if ( Controller.OpenMenu(string(Class'TurboTab_ModelSelect'), PlayerRec.DefaultName, Eval(Controller.CtrlPressed, PlayerRec.Race, "")) )
	{
		Controller.ActivePage.OnClose = ModelSelectClosed;
	}

	return true;
}

defaultproperties
{
     Begin Object Class=TurboPerkSelectListBox Name=PerkSelectList
         OnCreateComponent=PerkSelectList.InternalOnCreateComponent
         WinTop=0.082969
         WinLeft=0.323418
         WinWidth=0.318980
         WinHeight=0.654653
     End Object
     lb_PerkSelect=TurboPerkSelectListBox'KFTurbo.TurboTab_Profile.PerkSelectList'

}
