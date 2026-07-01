//Killing Floor Turbo TurboCardHintMultiLineText
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardHintMultiLineText extends TurboCardHint
	abstract;

var localized array<string> TextList;
var Texture RoundedContainer;

//DrawY should convey the bottom of the hint space.
static function DrawHint(Canvas Canvas, float DrawX, out float DrawY, float CardSizeX, float Opacity)
{
	local int Index;
	local float TextStartOffsetX, TextAreaWidth, TotalTextY;
	local float TextSizeX, TextSizeY, CurrentY;
	local array<float> OffsetY;

	TextStartOffsetX = (CardSizeX * 0.025f);
	TextAreaWidth = (CardSizeX * 0.975f);

	Canvas.OrgX = DrawX + TextStartOffsetX;
	Canvas.ClipX = ((DrawX + CardSizeX) - TextStartOffsetX) - Canvas.OrgX;
	Canvas.CurX = 0.f;
	Canvas.SetPos(0.f, DrawY);

	OffsetY.Length = default.TextList.Length;
	for (Index = default.TextList.Length - 1; Index >= 0; Index--)
	{
    	Canvas.StrLen(default.TextList[Index], TextSizeX, TextSizeY);
		OffsetY[Index] = TextSizeY;
		TotalTextY += TextSizeY;
	}

	Canvas.OrgX = 0.f;
	Canvas.ClipX = Canvas.SizeX;

	CurrentY = DrawY + TextStartOffsetX;

	Canvas.SetPos(DrawX, DrawY);
	Canvas.DrawColor = class'TurboHUDOverlay'.static.MakeColor(0, 0, 0, 120);
	Canvas.DrawTileStretched(default.RoundedContainer, CardSizeX, (TextStartOffsetX * 2.f) + TotalTextY);

	Canvas.OrgX = DrawX + TextStartOffsetX;
	Canvas.ClipX = ((DrawX + CardSizeX) - TextStartOffsetX) - Canvas.OrgX;
	Canvas.DrawColor = class'TurboHUDOverlay'.static.MakeColor(255, 255, 255, 255);

	for (Index = 0; Index < default.TextList.Length; Index++)
	{
		Canvas.SetPos(0.f, CurrentY);
		Canvas.DrawText(default.TextList[Index]);
		CurrentY += OffsetY[Index];
	}

	Canvas.OrgX = 0.f;
	Canvas.ClipX = Canvas.SizeX;

	DrawY += TotalTextY + (TextStartOffsetX * 2.f);
}

defaultproperties
{
	RoundedContainer=Texture'KFTurbo.HUD.ContainerRounded_D'
}