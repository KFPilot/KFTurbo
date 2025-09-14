//Killing Floor Turbo TurboGUIStyleItalicFont
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGUIFontItalic extends TurboGUIFont;

static function Font LoadFontStatic(int i)
{
    if (default.FontArrayFonts.Length <= i || default.FontArrayFonts[i] == None)
    {
        default.FontArrayFonts[i] = class'TurboHUDKillingFloorBase'.static.LoadItalicFontStatic(i);
    }

    return default.FontArrayFonts[i];
}

function Font LoadFont(int i)
{
    if (default.FontArrayFonts.Length <= i || FontArrayFonts[i] == None)
    {
        FontArrayFonts[i] = class'TurboHUDKillingFloorBase'.static.LoadItalicFontStatic(i);
    }

    return FontArrayFonts[i];
}

defaultproperties
{
	KeyName="TurboItalicFont"
    NormalXRes=800
}
