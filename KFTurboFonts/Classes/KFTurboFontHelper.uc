//Killing Floor Turbo KFTurboFonts
//Handles fonts for KFTurbo.
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboFontHelper extends Object;

#exec new TrueTypeFontFactory Name=BahnschriftNumbers134 FontName="Bahnschrift Regular" Height=134 Chars="0123456789:/-+£" AntiAlias=1 XPad=4
#exec new TrueTypeFontFactory Name=BahnschriftNumbers110 FontName="Bahnschrift Regular" Height=110 Chars="0123456789:/-+£" AntiAlias=1 XPad=4
#exec new TrueTypeFontFactory Name=BahnschriftNumbers72 FontName="Bahnschrift Regular" Height=72 Chars="0123456789:/-+£" AntiAlias=1 XPad=4
#exec new TrueTypeFontFactory Name=Bahnschrift48 FontName="Bahnschrift Regular" Height=48 AntiAlias=1 XPad=2
#exec new TrueTypeFontFactory Name=Bahnschrift36 FontName="Bahnschrift Regular" Height=36 AntiAlias=1 XPad=2
#exec new TrueTypeFontFactory Name=Bahnschrift24 FontName="Bahnschrift Regular" Height=24 AntiAlias=1 XPad=2
#exec new TrueTypeFontFactory Name=Bahnschrift18 FontName="Bahnschrift Regular" Height=18 AntiAlias=1 XPad=2
#exec new TrueTypeFontFactory Name=Bahnschrift12 FontName="Bahnschrift Regular" Height=12 AntiAlias=1 XPad=2
#exec new TrueTypeFontFactory Name=Bahnschrift9 FontName="Bahnschrift Regular" Height=9 AntiAlias=1 XPad=2

#exec new TrueTypeFontFactory Name=BahnschriftSemiLight72 FontName="Bahnschrift SemiLight Condensed" Height=72 AntiAlias=1 XPad=2 Kerning=0
#exec new TrueTypeFontFactory Name=BahnschriftSemiLight48 FontName="Bahnschrift SemiLight Condensed" Height=48 AntiAlias=1 XPad=2 Kerning=0
#exec new TrueTypeFontFactory Name=BahnschriftSemiLight36 FontName="Bahnschrift SemiLight Condensed" Height=36 AntiAlias=1 XPad=2 Kerning=0
#exec new TrueTypeFontFactory Name=BahnschriftSemiLight24 FontName="Bahnschrift SemiLight Condensed" Height=24 AntiAlias=1 XPad=2 Kerning=0
#exec new TrueTypeFontFactory Name=BahnschriftSemiLight18 FontName="Bahnschrift SemiLight Condensed" Height=18 AntiAlias=1 XPad=2 Kerning=0
#exec new TrueTypeFontFactory Name=BahnschriftSemiLight12 FontName="Bahnschrift SemiLight Condensed" Height=12 AntiAlias=1 XPad=2 Kerning=0
#exec new TrueTypeFontFactory Name=BahnschriftSemiLight9 FontName="Bahnschrift SemiLight Condensed" Height=9 AntiAlias=1 XPad=2 Kerning=0

#exec new TrueTypeFontFactory Name=BahnschriftBold72 FontName="Bahnschrift Bold SemiCondensed" Height=72 AntiAlias=1 XPad=2 Kerning=0
#exec new TrueTypeFontFactory Name=BahnschriftBold48 FontName="Bahnschrift Bold SemiCondensed" Height=48 AntiAlias=1 XPad=2 Kerning=0
#exec new TrueTypeFontFactory Name=BahnschriftBold36 FontName="Bahnschrift Bold SemiCondensed" Height=36 AntiAlias=1 XPad=2 Kerning=0
#exec new TrueTypeFontFactory Name=BahnschriftBold24 FontName="Bahnschrift Bold SemiCondensed" Height=24 AntiAlias=1 XPad=2 Kerning=0
#exec new TrueTypeFontFactory Name=BahnschriftBold18 FontName="Bahnschrift Bold SemiCondensed" Height=18 AntiAlias=1 XPad=2 Kerning=0
#exec new TrueTypeFontFactory Name=BahnschriftBold12 FontName="Bahnschrift Bold SemiCondensed" Height=12 AntiAlias=1 XPad=2 Kerning=0
#exec new TrueTypeFontFactory Name=BahnschriftBold9 FontName="Bahnschrift Bold SemiCondensed" Height=9 AntiAlias=1 XPad=2 Kerning=0

