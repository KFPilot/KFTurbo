//Killing Floor Turbo TurboLobbyFooter
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboLobbyFooter extends SRLobbyFooter;

function bool OnFooterClick(GUIComponent Sender)
{
	local GUIController C;
	local PlayerController PC;

	PC = PlayerOwner();
	C = Controller;

	if(Sender == b_Cancel)
	{
		//Kill Window and exit game/disconnect from server
		LobbyMenu(PageOwner).bAllowClose = true;
		C.ViewportOwner.Console.ConsoleCommand("DISCONNECT");
		PC.ClientCloseMenu(true, false);
		C.AutoLoadMenus();
	}
	else if(Sender == b_Ready)
	{
		if ( PC.Level.NetMode == NM_Standalone || !PC.PlayerReplicationInfo.bReadyToPlay )
		{
			//Set Ready
			PC.ServerRestartPlayer();
			PC.PlayerReplicationInfo.bReadyToPlay = True;
			if ( PC.Level.GRI.bMatchHasBegun )
				PC.ClientCloseMenu(true, false);
			b_Ready.Caption = UnreadyString;
		}
		else
		{
			// Spectate map while waiting for players to get ready
			LobbyMenu(PageOwner).bAllowClose = true;
			PC.ClientCloseMenu(true, false);
		}
	}
	else if (Sender == b_Options)
	{
		PC.ClientOpenMenu("KFGUI.KFSettingsPage", false);
	}
	else if (Sender == b_Perks)
	{
		PC.ClientOpenMenu(string(Class'TurboInvasionLoginMenu'), false);
	}

	return false;
}

defaultproperties
{
}
