//Killing Floor Turbo TurboInvasionLoginMenu
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboInvasionLoginMenu extends SRInvasionLoginMenu;

var automated GUIButton b_PlayerChat;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;
	local string SizingCaption;
	local SRMenuAddition M;

	// Setup panel classes.
	Panels[0].ClassName = string(class'TurboTab_ServerNews');
	Panels[1].ClassName = string(class'TurboTab_MidGamePerks');
	Panels[2].ClassName = string(class'SRTab_MidGameVoiceChat');
	Panels[3].ClassName = string(class'TurboTab_EmoteList');
	Panels[4].ClassName = string(class'TurboTab_TurboSettings');

	// Setup localization.
	Panels[1].Caption = Class'KFInvasionLoginMenu'.Default.Panels[1].Caption;
	Panels[2].Caption = Class'KFInvasionLoginMenu'.Default.Panels[2].Caption;
	Panels[3].Caption = Class'TurboInvasionLoginMenu'.Default.Panels[3].Caption;
	Panels[4].Caption = Class'TurboInvasionLoginMenu'.Default.Panels[4].Caption;
	Panels[1].Hint = Class'KFInvasionLoginMenu'.Default.Panels[1].Hint;
	Panels[2].Hint = Class'KFInvasionLoginMenu'.Default.Panels[2].Hint;
	Panels[3].Hint = Class'TurboInvasionLoginMenu'.Default.Panels[3].Hint;
	Panels[4].Hint = Class'TurboInvasionLoginMenu'.Default.Panels[4].Hint;

	b_Spec.Caption=class'KFTab_MidGamePerks'.default.b_Spec.Caption;
	b_MatchSetup.Caption=class'KFTab_MidGamePerks'.default.b_MatchSetup.Caption;
	b_KickVote.Caption=class'KFTab_MidGamePerks'.default.b_KickVote.Caption;
	b_MapVote.Caption=class'KFTab_MidGamePerks'.default.b_MapVote.Caption;
	b_Quit.Caption=class'KFTab_MidGamePerks'.default.b_Quit.Caption;
	b_Favs.Caption=class'KFTab_MidGamePerks'.default.b_Favs.Caption;
	b_Favs.Hint=class'KFTab_MidGamePerks'.default.b_Favs.Hint;
	b_Settings.Caption=class'KFTab_MidGamePerks'.default.b_Settings.Caption;
	b_Browser.Caption=class'KFTab_MidGamePerks'.default.b_Browser.Caption;

	b_Settings.StyleName = class'TurboGUIStyleButton'.default.KeyName;
	b_Browser.StyleName = class'TurboGUIStyleButton'.default.KeyName;
	b_Quit.StyleName = class'TurboGUIStyleButton'.default.KeyName;
	b_Favs.StyleName = class'TurboGUIStyleButton'.default.KeyName;
	b_Leave.StyleName = class'TurboGUIStyleButton'.default.KeyName;
	b_MapVote.StyleName = class'TurboGUIStyleButton'.default.KeyName;
	b_KickVote.StyleName = class'TurboGUIStyleButton'.default.KeyName;
	b_MatchSetup.StyleName = class'TurboGUIStyleButton'.default.KeyName;
	b_Spec.StyleName = class'TurboGUIStyleButton'.default.KeyName;
	b_Profile.StyleName = class'TurboGUIStyleButton'.default.KeyName;
	b_PlayerChat.StyleName = class'TurboGUIStyleButton'.default.KeyName;

 	Super(UT2K4PlayerLoginMenu).InitComponent(MyController, MyOwner);

	// Mod menus
	if (MyController != None)
	{
		foreach MyController.ViewportOwner.Actor.DynamicActors(class'SRMenuAddition',M)
			if( M.bHasInit )
			{
				AddOnList[AddOnList.Length] = M;
				M.NotifyMenuOpen(Self,MyController);
			}
	}

   	SizingCaption = GetSizingCaption();

	for ( i = 0; i < Controls.Length; i++ )
    {
    	if (GUIButton(Controls[i]) != None)
        {
            GUIButton(Controls[i]).bAutoSize = true;
            GUIButton(Controls[i]).bAutoSize = true;
            GUIButton(Controls[i]).SizingCaption = SizingCaption;
            GUIButton(Controls[i]).AutoSizePadding.HorzPerc = 0.05;
            GUIButton(Controls[i]).AutoSizePadding.VertPerc = 0.1;
        }
    }
    //s = class'KFTab_MidGamePerks'.default.PlayerStyleName;
    //PlayerStyle = MyController.GetStyle(s, fs);
	InitGRI();
}

