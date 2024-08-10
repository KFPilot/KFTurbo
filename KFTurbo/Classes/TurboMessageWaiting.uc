class TurboMessageWaiting extends KFMod.WaitingMessage;

static function int GetFontSize(int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer)
{
	if ( Switch == 1 ||  Switch == 2 || Switch == 3  )
	{
		return 5;
	}

	if ( Switch == 4 || Switch == 5 )
	{
		return 4;
	}

	return 3;
}

static function GetPos(int Switch, out EDrawPivot OutDrawPivot, out EStackMode OutStackMode, out float OutPosX, out float OutPosY)
{
	OutDrawPivot = default.DrawPivot;
	OutStackMode = default.StackMode;
	OutPosX = default.PosX;

	switch( Switch )
	{
		case 1:
		case 3:
			OutPosY = 0.45f;
			break;
		case 2:
		    OutPosY = 0.4f;
		    break;
		case 4:
			OutPosY = 0.8f;
			break;
		case 5:
			OutPosY = 0.8f;
			break;
		case 6:
			OutPosY = 0.8f;
			break;
		case 7:
			OutPosY = 0.8f;
			break;
	}
}

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
	local int i;
	local float TempY;

	i = InStr(MessageString, "|");

	TempY = Canvas.CurY;

	Canvas.FontScaleX = FMax(Canvas.ClipY / 2160.f, 0.5f);
	Canvas.FontScaleY = Canvas.FontScaleX;

	if ( i < 0 )
	{
		Canvas.TextSize(MessageString, XL, YL);
		Canvas.SetPos((Canvas.ClipX / 2.0) - (XL / 2.0), TempY);
		Canvas.DrawTextClipped(MessageString, false);
	}
	else
	{
		Canvas.TextSize(Left(MessageString, i), XL, YL);
		Canvas.SetPos((Canvas.ClipX / 2.0) - (XL / 2.0), TempY);
		Canvas.DrawTextClipped(Left(MessageString, i), false);

		Canvas.TextSize(Mid(MessageString, i + 1), XL, YL);
		Canvas.SetPos((Canvas.ClipX / 2.0) - (XL / 2.0), TempY + YL);
		Canvas.DrawTextClipped(Mid(MessageString, i + 1), false);
	}

	Canvas.FontScaleX = 1.0;
	Canvas.FontScaleY = 1.0;
}

defaultproperties
{
	bComplexString=True
	DrawColor=(G=0)
	FontSize=5
}
