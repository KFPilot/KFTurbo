class TurboMessagePickup extends UnrealGame.PickupMessagePlus;


static function RenderComplexMessage(
	Canvas Canvas,
	out float XL,
	out float YL,
	optional string MessageString,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Canvas.Font = class'KFTurboFontHelper'.static.LoadFontStatic(default.FontSize);
	Canvas.FontScaleX = FMax(Canvas.ClipY / 2160.f, 0.5f);
	Canvas.FontScaleY = Canvas.FontScaleX;

	Canvas.TextSize(MessageString, XL, YL);
	Canvas.SetPos((Canvas.ClipX / 2.0) - (XL / 2.0), Canvas.CurY);
	Canvas.DrawTextClipped(MessageString, false);

	Canvas.FontScaleX = 1.0;
	Canvas.FontScaleY = 1.0;
}

defaultproperties
{
	bComplexString=True
	FontSize=0
	PosY=0.8f
}