function InitGRI()
{
    local PlayerController PC;
    local GameReplicationInfo GRI;

    GRI = GetGRI();
    PC = PlayerOwner();

    if ( PC == none || PC.PlayerReplicationInfo == none || GRI == none )
        return;

    bInit = False;

    bNetGame = PC.Level.NetMode != NM_StandAlone;

    if ( bNetGame )
        b_Leave.Caption = class'KFTab_MidGamePerks'.default.LeaveMPButtonText;
    else b_Leave.Caption = class'KFTab_MidGamePerks'.default.LeaveSPButtonText;

	bOldSpectator = PC.PlayerReplicationInfo.bOnlySpectator;
    if ( bOldSpectator )
        b_Spec.Caption = class'KFTab_MidGamePerks'.default.JoinGameButtonText;
    else b_Spec.Caption = class'KFTab_MidGamePerks'.default.SpectateButtonText;

    SetupGroups();
	//InitLists();
}

function AddPanels()
{
	Super.AddPanels();
}

function bool ButtonClicked(GUIComponent Sender)
{
    local PlayerController PC;
 
    PC = PlayerOwner();

	if ( Sender == b_Settings )
    {
        // Settings
        Controller.OpenMenu(Controller.GetSettingsPage());
    }
    else if ( Sender == b_Browser )
    {
        // Server browser
        Controller.OpenMenu("KFGUI.KFServerBrowser");
    }
    else if ( Sender == b_Leave )
    {
		// Forfeit/Disconnect
		PC.ConsoleCommand("DISCONNECT");
        KFGUIController(Controller).ReturnToMainMenu();
    }
    else if ( Sender == b_Favs )
    {
        // Add this server to favorites
        PC.ConsoleCommand( "ADDCURRENTTOFAVORITES" );
        b_Favs.MenuStateChange(MSAT_Disabled);
    }
    else if ( Sender == b_Quit )
    {
        // Quit game
        Controller.OpenMenu(Controller.GetQuitPage());
    }
    else if ( Sender == b_MapVote )
    {
        // Map voting
        Controller.OpenMenu(Controller.MapVotingMenu);
    }
    else if ( Sender == b_KickVote )
    {
        // Kick voting
        Controller.OpenMenu(Controller.KickVotingMenu);
    }
    else if ( Sender == b_MatchSetup )
    {
        // Match setup
        Controller.OpenMenu(Controller.MatchSetupMenu);
    }
	else if ( Sender == b_Spec )
	{
		Controller.CloseMenu();

		// Spectate/rejoin
		if ( PC.PlayerReplicationInfo.bOnlySpectator )
			PC.BecomeActivePlayer();
		else PC.BecomeSpectator();
	}
	else if( Sender==b_Profile )
	{
		// Profile
		Controller.OpenMenu(string(Class'TurboProfilePage'));
	}
	
	return true;
}

function bool InternalOnPreDraw(Canvas C)
{
	local GameReplicationInfo GRI;
	local PlayerController PC;

	GRI = GetGRI();

    if ( GRI != none )
	{
		if ( bInit )
			InitGRI();

		SetButtonPositions(C);

		PC = PlayerOwner();
		if ( (PC.myHUD == None || !PC.myHUD.IsInCinematic()) && GRI != none && GRI.bMatchHasBegun && !PC.IsInState('GameEnded') )
        	EnableComponent(b_Spec);
		else DisableComponent(b_Spec);
		
		if( PC.PlayerReplicationInfo!=None && bOldSpectator!=PC.PlayerReplicationInfo.bOnlySpectator )
		{
			bOldSpectator = !bOldSpectator;
			if ( bOldSpectator )
				b_Spec.Caption = class'KFTab_MidGamePerks'.default.JoinGameButtonText;
			else b_Spec.Caption = class'KFTab_MidGamePerks'.default.SpectateButtonText;
		}
	}

	return false;
}

function Opened(GUIComponent Sender)
{
	Super.Opened(Sender);

	if (TurboPlayerController(PlayerOwner()) != None)
	{
        TurboPlayerController(PlayerOwner()).SetLoginMenuState(true);
    }
}

function Closed(GUIComponent Sender, bool bCancelled)
{
	Super.Closed(Sender,bCancelled);

	if (TurboPlayerController(PlayerOwner()) != None)
	{
        TurboPlayerController(PlayerOwner()).SetLoginMenuState(false);
    }
}

