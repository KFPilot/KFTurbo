class KFTTTabMain extends KFTTBlankPanel
	config(User);

var KFTTPlayerController PC;
var automated GUISectionBackground sb_TopLeft, sb_MidLeft, sb_BottomLeft, sb_TopRight, sb_BottomRight;
var automated GUILabel l_PerkLabel, l_HealthLabel, l_SpeedLabel;
var automated GUIButton b_SetPerk, b_SetHealth, b_SetSpeed, b_ClearLevel, b_ClearZeds, b_Teleport, b_Trade, b_God, b_ViewZeds, b_ViewSelf, b_Radial;
var automated moNumericEdit nu_NumPlayers;
var automated moComboBox co_PerkName;
var automated moFloatEdit fl_GameSpeed;
var automated moCheckbox ch_KeepWeapons, ch_EnableCrosshairs, ch_DrawHitboxes;

var array<GUIButton> LColumn, RColumn;

function InitPanel() {
	PC = KFTTPlayerController(PlayerOwner());
	if (PC == None)
		Free();
}

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
	Super.Initcomponent(MyController, MyOwner);

	co_PerkName.AddItem("Medic");
	co_PerkName.AddItem("Support Specialist");
	co_PerkName.AddItem("Sharpshooter");
	co_PerkName.AddItem("Commando");
	co_PerkName.AddItem("Berserker");
	co_PerkName.AddItem("Firebug");
	co_PerkName.AddItem("Demolitions");
	
	sb_TopLeft.ManageComponent(co_PerkName);
	sb_TopLeft.ManageComponent(l_PerkLabel);
	
	sb_MidLeft.ManageComponent(nu_NumPlayers);
	sb_MidLeft.ManageComponent(l_HealthLabel);
	
	sb_BottomLeft.ManageComponent(fl_GameSpeed);
	sb_BottomLeft.ManageComponent(l_SpeedLabel);
	
	sb_TopRight.ManageComponent(ch_KeepWeapons);
	sb_TopRight.ManageComponent(ch_EnableCrosshairs);
	sb_TopRight.ManageComponent(ch_DrawHitboxes);
	
	sb_BottomRight.ManageComponent(b_ClearLevel);
	sb_BottomRight.ManageComponent(b_Teleport);
	sb_BottomRight.ManageComponent(b_God);
	sb_BottomRight.ManageComponent(b_ViewZeds);
	
	LColumn[0] = b_ClearLevel;
	RColumn[0] = b_ClearZeds;
	LColumn[1] = b_Teleport;
	RColumn[1] = b_Trade;
	LColumn[2] = b_God;
	RColumn[2] = b_Radial;
	LColumn[3] = b_ViewZeds;
	RColumn[3] = b_ViewSelf;
}

function InternalOnLoadINI(GUIComponent Sender, string S) {
	switch (Sender) {
		case ch_KeepWeapons:
			ch_KeepWeapons.SetComponentValue(PC.bWantsKeepWeapons, true);
			break;
		case ch_EnableCrosshairs:
			ch_EnableCrosshairs.SetComponentValue(PC.bEnableCrosshairs, true);
			break;
		case ch_DrawHitboxes:
			ch_DrawHitboxes.SetComponentValue(PC.bDrawHitboxes, true);
			break;
	}
}

function InitValues() {
	local KFPlayerReplicationInfo PRI;
	
	nu_NumPlayers.SetValue(PC.Mut.numPlayers);
	fl_GameSpeed.SetValue(PC.Mut.gameSpeed);
	ch_KeepWeapons.SetComponentValue(PC.bWantsKeepWeapons, true);
	ch_EnableCrosshairs.SetComponentValue(PC.bEnableCrosshairs, true);
	ch_DrawHitboxes.SetComponentValue(PC.bDrawHitboxes, true);
	
	PRI = KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);
	if (PRI != None) {
		if (PRI.ClientVeteranSkill != None)
			co_PerkName.SetIndex(PRI.ClientVeteranSkill.default.PerkIndex);
	}
}

function ShowPanel(bool bShow) {
	Super.ShowPanel(bShow);

	if (bShow)
		InitValues();
}

function string GetPerkString(int aIndex) {
	switch (aIndex) {
		case 0:
			return "med";
		case 1:
			return "supp";
		case 2:
			return "sharp";
		case 3:
			return "cmdo";
		case 4:
			return "zerk";
		case 5:
			return "fire";
		case 6:
			return "demo";
		default:
			return "";
	}
}

