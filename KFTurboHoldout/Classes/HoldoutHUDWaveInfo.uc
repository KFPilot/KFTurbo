//Killing Floor Turbo HoldoutHUDWaveInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class HoldoutHUDWaveInfo extends TurboHUDWaveInfo;

var int LastKnownWaveNumber;
var float NextWaveEffectProgress;
var float NextWaveEffectRate;
var float NextWaveGlowProgress;
var float NextWaveGlowDelay;
var float NextWaveGlowRate;

simulated function Tick(float DeltaTime)
{
	if (TGRI == None)
	{
		TGRI = TurboGameReplicationInfo(Level.GRI);

		if (TGRI == None)
		{
			return;
		}
	}

	TickGameState(DeltaTime);
	TickKillFeed(DeltaTime);
	
	if (LastKnownWaveNumber != (TGRI.WaveNumber + 1))
	{
		if (LastKnownWaveNumber == 0)
		{
			LastKnownWaveNumber = (TGRI.WaveNumber + 1);
			return;
		}

		LastKnownWaveNumber = (TGRI.WaveNumber + 1);
		GotoState('PlayNextWave');
	}
}

simulated function Render(Canvas C)
{	
	Super.Render(C);

	if (TGRI == None)
	{
		return;
	}
	
	DrawGameData(C);
	class'TurboHUDKillingFloor'.static.ResetCanvas(C);
	DrawKillFeed(C);
	class'TurboHUDKillingFloor'.static.ResetCanvas(C);
}

simulated function DrawGameData(Canvas C)
{
	local float TopY;
	local float TempX, TempY;
	local float SizeX, SizeY;
	local float TextSizeX, TextSizeY, TextScale;
	local string TestText;
	local float Progress;

	TopY = C.ClipY * BackplateSpacing.Y;

	TempX = float(C.SizeX) - (float(C.SizeX) * (BackplateSpacing.X + BackplateSize.X));
	TempY = TopY;

	SizeX = C.ClipX * BackplateSize.X;
	SizeY = C.ClipY * BackplateSize.Y;

	TestText = GetStringOfZeroes(2);

	C.SetPos(TempX, TempY);

	C.Font = TurboHUD.LoadLargeNumberFont(FontSizeOffset);
	C.FontScaleX = 1.f;
	C.FontScaleX = 1.f;
	C.TextSize(TestText, TextSizeX, TextSizeY);

	TextScale = (C.ClipY * (BackplateSize.Y - BackplateTextSpacing.Y)) / TextSizeY;
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;

	C.TextSize(TestText, TextSizeX, TextSizeY);
	SizeX = TextSizeX + (BackplateTextSpacing.X * C.ClipX);
	TempX = (float(C.SizeX) * (1.f - BackplateSpacing.X)) - SizeX;

	if (RoundedContainer != None)
	{
		C.DrawColor = BackplateColor;
		C.SetPos(TempX, TempY);
		C.DrawTileStretched(RoundedContainer, SizeX, SizeY);
	}

	TempX = (TempX + (SizeX * 0.5f)) - (TextSizeX * 0.5f);
	TempY = ((TempY + (SizeY * 0.5f)) - (TextSizeY * 0.5f));

	Progress = (NextWaveEffectProgress * 2.f) - 1.f;
	if (Progress > 0.f)
	{
		if (NextWaveGlowProgress >= 1.f)
		{
			C.DrawColor = MakeColor(255, 255, 255, 255);
		}
		else
		{
			C.DrawColor = MakeColor(255, Round(FMin(NextWaveGlowProgress, 1.f) * 255.f), Round(FMin(NextWaveGlowProgress, 1.f) * 255.f), Round(FMin(Progress, 1.f) * 255.f));
		}

		TestText = FillStringWithZeroes(string(Min(LastKnownWaveNumber, 99)), 2);
		C.SetPos(TempX, TempY + (SizeY * NextWaveEffectProgress) - SizeY);
		DrawTextClippedMeticulous(C, TestText, TextSizeX);
	}

	if (NextWaveEffectProgress < 1.f && (1.f - (NextWaveEffectProgress * 2.f)) > 0.f)
	{
		C.ClipY = TopY + SizeY;

		if (NextWaveGlowDelay <= 0.f)
		{
			C.DrawColor = MakeColor(255, Round(FMin(NextWaveGlowProgress, 1.f) * 255.f), Round(FMin(NextWaveGlowProgress, 1.f) * 255.f), Round(FMax((1.f - (NextWaveEffectProgress * 2.f)), 0.f) * 255.f));
		}
		else
		{
			C.DrawColor = MakeColor(255, 255, 255, Round(FMax((1.f - (NextWaveEffectProgress * 2.f)), 0.f) * 255.f));
		}

		C.DrawColor = MakeColor(255, 255, 255, Round(FMax((1.f - (NextWaveEffectProgress * 2.f)), 0.f) * 255.f));

		TestText = FillStringWithZeroes(string(Min(LastKnownWaveNumber - 1, 99)), 2);
		C.SetPos(TempX, TempY + (SizeY * NextWaveEffectProgress));
		DrawTextClippedMeticulous(C, TestText, TextSizeX);
		C.ClipY = C.SizeY;
	}
}

static final function DrawTextClippedMeticulous(Canvas C, coerce String String, float SizeX)
{
	local String StringToDraw;
	local float SubStringSizeX, SubStringSizeY;
	local float RootX, RootY;

	SizeX /= float(Len(String));

	RootX = C.CurX;
	RootY = C.CurY;

	while (Len(String) > 0)
	{
		StringToDraw = Left(String, 1);

		C.TextSize(StringToDraw, SubStringSizeX, SubStringSizeY);
		C.CurX += (SizeX * 0.5f) - (SubStringSizeX * 0.5f);

		C.DrawTextClipped(StringToDraw);

		if (Len(String) == 1)
		{
			break;
		}

		RootX += SizeX;
		C.CurX = RootX;
		C.CurY = RootY;
		String = Right(String, Len(String) - 1);
	}
}

state PlayNextWave
{
	function BeginState()
	{
		Super.BeginState();
		NextWaveEffectProgress = 0.f;
		NextWaveGlowDelay = default.NextWaveGlowDelay;
		NextWaveGlowProgress = 0.f;
	}

	simulated function Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);
		NextWaveEffectProgress = Lerp(DeltaTime * NextWaveEffectRate, NextWaveEffectProgress, 1.f);

		if (NextWaveEffectProgress < 0.99f)
		{
			return;
		}

		NextWaveEffectProgress = 1.f;
		
		NextWaveGlowDelay -= DeltaTime;

		if (NextWaveGlowDelay > 0.f)
		{
			return;
		}
		
		NextWaveGlowProgress = Lerp(DeltaTime * NextWaveGlowRate, NextWaveGlowProgress, 1.f);

		if (NextWaveGlowProgress < 0.99f)
		{
			return;
		}

		NextWaveGlowProgress = 1.f;
		NextWaveGlowDelay = default.NextWaveGlowDelay;
		GotoState('');
	}
}

defaultproperties
{
	NextWaveEffectProgress=1.f
	NextWaveEffectRate=4.f

	NextWaveGlowDelay=3.f
	NextWaveGlowRate=2.f
	NextWaveGlowProgress=1.f
	
	BackplateSize=(X=0.15f,Y=0.1f)
}