simulated function bool OpenPlayerChat(GUIComponent Sender)
{
	if (Controller == None || Controller.Master == None || ExtendedConsole(Controller.Master.Console) == None)
	{
		return false;
	}

	if (ExtendedConsole(Controller.Master.Console) != None)
	{
		ExtendedConsole(Controller.Master.Console).ChatMenuClass = string(class'KFTurbo.TurboInGameChat');
	}

	Controller.CloseMenu();
	Controller.OpenMenu("KFTurbo.TurboInGameChat");
	return true;
}

function SetButtonPositions(Canvas C)
{
    local int i, j, ButtonsPerRow, ButtonsLeftInRow, NumButtons;
    local float Width, Height, Center, X, Y, YL, ButtonSpacing;

    Width = b_Settings.ActualWidth();
    Height = b_Settings.ActualHeight();
    Center = ActualLeft() + (ActualWidth() / 2.0);

    ButtonSpacing = Width * 0.05;
    YL = Height * 1.2;
    Y = b_Settings.ActualTop();

    ButtonsPerRow = ActualWidth() / (Width + ButtonSpacing);
    ButtonsLeftInRow = ButtonsPerRow;

    for (i = 0; i < Components.Length; i++)
	{
		if (Components[i].bVisible && GUIButton(Components[i]) != None)
	    {
			NumButtons++;
	    }
    }

    if (NumButtons < ButtonsPerRow)
    {
    	X = Center - (((Width * float(NumButtons)) + (ButtonSpacing * float(NumButtons - 1))) * 0.5);
    }
    else if ( ButtonsPerRow > 1 )
    {
        X = Center - (((Width * float(ButtonsPerRow)) + (ButtonSpacing * float(ButtonsPerRow - 1))) * 0.5);
    }
    else
    {
        X = Center - Width / 2.0;
    }

    for (i = 0; i < Components.Length; i++)
	{
		if (!Components[i].bVisible || GUIButton(Components[i]) == None)
        {
            continue;
        }

        Components[i].SetPosition(X, Y, Width, Height, true);

        if (--ButtonsLeftInRow > 0)
        {
            X += Width + ButtonSpacing;
        }
        else
        {
            Y += YL;

            for (j = i + 1; j < Components.Length && ButtonsLeftInRow < ButtonsPerRow; j++)
            {
                if (Components[i].bVisible && GUIButton(Components[i]) != None)
                {
                    ButtonsLeftInRow++;
                }
            }

            if (ButtonsLeftInRow > 1)
            {
                X = Center - (((Width * float(ButtonsLeftInRow)) + (ButtonSpacing * float(ButtonsLeftInRow - 1))) * 0.5);
            }
            else
            {
                X = Center - Width / 2.0;
            }
        }
    }
}

defaultproperties
{
	Panels(0)=(Caption="Info",Hint="Information about KFTurbo.")
    Panels(3)=(ClassName="KFTurbo.TurboTab_EmoteList",Caption="Emotes",Hint="List of emotes.")
    Panels(4)=(ClassName="KFTurbo.TurboTab_TurboSettings",Caption="Settings",Hint="KFTurbo settings.")

	Begin Object Class=TurboGUITabControl Name=LoginMenuTC
		WinWidth=1.0
		WinHeight=0.055
		WinLeft=0.0
		WinTop=0.01
        TabHeight=0.035000
        bAcceptsInput=true
        bDockPanels=true
        bScaleToParent=true
        bFillSpace=True
        BackgroundStyleName="TabBackground"
    End Object
    c_Main=TurboGUITabControl'LoginMenuTC'


	Begin Object Class=GUIButton Name=SettingsButton
		WinTop=0.885
		WinLeft=0.194420
		WinWidth=0.147268
		WinHeight=0.035000
		TabOrder=0
		bBoundToParent=True
		bScaleToParent=True
		OnClick=SRInvasionLoginMenu.ButtonClicked
		OnKeyEvent=SettingsButton.InternalOnKeyEvent
	End Object
	b_Settings=GUIButton'SettingsButton'

	Begin Object Class=GUIButton Name=PlayerChatButton
		Caption="Show Chat"
		WinTop=0.900000
		WinLeft=0.194420
		WinWidth=0.147268
		WinHeight=0.035000
		TabOrder=0
		bBoundToParent=True
		bScaleToParent=True
		OnClick=TurboInvasionLoginMenu.OpenPlayerChat
		OnKeyEvent=PlayerChatButton.InternalOnKeyEvent
	End Object
	b_PlayerChat=GUIButton'PlayerChatButton'

	DefaultWidth=0.8
	DefaultHeight=0.9
	DefaultLeft=0.1
	DefaultTop=0.05
	WinWidth=0.8
	WinHeight=0.9
	WinLeft=0.1
	WinTop=0.05
}