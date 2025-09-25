//Killing Floor Turbo TurboLobbyFooter
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboLobbyFooter extends SRLobbyFooter;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	b_Perks.StyleName = class'TurboGUIStyleButton'.default.KeyName;
	b_Perks.AutoSizePadding.VertPerc += 0.1f;
	b_Perks.AutoSizePadding.HorzPerc += 0.05f;

	b_Ready.StyleName = class'TurboGUIStyleButton'.default.KeyName;
	b_Ready.AutoSizePadding.VertPerc = 0.1f;
	b_Ready.AutoSizePadding.HorzPerc += 0.05f;
	
	b_Cancel.StyleName = class'TurboGUIStyleButton'.default.KeyName;
	b_Cancel.AutoSizePadding.VertPerc = 0.1f;
	b_Cancel.AutoSizePadding.HorzPerc += 0.05f;
	
	b_Options.StyleName = class'TurboGUIStyleButton'.default.KeyName;
	b_Options.AutoSizePadding.VertPerc = 0.1f;
	b_Options.AutoSizePadding.HorzPerc += 0.05f;

	Super.InitComponent(MyController, MyOwner);
}

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

/*
function bool ButtonsSized(Canvas C)
{
	local int i;
	local GUIButton Button;
	local bool bResult;
	local string CaptionString;
	local float T, AH, AT;

	if (!bPositioned)
	{
		return false;
	}

	bResult = true;
	CaptionString = GetLongestCaption(C);

	AH = ActualHeight();
	AT = ActualTop();

	for (i = 0; i < Controls.Length; i++ )
	{
		Button = GUIButton(Controls[i]);

		if (Button != None)
		{
			if (bAutoSize && bFixedWidth)
			{
				Button.SizingCaption = CaptionString;
			}
			else
			{
				Button.SizingCaption = "";
			}

			bResult = bResult && Button.bPositioned;
			
			if (bFullHeight)
			{
				Button.WinHeight = Button.RelativeHeight(AH,true);
			}
			else 
			{
				Button.WinHeight = Button.RelativeHeight(ActualHeight(ButtonHeight), true);
			}

			switch (Justification)
			{
			case TXTA_Left:
				T = ClientBounds[1];
				break;
			case TXTA_Center:
				T = (AT + AH / 2) - (Button.ActualHeight() / 2);
				break;
			case TXTA_Right:
				T = Bounds[3] - Button.ActualHeight();
				break;
			}

			Button.WinTop = Button.RelativeTop(T, true) + ((WinHeight - (ButtonHeight)) / 2);
		}
	}

	return bResult;
}
*/

defaultproperties
{
	ButtonHeight=0.04
	bAutoSize = true
	bFixedWidth = true
}