#exec new TrueTypeFontFactory Name=LemonMilkBoldItalic72 FontName="LEMON MILK Bold Italic" Height=72 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-2 Italic=1 Style=700
#exec new TrueTypeFontFactory Name=LemonMilkBoldItalic36 FontName="LEMON MILK Bold Italic" Height=36 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-4 Italic=1 Style=700
#exec new TrueTypeFontFactory Name=LemonMilkBoldItalic18 FontName="LEMON MILK Bold Italic" Height=18 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-6 Italic=1 Style=700
#exec new TrueTypeFontFactory Name=LemonMilkBoldItalic12 FontName="LEMON MILK Bold Italic" Height=12 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-6 Italic=1 Style=700

#exec new TrueTypeFontFactory Name=LemonMilkRegularItalic72 FontName="LEMON MILK Bold Italic" Height=72 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-2 Italic=1 Style=500
#exec new TrueTypeFontFactory Name=LemonMilkRegularItalic36 FontName="LEMON MILK Bold Italic" Height=36 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-4 Italic=1 Style=500
#exec new TrueTypeFontFactory Name=LemonMilkRegularItalic18 FontName="LEMON MILK Bold Italic" Height=18 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-6 Italic=1 Style=600
#exec new TrueTypeFontFactory Name=LemonMilkRegularItalic12 FontName="LEMON MILK Bold Italic" Height=12 AntiAlias=1 XPad=24 ExtendBoxRight=8 Kerning=-6 Italic=1 Style=600

var	localized string HUDLargeFontNames[8];
var	Font HUDLargeFonts[8];

var	localized string HUDFontArrayNames[8];
var	Font HUDFontArrayFonts[8];

var	localized string HUDBoldFontArrayNames[8];
var	Font HUDBoldFontArrayFonts[8];

var	localized string HUDItalicFontArrayNames[4];
var	Font HUDItalicFontArrayFonts[4];

var	localized string HUDBoldItalicFontArrayNames[4];
var	Font HUDBoldItalicFontArrayFonts[4];

static final function Font LoadLargeNumberFont(int i)
{
	i = Clamp(i, 0, ArrayCount(default.HUDLargeFonts) - 1);
	if (default.HUDLargeFonts[i] == none)
	{
		default.HUDLargeFonts[i] = Font(DynamicLoadObject(default.HUDLargeFontNames[i], class'Font'));
		if (default.HUDLargeFonts[i] == none)
			Log("Warning: "$default.Class$" Couldn't dynamically load font "$default.HUDLargeFontNames[i]);
	}

	return default.HUDLargeFonts[i];
}

static final function Font LoadFontStatic(int i)
{
	i = Clamp(i, 0, ArrayCount(default.HUDFontArrayFonts) - 1);
	if( default.HUDFontArrayFonts[i] == None )
	{
		default.HUDFontArrayFonts[i] = Font(DynamicLoadObject(default.HUDFontArrayNames[i], class'Font'));
		if( default.HUDFontArrayFonts[i] == None )
			Log("Warning: "$default.Class$" Couldn't dynamically load font "$default.HUDFontArrayNames[i]);
	}

	return default.HUDFontArrayFonts[i];
}
static final function Font LoadBoldFontStatic(int i)
{
	i = Clamp(i, 0, ArrayCount(default.HUDBoldFontArrayFonts) - 1);
	if( default.HUDBoldFontArrayFonts[i] == None )
	{
		default.HUDBoldFontArrayFonts[i] = Font(DynamicLoadObject(default.HUDBoldFontArrayNames[i], class'Font'));
		if( default.HUDBoldFontArrayFonts[i] == None )
			Log("Warning: "$default.Class$" Couldn't dynamically load font "$default.HUDBoldFontArrayNames[i]);
	}

	return default.HUDBoldFontArrayFonts[i];
}

