//Killing Floor Turbo TurboHUDWaveInfo
//Handles wave info-related UI such as wave number, remaining monsters/trader time, monster kill feed.
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHUDWaveInfo extends TurboHUDOverlay
    hidecategories(Advanced,Collision,Display,Events,Force,Karma,LightColor,Lighting,Movement,Object,Sound);

var KFGameReplicationInfo KFGRI;

//Trader
var bool bNeedTraderWaveInitialization;
var float TraderFadeRatio;
var float TraderFadeRate;

var float WaveTimeRemaining;
var int WaveTimeSecondsRemaining;

//Active Wave
var bool bNeedActiveWaveInitialization;
var float ActiveWaveFadeRatio;
var float ActiveWaveFadeRate;

var float ActiveWaveSizeRate;
var float DesiredXSize, DesiredYSize;

var float NumberZedsRemaining;
var float NumberZedsInterpRate;

var Vector2D BackplateSize;
var Vector2D ActiveBackplateSize;
var Vector2D BackplateSpacing; //Distance from top and middle.

//End Trader Vote
var localized string EndTraderVoteTitle;
struct EndTraderVoteEntry
{
	var TurboPlayerReplicationInfo PRI;
	var float Ratio;
};
var array<EndTraderVoteEntry> EndTraderVoteList;
var float EndTraderVoteRatio;

var Color BackplateColor;
var Texture RoundedContainer;
var Texture EdgeContainer;
var Texture LeftEdgeContainer;
var Texture SquareContainer;

//Kill Feed
struct KillFeedEntry
{
	var TurboPlayerReplicationInfo TPRI;
	var string ResolvedName;
	var class<Monster> KilledMonster;
	var class<TurboKillsMessage> KillsMessageClass;
	var int Count;
	var float LifeTime; //Time left for this entry.
	var float InitialRatio; //Initial fade in ratio.
	var float TriggerRatio; //Ratio for kill trigger.
	var bool bIsLocalPlayer;
};
var array<KillFeedEntry> KillFeedList;
var float TrashMonsterKillLifeTime, TrashMonsterKillCountExtension;
var float EliteMonsterKillLifeTime, EliteMonsterKillCountExtension;
var int KillFeedFontSizeOffset;

simulated function Initialize(TurboHUDKillingFloor OwnerHUD)
{
	Super.Initialize(OwnerHUD);

	KFGRI = KFGameReplicationInfo(KFPHUD.Level.GRI);

	ActiveBackplateSize = BackplateSize;
}

simulated function Tick(float DeltaTime)
{
	if (KFGRI == None)
	{
		KFGRI = KFGameReplicationInfo(KFPHUD.Level.GRI);

		if (KFGRI == None)
		{
			return;
		}
	}

	TickKillFeed(DeltaTime);

	if (KFGRI.bWaveInProgress && !IsInState('ActiveWave'))
	{
		GotoState('ActiveWave');
	}
	else if (!KFGRI.bWaveInProgress && !IsInState('WaitingWave'))
	{
		GotoState('WaitingWave');
	}	
}

simulated function Render(Canvas C)
{
	local Vector2D BackplateACenter, BackplateBCenter;
	
	Super.Render(C);

	if (KFGRI == None)
	{
		return;
	}
	
	DrawGameBackplate(C, BackplateACenter, BackplateBCenter);
	DrawCurrentWave(C, BackplateACenter);
	DrawWaveData(C, BackplateBCenter);
	
	C.Reset();
	C.DrawColor = class'HudBase'.default.WhiteColor;
	C.Style = ERenderStyle.STY_Alpha;
}

simulated function OnScreenSizeChange(Canvas C, Vector2D CurrentClipSize, Vector2D PreviousClipSize)
{
	KillFeedFontSizeOffset = 0;

	if (CurrentClipSize.Y <= 1440)
	{
		KillFeedFontSizeOffset++;
	}

	if (CurrentClipSize.Y <= 1080)
	{
		KillFeedFontSizeOffset++;
	}

	if (CurrentClipSize.Y <= 820)
	{
		KillFeedFontSizeOffset++;
	}

	if (CurrentClipSize.Y <= 720)
	{
		KillFeedFontSizeOffset++;
	}
}

