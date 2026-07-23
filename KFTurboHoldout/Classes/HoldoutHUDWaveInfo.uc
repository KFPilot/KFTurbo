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

var Texture ReadyUpBarTexture;

var localized string PressShiftString;
var localized string ReadyUpString;
var localized string WaitingForPlayersString;

var bool bShouldDrawReadyUp;
var float ReadyUpOpacity;
var float ReadyUpProgress;

simulated function Tick(float DeltaTime)
{
	if (TGRI == None)
	{
	    InitializeGRI(TurboGameReplicationInfo(Level.GRI));

		if (TGRI == None)
		{
			return;
		}
	}

	TickReadyUpOpacity(DeltaTime);
	TickGameState(DeltaTime);
	TickKillFeed(DeltaTime);

	TickBossData(DeltaTime);
	TickVoteInstance(DeltaTime);

	if (CheckNextWave())
	{
		return;
	}
}

simulated function TickReadyUpOpacity(float DeltaTime)
{
	if (ReadyUpOpacity > 0.f)
	{
		ReadyUpOpacity = Lerp(DeltaTime, ReadyUpOpacity, 0.f);
		if (ReadyUpOpacity <= 0.005f)
		{
			ReadyUpOpacity = 0.f;
		}
	}
}

simulated function bool CheckNextWave()
{
	if (TGRI == None || LastKnownWaveNumber == (TGRI.WaveNumber + 1))
	{
		return false;
	}

	if (LastKnownWaveNumber == 0)
	{
		LastKnownWaveNumber = (TGRI.WaveNumber + 1);
		return false;
	}

	LastKnownWaveNumber = (TGRI.WaveNumber + 1);
	GotoState('PlayNextWave');
	return true;
}

state ShowReadyUp
{
	simulated function BeginState()
	{
		bShouldDrawReadyUp = true;
	}

	simulated function EndState()
	{
		bShouldDrawReadyUp = false;
	}

	simulated function float GetReadyUpProgress()
	{
		ReadyUpProgress = HoldoutPlayerController(TurboHUD.PlayerOwner).HoldoutInteraction.GetReadyHoldPercent();
		return ReadyUpProgress;
	}

	simulated function TickReadyUpOpacity(float DeltaTime)
	{
		if (ReadyUpOpacity < 1.f)
		{
			ReadyUpOpacity = Lerp(DeltaTime * 4.f, ReadyUpOpacity, 1.f);
			if (ReadyUpOpacity >= 0.995f)
			{
				ReadyUpOpacity = 1.f;
			}

			return;
		}

		if (TGRI.TimeToNextWave < 100)
		{
			GotoState('');
		}
	}

	simulated function bool CheckNextWave() { return false; }
}

state PlayNextWave extends ShowReadyUp
{
	simulated function BeginState()
	{
		Super.BeginState();
		bShouldDrawReadyUp = true;
		ReadyUpOpacity = FMax(0.f, ReadyUpOpacity);
		NextWaveEffectProgress = 0.f;
		NextWaveGlowDelay = default.NextWaveGlowDelay;
		NextWaveGlowProgress = 0.f;
	}

	simulated function EndState() {}

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
		GotoState('ShowReadyUp');
	}

	simulated function TickReadyUpOpacity(float DeltaTime)
	{
		if (ReadyUpOpacity < 1.f)
		{
			ReadyUpOpacity = Lerp(DeltaTime * 4.f, ReadyUpOpacity, 1.f);
			if (ReadyUpOpacity >= 0.995f)
			{
				ReadyUpOpacity = 1.f;
			}
		}
	}
}

simulated function Render(Canvas C)
{
	Super.Render(C);

	if (TGRI == None)
	{
		return;
	}

	class'TurboHUDKillingFloor'.static.ResetCanvas(C);
	DrawReadyUpStatus(C);
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

		//C.DrawColor = MakeColor(255, 255, 255, Round(FMax((1.f - (NextWaveEffectProgress * 2.f)), 0.f) * 255.f));

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

simulated function DrawReadyUpStatus(Canvas Canvas)
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(Level.GRI);
	if (KFGRI == None || KFGRI.EndGameType != 0)
	{
		return;
	}

	if (TurboHUD != None && !TurboHUD.PlayerOwner.PlayerReplicationInfo.bOnlySpectator)
	{
	    DrawReadyUpBar(Canvas);
	}

	if (bShouldDrawReadyUp)
	{
		DrawReadyUpList(Canvas);
	}
}

simulated function float GetReadyUpProgress()
{
	return ReadyUpProgress;
}

