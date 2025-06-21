class KFTTTabDisplay extends KFTTBlankPanel;

var KFTTPlayerController PC;
var automated GUISectionBackground sb_Damage, sb_Hitbox;
var automated GUILabel l_DamageExample, l_HitboxExample;
var automated moSlider sl_DamageR, sl_DamageG, sl_DamageB, sl_DamageA, sl_HitboxR, sl_HitboxG, sl_HitboxB, sl_NumSegments;

function InitPanel() {
	PC = KFTTPlayerController(PlayerOwner());
	if (PC == None) {
		Free();
	}
}

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
	Super.Initcomponent(MyController, MyOwner);
	sb_Damage.ManageComponent(l_DamageExample);
	sb_Damage.ManageComponent(sl_DamageR);
	sb_Damage.ManageComponent(sl_DamageG);
	sb_Damage.ManageComponent(sl_DamageB);
	sb_Damage.ManageComponent(sl_DamageA);
	sb_Hitbox.ManageComponent(l_HitboxExample);
	sb_Hitbox.ManageComponent(sl_HitboxR);
	sb_Hitbox.ManageComponent(sl_HitboxG);
	sb_Hitbox.ManageComponent(sl_HitboxB);
	sb_Hitbox.ManageComponent(sl_NumSegments);
}

function ShowPanel(bool bShow) {
	Super.ShowPanel(bShow);
	
	if (!bShow) {
		return;
	}
	
	l_DamageExample.TextColor = PC.DmgMsgCol;
	sl_DamageR.SetValue(PC.DmgMsgCol.R);
	sl_DamageG.SetValue(PC.DmgMsgCol.G);
	sl_DamageB.SetValue(PC.DmgMsgCol.B);
	sl_DamageA.SetValue(PC.DmgMsgCol.A / 255 * 100);
	
	l_HitboxExample.TextColor = PC.HitboxCol;
	sl_HitboxR.SetValue(PC.HitboxCol.R);
	sl_HitboxG.SetValue(PC.HitboxCol.G);
	sl_HitboxB.SetValue(PC.HitboxCol.B);
	sl_NumSegments.SetValue(PC.NumSegments);
}

function bool InternalOnPreDraw(Canvas C) {
	local float w, h, center, x, y, vpad, hspacing;

	vpad = 0.15;
	w = ActualWidth() * 0.4;
	h = ActualHeight() * (b_KFButtons[0].winTop - 2 * vpad);
	center = ActualLeft() + ActualWidth() / 2;
	x = center - w;
	y = ActualTop() + ActualHeight() * b_KFButtons[0].winTop * vpad;
	
	hspacing = w * 0.01;
	w -= hspacing;
	center += hspacing;
	sb_Damage.SetPosition(x, y, w, h, true);
	sb_Hitbox.SetPosition(center, y, w, h, true);
	
	return Super.InternalOnPreDraw(C);
}