simulated function DrawGameBackplate(Canvas C, out Vector2D BackplateACenter, out Vector2D BackplateBCenter)
{
	local float CenterX, TopY;
	local float TempX, TempY;

	CenterX = C.ClipX * 0.5f;
	TopY = C.ClipY * BackplateSpacing.Y;

	TempX = CenterX - (C.ClipX * (BackplateSpacing.X + BackplateSize.X));
	TempY = TopY;

	C.DrawColor = BackplateColor;

	C.SetPos(TempX, TempY);
	BackplateACenter.X = TempX + (C.ClipX * BackplateSize.X * 0.5f);
	BackplateACenter.Y = TempY + (C.ClipY * BackplateSize.Y * 0.5f);

	if (RoundedContainer != None)
	{
		C.DrawTileStretched(RoundedContainer, C.ClipX * BackplateSize.X, C.ClipY * BackplateSize.Y);
	}
	
	TempX = CenterX + (C.ClipX * BackplateSpacing.X);

	C.SetPos(TempX, TempY);
	BackplateBCenter.X = TempX + (C.ClipX * ActiveBackplateSize.X * 0.5f);
	BackplateBCenter.Y = BackplateACenter.Y;

	if (RoundedContainer != None)
	{
		C.DrawTileStretched(RoundedContainer, C.ClipX * ActiveBackplateSize.X, C.ClipY * ActiveBackplateSize.Y);
	}
}

simulated function DrawCurrentWave(Canvas C, Vector2D Center)
{
	local String CurrentWaveString;
	local float TextSizeX, TextSizeY, TextScale;

	C.DrawColor = C.MakeColor(255, 255, 255, 220);
	CurrentWaveString = FillStringWithZeroes(string(KFGRI.WaveNumber + 1), 2);
	CurrentWaveString = CurrentWaveString $ "/";
	CurrentWaveString = CurrentWaveString $ FillStringWithZeroes(string(KFGRI.FinalWave), 2);
	
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = class'KFTurboFontHelper'.static.LoadLargeNumberFont(2);
	C.TextSize(GetStringOfZeroes(Len(CurrentWaveString)), TextSizeX, TextSizeY);
	
	TextScale = (C.ClipY * BackplateSize.Y) / TextSizeY;
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;
	
	C.TextSize(GetStringOfZeroes(Len(CurrentWaveString)), TextSizeX, TextSizeY);

	C.SetPos(Center.X - (TextSizeX * 0.5f), Center.Y - (TextSizeY * 0.5f));
	DrawTextMeticulous(C, CurrentWaveString, TextSizeX);
}


simulated function DrawWaveData(Canvas C, Vector2D Center)
{
	DrawKillFeed(C);
}

