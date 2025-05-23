//Killing Floor Turbo KFTurboFonts
//Handles fonts for KFTurbo.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboFontHelper extends Object;

#exec new TrueTypeFontFactory Name=BahnschriftNumbers134 FontName="Bahnschrift Regular" Height=134 Chars="0123456789:/|-+£" AntiAlias=1 XPad=4
#exec new TrueTypeFontFactory Name=BahnschriftNumbers110 FontName="Bahnschrift Regular" Height=110 Chars="0123456789:/|-+£" AntiAlias=1 XPad=4
#exec new TrueTypeFontFactory Name=BahnschriftNumbers72 FontName="Bahnschrift Regular" Height=72 Chars="0123456789:/|-+£" AntiAlias=1 XPad=4
#exec new TrueTypeFontFactory Name=BahnschriftNumbers48 FontName="Bahnschrift Regular" Height=48 Chars="0123456789:/|-+£" AntiAlias=1 XPad=2
#exec new TrueTypeFontFactory Name=BahnschriftNumbers36 FontName="Bahnschrift Regular" Height=36 Chars="0123456789:/|-+£" AntiAlias=1 XPad=2
#exec new TrueTypeFontFactory Name=BahnschriftNumbers24 FontName="Bahnschrift Regular" Height=24 Chars="0123456789:/|-+£" AntiAlias=1 XPad=2
#exec new TrueTypeFontFactory Name=BahnschriftNumbers18 FontName="Bahnschrift Regular" Height=18 Chars="0123456789:/|-+£" AntiAlias=1 XPad=2
#exec new TrueTypeFontFactory Name=BahnschriftNumbers12 FontName="Bahnschrift Regular" Height=12 Chars="0123456789:/|-+£" AntiAlias=1 XPad=2

var	string HUDLargeFontNames[8];
var	Font HUDLargeFonts[8];

var	string HUDFontArrayNames[8];
var	Font HUDFontArrayFonts[8];

var	string HUDBoldFontArrayNames[8];
var	Font HUDBoldFontArrayFonts[8];

var	string HUDItalicFontArrayNames[4];
var	Font HUDItalicFontArrayFonts[4];

var	string HUDBoldItalicFontArrayNames[4];
var	Font HUDBoldItalicFontArrayFonts[4];

//Called when someone switches font types. Unloads the font.
static final function Cleanup()
{
	local int Index;
	for (Index = 0; Index < ArrayCount(default.HUDLargeFonts); Index++)
	{
		default.HUDLargeFonts[Index] = None;
		default.HUDFontArrayFonts[Index] = None;
		default.HUDBoldFontArrayFonts[Index] = None;
	}
	
	for (Index = 0; Index < ArrayCount(default.HUDItalicFontArrayFonts); Index++)
	{
		default.HUDItalicFontArrayFonts[Index] = None;
		default.HUDBoldItalicFontArrayFonts[Index] = None;
	}
}

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
	if( default.HUDFontArrayFonts[i] == None)
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
	HUDLargeFontNames(3)="KFTurboFonts.BahnschriftNumbers48"
	HUDLargeFontNames(4)="KFTurboFonts.BahnschriftNumbers36"
	HUDLargeFontNames(5)="KFTurboFonts.BahnschriftNumbers24"
	HUDLargeFontNames(6)="KFTurboFonts.BahnschriftNumbers18"
	HUDLargeFontNames(7)="KFTurboFonts.BahnschriftNumbers12"
}