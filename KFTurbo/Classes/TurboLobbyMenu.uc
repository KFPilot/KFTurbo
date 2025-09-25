//Killing Floor Turbo TurboLobbyMenu
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboLobbyMenu extends SRLobbyMenu;

function bool ShowPerkMenu(GUIComponent Sender)
{
	if (PlayerOwner() != None)
	{
		PlayerOwner().ClientOpenMenu(string(Class'TurboProfilePage'), false);
	}

	return true;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
}

function HandleClientNotReady()
{
	if (CurrentVeterancyLevel == 255)
	{
		return;
	}

	CurrentVeterancyLevel = 255;
	lb_PerkEffects.SetContent("None perk active");
}

function UpdatePerkInformation(class<TurboVeterancyTypes> SelectedVeterancy, int CurrentLevel)
{
	if(CurrentVeterancy != SelectedVeterancy || CurrentVeterancyLevel != CurrentLevel)
	{
		CurrentVeterancy = SelectedVeterancy;
		CurrentVeterancyLevel = CurrentLevel;
		lb_PerkEffects.SetContent(SelectedVeterancy.static.GetVetInfoText(CurrentLevel, 1));
	}
}

function DrawPerk(Canvas Canvas)
{
	local float X, Y, Width, Height;
	local KFPlayerReplicationInfo KFPRI;
	local ClientPerkRepLink CPRL;
	local class<TurboVeterancyTypes> SelectedVeterancy;

	DrawPortrait();

	KFPRI = KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);

	if (KFPRI == None || KFPRI.ClientVeteranSkill == None)
	{
		HandleClientNotReady();
		return;
	}

	CPRL = TurboPlayerController(PlayerOwner()).GetClientPerkRepLink();

	if (CPRL == None || !CPRL.bRepCompleted)
	{
		HandleClientNotReady();
		return;
	}
	
	SelectedVeterancy = class<TurboVeterancyTypes>(KFPRI.ClientVeteranSkill);

	if (SelectedVeterancy == None)
	{
		HandleClientNotReady();
		return;
	}

	UpdatePerkInformation(SelectedVeterancy, KFPRI.ClientVeteranSkillLevel);

	//Get the position size etc in pixels
	X = (i_BGPerk.WinLeft + 0.00125) * Canvas.ClipX;
	Y = (i_BGPerk.WinTop + 0.0025) * Canvas.ClipY;

	X += 4.f;
	Y += 30.f;

	Width = (i_BGPerk.WinWidth - 0.0025) * Canvas.ClipX;
	Height = (i_BGPerk.WinHeight - 0.005) * Canvas.ClipY;

	Width -= 6.f;
	Height -= 34.f;
	
	class'TurboHUDPerkEntryDrawer'.static.Draw(Canvas, TurboHUDKillingFloor(PlayerOwner().myHUD), X, Y, Width, Height, SelectedVeterancy, KFPRI.ClientVeteranSkillLevel, SelectedVeterancy.static.GetTotalProgress(CPRL, KFPRI.ClientVeteranSkillLevel + 1), 1.f, 0.f, true);
	class'TurboHUDKillingFloor'.static.ResetCanvas(Canvas);
}

defaultproperties
{
     Begin Object Class=TurboLobbyFooter Name=BuyFooter
         RenderWeight=0.300000
         TabOrder=8
         bBoundToParent=False
         bScaleToParent=False
         OnPreDraw=BuyFooter.InternalOnPreDraw
     End Object
     t_Footer=TurboLobbyFooter'KFTurbo.TurboLobbyMenu.BuyFooter'

}