simulated function ReceivedKillMessage(class<KillsMessage> KillsMessageClass, class<Monster> MonsterClass, PlayerReplicationInfo Killer)
{
	local int Index;
	local int InsertIndex;
	local bool bIsLocalPlayer;

	//Automatically convert KillsMessage local messages.
	KillsMessageClass = class<TurboKillsMessage>(KillsMessageClass);
	if (KillsMessageClass == None)
	{
		KillsMessageClass = class'TurboKillsMessage';
	}

	if (KillsMessageClass == None || MonsterClass == None)
	{
		return;
	}

	if (Killer == None)
	{
		Killer = KFPHUD.PlayerOwner.PlayerReplicationInfo;
	}

	InsertIndex = -1;
	for (Index = KillFeedList.Length - 1; Index >= 0; Index--)
	{
		if (KillFeedList[Index].KilledMonster != MonsterClass)
		{
			if (InsertIndex == -1 && MonsterClass.default.Health > KillFeedList[Index].KilledMonster.default.Health)
			{
				InsertIndex = Index;
			}

			continue;
		}

		if (KillFeedList[Index].TPRI != Killer)
		{
			continue;
		}

		if (KillFeedList[Index].KillsMessageClass != KillsMessageClass)
		{
			continue;
		}

		IncrementKillFeedEntry(KillFeedList[Index]);
		return;
	}

	if (InsertIndex != -1)
	{
		KillFeedList.Insert(InsertIndex, 1);
	}
	else
	{
		KillFeedList.Length = KillFeedList.Length + 1;
		InsertIndex = KillFeedList.Length - 1;
	}

	bIsLocalPlayer = (KFPHUD.PlayerOwner != None && KFPHUD.PlayerOwner.PlayerReplicationInfo != None && KFPHUD.PlayerOwner.PlayerReplicationInfo == Killer);
	InitializeKillFeedEntry(KillFeedList[InsertIndex], TurboPlayerReplicationInfo(Killer), MonsterClass, class<TurboKillsMessage>(KillsMessageClass), bIsLocalPlayer);
}

//===========================
//ACTIVE WAVE:

state ActiveWave
{
	simulated function BeginState()
	{
		NumberZedsRemaining = KFGRI.MaxMonsters;
		ActiveWaveFadeRatio = 0.f;
		EndTraderVoteList.Length = 0;
	}

	simulated function Tick(float DeltaTime)
	{
		if (KFGRI == None)
		{
			return;
		}

		TickActiveWave(DeltaTime);
		TickKillFeed(DeltaTime);

		if (!KFGRI.bWaveInProgress)
		{
			TickActiveFadeOut(DeltaTime);
		}
		else
		{
			TickActiveFadeIn(DeltaTime);
		}

	}

	simulated function DrawWaveData(Canvas C, Vector2D Center)
	{
		DrawActiveWave(C, Center);
		DrawKillFeed(C);
	}
}

simulated function TickActiveFadeOut(float DeltaTime)
{
	if (ActiveWaveFadeRatio >= 0.001f)
	{
		ActiveWaveFadeRatio = FMax(ActiveWaveFadeRatio - (ActiveWaveFadeRate * DeltaTime), 0.f);
		return;
	}

	ActiveWaveFadeRatio = 0.f;

	ActiveBackplateSize.X = Lerp(2.f * ActiveWaveSizeRate * DeltaTime, ActiveBackplateSize.X, BackplateSize.X);

	if (Abs(BackplateSize.X - ActiveBackplateSize.X) > 0.0001f)
	{
		return;
	}

	ActiveBackplateSize.X = BackplateSize.X;
	
	GotoState('WaitingWave');
}

simulated function TickActiveFadeIn(float DeltaTime)
{
	if (Abs(DesiredXSize - ActiveBackplateSize.X) > 0.0001f)
	{
		ActiveBackplateSize.X = Lerp(ActiveWaveSizeRate * DeltaTime, ActiveBackplateSize.X, DesiredXSize);
		return;
	}

	ActiveBackplateSize.X = DesiredXSize;

	if (ActiveWaveFadeRatio >= 0.999f)
	{
		ActiveWaveFadeRatio = 1.f;
		return;
	}

	ActiveWaveFadeRatio = FMin(ActiveWaveFadeRatio + (ActiveWaveFadeRate * DeltaTime), 1.f);
}

simulated function TickActiveWave(float DeltaTime)
{
	NumberZedsRemaining = Lerp(DeltaTime * NumberZedsInterpRate, NumberZedsRemaining, float(KFGRI.MaxMonsters));
}

