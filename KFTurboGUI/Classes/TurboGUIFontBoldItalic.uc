//Killing Floor Turbo TurboGUIStyleBoldItalicFont
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGUIFontBoldItalic extends TurboGUIFont;

static function Font LoadFontStatic(int i)
{
    if (default.FontArrayFonts.Length <= i || default.FontArrayFonts[i] == None)
    {
        default.FontArrayFonts[i] = class'TurboHUDKillingFloorBase'.static.LoadBoldItalicFontStatic(i);
    }

    return default.FontArrayFonts[i];
}

function Font LoadFont(int i)
{
    if (default.FontArrayFonts.Length <= i || FontArrayFonts[i] == None)
    {
        FontArrayFonts[i] = class'TurboHUDKillingFloorBase'.static.LoadBoldItalicFontStatic(i);
    }

    return FontArrayFonts[i];
}

defaultproperties
{
	KeyName="TurboBoldItalicFont"
    NormalXRes=800
}
