class KFTTTabDamage extends KFTTBlankPanel;

var KFTTPlayerController PC;
var automated GUISectionBackground sb_Damage;
var automated GUIScrollTextBox lb_Damage;
var automated GUIButton b_Clear;

function InitPanel() {
	PC = KFTTPlayerController(PlayerOwner());
	if (PC == None)
		Free();
}

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
	Super.Initcomponent(MyController, MyOwner);
	sb_Damage.ManageComponent(lb_Damage);
}

function ShowPanel(bool bShow) {
	local int i;
	
	Super.ShowPanel(bShow);
	
	if (!bShow)
		return;
	
	lb_Damage.SetContent("");
	for (i = 0; i < PC.DamageMessages.length; i++) {
		if (Left(PC.DamageMessages[i], 10) ~= "Total hits")
			lb_Damage.AddText("|");
		
		lb_Damage.AddText(PC.DamageMessages[i]);
	}
	
	SetTimer(0.015, false);
}

event Timer() {
	Super.Timer();
	lb_Damage.MyScrollText.End();
}

function bool InternalOnPreDraw(Canvas C) {
	local float w, h, center, x, y, vpad, wB, hB, bpad;

	vpad = 0.05;
	wB = b_Clear.ActualWidth();
	hB = b_Clear.ActualHeight();
	bpad = hB * vpad;
	w = ActualWidth() * 0.8;
	h = ActualHeight() * (b_KFButtons[0].winTop - 2 * vpad) - hB;
	center = ActualLeft() + ActualWidth() / 2;
	x = center - w / 2;
	y = ActualTop() + ActualHeight() * b_KFButtons[0].winTop * vpad;
	
	sb_Damage.SetPosition(x, y, w, h - bpad, true);
	b_Clear.SetPosition(x + w - wB, y + h, wB, hB, true);
	
	return Super.InternalOnPreDraw(C);
}

function bool ButtonClicked(GUIComponent Sender) {
	if (Sender == b_Clear) {
		PC.ClearDamageMessages();
		lb_Damage.SetContent("");
	}
	
	return Super.ButtonClicked(Sender);
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=sbDamage
         bFillClient=True
         Caption="Damage"
         OnPreDraw=sbDamage.InternalPreDraw
     End Object
     sb_Damage=AltSectionBackground'KFTurboTestMut.KFTTTabDamage.sbDamage'

     Begin Object Class=GUIScrollTextBox Name=lbDamage
         bNoTeletype=True
         CharDelay=0.000000
         EOLDelay=0.000000
         RepeatDelay=0.000000
         OnCreateComponent=lbDamage.InternalOnCreateComponent
         FontScale=FNS_Small
         bNeverFocus=True
     End Object
     lb_Damage=GUIScrollTextBox'KFTurboTestMut.KFTTTabDamage.lbDamage'

     Begin Object Class=GUIButton Name=bClear
         Caption="Clear"
         TabOrder=0
         OnClick=KFTTTabDamage.ButtonClicked
         OnKeyEvent=bClear.InternalOnKeyEvent
     End Object
     b_Clear=GUIButton'KFTurboTestMut.KFTTTabDamage.bClear'

     OnPreDraw=KFTTTabDamage.InternalOnPreDraw
}