simulated function DrawActiveWave(Canvas C, Vector2D Center)
{
	local float TextSizeX, TextSizeY, TextScale;
	local string ActiveWaveString;

	ActiveWaveString = string(int(NumberZedsRemaining));
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = class'KFTurboFontHelper'.static.LoadLargeNumberFont(2);
	C.TextSize(GetStringOfZeroes(Len(ActiveWaveString)), TextSizeX, TextSizeY);
	TextScale = (C.ClipY * BackplateSize.Y) / TextSizeY;
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;
	C.TextSize(GetStringOfZeroes(Len(ActiveWaveString)), TextSizeX, TextSizeY);

	DesiredXSize = TextSizeX;
	DesiredXSize /= C.ClipX;
	DesiredXSize += 0.01f;

	if (ActiveBackplateSize.X < DesiredXSize)
	{
		ActiveBackplateSize.X = DesiredXSize;
	}
	
	if (ActiveWaveFadeRatio <= 0.001f)
	{
		return;
	}

	C.SetDrawColor(255, 255, 255, byte(ActiveWaveFadeRatio * 255.f));

	C.SetPos(Center.X - (TextSizeX * 0.5f), Center.Y - (TextSizeY * 0.5f));
	DrawTextMeticulous(C, ActiveWaveString, TextSizeX);
}

static final function bool IsEliteMonster(class<Monster> Monster)
{
	return Class'HUDKillingFloor'.Default.MessageHealthLimit <= Monster.Default.Health || Class'HUDKillingFloor'.Default.MessageMassLimit <= Monster.Default.Mass;
}

static final function float GetLifeTimeForMonster(class<Monster> Monster, int Count)
{
	if(IsEliteMonster(Monster))
	{
		return default.EliteMonsterKillLifeTime + (default.EliteMonsterKillCountExtension * float(Count));
	}

	return default.TrashMonsterKillLifeTime + (default.TrashMonsterKillCountExtension * float(Count));
}

static final function float GetBonusScale(out KillFeedEntry Entry)
{
	if (IsEliteMonster(Entry.KilledMonster))
	{
		return Lerp(Entry.TriggerRatio, 1.f, 1.5f) * Lerp(FMin((Entry.Count - 1) / 10.f, 1.f), 1.f, 1.5f);
	}

	return Lerp(Entry.TriggerRatio, 1.f, 1.5f) * Lerp(FMin((Entry.Count - 1) / 20.f, 1.f), 1.f, 1.25f);
}

static final function InitializeKillFeedEntry(out KillFeedEntry Entry, TurboPlayerReplicationInfo Killer, class<Monster> MonsterClass, class<TurboKillsMessage> KillsMessageClass, bool bIsLocalPlayer)
{
	Entry.TPRI = Killer;
	Entry.ResolvedName = Eval(Len(Entry.TPRI.PlayerName) > 15, Left(Entry.TPRI.PlayerName, 15), Entry.TPRI.PlayerName);

	Entry.KilledMonster = MonsterClass;

	Entry.KillsMessageClass = KillsMessageClass;

	Entry.Count = 1;
	Entry.LifeTime = GetLifeTimeForMonster(Entry.KilledMonster, Entry.Count);
	Entry.InitialRatio = 1.f;
	Entry.TriggerRatio = 1.f;

	Entry.bIsLocalPlayer = bIsLocalPlayer;
}

static final function IncrementKillFeedEntry(out KillFeedEntry Entry)
{
	Entry.Count++;
	Entry.LifeTime = GetLifeTimeForMonster(Entry.KilledMonster, Entry.Count);
	Entry.TriggerRatio = 1.f;
}

