class KFTTBlankPanel extends GUI2K4.MidGamePanel;

var automated array<GUIButton> b_KFButtons;
var noexport bool bNetGame;
var localized string LeaveMPButtonText, LeaveSPButtonText, SpectateButtonText, JoinGameButtonText, KickPlayer, BanPlayer;
var string PlayerStyleName;
var GUIStyles PlayerStyle;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
	local GUIButton B;
	local string s;
	local int i;
	local eFontScale FS;

	Super.InitComponent(MyController, MyOwner);

	s = GetSizingCaption();

	for (i = 0; i < Controls.length; i++) {
		B = GUIButton(Controls[i]);
		if (B != None) {
			B.bAutoSize = true;
			B.SizingCaption = s;
			B.AutoSizePadding.HorzPerc = 0.04;
			B.AutoSizePadding.VertPerc = 0.5;
		}
	}

	PlayerStyle = MyController.GetStyle(PlayerStyleName, FS);
}

function bool RemoveComponent(GUIComponent Comp, optional bool SkipRemap) {
	local int i;
	
	for (i = 0; i < b_KFButtons.length; i++)
		if (b_KFButtons[i] == Comp)
			b_KFButtons[i] = None;
	
	return Super.RemoveComponent(Comp, SkipRemap);
}

function ShowPanel(bool bShow) {
	Super.ShowPanel(bShow);
	if (bShow)
		InitGRI();
}

function string GetSizingCaption() {
	local int i;
	local string S;

	for (i = 0; i < Controls.length; i++)
		if (GUIButton(Controls[i]) != None)
			if (S == "" || Len(GUIButton(Controls[i]).Caption) > Len(S))
				S = GUIButton(Controls[i]).Caption;

	return S;
}

function GameReplicationInfo GetGRI() {
	return PlayerOwner().GameReplicationInfo;
}

function InitGRI() {
	local PlayerController PC;
	local GameReplicationInfo GRI;

	GRI = GetGRI();
	PC = PlayerOwner();
	if (PC == None || PC.PlayerReplicationInfo == None || GRI == None)
		return;

	bInit = false;
	bNetGame = PC.Level.NetMode != NM_StandAlone;
	if (bNetGame)
		b_KFButtons[6].Caption = LeaveMPButtonText;
	else
		b_KFButtons[6].Caption = LeaveSPButtonText;

	if (PC.PlayerReplicationInfo.bOnlySpectator)
		b_KFButtons[5].Caption = JoinGameButtonText;
	else
		b_KFButtons[5].Caption = SpectateButtonText;

	SetupGroups();
}

function float ItemHeight(Canvas C) {
	local float XL, yl, H;
	local eFontScale f;

	f = FNS_Medium;

	PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", XL, H, F);

	if (C.ClipX > 640 && bNetGame)
		PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", XL, yl, FNS_Small);

	H += yl;
	H += (H * 0.2);

	return H;
}

function SetupGroups() {
	local PlayerController PC;

	PC = PlayerOwner();

	if (PC.Level.NetMode != NM_Client) {
		RemoveComponent(b_KFButtons[2]);
		RemoveComponent(b_KFButtons[1]);
	}
	else if (CurrentServerIsInFavorites()) {
		DisableComponent(b_KFButtons[2]);
	}

	if (PC.Level.NetMode == NM_StandAlone) {
		RemoveComponent(b_KFButtons[3], true);
		RemoveComponent(b_KFButtons[4], true);
	}
	else if (PC.VoteReplicationInfo != None) {
		if (!PC.VoteReplicationInfo.MapVoteEnabled())
			RemoveComponent(b_KFButtons[3], true);

		if (!PC.VoteReplicationInfo.KickVoteEnabled())
			RemoveComponent(b_KFButtons[4]);
	}
	else {
		RemoveComponent(b_KFButtons[3]);
		RemoveComponent(b_KFButtons[4]);
	}

	RemapComponents();
}