function bool ButtonClicked(GUIComponent Sender) {
	switch (Sender) {
		case b_SetPerk:
			PC.SetPerk(GetPerkString(co_PerkName.GetIndex()));
			break;
		case b_SetHealth:
			PC.SetHealth(nu_NumPlayers.GetValue());
			break;
		case b_SetSpeed:
			PC.SetGameSpeed(fl_GameSpeed.GetValue());
			break;
		case b_ClearLevel:
			PC.ClearLevel();
			break;
		case b_ClearZeds:
			PC.ClearZeds();
			break;
		case b_Teleport:
			PC.Whoosh();
			break;
		case b_Trade:
			PC.Trade();
			break;
		case b_God:
			PC.GodMode();
			break;
		case b_ViewZeds:
			PC.ViewZeds();
			break;
		case b_ViewSelf:
			PC.ViewSelf();
			break;
		case b_Radial:
			PC.ForceRadial();
			break;
	}

	return Super.ButtonClicked(Sender);
}

function InternalOnChange(GUIComponent Sender) {
	switch (Sender) {
		case ch_KeepWeapons:
			PC.SetKeepWeapons(ch_KeepWeapons.IsChecked());
			break;
		case ch_EnableCrosshairs:
			PC.SetEnableCrosshairs(ch_EnableCrosshairs.IsChecked());
			break;
		case ch_DrawHitboxes:
			PC.SetDrawHitboxes(ch_DrawHitboxes.IsChecked());
			break;
	}
}

function UpdateButtonsVisibility() {
	if (PC.IsInState('PlayerWaiting') || PC.IsInState('Dead') || PC.IsInState('Spectating')) {
		b_SetPerk.DisableMe();
		b_SetHealth.DisableMe();
		b_SetSpeed.DisableMe();
		b_ClearLevel.DisableMe();
		b_ClearZeds.DisableMe();
		b_Teleport.DisableMe();
		b_Trade.DisableMe();
		b_God.DisableMe();
		b_Radial.DisableMe();
	}
	else {
		b_SetPerk.EnableMe();
		b_SetHealth.EnableMe();
		b_SetSpeed.EnableMe();
		b_Teleport.EnableMe();
		b_Trade.EnableMe();
		b_God.EnableMe();
		b_Radial.EnableMe();
		
		if (PC.Mut.bWaitClearLevel)
			b_ClearLevel.DisableMe();
		else
			b_ClearLevel.EnableMe();
		
		if (PC.Mut.bWaitClearZeds)
			b_ClearZeds.DisableMe();
		else
			b_ClearZeds.EnableMe();
	}
}