simulated final function DrawKillFeedEntry(Canvas C, out float DrawY, out KillFeedEntry Entry)
{
	local string KillCountString, KillTextString;
	local bool bIsElite;
	local float TextSizeX, TextSizeY;
	local float EntrySizeY, EntrySizeX, KillTextX, DrawX, DrawOffsetX;
	local float BaseTextSizeY, BaseTextScale;
	local float FadeOutRatio;

	if (Entry.LifeTime < 0.01f)
	{
		return;
	}

	KillCountString = Entry.KillsMessageClass.static.GetKillCountString(Entry);
	KillTextString = Entry.KillsMessageClass.static.GetKillString(Entry);

	if (KillCountString == "")
	{
		return;
	}

	bIsElite = IsEliteMonster(Entry.KilledMonster);

	if (bIsElite)
	{
		C.Font = class'KFTurboFontHelper'.static.LoadBoldItalicFontStatic(0 + KillFeedFontSizeOffset);
	}
	else
	{
		C.Font = class'KFTurboFontHelper'.static.LoadItalicFontStatic(1 + KillFeedFontSizeOffset);
	}
	
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.TextSize(KillCountString, TextSizeX, TextSizeY);

	if (bIsElite)
	{
		C.FontScaleY = (C.ClipY * 0.045) / TextSizeY;
		C.FontScaleX = C.FontScaleY;
	}
	else
	{
		C.FontScaleY = (C.ClipY * 0.035) / TextSizeY;
		C.FontScaleX = C.FontScaleY;
	}
	
	EntrySizeX = 8.f;
	BaseTextScale = C.FontScaleX;

	C.TextSize(KillCountString, TextSizeX, TextSizeY);
	EntrySizeX += TextSizeX;
	KillTextX = EntrySizeX;
	BaseTextSizeY = TextSizeY;

	C.TextSize(KillTextString, TextSizeX, TextSizeY);
	EntrySizeX += TextSizeX;
	EntrySizeY = TextSizeY * 1.1f;

	FadeOutRatio = Sqrt(FMin(Entry.LifeTime / 0.2f, 1.f));

	DrawOffsetX = ((1.f - FadeOutRatio) * 32.f);

	C.SetDrawColor(0, 0, 0, byte(FadeOutRatio * 160.f));
	C.SetPos((-2.f) - DrawOffsetX, DrawY);

	if (LeftEdgeContainer != None)
	{
		C.DrawTileStretched(LeftEdgeContainer, (EntrySizeX + 2.f + 24.f), EntrySizeY);
	}

	DrawX = 8.f - DrawOffsetX;
	C.SetDrawColor(255, 255, 255, byte(FadeOutRatio * 255.f));

	C.SetPos(DrawX + KillTextX, DrawY + (EntrySizeY * 0.5f) - (BaseTextSizeY * 0.45f));
	C.DrawTextClipped(KillTextString);

	C.FontScaleX *= GetBonusScale(Entry);
	C.FontScaleY = C.FontScaleX;
	C.TextSize(KillCountString, TextSizeX, TextSizeY);

	C.SetPos(DrawX + 4.f, DrawY + (EntrySizeY * 0.5f) - (TextSizeY * 0.45f));
	C.DrawTextClipped(KillCountString);

	//Draw player name if this isn't our entry.
	if (!Entry.bIsLocalPlayer)
	{
		C.Font = class'KFTurboFontHelper'.static.LoadItalicFontStatic(3 + KillFeedFontSizeOffset);
		C.FontScaleX = BaseTextScale;
		C.FontScaleY = BaseTextScale;

		C.TextSize(Entry.ResolvedName, TextSizeX, TextSizeY);
		C.SetPos(DrawX + (KillTextX * 0.5f), DrawY - (TextSizeY * 0.65f));
		C.DrawTextClipped(Entry.ResolvedName);
	}

	DrawY += (EntrySizeY + 2.f) * FadeOutRatio;
}

//Returns true if entry is still valid (do not remove).
static final function bool TickKillFeedEntry(out KillFeedEntry Entry, float DeltaTime)
{
	Entry.LifeTime = FMax(Entry.LifeTime - DeltaTime, 0.f);
	Entry.InitialRatio = Lerp(DeltaTime * 10.f, Entry.InitialRatio, 0.f);
	Entry.TriggerRatio = Lerp(DeltaTime * 10.f, Entry.TriggerRatio, 0.f);
	return Entry.LifeTime > 0.f;
}