simulated function DrawReadyUpBar(Canvas Canvas)
{
	local float Percent;
	local float BarX, BarY, BarW, BarH;
	local float TextSizeX, TextSizeY;

	Percent = GetReadyUpProgress();

	BarW = Canvas.ClipX * 0.25f;
	BarH = Canvas.ClipY * 0.05f;
	BarX = (Canvas.ClipX - BarW) * 0.5f;
	BarY = Canvas.ClipY * 0.675f;

	//Background
	Canvas.DrawColor = MakeColor(255, 255, 255, int(60.f * ReadyUpOpacity));
	Canvas.SetPos(BarX, BarY);
	Canvas.DrawTileScaled(ReadyUpBarTexture, BarW / float(ReadyUpBarTexture.USize), BarH / float(ReadyUpBarTexture.VSize));

	//Fill
	if (Percent > 0.f)
	{
		Canvas.DrawColor = MakeColor(20, 20, 20, int(200.f * ReadyUpOpacity));
		Canvas.SetPos(BarX, BarY);
		Canvas.DrawTileScaled(ReadyUpBarTexture, (BarW * Percent) / ReadyUpBarTexture.USize, BarH / float(ReadyUpBarTexture.VSize));
	}

	//Text
	Canvas.Font = TurboHUD.LoadBoldFont(1 + FontSizeOffset);
	Canvas.FontScaleX = 1.f;
	Canvas.FontScaleY = 1.f;
	Canvas.TextSize(PressShiftString, TextSizeX, TextSizeY);
	Canvas.FontScaleX = (BarH * 0.85f) / TextSizeY;
	Canvas.FontScaleY = Canvas.FontScaleX;
	Canvas.TextSize(PressShiftString, TextSizeX, TextSizeY);
	Canvas.DrawColor = class'TurboLocalMessage'.default.KeywordColor;
	Canvas.DrawColor.A = Round((1.f - Percent) * 254.f * ReadyUpOpacity);
	Canvas.SetPos(BarX + (BarW - TextSizeX) * 0.5f, BarY + (BarH - TextSizeY) * 0.5f);
	Canvas.DrawText(PressShiftString);

}

simulated function DrawReadyUpList(Canvas Canvas)
{
	local HoldoutPlayerController HPC;
	local HoldoutPlayerSparseInfo LocalSRI, SRI;
	local float TextX, TextY, TextSizeX, TextSizeY;
	local int Index;
	local array<HoldoutPlayerSparseInfo> HoldoutSRIList;
	local string DrawString;

	if (TurboHUD == None)
	{
		return;
	}

	HPC = HoldoutPlayerController(TurboHUD.PlayerOwner);
	if (HPC == None || HPC.HoldoutInteraction == None)
	{
		return;
	}

	LocalSRI = HPC.HoldoutInteraction.FindHoldoutSRI();

	Canvas.Font = TurboHUD.LoadBoldFont(3 + FontSizeOffset);
	Canvas.FontScaleX = 1.f;
	Canvas.FontScaleY = 1.f;

	TextY = (Canvas.ClipY * 0.675f) + (Canvas.ClipY * 0.075f);

	if (LocalSRI == None || !LocalSRI.IsReady())
	{
		DrawString = class'TurboLocalMessage'.static.FormatString(ReadyUpString);
		Canvas.DrawColor = MakeColor(255, 255, 255, 255);
		Canvas.TextSize(class'GUIComponent'.static.StripColorCodes(DrawString), TextSizeX, TextSizeY);
		TextX = (Canvas.ClipX - TextSizeX) * 0.5f;
		Canvas.SetPos(TextX, TextY);
		Canvas.DrawText(DrawString);
		return;
	}

	for (Index = 0; Index < Level.GRI.PRIArray.Length; Index++)
	{
		if (Level.GRI.PRIArray[Index] == None || Level.GRI.PRIArray[Index].bOnlySpectator)
		{
			continue;
		}

		SRI = class'HoldoutPlayerSparseInfo'.static.GetHoldoutInfo(Level.GRI.PRIArray[Index]);

		if (SRI == None || SRI.OwningPRI == None || SRI.IsReady())
		{
			continue;
		}

		HoldoutSRIList[HoldoutSRIList.Length] = SRI;
	}

	if (HoldoutSRIList.Length == 0)
	{
		return;
	}

	Canvas.DrawColor = MakeColor(255, 255, 255, 255);
	Canvas.TextSize(WaitingForPlayersString, TextSizeX, TextSizeY);
	TextX = (Canvas.ClipX - TextSizeX) * 0.5f;
	Canvas.SetPos(TextX, TextY);
	Canvas.DrawText(WaitingForPlayersString);
	TextY += TextSizeY + (Canvas.ClipY * 0.005f);

	Canvas.DrawColor = MakeColor(150, 150, 150, 200);
	for (Index = 0; Index < HoldoutSRIList.Length; Index++)
	{
		SRI = HoldoutSRIList[Index];

		Canvas.TextSize(SRI.OwningPRI.PlayerName, TextSizeX, TextSizeY);
		TextX = (Canvas.ClipX - TextSizeX) * 0.5f;
		Canvas.SetPos(TextX, TextY);
		Canvas.DrawText(SRI.OwningPRI.PlayerName);
		TextY += TextSizeY + (Canvas.ClipY * 0.005f);
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

	ReadyUpBarTexture=Texture'KFTurbo.Scoreboard.ScoreboardBackplate_D'

	PressShiftString="READY UP"
	ReadyUpString="Hold %kshift%d to start the %knext wave%d!"
	WaitingForPlayersString="Waiting for players:"
}
