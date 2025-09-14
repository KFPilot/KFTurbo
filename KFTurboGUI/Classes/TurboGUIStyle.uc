//Killing Floor Turbo TurboGUIStyle
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGUIStyle extends GUIStyles
    abstract;

var class<TurboGUIFont> FontClass;

simulated function Initialize()
{
    local int Index;
    local TurboGUIFont Font;
    Font = new (Self) FontClass;

    for (Index = 0; Index < ArrayCount(FontNames) && Index < ArrayCount(Fonts); Index++)
    {
        Fonts[Index] = Font;
    }
}

defaultproperties
{
    FontClass=class'TurboGUIFont'

    RStyles(0)=MSTY_Normal
    RStyles(1)=MSTY_Normal
    RStyles(2)=MSTY_Normal
    RStyles(3)=MSTY_Normal
    RStyles(4)=MSTY_Normal

    ImgStyle(0)=ISTY_Stretched
    ImgStyle(1)=ISTY_Stretched
    ImgStyle(2)=ISTY_Stretched
    ImgStyle(3)=ISTY_Stretched
    ImgStyle(4)=ISTY_Stretched
    
    ImgColors(0)=(R=225,G=225,B=225,A=255)
    ImgColors(1)=(R=255,G=255,B=255,A=255)
    ImgColors(2)=(R=225,G=225,B=225,A=255)
    ImgColors(3)=(R=225,G=225,B=225,A=255)
    ImgColors(4)=(R=125,G=125,B=125,A=255)

    FontColors(0)=(R=225,G=225,B=225,A=255)
    FontColors(1)=(R=255,G=255,B=255,A=255)
    FontColors(2)=(R=225,G=225,B=225,A=255)
    FontColors(3)=(R=225,G=225,B=225,A=255)
    FontColors(4)=(R=125,G=125,B=125,A=255)

    FontBKColors(0)=(R=0,G=0,B=0,A=255)
    FontBKColors(1)=(R=0,G=0,B=0,A=255)
    FontBKColors(2)=(R=0,G=0,B=0,A=255)
    FontBKColors(3)=(R=0,G=0,B=0,A=255)
    FontBKColors(4)=(R=0,G=0,B=0,A=255)

    BorderOffsets(0)=0
    BorderOffsets(1)=0
    BorderOffsets(2)=0
    BorderOffsets(3)=0

    FontNames(0)="TurboFont"
    FontNames(1)="TurboFont"
    FontNames(2)="TurboFont"
    FontNames(3)="TurboFont"
    FontNames(4)="TurboFont"
    FontNames(5)="TurboFont"
    FontNames(6)="TurboFont"
    FontNames(7)="TurboFont"
    FontNames(8)="TurboFont"
    FontNames(9)="TurboFont"
    FontNames(10)="TurboFont"
    FontNames(11)="TurboFont"
    FontNames(12)="TurboFont"
    FontNames(13)="TurboFont"
    FontNames(14)="TurboFont"

    bTemporary=true
}