simulated function TickKillFeed(float DeltaTime)
{
	local int Index;
	for (Index = KillFeedList.Length - 1; Index >= 0; Index--)
	{
		if (TickKillFeedEntry(KillFeedList[Index], DeltaTime))
		{
			continue;
		}

		KillFeedList.Remove(Index, 1);
	}
}

simulated function DrawKillFeed(Canvas C)
{
	local int Index;
	local float DrawY;

	DrawY = C.ClipY * 0.3f;
	for (Index = 0; Index < KillFeedList.Length; Index++)
	{
		DrawKillFeedEntry(C, DrawY, KillFeedList[Index]);
	}
}

//===========================
//TRADER/GAME START TIME:

state WaitingWave
{
	simulated function BeginState()
	{
		WaveTimeSecondsRemaining = KFGRI.TimeToNextWave;
		TraderFadeRatio = 0.f;
		EndTraderVoteList.Length = 0;
	}

	simulated function Tick(float DeltaTime)
	{
		if (KFGRI == None)
		{
			return;
		}

		TickTraderWave(DeltaTime);
		TickKillFeed(DeltaTime);

		if (KFGRI.bWaveInProgress)
		{
			TickTraderFadeOut(DeltaTime);
		}
		else
		{
			TickTraderFadeIn(DeltaTime);
		}
	}
	
	simulated function DrawWaveData(Canvas C, Vector2D Center)
	{
		DrawTraderWave(C, Center);
		DrawTraderEndVote(C);
		DrawKillFeed(C);
	}
}

simulated function TickTraderWave(float DeltaTime)
{
	local int Index, EndTraderVoteIndex;
	local TurboPlayerReplicationInfo TPRI;
	local bool bFoundEntry;

	if (KFGRI.TimeToNextWave != WaveTimeSecondsRemaining && Abs(WaveTimeRemaining - float(KFGRI.TimeToNextWave)) > 0.15f)
	{
		WaveTimeSecondsRemaining = KFGRI.TimeToNextWave;
		WaveTimeRemaining = (float(KFGRI.TimeToNextWave) - 0.0001f);
	}
	else
	{
		WaveTimeRemaining -= DeltaTime * 0.95f;
	}

	//Update end trader vote UI.

	for (EndTraderVoteIndex = EndTraderVoteList.Length - 1; EndTraderVoteIndex >= 0; EndTraderVoteIndex--)
	{
		if (EndTraderVoteList[EndTraderVoteIndex].PRI == None || !EndTraderVoteList[EndTraderVoteIndex].PRI.bVotedForTraderEnd)
		{
			EndTraderVoteList.Remove(EndTraderVoteIndex, 1);
		}
	}

	if (TurboGameReplicationInfo(Level.GRI).TimeToNextWave <= 10)
	{
		for (EndTraderVoteIndex = EndTraderVoteList.Length - 1; EndTraderVoteIndex >= 0; EndTraderVoteIndex--)
		{
			EndTraderVoteList[EndTraderVoteIndex].Ratio = Lerp(2.f * DeltaTime, EndTraderVoteList[EndTraderVoteIndex].Ratio, 0.f);
		}

		if (EndTraderVoteList.Length != 0)
		{
			EndTraderVoteRatio = Lerp(4.f * DeltaTime, EndTraderVoteRatio, 0.f);
		}

		return;
	}

	for (Index = Level.GRI.PRIArray.Length - 1; Index >= 0; Index--)
	{
		TPRI = TurboPlayerReplicationInfo(Level.GRI.PRIArray[Index]);

		if (TPRI.bOnlySpectator || !TPRI.bVotedForTraderEnd)
		{
			continue;
		}

		bFoundEntry = false;
		for (EndTraderVoteIndex = EndTraderVoteList.Length - 1; EndTraderVoteIndex >= 0; EndTraderVoteIndex--) 
		{
			if (EndTraderVoteList[EndTraderVoteIndex].PRI == TPRI)
			{ 
				bFoundEntry = true;
				break;
			}
		}

		if (bFoundEntry)
		{
			continue;
		}

		EndTraderVoteList.Length = EndTraderVoteList.Length + 1;
		EndTraderVoteList[EndTraderVoteList.Length - 1].PRI = TPRI;
		EndTraderVoteList[EndTraderVoteList.Length - 1].Ratio = 0.f;
	}

	for (EndTraderVoteIndex = EndTraderVoteList.Length - 1; EndTraderVoteIndex >= 0; EndTraderVoteIndex--)
	{
		EndTraderVoteList[EndTraderVoteIndex].Ratio = Lerp(2.f * DeltaTime, EndTraderVoteList[EndTraderVoteIndex].Ratio, 1.f);
	}

	if (EndTraderVoteList.Length != 0)
	{
		EndTraderVoteRatio = Lerp(4.f * DeltaTime, EndTraderVoteRatio, 1.f);
	}
}

