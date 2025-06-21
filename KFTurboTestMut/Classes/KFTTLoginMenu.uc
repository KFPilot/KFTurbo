class KFTTLoginMenu extends KFGui.KFInvasionLoginMenu;

function InitComponent(GUIController MyController, GUIComponent MyComponent) {
	Super(FloatingWindow).InitComponent(MyController, MyComponent);
	
	if (Panels.length > 0)
		AddPanels();

	SetTitle();
	T_WindowTitle.DockedTabs = c_Main;
	c_Main.RemoveTab(Panels[0].Caption);
	if (KFTTPlayerController(PlayerOwner()) != None) {
		c_Main.ActivateTabByName(Panels[1].Caption, true);
	}
	else {
		c_Main.RemoveTab(Panels[1].Caption);
		c_Main.ActivateTabByName(Panels[2].Caption, true);
	}
}

function AddPanels() {
	local int i;
	local MidGamePanel Panel;

	for (i = 0; i < Panels.length; i++) {
		if (Panels[i].Caption != "")
			Panel = MidGamePanel(c_Main.AddTabItem(Panels[i]));
		if (Panel != None)
			Panel.ModifiedChatRestriction = UpdateChatRestriction;
	}
}

defaultproperties
{
	Panels(1)=(ClassName="KFTurboTestMut.KFTTTabMain",Caption="Commands",Hint="Main mutator interface")
	Panels(2)=(ClassName="KFTurboTestMut.KFTTTabDamage",Caption="Damage",Hint="Damage dealt to zeds")
	Panels(3)=(ClassName="KFTurboTestMut.KFTTTabDisplay",Caption="Display",Hint="Customize appearance of damage messages and head hitboxes")
	Panels(4)=(ClassName="KFTurboTestMut.KFTTTabWeapon",Caption="Weapon",Hint="Your current weapon stats adjusted for your current perk bonuses")
	Panels(5)=(ClassName="KFGui.KFTab_MidGameVoiceChat",Caption="Communication",Hint="Manage communication with other players")
	Panels(6)=(ClassName="KFTurboTestMut.KFTTTabHelp",Caption="Help",Hint="List of all available commands")
	Panels(7)=(ClassName="KFTurbo.TurboTab_EmoteList",Caption="Emotes",Hint="List of emotes.")
	Panels(8)=(ClassName="KFTurbo.TurboTab_TurboSettings",Caption="Settings",Hint="KFTurbo settings.")
	Begin Object Class=GUITabControl Name=LoginMenuTC
		bDockPanels=True
		BackgroundStyleName="TabBackground"
		WinTop=0.026336
		WinLeft=0.012500
		WinWidth=0.974999
		WinHeight=0.050000
		bScaleToParent=True
		bAcceptsInput=True
		OnActivate=LoginMenuTC.InternalOnActivate
	End Object
	c_Main=GUITabControl'KFTurboTestMut.KFTTLoginMenu.LoginMenuTC'

}