function bool InternalOnPreDraw(Canvas C) {
	local float w, h, h1, h2, center, x, y1, y2, y3, vpad;
	local byte i;

	vpad = 0.05;
	w = ActualWidth() * 0.47;
	h = ActualHeight() * (b_KFButtons[0].winTop - 2 * vpad);
	h1 = h * 0.4;
	h2 = (h - h1) / 2;
	center = ActualLeft() + ActualWidth() * 0.5;
	x = center - w;
	y1 = ActualTop() + ActualHeight() * b_KFButtons[0].winTop * vpad;
	y2 = y1 + h1;
	y3 = y2 + h2;

	sb_TopLeft.SetPosition(x, y1, w, h1, true);
	sb_MidLeft.SetPosition(x, y2, w, h2, true);
	sb_BottomLeft.SetPosition(x, y3, w, h2, true);
	sb_TopRight.SetPosition(center, y1, w, h1, true);
	sb_BottomRight.SetPosition(center, y2, w, 2 * h2, true);
	
	w = b_SetPerk.ActualWidth();
	h = b_SetPerk.ActualHeight();
	b_SetPerk.SetPosition(x, l_PerkLabel.ActualTop(), w, h, true);
	b_SetHealth.SetPosition(x, l_HealthLabel.ActualTop(), w, h, true);
	b_SetSpeed.SetPosition(x, l_SpeedLabel.ActualTop(), w, h, true);
	
	x = 2 * sb_BottomRight.ActualLeft() + sb_BottomRight.ActualWidth() - LColumn[0].ActualLeft() - w;
	for (i = 0; i < LColumn.length; i++)
		RColumn[i].SetPosition(x, LColumn[i].ActualTop(), w, h, true);
	
	UpdateButtonsVisibility();

	return Super.InternalOnPreDraw(C);
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=BGTopLeft
         bFillClient=True
         Caption="Change perk"
         OnPreDraw=BGTopLeft.InternalPreDraw
     End Object
     sb_TopLeft=GUISectionBackground'KFTurboTestMut.KFTTTabMain.BGTopLeft'

     Begin Object Class=GUISectionBackground Name=BGMidLeft
         bFillClient=True
         Caption="Health config"
         OnPreDraw=BGMidLeft.InternalPreDraw
     End Object
     sb_MidLeft=GUISectionBackground'KFTurboTestMut.KFTTTabMain.BGMidLeft'

     Begin Object Class=GUISectionBackground Name=BGBottomLeft
         bFillClient=True
         Caption="Game speed"
         OnPreDraw=BGBottomLeft.InternalPreDraw
     End Object
     sb_BottomLeft=GUISectionBackground'KFTurboTestMut.KFTTTabMain.BGBottomLeft'

     Begin Object Class=GUISectionBackground Name=BGTopRight
         bFillClient=True
         Caption="Misc. options"
         OnPreDraw=BGTopRight.InternalPreDraw
     End Object
     sb_TopRight=GUISectionBackground'KFTurboTestMut.KFTTTabMain.BGTopRight'

     Begin Object Class=GUISectionBackground Name=BGBottomRight
         Caption="Misc. commands"
         OnPreDraw=BGBottomRight.InternalPreDraw
     End Object
     sb_BottomRight=GUISectionBackground'KFTurboTestMut.KFTTTabMain.BGBottomRight'

     Begin Object Class=GUILabel Name=PerkLabel
         TabOrder=2
     End Object
     l_PerkLabel=GUILabel'KFTurboTestMut.KFTTTabMain.PerkLabel'

     Begin Object Class=GUILabel Name=HealthLabel
         TabOrder=5
     End Object
     l_HealthLabel=GUILabel'KFTurboTestMut.KFTTTabMain.HealthLabel'

     Begin Object Class=GUILabel Name=SpeedLabel
         TabOrder=8
     End Object
     l_SpeedLabel=GUILabel'KFTurboTestMut.KFTTTabMain.SpeedLabel'

     Begin Object Class=GUIButton Name=SetPerkButton
         Caption="Apply"
         TabOrder=3
         OnClick=KFTTTabMain.ButtonClicked
         OnKeyEvent=SetPerkButton.InternalOnKeyEvent
     End Object
     b_SetPerk=GUIButton'KFTurboTestMut.KFTTTabMain.SetPerkButton'

     Begin Object Class=GUIButton Name=SetHealth
         Caption="Apply"
         TabOrder=6
         OnClick=KFTTTabMain.ButtonClicked
         OnKeyEvent=SetHealth.InternalOnKeyEvent
     End Object
     b_SetHealth=GUIButton'KFTurboTestMut.KFTTTabMain.SetHealth'

     Begin Object Class=GUIButton Name=SetSpeed
         Caption="Apply"
         TabOrder=9
         OnClick=KFTTTabMain.ButtonClicked
         OnKeyEvent=SetSpeed.InternalOnKeyEvent
     End Object
     b_SetSpeed=GUIButton'KFTurboTestMut.KFTTTabMain.SetSpeed'

     Begin Object Class=GUIButton Name=ClearLevelButton
         Caption="Clear Level"
         Hint="Remove all weapon pickups and projectiles and reset all doors."
         TabOrder=13
         OnClick=KFTTTabMain.ButtonClicked
         OnKeyEvent=ClearLevelButton.InternalOnKeyEvent
     End Object
     b_ClearLevel=GUIButton'KFTurboTestMut.KFTTTabMain.ClearLevelButton'

     Begin Object Class=GUIButton Name=ClearZedsButton
         Caption="Clear Zeds"
         Hint="Remove all zeds."
         TabOrder=14
         OnClick=KFTTTabMain.ButtonClicked
         OnKeyEvent=ClearZedsButton.InternalOnKeyEvent
     End Object
     b_ClearZeds=GUIButton'KFTurboTestMut.KFTTTabMain.ClearZedsButton'

     Begin Object Class=GUIButton Name=TeleportButton
         Caption="Teleport"
         Hint="Teleport between set locations on the map."
         TabOrder=15
         OnClick=KFTTTabMain.ButtonClicked
         OnKeyEvent=TeleportButton.InternalOnKeyEvent
     End Object
     b_Teleport=GUIButton'KFTurboTestMut.KFTTTabMain.TeleportButton'

     Begin Object Class=GUIButton Name=TradeButton
         Caption="Trade"
         Hint="Open the trader menu."
         TabOrder=16
         OnClick=KFTTTabMain.ButtonClicked
         OnKeyEvent=TradeButton.InternalOnKeyEvent
     End Object
     b_Trade=GUIButton'KFTurboTestMut.KFTTTabMain.TradeButton'

     Begin Object Class=GUIButton Name=GodButton
         Caption="God Mode"
         Hint="Toggle god mode."
         TabOrder=17
         OnClick=KFTTTabMain.ButtonClicked
         OnKeyEvent=GodButton.InternalOnKeyEvent
     End Object
     b_God=GUIButton'KFTurboTestMut.KFTTTabMain.GodButton'

     Begin Object Class=GUIButton Name=ViewZedsButton
         Caption="View Zeds"
         Hint="Spectate zeds."
         TabOrder=19
         OnClick=KFTTTabMain.ButtonClicked
         OnKeyEvent=ViewZedsButton.InternalOnKeyEvent
     End Object
     b_ViewZeds=GUIButton'KFTurboTestMut.KFTTTabMain.ViewZedsButton'

     Begin Object Class=GUIButton Name=ViewSelfButton
         Caption="View Self"
         Hint="Set camera to the player."
         TabOrder=20
         OnClick=KFTTTabMain.ButtonClicked
         OnKeyEvent=ViewSelfButton.InternalOnKeyEvent
     End Object
     b_ViewSelf=GUIButton'KFTurboTestMut.KFTTTabMain.ViewSelfButton'

     Begin Object Class=GUIButton Name=RadialButton
         Caption="Force Radial"
         Hint="Force Patriarch to do his radial attack."
         TabOrder=18
         OnClick=KFTTTabMain.ButtonClicked
         OnKeyEvent=RadialButton.InternalOnKeyEvent
     End Object
     b_Radial=GUIButton'KFTurboTestMut.KFTTTabMain.RadialButton'

     Begin Object Class=moNumericEdit Name=NumPlayers
         MinValue=1
         MaxValue=99
         Caption="Number of players"
         OnCreateComponent=NumPlayers.InternalOnCreateComponent
         Hint="Number of players to scale zeds' health."
         TabOrder=4
         OnChange=KFTTTabMain.InternalOnChange
     End Object
     nu_NumPlayers=moNumericEdit'KFTurboTestMut.KFTTTabMain.NumPlayers'

     Begin Object Class=moComboBox Name=PerkName
         bReadOnly=True
         Caption="Perk"
         OnCreateComponent=PerkName.InternalOnCreateComponent
         Hint="Select your perk."
         TabOrder=1
         OnChange=KFTTTabMain.InternalOnChange
     End Object
     co_PerkName=moComboBox'KFTurboTestMut.KFTTTabMain.PerkName'

     Begin Object Class=moFloatEdit Name=GameSpeed
         MinValue=0.100000
         MaxValue=1.000000
         Caption="Game speed"
         OnCreateComponent=GameSpeed.InternalOnCreateComponent
         Hint="Adjust the game speed."
         TabOrder=7
         OnChange=KFTTTabMain.InternalOnChange
     End Object
     fl_GameSpeed=moFloatEdit'KFTurboTestMut.KFTTTabMain.GameSpeed'

     Begin Object Class=moCheckBox Name=KeepWeapons
         Caption="Keep weapons"
         OnCreateComponent=KeepWeapons.InternalOnCreateComponent
         Hint="Keep all weapons in the inventory upon death."
         TabOrder=10
         OnChange=KFTTTabMain.InternalOnChange
         OnLoadINI=KFTTTabMain.InternalOnLoadINI
     End Object
     ch_KeepWeapons=moCheckBox'KFTurboTestMut.KFTTTabMain.KeepWeapons'

     Begin Object Class=moCheckBox Name=EnableCrosshairs
         Caption="Show crosshairs"
         OnCreateComponent=EnableCrosshairs.InternalOnCreateComponent
         Hint="Show crosshairs."
         TabOrder=11
         OnChange=KFTTTabMain.InternalOnChange
         OnLoadINI=KFTTTabMain.InternalOnLoadINI
     End Object
     ch_EnableCrosshairs=moCheckBox'KFTurboTestMut.KFTTTabMain.EnableCrosshairs'

     Begin Object Class=moCheckBox Name=DrawHitboxes
         Caption="Draw head hitboxes"
         OnCreateComponent=DrawHitboxes.InternalOnCreateComponent
         Hint="Draw head hitboxes for zeds. Some zeds have larger hitboxes on dedicated servers, and they are also 25% larger for melee weapons."
         TabOrder=12
         OnChange=KFTTTabMain.InternalOnChange
         OnLoadINI=KFTTTabMain.InternalOnLoadINI
     End Object
     ch_DrawHitboxes=moCheckBox'KFTurboTestMut.KFTTTabMain.DrawHitboxes'

     OnPreDraw=KFTTTabMain.InternalOnPreDraw
}