simulated function TickTraderFadeOut(float DeltaTime)
{
	TraderFadeRatio = FMax(TraderFadeRatio - (TraderFadeRate * DeltaTime), 0.f);

	if (TraderFadeRatio <= 0.001f)
	{
		TraderFadeRatio = 0.f;
		GotoState('ActiveWave');
	}
}

simulated function TickTraderFadeIn(float DeltaTime)
{
	if (TraderFadeRatio >= 1.f)
	{
		return;
	}

	TraderFadeRatio = FMin(TraderFadeRatio + (TraderFadeRate * DeltaTime), 1.f);
}

simulated function DrawTraderWave(Canvas C, Vector2D Center)
{
	local String TraderTime;
	local float SecondTime, MillisecondTime;
	local float TextSizeX, TextSizeY, TextScale;

	if (TraderFadeRatio <= 0.001f)
	{
		return;
	}

	C.SetDrawColor(255, 255, 255, byte(TraderFadeRatio * 255.f));

	if (WaveTimeSecondsRemaining >= 60.f)
	{
		TraderTime = "01:" $ FillStringWithZeroes(string(Max(WaveTimeSecondsRemaining - 60, 0)), 2);
	}
	else if ( WaveTimeSecondsRemaining > 10.f)
	{
		TraderTime = "00:" $ FillStringWithZeroes(string(Max(WaveTimeSecondsRemaining,0)), 2);
	}
	else
	{
		SecondTime = Max(int(WaveTimeRemaining), 0);
		MillisecondTime = WaveTimeRemaining - SecondTime;
		MillisecondTime = MillisecondTime * 100.f;

		TraderTime = "0"$int(SecondTime)$":";
		TraderTime = TraderTime $ FillStringWithZeroes(string(Max(int(MillisecondTime), 0)), 2);
	}
	
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = class'KFTurboFontHelper'.static.LoadLargeNumberFont(2);
	C.TextSize(GetStringOfZeroes(Len(TraderTime)), TextSizeX, TextSizeY);
	
	TextScale = (C.ClipY * BackplateSize.Y) / TextSizeY;
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;
	
	C.TextSize(GetStringOfZeroes(Len(TraderTime)), TextSizeX, TextSizeY);

	C.SetPos(Center.X - (TextSizeX * 0.5f), Center.Y - (TextSizeY * 0.5f));
	DrawTextMeticulous(C, TraderTime, TextSizeX);
}

