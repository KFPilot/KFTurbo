class KFTTTabHelp extends KFTTBlankPanel;

var automated GUISectionBackground sb_Help;
var automated GUIScrollTextBox lb_Help;
var string HelpStr;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
	Super.Initcomponent(MyController, MyOwner);
	sb_Help.ManageComponent(lb_Help);
}

function InitGRI() {
	if (HelpStr != "")
		lb_Help.SetContent(HelpStr);
	
	Super.InitGRI();
}

function bool InternalOnPreDraw(Canvas C) {
	local float w, h, center, x, y, vpad;

	vpad = 0.05;
	w = ActualWidth() * 0.8;
	h = ActualHeight() * (b_KFButtons[0].winTop - 2 * vpad);
	center = ActualLeft() + ActualWidth() / 2;
	x = center - w / 2;
	y = ActualTop() + ActualHeight() * b_KFButtons[0].winTop * vpad;
	
	sb_Help.SetPosition(x, y, w, h, true);
	
	return Super.InternalOnPreDraw(C);
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=sbHelp
         bFillClient=True
         Caption="Available commands"
         OnPreDraw=sbHelp.InternalPreDraw
     End Object
     sb_Help=AltSectionBackground'KFTurboTestMut.KFTTTabHelp.sbHelp'

     Begin Object Class=GUIScrollTextBox Name=lbHelp
         bNoTeletype=True
         CharDelay=0.002500
         EOLDelay=0.000000
         OnCreateComponent=lbHelp.InternalOnCreateComponent
         bNeverFocus=True
     End Object
     lb_Help=GUIScrollTextBox'KFTurboTestMut.KFTTTabHelp.lbHelp'

     HelpStr="Aside from using the GUI, the following commands can either be bound to a key or manually typed in the console. All commands are case insensitive.||* SetPerk [perk] [level] - change your perk and level;||* SetHealth [number of players] - set the number of players to scale zeds' health;||* SetGameSpeed [new speed] - adjust the game speed;||* ClearLevel - remove all weapon pickups and projectiles and reset all doors;||* ClearZeds - remove all zeds;||* Whoosh - teleport between set locations on the map;||* Trade - open the trader menu;||* GodMode - toggle god mode;||* ViewZeds / ViewSelf - spectate zeds;||* ForceRadial - force Patriarch to do his radial attack;||* Poof - fire a projectile that instantly kills zeds."
     OnPreDraw=KFTTTabHelp.InternalOnPreDraw
}
