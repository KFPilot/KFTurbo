class KFTTTabWeapon extends KFTTBlankPanel;

const STR_Separator = "------------------------------------------------";
const STR_SeparatorShort = "|------------------------|";
const STR_Tab = "     ";

var automated GUISectionBackground sb_Stats;
var automated GUIScrollTextBox lb_Stats;
var color StatColour, TextColour;
var bool bSwitchSmiley;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
	Super.Initcomponent(MyController, MyOwner);
	sb_Stats.ManageComponent(lb_Stats);
}

function bool InternalOnPreDraw(Canvas C) {
	local float w, h, center, x, y, vpad;

	vpad = 0.05;
	w = ActualWidth() * 0.8;
	h = ActualHeight() * (b_KFButtons[0].winTop - 2 * vpad);
	center = ActualLeft() + ActualWidth() / 2;
	x = center - w / 2;
	y = ActualTop() + ActualHeight() * b_KFButtons[0].winTop * vpad;
	
	sb_Stats.SetPosition(x, y, w, h, true);
	
	return Super.InternalOnPreDraw(C);
}

function ShowPanel(bool bShow) {
	Super.ShowPanel(bShow);
	InitStats();
}

function InitStats() {
	local KFPlayerReplicationInfo PRI;
	local KFWeapon W;
	local class<KFTTStatsGenerator> SG;
	local string SC, TC;

	PRI = KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);
	if (PlayerOwner().Pawn != None)
		W = KFWeapon(PlayerOwner().Pawn.Weapon);
	else
		W = None;

	if (W != None && Welder(W) == None && Syringe(W) == None) {
		SG = class'KFTTStatsGenerator';
		SC = MakeColorCode(StatColour);
		TC = MakeColorCode(TextColour);
		
		lb_Stats.SetContent(SC $ "Current perk:" $ TC @ SG.static.GetPerkString(PRI));
		lb_Stats.AddText(SC $ "Weapon:" $ TC @ SG.static.GetWeaponName(W));
		lb_Stats.AddText(SC $ "Description:" $ TC @ SG.static.GetDescription(W));
		lb_Stats.AddText(TC $ STR_Separator $ "|");

		if (PipeBombExplosive(W) != None) {
			lb_Stats.AddText(SC $ "Damage:" $ TC @ SG.static.GetDamage(PRI, W));
			lb_Stats.AddText(SC $ "Damage radius:" $ TC @ SG.static.GetDamageRadius(W));
			lb_Stats.AddText(SC $ "Total capacity:" $ TC @ SG.static.GetMaxAmmo(PRI, W));
		}
		else if (!W.bMeleeWeapon) {
			lb_Stats.AddText(SC $ "Rate of fire:" $ TC @ SG.static.GetFireRate(PRI, W));
			
			if (AA12AutoShotgun(W) != None || Boomstick(W) != None || BenelliShotgun(W) != None || KSGShotgun(W) != None || NailGun(W) != None || Shotgun(W) != None || TrenchGun(W) != None) {
				lb_Stats.AddText(SC $ "Pellets per fire:" $ TC @ SG.static.GetProjPerFire(W));
				lb_Stats.AddText(SC $ "Pen. damage reduction:" $ TC @ SG.static.GetPenDamageReduction(PRI, W));

				lb_Stats.AddText(TC $ STR_SeparatorShort);
				
				lb_Stats.AddText(TC $ "Single pellet:|");
				lb_Stats.AddText(SC $ STR_Tab $ "Base damage:" $ TC @ SG.static.GetDamage(PRI, W));
				lb_Stats.AddText(SC $ STR_Tab $ "Headshot damage:" $ TC @ SG.static.GetHeadshotDamage(PRI, W));
				lb_Stats.AddText(SC $ STR_Tab $ "Headshot multiplier:" $ TC @ SG.static.GetHeadshotMulti(PRI, W));
			}
			else if (Huskgun(W) != None || FlareRevolver(W) != None || DualFlareRevolver(W) != None || LAW(W) != None || M79GrenadeLauncher(W) != None || M32GrenadeLauncher(W) != None) {
				if (HuskGun(W) != None) {
					lb_Stats.AddText(SC $ "Base damage:" $ TC @ SG.static.GetHuskDamage(PRI, W));
					lb_Stats.AddText(SC $ "Damage radius:" $ TC @ SG.static.GetHuskDamageRadius(W));

					lb_Stats.AddText(TC $ STR_SeparatorShort);

					lb_Stats.AddText(SC $ "Impact damage:" $ TC @ SG.static.GetHuskImpactDamage(PRI, W));
					lb_Stats.AddText(SC $ "Headshot impact damage:" $ TC @ SG.static.GetHuskHeadshotImpactDamage(PRI, W));
				}
				else {
					lb_Stats.AddText(SC $ "Base damage:" $ TC @ SG.static.GetDamage(PRI, W));
					lb_Stats.AddText(SC $ "Damage radius:" $ TC @ SG.static.GetDamageRadius(W));

					lb_Stats.AddText(TC $ STR_SeparatorShort);

					lb_Stats.AddText(SC $ "Impact damage:" $ TC @ SG.static.GetImpactDamage(PRI, W));
					lb_Stats.AddText(SC $ "Headshot impact damage:" $ TC @ SG.static.GetHeadshotImpactDamage(PRI, W));
				}
				
				lb_Stats.AddText(SC $ "Headshot multiplier:" $ TC @ SG.static.GetHeadshotMulti(PRI, W));
			}
			else if (FlameThrower(W) != None) {
				lb_Stats.AddText(SC $ "Base damage:" $ TC @ SG.static.GetDamage(PRI, W));
			}
			else {
				lb_Stats.AddText(SC $ "Base damage:" $ TC @ SG.static.GetDamage(PRI, W));
				lb_Stats.AddText(SC $ "Headshot damage:" $ TC @ SG.static.GetHeadshotDamage(PRI, W));
				lb_Stats.AddText(SC $ "Headshot multiplier:" $ TC @ SG.static.GetHeadshotMulti(PRI, W));
			}

			lb_Stats.AddText(TC $ STR_SeparatorShort);
	
			if (W.MagCapacity > 1)
				lb_Stats.AddText(SC $ "Capacity:" $ TC @ SG.static.GetMagCapacity(PRI, W));
			lb_Stats.AddText(SC $ "Total capacity:" $ TC @ SG.static.GetMaxAmmo(PRI, W));
			if (W.MagCapacity > 1 && Boomstick(W) == None)
				lb_Stats.AddText(SC $ "Reload time:" $ TC @ SG.static.GetReloadRate(PRI, W));

			lb_Stats.AddText(TC $ STR_SeparatorShort);

			lb_Stats.AddText(SC $ "Spread:" $ TC @ SG.static.GetRecoilSpread(PRI, W));
			lb_Stats.AddText(SC $ "Max vertical recoil:" $ TC @ SG.static.GetVerticalRecoilAngle(W));
			lb_Stats.AddText(SC $ "Max horizontal recoil:" $ TC @ SG.static.GetHorizontalRecoilAngle(W));

			if (KFMedicGun(W) != None) {
				lb_Stats.AddText(TC $ STR_SeparatorShort);

				lb_Stats.AddText(SC $ "Healing amount:" $ TC @ SG.static.GetHealAmount(PRI, W));
				lb_Stats.AddText(SC $ "Single dart regen time:" $ TC @ SG.static.GetRegenTime(PRI, W));
			}
		}
		else {
			lb_Stats.AddText(TC $ "Primary:|");
			lb_Stats.AddText(SC $ STR_Tab $ "Rate of fire:" $ TC @ SG.static.GetFireRate(PRI, W));
			lb_Stats.AddText(SC $ STR_Tab $ "Base damage:" $ TC @ SG.static.GetDamage(PRI, W));
			lb_Stats.AddText(SC $ STR_Tab $ "Headshot damage:" $ TC @ SG.static.GetHeadshotDamage(PRI, W));

			lb_Stats.AddText(TC $ STR_SeparatorShort);

			lb_Stats.AddText(TC $ "Secondary:|");
			lb_Stats.AddText(SC $ STR_Tab $ "Rate of fire:" $ TC @ SG.static.GetFireRate(PRI, W, 1));
			lb_Stats.AddText(SC $ STR_Tab $ "Base damage:" $ TC @ SG.static.GetDamage(PRI, W, 1));
			lb_Stats.AddText(SC $ STR_Tab $ "Headshot damage:" $ TC @ SG.static.GetHeadshotDamage(PRI, W, 1));

			lb_Stats.AddText(TC $ STR_SeparatorShort);

			lb_Stats.AddText(SC $ "Headshot multiplier:" $ TC @ SG.static.GetHeadshotMulti(PRI, W));
			lb_Stats.AddText(SC $ "Melee range:" $ TC @ SG.static.GetWeaponRange(W));
			lb_Stats.AddText(SC $ "Movement speed reduction when attacking:" $ TC @ SG.static.GetChopSlowRate(W));
		}
		lb_Stats.AddText(TC $ STR_SeparatorShort);

		lb_Stats.AddText(SC $ "Cost:" $ TC @ SG.static.GetWeaponCost(PRI, W));
		lb_Stats.AddText(SC $ "Weight:" $ TC @ SG.static.GetWeight(W));
		lb_Stats.AddText(SC $ "Inventory group:" $ TC @ SG.static.GetInventoryGroup(W));
		lb_Stats.AddText(SC $ "Priority:" $ TC @ SG.static.GetPriority(W));
	}
	else {
		lb_Stats.SetContent("N/A");
	}
	
	SetTimer(0.015, false);
}

event Timer() {
	Super.Timer();
	lb_Stats.MyScrollText.Home();
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=sbStats
         bFillClient=True
         Caption="Weapon Stats"
         OnPreDraw=sbStats.InternalPreDraw
     End Object
     sb_Stats=AltSectionBackground'KFTurboTestMut.KFTTTabWeapon.sbStats'

     Begin Object Class=GUIScrollTextBox Name=lbStats
         bNoTeletype=True
         CharDelay=0.002500
         EOLDelay=0.000000
         OnCreateComponent=lbStats.InternalOnCreateComponent
         FontScale=FNS_Small
         bNeverFocus=True
     End Object
     lb_Stats=GUIScrollTextBox'KFTurboTestMut.KFTTTabWeapon.lbStats'

     StatColour=(B=120,G=120,R=120)
     TextColour=(B=255,G=255,R=255)
     OnPreDraw=KFTTTabWeapon.InternalOnPreDraw
}
