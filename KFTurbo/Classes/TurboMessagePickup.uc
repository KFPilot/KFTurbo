//Killing Floor Turbo TurboMessagePickup
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
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
	local TurboHUDKillingFloor TurboHUD;
	TurboHUD = TurboHUDKillingFloor(Canvas.Viewport.Actor.myHUD);

	Canvas.Font = TurboHUD.LoadFont(default.FontSize);
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
