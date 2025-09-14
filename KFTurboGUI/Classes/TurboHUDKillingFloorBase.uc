//Killing Floor Turbo TurboHUDKillingFloorBase
//Parent class for KFTurbo's HUD class. Allows for KFTurboGUI to work with Turbo's locale fonts.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHUDKillingFloorBase extends SRHUDKillingFloor;

var class<KFTurboFontHelper> FontHelperClass;
var string FontHelperClassCYString;
var class<KFTurboFontHelper> FontHelperClassCY;
var string FontHelperClassJPString;
var class<KFTurboFontHelper> FontHelperClassJP;

static function font GetConsoleFont(Canvas C)
{
	local int FontSize;

	if( default.OverrideConsoleFontName != "" )
	{
		if( default.OverrideConsoleFont != None )
			return default.OverrideConsoleFont;
		default.OverrideConsoleFont = Font(DynamicLoadObject(default.OverrideConsoleFontName, class'Font'));
		if( default.OverrideConsoleFont != None )
			return default.OverrideConsoleFont;
		Log("Warning: HUD couldn't dynamically load font "$default.OverrideConsoleFontName);
		default.OverrideConsoleFontName = "";
	}

	FontSize = Default.ConsoleFontSize;
	if ( C.ClipX < 640 )
		FontSize++;
	if ( C.ClipX < 800 )
		FontSize++;
	if ( C.ClipX < 1024 )
		FontSize++;
	if ( C.ClipX < 1280 )
		FontSize++;
	if ( C.ClipX < 1600 )
		FontSize++;
	
	return class'SRHUDKillingFloor'.static.LoadFontStatic(Min(8,FontSize));
}

static function font GetDefaultConsoleFont(Canvas C)
{
	local int FontSize;

	if( default.OverrideConsoleFontName != "" )
	{
		if( default.OverrideConsoleFont != None )
			return default.OverrideConsoleFont;
		default.OverrideConsoleFont = Font(DynamicLoadObject(default.OverrideConsoleFontName, class'Font'));
		if( default.OverrideConsoleFont != None )
			return default.OverrideConsoleFont;
		Log("Warning: HUD couldn't dynamically load font "$default.OverrideConsoleFontName);
		default.OverrideConsoleFontName = "";
	}

	FontSize = Default.ConsoleFontSize;
	if ( C.ClipX < 640 )
		FontSize++;
	if ( C.ClipX < 800 )
		FontSize++;
	if ( C.ClipX < 1024 )
		FontSize++;
	if ( C.ClipX < 1280 )
		FontSize++;
	if ( C.ClipX < 1600 )
		FontSize++;
	return class'SRHUDKillingFloor'.static.LoadFontStatic(Min(8,FontSize));
}

static function font GetChatFont(Canvas C)
{
	local int FontSize;

	if( default.OverrideConsoleFontName != "" )
	{
		if( default.OverrideConsoleFont != None )
			return default.OverrideConsoleFont;
		default.OverrideConsoleFont = Font(DynamicLoadObject(default.OverrideConsoleFontName, class'Font'));
		if( default.OverrideConsoleFont != None )
			return default.OverrideConsoleFont;
		Log("Warning: HUD couldn't dynamically load font "$default.OverrideConsoleFontName);
		default.OverrideConsoleFontName = "";
	}

	FontSize = Default.ConsoleFontSize;
	if ( C.ClipX < 640 )
		FontSize++;
	if ( C.ClipX < 800 )
		FontSize++;
	if ( C.ClipX < 1024 )
		FontSize++;
	if ( C.ClipX < 1280 )
		FontSize++;
	if ( C.ClipX < 1600 )
		FontSize++;
	
	return class'TurboHUDKillingFloorBase'.static.LoadFontStatic(Min(8,FontSize));
}

static function Font LoadFontStatic(int i)
{
	return default.FontHelperClass.static.LoadFontStatic(i);
}

simulated function Font LoadFont(int i)
{
	return FontHelperClass.static.LoadFontStatic(i);
}

final simulated function Font LoadLargeNumberFont(int i)
{
	return FontHelperClass.static.LoadLargeNumberFont(i);
}

final static function Font LoadBoldFontStatic(int i)
{
	return default.FontHelperClass.static.LoadBoldFontStatic(i);
}

final simulated function Font LoadBoldFont(int i)
{
	return FontHelperClass.static.LoadBoldFontStatic(i);
}

final static function Font LoadBoldItalicFontStatic(int i)
{
	return default.FontHelperClass.static.LoadBoldItalicFontStatic(i);
}

final simulated function Font LoadBoldItalicFont(int i)
{
	return FontHelperClass.static.LoadBoldItalicFontStatic(i);
}

final static function Font LoadItalicFontStatic(int i)
{
	return default.FontHelperClass.static.LoadItalicFontStatic(i);
}

final simulated function Font LoadItalicFont(int i)
{
	return FontHelperClass.static.LoadItalicFontStatic(i);
}

simulated function SetFontLocale(string LocaleString)
{
	CleanupFontPackage();

	switch(LocaleString)
	{
		case "ENG":
			FontHelperClass = class'KFTurboFonts.KFTurboFontHelperEN';
			break;
		case "JPN":
			if (FontHelperClassJP == None)
			{
				FontHelperClassJP = class<KFTurboFontHelper>(DynamicLoadObject(FontHelperClassJPString, Class'Class'));
			}
			FontHelperClass = FontHelperClassJP;
			break;
		case "CYR":
			if (FontHelperClassCY == None)
			{
				FontHelperClassCY = class<KFTurboFontHelper>(DynamicLoadObject(FontHelperClassCYString, Class'Class'));
			}
			FontHelperClass = FontHelperClassCY;
			break;
	}

	if (FontHelperClass == None)
	{
		FontHelperClass = class'KFTurboFonts.KFTurboFontHelperEN';
	}

	default.FontHelperClass = FontHelperClass; //Styles will request this via CDO.
}

simulated function CleanupFontPackage()
{
	if (default.FontHelperClass != None)
	{
		default.FontHelperClass.static.Cleanup();
	}

	if (FontHelperClass != None)
	{
		FontHelperClass.static.Cleanup();
	}

	FontHelperClass = None;
	default.FontHelperClass = None;
}

defaultproperties
{
	FontHelperClass=class'KFTurboFonts.KFTurboFontHelperEN'
	FontHelperClassCYString = "KFTurboFontsCY.KFTurboFontHelperCY"
	FontHelperClassJPString = "KFTurboFontsJP.KFTurboFontHelperJP"
}