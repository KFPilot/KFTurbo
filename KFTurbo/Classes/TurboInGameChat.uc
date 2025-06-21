//Killing Floor Turbo TurboInGameChat
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboInGameChat extends UT2K4InGameChat;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	//This character does not like being copied so we're just gonna pull it from the UT2K4InGameChat widget.
	lb_Chat.Separator = class'UT2K4InGameChat'.default.lb_Chat.Separator;
	eb_Send.Caption = class'UT2K4InGameChat'.default.eb_Send.Caption;
	eb_Send.Hint = class'UT2K4InGameChat'.default.eb_Send.Hint;

	Super.InitComponent(MyController, MyOwner);

	//We don't want this component to be managed.
	sb_Main.UnmanageComponent(lb_Chat);
}

function HandleChat(string Msg, int TeamIndex)
{
	lb_chat.AddText(Msg);
}

defaultproperties
{
	Begin Object class=AltSectionBackground name=TurboMain
		WinWidth=1.0
		WinHeight=1.0
		WinLeft=0.0
		Wintop=0.0
		LeftPadding=0
		RightPadding=0
		TopPadding=0
		BottomPadding=0
		bFillClient=true
        bBoundToParent=true
        bScaleToParent=true
        bNeverFocus=true
	End Object
	sb_Main=AltSectionBackground'TurboMain'

	Begin Object Class=GUIScrollTextBox Name=TurboChat
		WinWidth=0.95
		WinHeight=0.9
		WinLeft=0.025
		WinTop=0.05
		CharDelay=0.0025
		EOLDelay=0
		StyleName="NoBackground"
        bNoTeletype=true
        bNeverFocus=true
        TextAlign=TXTA_Left
        bBoundToParent=true
        bScaleToParent=true
        FontScale=FNS_Small
        Separator=""
	End Object
	lb_Chat=GUIScrollTextBox'TurboChat'

	Begin Object Class=moEditBox Name=TurboSend
		WinWidth=0.95
		WinHeight=0.035
		WinLeft=0.025
		WinTop=0.95
		bScaleToParent=True
		bBoundToParent=True
		Caption=""
		Hint=""
		ComponentWidth=-1
		CaptionWidth=0.1
		bAutoSizeCaption=True
		TabOrder=0
		LabelJustification=TXTA_Left
	End Object
	eb_Send=moEditBox'TurboSend'

	bRenderWorld=true
    bRequire640x480=false
    bAllowedAsLast=true
	DefaultWidth=0.8
	DefaultHeight=0.8
	DefaultLeft=0.1
	DefaultTop=0.05
	WinWidth=0.8
	WinHeight=0.8
	WinLeft=0.1
	WinTop=0.05

	bResizeWidthAllowed=False
	bResizeHeightAllowed=False
	bMoveAllowed=False
	bPersistent=True
}