function InternalOnChange(GUIComponent Sender) {
	local Color TempCol;
	
	switch (Sender) {
		case sl_DamageR:
			TempCol = PC.DmgMsgCol;
			TempCol.R = sl_DamageR.GetValue();
			PC.SetDmgMsgCol(TempCol);
			l_DamageExample.TextColor = TempCol;
			break;
		case sl_DamageG:
			TempCol = PC.DmgMsgCol;
			TempCol.G = sl_DamageG.GetValue();
			PC.SetDmgMsgCol(TempCol);
			l_DamageExample.TextColor = TempCol;
			break;
		case sl_DamageB:
			TempCol = PC.DmgMsgCol;
			TempCol.B = sl_DamageB.GetValue();
			PC.SetDmgMsgCol(TempCol);
			l_DamageExample.TextColor = TempCol;
			break;
		case sl_DamageA:
			TempCol = PC.DmgMsgCol;
			TempCol.A = sl_DamageA.GetValue() / 100 * 255;
			l_DamageExample.TextColor = TempCol;
			PC.SetDmgMsgCol(TempCol);
			break;
		case sl_HitboxR:
			TempCol = PC.HitboxCol;
			TempCol.R = sl_HitboxR.GetValue();
			PC.SetHitboxCol(TempCol);
			l_HitboxExample.TextColor = TempCol;
			break;
		case sl_HitboxG:
			TempCol = PC.HitboxCol;
			TempCol.G = sl_HitboxG.GetValue();
			PC.SetHitboxCol(TempCol);
			l_HitboxExample.TextColor = TempCol;
			break;
		case sl_HitboxB:
			TempCol = PC.HitboxCol;
			TempCol.B = sl_HitboxB.GetValue();
			PC.SetHitboxCol(TempCol);
			l_HitboxExample.TextColor = TempCol;
			break;
		case sl_NumSegments:
			PC.SetNumSegments(sl_NumSegments.GetValue());
			break;
	}
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=sbDamage
         bFillClient=True
         Caption="Damage Messages"
         OnPreDraw=sbDamage.InternalPreDraw
     End Object
     sb_Damage=AltSectionBackground'KFTurboTestMut.KFTTTabDisplay.sbDamage'

     Begin Object Class=AltSectionBackground Name=sbHitbox
         bFillClient=True
         Caption="Head Hitboxes"
         OnPreDraw=sbHitbox.InternalPreDraw
     End Object
     sb_Hitbox=AltSectionBackground'KFTurboTestMut.KFTTTabDisplay.sbHitbox'

     Begin Object Class=GUILabel Name=DamageExample
         Caption="Example"
         TextAlign=TXTA_Center
         FontScale=FNS_Small
     End Object
     l_DamageExample=GUILabel'KFTurboTestMut.KFTTTabDisplay.DamageExample'

     Begin Object Class=GUILabel Name=HitboxExample
         Caption="Example"
         TextAlign=TXTA_Center
         FontScale=FNS_Small
     End Object
     l_HitboxExample=GUILabel'KFTurboTestMut.KFTTTabDisplay.HitboxExample'

     Begin Object Class=moSlider Name=DamageR
         MaxValue=255.000000
         bIntSlider=True
         LabelJustification=TXTA_Center
         ComponentJustification=TXTA_Left
         CaptionWidth=0.450000
         Caption="Red"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=DamageR.InternalOnCreateComponent
         TabOrder=1
         OnChange=KFTTTabDisplay.InternalOnChange
     End Object
     sl_DamageR=moSlider'KFTurboTestMut.KFTTTabDisplay.DamageR'

     Begin Object Class=moSlider Name=DamageG
         MaxValue=255.000000
         bIntSlider=True
         LabelJustification=TXTA_Center
         ComponentJustification=TXTA_Left
         CaptionWidth=0.450000
         Caption="Green"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=DamageG.InternalOnCreateComponent
         TabOrder=2
         OnChange=KFTTTabDisplay.InternalOnChange
     End Object
     sl_DamageG=moSlider'KFTurboTestMut.KFTTTabDisplay.DamageG'

     Begin Object Class=moSlider Name=DamageB
         MaxValue=255.000000
         bIntSlider=True
         LabelJustification=TXTA_Center
         ComponentJustification=TXTA_Left
         CaptionWidth=0.450000
         Caption="Blue"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=DamageB.InternalOnCreateComponent
         TabOrder=3
         OnChange=KFTTTabDisplay.InternalOnChange
     End Object
     sl_DamageB=moSlider'KFTurboTestMut.KFTTTabDisplay.DamageB'

     Begin Object Class=moSlider Name=DamageA
         MaxValue=100.000000
         bIntSlider=True
         LabelJustification=TXTA_Center
         ComponentJustification=TXTA_Left
         CaptionWidth=0.450000
         Caption="Alpha"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=DamageA.InternalOnCreateComponent
         TabOrder=4
         OnChange=KFTTTabDisplay.InternalOnChange
     End Object
     sl_DamageA=moSlider'KFTurboTestMut.KFTTTabDisplay.DamageA'

     Begin Object Class=moSlider Name=HitboxR
         MaxValue=255.000000
         bIntSlider=True
         LabelJustification=TXTA_Center
         ComponentJustification=TXTA_Left
         CaptionWidth=0.450000
         Caption="Red"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=HitboxR.InternalOnCreateComponent
         TabOrder=5
         OnChange=KFTTTabDisplay.InternalOnChange
     End Object
     sl_HitboxR=moSlider'KFTurboTestMut.KFTTTabDisplay.HitboxR'

     Begin Object Class=moSlider Name=HitboxG
         MaxValue=255.000000
         bIntSlider=True
         LabelJustification=TXTA_Center
         ComponentJustification=TXTA_Left
         CaptionWidth=0.450000
         Caption="Green"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=HitboxG.InternalOnCreateComponent
         TabOrder=6
         OnChange=KFTTTabDisplay.InternalOnChange
     End Object
     sl_HitboxG=moSlider'KFTurboTestMut.KFTTTabDisplay.HitboxG'

     Begin Object Class=moSlider Name=HitboxB
         MaxValue=255.000000
         bIntSlider=True
         LabelJustification=TXTA_Center
         ComponentJustification=TXTA_Left
         CaptionWidth=0.450000
         Caption="Blue"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=HitboxB.InternalOnCreateComponent
         TabOrder=7
         OnChange=KFTTTabDisplay.InternalOnChange
     End Object
     sl_HitboxB=moSlider'KFTurboTestMut.KFTTTabDisplay.HitboxB'

     Begin Object Class=moSlider Name=NumSegments
         MaxValue=30.000000
         MinValue=10.000000
         bIntSlider=True
         LabelJustification=TXTA_Center
         ComponentJustification=TXTA_Left
         CaptionWidth=0.450000
         Caption="Segments"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=NumSegments.InternalOnCreateComponent
         TabOrder=8
         OnChange=KFTTTabDisplay.InternalOnChange
     End Object
     sl_NumSegments=moSlider'KFTurboTestMut.KFTTTabDisplay.NumSegments'

     OnPreDraw=KFTTTabDisplay.InternalOnPreDraw
}
