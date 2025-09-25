//Killing Floor Turbo TurboLobbyMenu
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboLobbyMenu extends SRLobbyMenu;

var array<GUILabel> PlayerNameLabelList;
var float PlayerEntryHeight;

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
	AdBackground.SetVisibility(false);
	Super.InitComponent(MyController, MyOwner);

	if (!bMOTDHidden)
	{
		RemoveComponent(ADBackground);
		RemoveComponent(tb_ServerMOTD);
		bMOTDHidden = true;
	}
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

function AddPlayer(KFPlayerReplicationInfo PRI, int Index, Canvas Canvas)
{
	local float Top;
	local Material M;

	if (Index >= PlayerBoxes.Length)
	{
		Top = float(Index) * PlayerEntryHeight;
		PlayerBoxes.Length = Index + 1;
		PlayerBoxes[Index] = CreatePlayerEntry(Top);
		PlayerNameLabelList.Length = Index + 1;
		PlayerNameLabelList[Index] = CreatePlayerEntryPlayerName(Top);

		AppendComponent(PlayerBoxes[Index].ReadyBox, true);
		AppendComponent(PlayerBoxes[Index].PlayerBox, true);
		AppendComponent(PlayerBoxes[Index].PlayerPerk, true);
		AppendComponent(PlayerBoxes[Index].PlayerVetLabel, true);
		AppendComponent(PlayerNameLabelList[Index], true);
		
		Top = (PlayerBoxes[Index].PlayerBox.WinTop + PlayerBoxes[Index].PlayerBox.WinHeight);
	}

	PlayerBoxes[Index].ReadyBox.Checked(PRI.bReadyToPlay);
	PlayerNameLabelList[Index].Caption = Left(PRI.PlayerName, 20);

	if (PRI.ClientVeteranSkill != None)
	{
		class<SRVeterancyTypes>(PRI.ClientVeteranSkill).Static.PreDrawPerk(Canvas, PRI.ClientVeteranSkillLevel, PlayerBoxes[Index].PlayerPerk.Image, M);
		PlayerBoxes[Index].PlayerPerk.ImageColor = Canvas.DrawColor;
		PlayerBoxes[Index].PlayerVetLabel.Caption = MakeColorCode(class'TurboHUDOverlay'.static.LerpColor(0.75f, Canvas.DrawColor, class'TurboHUDOverlay'.static.MakeColor(220, 220, 220, 220))) $ class'LobbyMenu'.default.LvAbbrString @ PRI.ClientVeteranSkillLevel @ PRI.ClientVeteranSkill.default.VeterancyName;
	}
	else
	{
		PlayerBoxes[Index].PlayerPerk.Image = None;
		PlayerBoxes[Index].PlayerVetLabel.Caption = "";
	}

	PlayerBoxes[Index].bIsEmpty = false;
}

function EmptyPlayers(int Index)
{
	Super.EmptyPlayers(Index);
	while (Index < PlayerBoxes.Length && !PlayerBoxes[Index].bIsEmpty)
	{

		Index++;
	}
}

function FPlayerBoxEntry CreatePlayerEntry(float Top)
{
	local FPlayerBoxEntry Entry;
	Entry.ReadyBox = CreatePlayerEntryReadyBox(Top);
	Entry.PlayerBox = CreatePlayerEntryPlayerBox(Top);
	Entry.PlayerPerk = CreatePlayerEntryPlayerPerk(Top);
	Entry.PlayerVetLabel = CreatePlayerEntryPlayerVetLabel(Top);
	return Entry;
}

function moCheckBox CreatePlayerEntryReadyBox(float Top)
{
	local moCheckBox NewReadyBox;
	NewReadyBox = new (None) class'moCheckBox';
	NewReadyBox.bValueReadOnly = true;
	NewReadyBox.ComponentJustification = TXTA_Left;
	NewReadyBox.CaptionWidth = 0.82;
	NewReadyBox.LabelColor.B = 0;
	NewReadyBox.WinTop = 0.0525 + Top;
	NewReadyBox.WinLeft = 0.075;
	NewReadyBox.WinWidth = 0.3975;
	NewReadyBox.WinHeight = PlayerEntryHeight;
	NewReadyBox.RenderWeight = 0.55;
	NewReadyBox.bAcceptsInput = False;
	NewReadyBox.bMouseOverSound = False;
    NewReadyBox.OnClickSound = CS_None;
    NewReadyBox.StandardHeight = 0.03f;
	return NewReadyBox;
}

function KFPlayerReadyBar CreatePlayerEntryPlayerBox(float Top)
{
	local KFPlayerReadyBar NewPlayerBox;
	NewPlayerBox = new (None) class'TurboPlayerReadyBar';
	NewPlayerBox.WinTop = 0.04 + Top;
	NewPlayerBox.WinLeft = 0.035;
	NewPlayerBox.WinWidth = 0.42 - 0.032;
	NewPlayerBox.WinHeight = PlayerEntryHeight;
	NewPlayerBox.RenderWeight = 0.35;
	return NewPlayerBox;
}

function GUIImage CreatePlayerEntryPlayerPerk(float Top)
{
	local GUIImage NewPlayerPerk;
	NewPlayerPerk = new (None) class'GUIImage';
	NewPlayerPerk.ImageStyle = ISTY_Justified;
	NewPlayerPerk.ImageAlign=IMGA_TopLeft;
	NewPlayerPerk.WinTop = 0.04 + Top;
	NewPlayerPerk.WinLeft = 0.035;
	NewPlayerPerk.WinWidth = 0.045;
	NewPlayerPerk.WinHeight = PlayerEntryHeight;
	NewPlayerPerk.RenderWeight = 0.56;
	return NewPlayerPerk;
}

function GUILabel CreatePlayerEntryPlayerVetLabel(float Top)
{
	local GUILabel NewPlayerVetLabel;
	NewPlayerVetLabel = new (None) class'GUILabel';
	NewPlayerVetLabel.TextAlign = TXTA_Right;
	NewPlayerVetLabel.StyleName = class'TurboGUIStyleLabel'.default.KeyName;
	NewPlayerVetLabel.WinTop = 0.04 + Top;
	NewPlayerVetLabel.WinLeft = 0.22907;
	NewPlayerVetLabel.WinWidth = 0.1685;
	NewPlayerVetLabel.WinHeight = PlayerEntryHeight;
	NewPlayerVetLabel.RenderWeight = 0.5;
	return NewPlayerVetLabel;
}

function GUILabel CreatePlayerEntryPlayerName(float Top)
{
	local GUILabel NewPlayerName;
	NewPlayerName = new (None) class'GUILabel';
	NewPlayerName.TextAlign = TXTA_Left;
	NewPlayerName.StyleName = class'TurboGUIStyleLabel'.default.KeyName;
	NewPlayerName.WinTop = 0.04 + Top;
	NewPlayerName.WinLeft = 0.035f + 0.035f;
	NewPlayerName.WinWidth = 0.6;
	NewPlayerName.WinHeight = PlayerEntryHeight;
	NewPlayerName.RenderWeight = 0.56;
	return NewPlayerName;
}

defaultproperties
{
	Begin Object Class=TurboLobbyFooter Name=BuyFooter
		RenderWeight=0.300000
		TabOrder=8
		bBoundToParent=False
		bScaleToParent=False
		OnPreDraw=BuyFooter.InternalOnPreDraw
	End Object`
	t_Footer=TurboLobbyFooter'KFTurbo.TurboLobbyMenu.BuyFooter'

	PlayerEntryHeight=0.055f
}