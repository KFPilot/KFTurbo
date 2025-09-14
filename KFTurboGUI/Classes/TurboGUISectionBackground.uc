//Killing Floor Turbo TurboGUISectionBackground
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGUISectionBackground extends GUISectionBackground;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
}

simulated function bool FocusFirst(GUIComponent Sender)
{
    return false;
}

simulated function DrawTitle(Canvas Canvas)
{
    local float TextSizeX, TextSizeY;

    if (!bVisible)
    {
        return;
    }

    CaptionStyle.TextSize(Canvas, MSAT_Blurry, Caption, TextSizeX, TextSizeY, eFontScale.FNS_Small);
    CaptionStyle.DrawText(Canvas, MSAT_Blurry, ActualLeft() + 32.f, ActualTop() - 2.f, ActualWidth(), TextSizeY * 1.f, TXTA_Left, Caption, eFontScale.FNS_Small);
}

defaultproperties
{
    bNoCaption=true
    CaptionStyleName="TurboSectionLabel"

    OnRendered=DrawTitle
}