function SetButtonPositions() {
	local int i, j, buttonsPerRow, buttonsLeftInRow, numButtons;
	local float width, height, center, x, y, yl, buttonSpacing;

	width = b_KFButtons[0].ActualWidth();
	height = b_KFButtons[0].ActualHeight();
	center = ActualLeft() + (ActualWidth() / 2.0);

	buttonSpacing = width * 0.05;
	yl = height * 1.2;
	y = b_KFButtons[0].ActualTop();

	buttonsPerRow = ActualWidth() / (width + buttonSpacing);
	buttonsLeftInRow = buttonsPerRow;

	for (i = 0; i < b_KFButtons.length; i++)
		if (b_KFButtons[i] != None && b_KFButtons[i].bVisible)
			numButtons++;

	if (numButtons < buttonsPerRow)
		x = center - (((width * float(numButtons)) + (buttonSpacing * float(numButtons - 1))) * 0.5);
	else if (buttonsPerRow > 1)
		x = center - (((width * float(buttonsPerRow)) + (buttonSpacing * float(buttonsPerRow - 1))) * 0.5);
	else
		x = center - width / 2.0;

	for (i = 0; i < b_KFButtons.length; i++) {
		if (b_KFButtons[i] == None || !b_KFButtons[i].bVisible)
			continue;

		b_KFButtons[i].SetPosition(x, y, width, height, true);

		if (--buttonsLeftInRow > 0) {
			x += width + buttonSpacing;
		}
		else {
			y += yl;

			for (j = i + 1; j < b_KFButtons.length && buttonsLeftInRow < buttonsPerRow; j++)
				if (b_KFButtons[i] != None && b_KFButtons[i].bVisible)
					buttonsLeftInRow++;

			if (buttonsLeftInRow > 1)
				x = center - (((width * float(buttonsLeftInRow)) + (buttonSpacing * float(buttonsLeftInRow - 1))) * 0.5);
			else
				x = center - width / 2.0;
		}
	}
}

function bool CurrentServerIsInFavorites() {
	local ExtendedConsole.ServerFavorite Fav;
	local string Address, PortString;

	if (PlayerOwner() == None)
		return true;

	Address = PlayerOwner().GetServerNetworkAddress();

	if(Address == "")
		return true;

	if (Divide(Address, ":", Fav.IP, PortString))
		Fav.Port = int(PortString);
	else
		Fav.IP = Address;

	return class'ExtendedConsole'.static.InFavorites(Fav);
}

function bool ButtonClicked(GUIComponent Sender) {
	local PlayerController PC;

	PC = PlayerOwner();

	if (Sender == b_KFButtons[0]) {
		Controller.OpenMenu(Controller.GetSettingsPage());
	}
	else if (Sender == b_KFButtons[1]) {
		Controller.OpenMenu("KFGUI.KFServerBrowser");
	}
	else if (Sender == b_KFButtons[6]) {
		PC.ConsoleCommand("DISCONNECT");
		KFGUIController(Controller).ReturnToMainMenu();
	}
	else if (Sender == b_KFButtons[2]) {
		PC.ConsoleCommand("ADDCURRENTTOFAVORITES");
		b_KFButtons[2].MenuStateChange(MSAT_Disabled);
	}
	else if (Sender == b_KFButtons[7]) {
		Controller.OpenMenu(Controller.GetQuitPage());
	}
	else if (Sender == b_KFButtons[3]) {
		Controller.OpenMenu(Controller.MapVotingMenu);
	}
	else if (Sender == b_KFButtons[4]) {
		Controller.OpenMenu(Controller.KickVotingMenu);
	}
	else if (Sender == b_KFButtons[5]) {
		Controller.CloseMenu();

		if (PC.PlayerReplicationInfo.bOnlySpectator)
			PC.BecomeActivePlayer();
		else
			PC.BecomeSpectator();
	}

	return true;
}

function bool InternalOnPreDraw(Canvas C) {
	local GameReplicationInfo GRI;

	GRI = GetGRI();
	if (GRI != None) {
		if (bInit)
			InitGRI();

		SetButtonPositions();

		if ((PlayerOwner().myHUD == None || !PlayerOwner().myHUD.IsInCinematic()) && GRI != None && GRI.bMatchHasBegun && !PlayerOwner().IsInState('GameEnded'))
			EnableComponent(b_KFButtons[5]);
		else
			DisableComponent(b_KFButtons[5]);
	}

	return false;
}

