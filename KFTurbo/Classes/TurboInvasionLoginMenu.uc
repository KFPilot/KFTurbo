Class TurboInvasionLoginMenu extends SRInvasionLoginMenu;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;
    local string s;
    local eFontScale FS;
	local SRMenuAddition M;

	// Setup panel classes.
	Panels[0].ClassName = string(class'SRTab_ServerNews');
	Panels[1].ClassName = string(class'TurboTab_MidGamePerks');
	Panels[2].ClassName = string(class'SRTab_MidGameVoiceChat');
	Panels[3].ClassName = string(class'SRTab_MidGameHelp');
	Panels[4].ClassName = string(class'SRTab_MidGameStats');

	// Setup localization.
	Panels[1].Caption = Class'KFInvasionLoginMenu'.Default.Panels[1].Caption;
	Panels[2].Caption = Class'KFInvasionLoginMenu'.Default.Panels[2].Caption;
	Panels[3].Caption = Class'KFInvasionLoginMenu'.Default.Panels[3].Caption;
	Panels[1].Hint = Class'KFInvasionLoginMenu'.Default.Panels[1].Hint;
	Panels[2].Hint = Class'KFInvasionLoginMenu'.Default.Panels[2].Hint;
	Panels[3].Hint = Class'KFInvasionLoginMenu'.Default.Panels[3].Hint;
	b_Spec.Caption=class'KFTab_MidGamePerks'.default.b_Spec.Caption;
	b_MatchSetup.Caption=class'KFTab_MidGamePerks'.default.b_MatchSetup.Caption;
	b_KickVote.Caption=class'KFTab_MidGamePerks'.default.b_KickVote.Caption;
	b_MapVote.Caption=class'KFTab_MidGamePerks'.default.b_MapVote.Caption;
	b_Quit.Caption=class'KFTab_MidGamePerks'.default.b_Quit.Caption;
	b_Favs.Caption=class'KFTab_MidGamePerks'.default.b_Favs.Caption;
	b_Favs.Hint=class'KFTab_MidGamePerks'.default.b_Favs.Hint;
	b_Settings.Caption=class'KFTab_MidGamePerks'.default.b_Settings.Caption;
	b_Browser.Caption=class'KFTab_MidGamePerks'.default.b_Browser.Caption;

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


   	s = GetSizingCaption();

	for ( i = 0; i < Controls.Length; i++ )
    {
    	if ( GUIButton(Controls[i]) != None )
        {
            GUIButton(Controls[i]).bAutoSize = true;
            GUIButton(Controls[i]).SizingCaption = s;
            GUIButton(Controls[i]).AutoSizePadding.HorzPerc = 0.04;
            GUIButton(Controls[i]).AutoSizePadding.VertPerc = 0.5;
        }
    }
    s = class'KFTab_MidGamePerks'.default.PlayerStyleName;
    PlayerStyle = MyController.GetStyle(s, fs);
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

defaultproperties
{
}
