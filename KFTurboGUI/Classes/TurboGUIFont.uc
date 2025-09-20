//Killing Floor Turbo TurboGUIStyleFont
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGUIFont extends GUIFont;

//Used to check if we need to reset our style's font cache.
var int FontLocaleUpdateCounter;

var int FontSizeList[5];

simulated function Font GetFont(int XRes)
{
    if (FontLocaleUpdateCounter != class'TurboHUDKillingFloorBase'.default.FontLocaleUpdateCounter)
    {
        FontLocaleUpdateCounter = class'TurboHUDKillingFloorBase'.default.FontLocaleUpdateCounter;
        Cleanup();
    }

    if (XRes < 1000)
    {
        return LoadFont(FontSizeList[0]);
    }
    else if (XRes < 1500)
    {
        return LoadFont(FontSizeList[1]);
    }
    else if (XRes < 2000)
    {
        return LoadFont(FontSizeList[2]);
    }
    else if (XRes < 3000)
    {
        return LoadFont(FontSizeList[3]);
    }

    return LoadFont(FontSizeList[4]);
}

static function Font LoadFontStatic(int i)
{
    if (default.FontArrayFonts.Length <= i || default.FontArrayFonts[i] == None)
    {
        default.FontArrayFonts[i] = class'TurboHUDKillingFloorBase'.static.LoadFontStatic(i);
    }

    return default.FontArrayFonts[i];
}

function Font LoadFont(int i)
{
    if (default.FontArrayFonts.Length <= i || FontArrayFonts[i] == None)
    {
        FontArrayFonts[i] = class'TurboHUDKillingFloorBase'.static.LoadFontStatic(i);
    }

    return FontArrayFonts[i];
}

function Cleanup()
{
    FontArrayFonts.Length = 0;
    default.FontArrayFonts.Length = 0;
}

defaultproperties
{
	KeyName="TurboFont"

    FontSizeList(0)=6
    FontSizeList(1)=5
    FontSizeList(2)=4
    FontSizeList(3)=3
    FontSizeList(4)=3
}