defaultproperties
{
	Begin Object Class=GUIButton Name=SettingsButton
		Caption="Settings"
		WinTop=0.878657
		WinLeft=0.194420
		WinWidth=0.147268
		WinHeight=0.048769
		TabOrder=30
		OnClick=KFTTBlankPanel.ButtonClicked
		OnKeyEvent=SettingsButton.InternalOnKeyEvent
	End Object
	b_KFButtons(0)=GUIButton'KFTTBlankPanel.SettingsButton'

	Begin Object Class=GUIButton Name=BrowserButton
		Caption="Server Browser"
		bAutoSize=true
		TabOrder=31
		OnClick=KFTTBlankPanel.ButtonClicked
		OnKeyEvent=BrowserButton.InternalOnKeyEvent
	End Object
	b_KFButtons(1)=GUIButton'KFTTBlankPanel.BrowserButton'

	Begin Object Class=GUIButton Name=FavoritesButton
		Caption="Add to Favs"
		bAutoSize=true
		Hint="Add this server to your Favorites"
		TabOrder=32
		OnClick=KFTTBlankPanel.ButtonClicked
		OnKeyEvent=FavoritesButton.InternalOnKeyEvent
	End Object
	b_KFButtons(2)=GUIButton'KFTTBlankPanel.FavoritesButton'
	
	Begin Object Class=GUIButton Name=MapVotingButton
		Caption="Map Voting"
		bAutoSize=true
		TabOrder=33
		OnClick=KFTTBlankPanel.ButtonClicked
		OnKeyEvent=MapVotingButton.InternalOnKeyEvent
	End Object
	b_KFButtons(3)=GUIButton'KFTTBlankPanel.MapVotingButton'

	Begin Object Class=GUIButton Name=KickVotingButton
		Caption="Kick Voting"
		bAutoSize=true
		TabOrder=34
		OnClick=KFTTBlankPanel.ButtonClicked
		OnKeyEvent=KickVotingButton.InternalOnKeyEvent
	End Object
	b_KFButtons(4)=GUIButton'KFTTBlankPanel.KickVotingButton'

	Begin Object Class=GUIButton Name=SpectateButton
		Caption="Spectate"
		bAutoSize=true
		TabOrder=35
		OnClick=KFTTBlankPanel.ButtonClicked
		OnKeyEvent=SpectateButton.InternalOnKeyEvent
	End Object
	b_KFButtons(5)=GUIButton'KFTTBlankPanel.SpectateButton'
	
	Begin Object Class=GUIButton Name=LeaveMatchButton
		bAutoSize=true
		TabOrder=36
		OnClick=KFTTBlankPanel.ButtonClicked
		OnKeyEvent=LeaveMatchButton.InternalOnKeyEvent
	End Object
	b_KFButtons(6)=GUIButton'KFTTBlankPanel.LeaveMatchButton'
	
	Begin Object Class=GUIButton Name=QuitGameButton
		Caption="Exit Game"
		bAutoSize=true
		TabOrder=37
		OnClick=KFTTBlankPanel.ButtonClicked
		OnKeyEvent=QuitGameButton.InternalOnKeyEvent
	End Object
	b_KFButtons(7)=GUIButton'KFTTBlankPanel.QuitGameButton'
	
	LeaveMPButtonText="Disconnect"
	LeaveSPButtonText="Forfeit"
	SpectateButtonText="Spectate"
	JoinGameButtonText="Join"
	KickPlayer="Kick "
	BanPlayer="Ban "
	PlayerStyleName="TextLabel"
	PropagateVisibility=False
	WinTop=0.125000
	WinLeft=0.250000
	WinWidth=0.500000
	WinHeight=0.750000
	OnPreDraw=KFTTBlankPanel.InternalOnPreDraw
}