simulated function DrawTraderEndVote(Canvas C)
{
	local int Index;
	local TurboPlayerReplicationInfo TPRI;
	local float Ratio;
	local float TempX, TempY, MinEntrySizeX, EntrySizeY, EntryXOffset;
	local float TextSizeX, TextSizeY;
	local bool bHasVotes;

	bHasVotes = false;
	
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = class'KFTurboFontHelper'.static.LoadFontStatic(4);
	C.TextSize(EndTraderVoteTitle, TextSizeX, TextSizeY);

	C.FontScaleX = FMin((C.ClipY * BackplateSpacing.Y * 1.25f) / TextSizeY, 1.f);
	C.FontScaleY = C.FontScaleX;

	for (Index = EndTraderVoteList.Length - 1; Index >= 0; Index--)
	{
		TPRI = EndTraderVoteList[Index].PRI;
		if (TPRI == None)
		{
			continue;
		}

		if (!TPRI.bVotedForTraderEnd)
		{
			continue;
		}
		
		bHasVotes = true;
		C.TextSize(TPRI.PlayerName, TextSizeX, TextSizeY);
		MinEntrySizeX = FMax(TextSizeX, MinEntrySizeX);
		EntrySizeY = FMax(TextSizeY, EntrySizeY);
	}

	if (!bHasVotes)
	{
		return;
	}

	MinEntrySizeX += 24.f;
	EntrySizeY *= 1.1f;

	TempX = C.ClipX;
	TempY = C.ClipY * 0.3f;

	for (Index = EndTraderVoteList.Length - 1; Index >= 0; Index--)
	{
		TPRI = EndTraderVoteList[Index].PRI;
		if (TPRI == None)
		{
			continue;
		}

		if (!TPRI.bVotedForTraderEnd)
		{
			continue;
		}

		Ratio = EndTraderVoteList[Index].Ratio;
		EntryXOffset = (MinEntrySizeX * Lerp(Ratio, 0.5f, 0.f));

		C.TextSize(TPRI.PlayerName, TextSizeX, TextSizeY);

		if (EdgeContainer != None)
		{
			C.SetDrawColor(0, 0, 0, byte(Ratio * 120.f));
			C.SetPos((TempX - MinEntrySizeX) + EntryXOffset, TempY);
			C.DrawTileStretched(EdgeContainer, MinEntrySizeX + 2.f, EntrySizeY); //Avoid seams.
		}

		C.SetDrawColor(255, 255, 255, byte(Ratio * 255.f));
		C.SetPos((TempX - TextSizeX - 8.f) + EntryXOffset, TempY + (EntrySizeY * 0.5f) - (TextSizeY * 0.5f));
		C.DrawTextClipped(TPRI.PlayerName);

		TempY += EntrySizeY + 2.f;
	}

	if (bHasVotes)
	{
		C.SetDrawColor(255, 255, 255, byte(EndTraderVoteRatio * 255.f));
		TempY = C.ClipY * 0.3f;
		C.TextSize(EndTraderVoteTitle, TextSizeX, TextSizeY);

		C.SetPos(TempX - TextSizeX - 8.f, TempY - (TextSizeY + 8.f));
		C.DrawTextClipped(EndTraderVoteTitle);
	}
}

defaultproperties
{
	bNeedTraderWaveInitialization=true
	TraderFadeRate=2.f

	bNeedActiveWaveInitialization=false
	ActiveWaveFadeRate=2.f
	ActiveWaveSizeRate=4.f
	NumberZedsInterpRate=2.f

	BackplateColor=(R=0,G=0,B=0,A=140)

	BackplateSize=(X=0.075f,Y=0.05f)
	BackplateSpacing=(X=0.01f,Y=0.02f)

	EndTraderVoteTitle="End Trader Vote:"
	
	RoundedContainer=Texture'KFTurbo.HUD.ContainerRounded_D'
	EdgeContainer=Texture'KFTurbo.HUD.EdgeBackplate_D'
	LeftEdgeContainer=Texture'KFTurbo.HUD.EdgeBackplate_R_D'
	SquareContainer=Texture'KFTurbo.HUD.ContainerSquare_D'
	
	TrashMonsterKillLifeTime=3.f
	TrashMonsterKillCountExtension=0.1f
	EliteMonsterKillLifeTime=5.f
	EliteMonsterKillCountExtension=0.2f
	KillFeedFontSizeOffset=0
}