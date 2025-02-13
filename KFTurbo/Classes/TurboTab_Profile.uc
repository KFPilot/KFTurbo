//Killing Floor Turbo TurboTab_Profile
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTab_Profile extends SRTab_Profile;

function OnPerkSelected(GUIComponent Sender)
{
	local ClientPerkRepLink ST;
	local byte Idx;
	local string S;

	ST = Class'ClientPerkRepLink'.Static.FindStats(PlayerOwner());

	if ( ST==None || ST.CachePerks.Length==0 )
	{
		if( ST!=None )
			ST.ServerRequestPerks();

		lb_PerkEffects.SetContent("Please wait while your client is loading the perks...");
	}
	else
	{
		Idx = lb_PerkSelect.GetIndex();

		if( ST.CachePerks[Idx].CurrentLevel==0 )
			S = ST.CachePerks[Idx].PerkClass.Static.GetVetInfoText(0,1);
		else if( ST.CachePerks[Idx].CurrentLevel==ST.MaximumLevel )
			S = ST.CachePerks[Idx].PerkClass.Static.GetVetInfoText(ST.CachePerks[Idx].CurrentLevel-1,1);
		else S = ST.CachePerks[Idx].PerkClass.Static.GetVetInfoText(ST.CachePerks[Idx].CurrentLevel-1,1)$Class'TurboTab_MidGamePerks'.Default.NextInfoStr$ST.CachePerks[Idx].PerkClass.Static.GetVetInfoText(ST.CachePerks[Idx].CurrentLevel,1);
		
		lb_PerkEffects.SetContent(S);
		lb_PerkProgress.List.PerkChanged(KFStatsAndAchievements, Idx);
	}
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
