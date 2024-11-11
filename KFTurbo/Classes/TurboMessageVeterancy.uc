class TurboMessageVeterancy extends ServerPerks.KFVetEarnedMessageSR
	abstract;

static function RenderComplexMessage(
    Canvas Canvas,
    out float XL,
    out float YL,
    optional String MessageString,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	local float XS, YS, XPos, YPos, IconSize;
	local class<SRVeterancyTypes> VeterancyClass;
	local Material M1,M2;
	local byte A;

	VeterancyClass = class<SRVeterancyTypes>(OptionalObject);
	A = Canvas.DrawColor.A;

	if (VeterancyClass != None)
	{
		Class<SRVeterancyTypes>(OptionalObject).Static.PreDrawPerk(Canvas,Switch,M1,M2);
	}
	else
	{
		Canvas.DrawColor = Canvas.MakeColor(255, 255, 255, 255);
	}

	Canvas.DrawColor.A = A;
	Canvas.Font = class'KFTurboFontHelper'.static.LoadFontStatic(default.FontSize);
	Canvas.FontScaleX = FMax(Canvas.ClipY / 2160.f, 0.75f);
	Canvas.FontScaleY = Canvas.FontScaleX;
	Canvas.TextSize(MessageString, XS, YS);

	YPos = Canvas.CurY;
	Canvas.SetPos((Canvas.ClipX * 0.5f) - (XS * 0.5f), YPos);
	XPos = Canvas.CurX;

	Canvas.DrawTextClipped(MessageString);

	if(VeterancyClass != None && M1 != None)
	{
		IconSize = FMin(YS*2.5f,256.f);
		Canvas.SetPos(((Canvas.ClipX * 0.5f) - (XS * 0.5f)) - (IconSize * 1.1f), (YPos + (YS * 0.5f)) - (IconSize * 0.5f));

		A = Canvas.Style;
		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.DrawTile( M1, IconSize, IconSize, 0, 0, M1.MaterialUSize(), M1.MaterialVSize() );
		Canvas.SetPos(((Canvas.ClipX * 0.5f) + (XS * 0.5f)) + (IconSize * 0.1f), (YPos + (YS * 0.5f)) - (IconSize * 0.5f));
		Canvas.DrawTile( M1, IconSize, IconSize, 0, 0, M1.MaterialUSize(), M1.MaterialVSize() );
		Canvas.Style = A;
	}
}


defaultproperties
{
	FontSize=2
}