static final function Font LoadItalicFontStatic(int i)
{
	i /= 2;

	i = Clamp(i, 0, ArrayCount(default.HUDItalicFontArrayFonts) - 1);
	if( default.HUDItalicFontArrayFonts[i] == None )
	{
		default.HUDItalicFontArrayFonts[i] = Font(DynamicLoadObject(default.HUDItalicFontArrayNames[i], class'Font'));
		if( default.HUDItalicFontArrayFonts[i] == None )
			Log("Warning: "$default.Class$" Couldn't dynamically load font "$default.HUDItalicFontArrayNames[i]);
	}

	return default.HUDItalicFontArrayFonts[i];
}

static final function Font LoadBoldItalicFontStatic(int i)
{
	i /= 2;

	i = Clamp(i, 0, ArrayCount(default.HUDBoldItalicFontArrayFonts) - 1);
	if( default.HUDBoldItalicFontArrayFonts[i] == None )
	{
		default.HUDBoldItalicFontArrayFonts[i] = Font(DynamicLoadObject(default.HUDBoldItalicFontArrayNames[i], class'Font'));
		if( default.HUDBoldItalicFontArrayFonts[i] == None )
			Log("Warning: "$default.Class$" Couldn't dynamically load font "$default.HUDBoldItalicFontArrayNames[i]);
	}

	return default.HUDBoldItalicFontArrayFonts[i];
}

defaultproperties
{
	HUDLargeFontNames(0)="KFTurboFonts.BahnschriftNumbers134"
	HUDLargeFontNames(1)="KFTurboFonts.BahnschriftNumbers110"
	HUDLargeFontNames(2)="KFTurboFonts.BahnschriftNumbers72"
	HUDLargeFontNames(3)="KFTurboFonts.Bahnschrift48"
	HUDLargeFontNames(4)="KFTurboFonts.Bahnschrift36"
	HUDLargeFontNames(5)="KFTurboFonts.Bahnschrift24"
	HUDLargeFontNames(6)="KFTurboFonts.Bahnschrift18"
	HUDLargeFontNames(7)="KFTurboFonts.Bahnschrift12"

	HUDFontArrayNames(0)="KFTurboFonts.BahnschriftSemiLight72"
	HUDFontArrayNames(1)="KFTurboFonts.BahnschriftSemiLight72"
	HUDFontArrayNames(2)="KFTurboFonts.BahnschriftSemiLight48"
	HUDFontArrayNames(3)="KFTurboFonts.BahnschriftSemiLight36"
	HUDFontArrayNames(4)="KFTurboFonts.BahnschriftSemiLight24"
	HUDFontArrayNames(5)="KFTurboFonts.BahnschriftSemiLight18"
	HUDFontArrayNames(6)="KFTurboFonts.BahnschriftSemiLight12"
	HUDFontArrayNames(7)="KFTurboFonts.BahnschriftSemiLight9"

	HUDBoldFontArrayNames(0)="KFTurboFonts.BahnschriftBold72"
	HUDBoldFontArrayNames(1)="KFTurboFonts.BahnschriftBold72"
	HUDBoldFontArrayNames(2)="KFTurboFonts.BahnschriftBold48"
	HUDBoldFontArrayNames(3)="KFTurboFonts.BahnschriftBold36"
	HUDBoldFontArrayNames(4)="KFTurboFonts.BahnschriftBold24"
	HUDBoldFontArrayNames(5)="KFTurboFonts.BahnschriftBold18"
	HUDBoldFontArrayNames(6)="KFTurboFonts.BahnschriftBold12"
	HUDBoldFontArrayNames(7)="KFTurboFonts.BahnschriftBold9"
	
	HUDItalicFontArrayNames(0)="KFTurboFonts.LemonMilkRegularItalic72"
	HUDItalicFontArrayNames(1)="KFTurboFonts.LemonMilkRegularItalic36"
	HUDItalicFontArrayNames(2)="KFTurboFonts.LemonMilkRegularItalic18"
	HUDItalicFontArrayNames(3)="KFTurboFonts.LemonMilkRegularItalic12"

	HUDBoldItalicFontArrayNames(0)="KFTurboFonts.LemonMilkBoldItalic72"
	HUDBoldItalicFontArrayNames(1)="KFTurboFonts.LemonMilkBoldItalic36"
	HUDBoldItalicFontArrayNames(2)="KFTurboFonts.LemonMilkBoldItalic18"
	HUDBoldItalicFontArrayNames(3)="KFTurboFonts.LemonMilkBoldItalic12"
}