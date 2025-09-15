//Killing Floor Turbo TurboHUDWaveInfo
//Handles wave info-related UI such as wave number, remaining monsters/trader time, monster kill feed.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHUDWaveInfo extends TurboHUDOverlay
    hidecategories(Advanced,Collision,Display,Events,Force,Karma,LightColor,Lighting,Movement,Object,Sound);

var TurboGameReplicationInfo TGRI;

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

var(Turbo) Vector2D BackplateSize;
var(Turbo) Vector2D ActiveBackplateSize;
var(Turbo) Vector2D BackplateSpacing; //Distance from top and middle.
var(Turbo) Vector2D BackplateTextSpacing; //Distance from top and middle.

//Voting
var TurboGameVoteBase CurrentVoteInstance;
var float VoteRatio;
var float VoteRatioInterpRate;
var float VoteDurationPercent;
var float VoteDurationInterpRate;
var float VoteYesPercent;
var float VoteYesInterpRate;
var float VoteNoPercent;
var float VoteNoInterpRate;
var Sound VoteStartSound;
var Sound VoteTallyChangeSound;

var Color BackplateColor;
var Texture RoundedContainer;
var Texture EdgeContainer;
var Texture LeftEdgeContainer;
var Texture SquareContainer;

var Color ActiveWaveIconColor;
var Texture ActiveWaveIcon;

var bool bIsTestGameMode;
var bool bIsGameOver;

var int FontSizeOffset;

struct BossHitData
{
	var float HitAmount;
	var float Ratio;
	var float FadeRate;
};

struct BossSyringeEntry
{
	var float FadeRatio;
};

struct BossEntry
{
	var P_ZombieBoss BossMonster;
	var class<P_ZombieBoss> BossClass;
	var float PlayInRatio;
	var float PlayOutRatio;
	
	var float CurrentHealth;
	var float LastCheckedHealth;
	var float PreviousHealth;
	var float LastLowestRecordedHealth;

	var float HealthMax;
	
	var BossHitData LastHit;

	var float CurrentHealToHealth;
	var float PreviousHealToHealth;

	var int CurrentSyringeCount;

	var BossSyringeEntry SyringeList[3];
};

var BossEntry BossData;
var array<P_ZombieBoss> BossList;

var float BossDataFadeInRate;
var float BossDataFadeOutRate;
var float BossDataHealthInterpRate;
var Material BossHealthBarBackplate;
var Material BossHealthBarFill;
var Material BossHealthDamageBarFill;
var Texture BossSyringeIcon;
var Texture BossSyringeBackplateIcon;

var(Turbo) Vector2D BossBarSize;

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

static final function TurboHUDWaveInfo FindWaveInfoOverlay(PlayerController PlayerController)
{
	local TurboHUDKillingFloor TurboHUD;
	TurboHUD = TurboHUDKillingFloor(PlayerController.myHUD);
	return TurboHUD.WaveInfoHUD;
}

simulated function Initialize(TurboHUDKillingFloor OwnerHUD)
{
	local P_ZombieBoss BossMonster;
	
	Super.Initialize(OwnerHUD);

	InitializeGRI(TurboGameReplicationInfo(Level.GRI));

	ActiveBackplateSize = BackplateSize;

	foreach DynamicActors(class'P_ZombieBoss', BossMonster)
	{
		RegisterZombieBoss(BossMonster);
	}
}

simulated function OnVoteInstanceTallyChanged(TurboGameVoteBase VoteInstance, int NewYesVoteCount, int NewNoVoteCount)
{
	if (VoteRatio < 0.5f)
	{
		return;
	}

	TurboHUD.PlayerOwner.ClientPlaySound(VoteTallyChangeSound, true, 2.5f, SLOT_None);
}

simulated function OnVoteInstanceChanged(TurboGameVoteBase VoteInstance)
{
	if (VoteInstance == None || VoteInstance.GetVoteState() >= Expired)
	{
		return;
	}

	TurboHUD.PlayerOwner.ClientPlaySound(VoteStartSound, true, 1.25f, SLOT_None);
}

simulated function InitializeGRI(TurboGameReplicationInfo InTGRI)
{
	TGRI = TurboGameReplicationInfo(Level.GRI);

	if (TGRI == None)
	{
		return;
	}

	bIsTestGameMode = class'KFTurboGameType'.static.StaticIsTestGameType(Self);

	TGRI.OnVoteInstanceTallyChanged = OnVoteInstanceTallyChanged;
}

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

	TickGameState(DeltaTime);
	TickKillFeed(DeltaTime);

	if (TGRI.bWaveInProgress && !IsInState('ActiveWave'))
	{
		GotoState('ActiveWave');
	}
	else if (!TGRI.bWaveInProgress && !IsInState('WaitingWave'))
	{
		GotoState('WaitingWave');
	}

	TickBossData(DeltaTime);
	TickVoteInstance(DeltaTime);
}

simulated function TickGameState(float DeltaTime)
{
	bIsGameOver = TGRI != None && TGRI.EndGameType != 0;
}

simulated function Render(Canvas C)
{	
	Super.Render(C);

	if (TGRI == None)
	{
		return;
	}
	
	if (!bIsTestGameMode  && !bIsGameOver)
	{
		class'TurboHUDKillingFloor'.static.ResetCanvas(C);

		DrawGameData(C);

		class'TurboHUDKillingFloor'.static.ResetCanvas(C);

		DrawWaveData(C);
	}
	
	DrawKillFeed(C);
	
	class'TurboHUDKillingFloor'.static.ResetCanvas(C);

	if ((BossData.BossMonster != None || BossData.PlayOutRatio > 0.f) && BossData.PlayOutRatio < 1.f)
	{
		DrawBossHealthBar(C);
	}

	class'TurboHUDKillingFloor'.static.ResetCanvas(C);

	DrawVoteInstance(C);
	
	class'TurboHUDKillingFloor'.static.ResetCanvas(C);
}

simulated function OnScreenSizeChange(Canvas C, Vector2D CurrentClipSize, Vector2D PreviousClipSize)
{
	FontSizeOffset = 0;

	if (CurrentClipSize.Y <= 1440)
	{
		FontSizeOffset++;
	}

	if (CurrentClipSize.Y <= 1080)
	{
		FontSizeOffset++;
	}

	if (CurrentClipSize.Y <= 820)
	{
		FontSizeOffset++;
	}
}

simulated function DrawGameData(Canvas C)
{
	local float CenterX, TopY;
	local float TempX, TempY;
	local float SizeX, SizeY;
	local float TextSizeX, TextSizeY, TextScale;
	local string TestText;

	CenterX = C.ClipX * 0.5f;
	TopY = C.ClipY * BackplateSpacing.Y;

	TempX = CenterX - ((C.ClipX * (BackplateSize.X + BackplateTextSpacing.X)) + TopY);
	TempY = TopY;

	SizeX = C.ClipX * BackplateSize.X;
	SizeY = C.ClipY * BackplateSize.Y;

	TestText = GetStringOfZeroes(5);

	C.SetPos(TempX, TempY);

	
	C.Font = TurboHUD.LoadLargeNumberFont(2 + FontSizeOffset);
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.TextSize(TestText, TextSizeX, TextSizeY);

	TextScale = (C.ClipY * (BackplateSize.Y - BackplateTextSpacing.Y)) / TextSizeY;
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;

	C.TextSize(TestText, TextSizeX, TextSizeY);
	SizeX = TextSizeX + (BackplateTextSpacing.X * C.ClipX);

	if (RoundedContainer != None)
	{
		C.DrawColor = BackplateColor;
		C.SetPos(TempX, TempY);
		C.DrawTileStretched(RoundedContainer, SizeX, SizeY);
	}
	
	C.DrawColor = C.MakeColor(255, 255, 255, 255);
	TestText = FillStringWithZeroes(string(Min(TGRI.WaveNumber + 1, 99)), 2);
	TestText = TestText $ "|";
	TestText = TestText $ FillStringWithZeroes(string(Min(TGRI.FinalWave, 99)), 2);
	C.SetPos((TempX + (SizeX * 0.5f)) - (TextSizeX * 0.5f), (TempY + (SizeY * 0.5f)) - (TextSizeY * 0.5f));
	DrawTextMeticulous(C, TestText, TextSizeX);
}

simulated function DrawWaveData(Canvas C) {}

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
		Killer = TurboHUD.PlayerOwner.PlayerReplicationInfo;
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

	bIsLocalPlayer = (TurboHUD.PlayerOwner != None && TurboHUD.PlayerOwner.PlayerReplicationInfo != None && TurboHUD.PlayerOwner.PlayerReplicationInfo == Killer);
	InitializeKillFeedEntry(KillFeedList[InsertIndex], TurboPlayerReplicationInfo(Killer), MonsterClass, class<TurboKillsMessage>(KillsMessageClass), bIsLocalPlayer);
}

//===========================
//ACTIVE WAVE:

state ActiveWave
{
	simulated function BeginState()
	{
		NumberZedsRemaining = TGRI.MaxMonsters;
		ActiveWaveFadeRatio = 0.f;
	}

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

		TickGameState(DeltaTime);

		TickActiveWave(DeltaTime);
		TickKillFeed(DeltaTime);

		if (!TGRI.bWaveInProgress)
		{
			TickActiveFadeOut(DeltaTime);
		}
		else
		{
			TickActiveFadeIn(DeltaTime);
		}

		TickBossData(DeltaTime);
		TickVoteInstance(DeltaTime);
	}

	simulated function DrawWaveData(Canvas C)
	{
		DrawActiveWave(C);
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

	ActiveBackplateSize.X = Lerp(2.f * ActiveWaveSizeRate * DeltaTime, ActiveBackplateSize.X, DesiredXSize);

	if (Abs(DesiredXSize - ActiveBackplateSize.X) > 0.0001f)
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
	NumberZedsRemaining = Lerp(DeltaTime * NumberZedsInterpRate, NumberZedsRemaining, float(TGRI.MaxMonsters));
}

simulated function DrawActiveWave(Canvas C)
{
	local float CenterX, TopY;
	local float TempX, TempY;
	local float SizeX, SizeY;
	local float TextSizeX, TextSizeY, TextScale;
	local string TestText;

	CenterX = C.ClipX * 0.5f;
	TopY = C.ClipY * BackplateSpacing.Y;

	TempX = CenterX + TopY;
	TempY = TopY;

	SizeY = C.ClipY * BackplateSize.Y;

	TestText = GetStringOfZeroes(Len(string(int(NumberZedsRemaining))));

	C.SetPos(TempX, TempY);

	C.Font = TurboHUD.LoadLargeNumberFont(2 + FontSizeOffset);
	C.FontScaleX = 1.f;
	C.FontScaleX = 1.f;

	C.TextSize(TestText, TextSizeX, TextSizeY);

	TextScale = (C.ClipY * (BackplateSize.Y - BackplateTextSpacing.Y)) / TextSizeY;
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;

	C.TextSize(TestText, TextSizeX, TextSizeY);

	DesiredXSize = TextSizeX;
	DesiredXSize /= C.ClipX;
	DesiredXSize += BackplateTextSpacing.X;

	if (ActiveBackplateSize.X < DesiredXSize)
	{
		ActiveBackplateSize.X = DesiredXSize;
	}

	if (RoundedContainer != None)
	{
		SizeX = C.ClipX * ActiveBackplateSize.X;

		C.DrawColor = BackplateColor;
		C.SetPos(TempX, TempY);
		C.DrawTileStretched(RoundedContainer, SizeX, SizeY);
	}
	
	if (ActiveWaveFadeRatio <= 0.001f)
	{
		return;
	}

	C.SetDrawColor(255, 255, 255);
	C.DrawColor.A = byte(ActiveWaveFadeRatio * 255.f);

	TestText = string(int(NumberZedsRemaining));
	C.SetPos(TempX + (C.ClipX * ActiveBackplateSize.X * 0.5f) - (TextSizeX * 0.5f), TempY + (C.ClipY * BackplateSize.Y  * 0.5f) - (TextSizeY * 0.5f));
	DrawTextMeticulous(C, TestText, TextSizeX);
}

static final function float GetLifeTimeForMonster(class<Monster> Monster, int Count)
{
	if(class'PawnHelper'.static.IsEliteMonster(Monster))
	{
		return default.EliteMonsterKillLifeTime + (default.EliteMonsterKillCountExtension * float(Count));
	}

	return default.TrashMonsterKillLifeTime + (default.TrashMonsterKillCountExtension * float(Count));
}

static final function float GetBonusScale(out KillFeedEntry Entry)
{
	if (class'PawnHelper'.static.IsEliteMonster(Entry.KilledMonster))
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

	bIsElite = class'PawnHelper'.static.IsEliteMonster(Entry.KilledMonster);

	if (bIsElite)
	{
		KillTextString = Caps(KillTextString);
		C.Font = TurboHUD.LoadBoldItalicFont(0 + FontSizeOffset);
	}
	else
	{
		C.Font = TurboHUD.LoadItalicFont(1 + FontSizeOffset);
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
	EntrySizeX += TextSizeX * GetBonusScale(Entry);
	KillTextX = EntrySizeX;
	BaseTextSizeY = TextSizeY;

	C.TextSize(KillTextString, TextSizeX, TextSizeY);
	EntrySizeX += TextSizeX;
	EntrySizeY = TextSizeY * 1.1f;

	FadeOutRatio = Sqrt(FMin(Entry.LifeTime / 0.2f, 1.f));

	DrawOffsetX = ((1.f - FadeOutRatio) * 32.f);

	C.SetDrawColor(0, 0, 0);
	C.DrawColor.A = byte(FadeOutRatio * 160.f);
	C.SetPos((-2.f) - DrawOffsetX, DrawY);

	if (LeftEdgeContainer != None)
	{
		C.DrawTileStretched(LeftEdgeContainer, (EntrySizeX + 2.f + 24.f), EntrySizeY);
	}

	if (bIsElite)
	{
		C.DrawColor = MakeColor(255, 255, 255, byte(FadeOutRatio * 255.f));
	}

	DrawX = 8.f - DrawOffsetX;
	C.SetPos(DrawX + KillTextX, DrawY + (EntrySizeY * 0.5f) - (BaseTextSizeY * 0.45f));
	C.DrawTextClipped(KillTextString);

	if (bIsElite)
	{
		C.DrawColor = LerpColor(Entry.TriggerRatio, MakeColor(255, 255, 255, 255), MakeColor(255, 0, 0, 255));
		C.DrawColor.A = byte(FadeOutRatio * 255.f);
	}
	else
	{
		C.DrawColor = MakeColor(255, 255, 255, byte(FadeOutRatio * 255.f));
	}

	C.FontScaleX *= GetBonusScale(Entry);
	C.FontScaleY = C.FontScaleX;
	C.TextSize(KillCountString, TextSizeX, TextSizeY);

	C.SetPos(DrawX + 4.f, DrawY + (EntrySizeY * 0.5f) - (TextSizeY * 0.45f));
	C.DrawTextClipped(KillCountString);

	//Draw player name if this isn't our entry.
	if (!Entry.bIsLocalPlayer)
	{
		C.Font = TurboHUD.LoadItalicFont(3 + FontSizeOffset);
		C.FontScaleX = BaseTextScale * 1.5f;
		C.FontScaleY = BaseTextScale * 1.5f;

		C.TextSize(Entry.ResolvedName, TextSizeX, TextSizeY);
		C.SetPos(DrawX + (KillTextX * 0.5f), DrawY - (TextSizeY * 0.4f));
		C.DrawTextClipped(Entry.ResolvedName);
	}

	DrawY += (EntrySizeY + 2.f) * FadeOutRatio;
}

//Returns true if entry is still valid (do not remove).
static final function bool TickKillFeedEntry(out KillFeedEntry Entry, float DeltaTime)
{
	Entry.LifeTime = FMax(Entry.LifeTime - DeltaTime, 0.f);
	Entry.InitialRatio = Lerp(DeltaTime * 10.f, Entry.InitialRatio, 0.f);
	Entry.TriggerRatio = Lerp(DeltaTime * 4.f, Entry.TriggerRatio, 0.f);
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
		WaveTimeSecondsRemaining = TGRI.TimeToNextWave;
		TraderFadeRatio = 0.f;
	}

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

		TickGameState(DeltaTime);

		TickTraderWave(DeltaTime);
		TickKillFeed(DeltaTime);

		if (TGRI.bWaveInProgress)
		{
			TickTraderFadeOut(DeltaTime);
		}
		else
		{
			TickTraderFadeIn(DeltaTime);
		}

		TickBossData(DeltaTime);
		TickVoteInstance(DeltaTime);
	}
	
	simulated function DrawWaveData(Canvas C)
	{
		DrawTraderWave(C);
	}
}

simulated function TickTraderWave(float DeltaTime)
{
	if (TGRI.TimeToNextWave != WaveTimeSecondsRemaining && Abs(WaveTimeRemaining - float(TGRI.TimeToNextWave)) > 0.15f)
	{
		WaveTimeSecondsRemaining = TGRI.TimeToNextWave;
		WaveTimeRemaining = (float(TGRI.TimeToNextWave) - 0.0001f);
	}
	else
	{
		WaveTimeRemaining -= DeltaTime * 0.95f;
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

simulated function DrawTraderWave(Canvas C)
{
	local string TraderTime;
	local int MinutesRemaining;
	local bool bLessThanMinuteRemains;
	local float SecondTime, MillisecondTime;
	local float TextSizeX, TextSizeY, TextScale;
	local float TempX, TempY, SizeX, SizeY;

	TempY = C.ClipY * BackplateSpacing.Y;
	TempX = (C.ClipX * 0.5f) + TempY;

	SizeX = C.ClipX * BackplateSize.X;
	SizeY = C.ClipY * BackplateSize.Y;

	TraderTime = GetStringOfZeroes(5);

	C.SetPos(TempX, TempY);

	C.Font = TurboHUD.LoadLargeNumberFont(2 + FontSizeOffset);
	C.FontScaleX = 1.f;
	C.FontScaleX = 1.f;
	C.TextSize(TraderTime, TextSizeX, TextSizeY);

	TextScale = (C.ClipY * (BackplateSize.Y - BackplateTextSpacing.Y)) / TextSizeY;
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;

	C.TextSize(TraderTime, TextSizeX, TextSizeY);
	SizeX = TextSizeX + (BackplateTextSpacing.X * C.ClipX);

	if (RoundedContainer != None)
	{
		C.DrawColor = BackplateColor;
		C.SetPos(TempX, TempY);
		C.DrawTileStretched(RoundedContainer, SizeX, SizeY);
	}

	DesiredXSize = SizeX;
	DesiredXSize /= C.ClipX;

	if (ActiveBackplateSize.X < DesiredXSize)
	{
		ActiveBackplateSize.X = DesiredXSize;
	}

	if (TraderFadeRatio <= 0.001f)
	{
		return;
	}

	C.SetDrawColor(255, 255, 255);
	C.DrawColor.A = byte(TraderFadeRatio * 255.f);

	MinutesRemaining = int(WaveTimeRemaining) / 60;
	bLessThanMinuteRemains = MinutesRemaining <= 0;

	if (!bLessThanMinuteRemains || WaveTimeRemaining > 10.f)
	{
		SecondTime = Max(int(WaveTimeRemaining) - (MinutesRemaining * 60), 0);
		TraderTime = FillStringWithZeroes(MinutesRemaining, 2) $ ":" $ FillStringWithZeroes(int(SecondTime), 2);
	}
	else
	{
		SecondTime = Max(int(WaveTimeRemaining), 0);
		MillisecondTime = WaveTimeRemaining - SecondTime;
		MillisecondTime = MillisecondTime * 100.f;
		TraderTime = FillStringWithZeroes(int(SecondTime), 2) $ ":" $ FillStringWithZeroes(string(Max(int(MillisecondTime), 0)), 2);
	}
	
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = TurboHUD.LoadLargeNumberFont(2 + FontSizeOffset);
	C.TextSize(GetStringOfZeroes(Len(TraderTime)), TextSizeX, TextSizeY);
	
	TextScale = (C.ClipY * BackplateSize.Y) / TextSizeY;
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;
	
	C.TextSize(GetStringOfZeroes(Len(TraderTime)), TextSizeX, TextSizeY);

	C.SetPos((TempX + (SizeX * 0.5f)) - (TextSizeX * 0.5f), (TempY + (SizeY * 0.5f)) - (TextSizeY * 0.5f));
	DrawTextMeticulous(C, TraderTime, TextSizeX);
}

simulated function RegisterZombieBoss(P_ZombieBoss BossMonster)
{
	local int Index;

	if (bIsTestGameMode)
	{
		return;
	}

	for (Index = 0; Index < BossList.Length; Index++)
	{
		if (BossList[Index] == BossMonster)
		{
			return;
		}
	}

	BossList[BossList.Length] = BossMonster;

	//There's already a boss monster using the boss UI. Currently we only want one at a time.
	if (BossData.BossMonster != None)
	{
		return;
	}

	InitializeBossData(BossMonster);
}

simulated function InitializeBossData(P_ZombieBoss BossMonster)
{
	local int Index;

	BossData.BossMonster = BossMonster;
	BossData.BossClass = BossMonster.Class;
	BossData.PlayInRatio = 0.f;
	BossData.PlayOutRatio = 0.f;
	
	BossData.CurrentHealth = float(BossMonster.Health) / BossMonster.BossHealthMax;
	BossData.LastCheckedHealth = BossData.CurrentHealth;
	BossData.PreviousHealth = BossData.CurrentHealth;
	BossData.LastLowestRecordedHealth = 1.f;
	
	BossData.HealthMax = BossMonster.BossHealthMax;

	BossData.LastHit.HitAmount = 0.f;
	BossData.LastHit.Ratio = 1.f;

	BossData.CurrentHealToHealth = 0;
	BossData.PreviousHealToHealth = 0;

	BossData.CurrentSyringeCount = 3 - BossMonster.SyringeCount;

	BossData.SyringeList[0].FadeRatio = 0.f;
	BossData.SyringeList[1].FadeRatio = 0.f;
	BossData.SyringeList[2].FadeRatio = 0.f;

	Index = 3;
	while (Index > BossData.CurrentSyringeCount && Index - 1 >= 0)
	{
		BossData.SyringeList[Index - 1].FadeRatio = 1.f;
		Index--;
	}
}

simulated function OnPlayOutComplete()
{
	local int Index;

	if (BossList.Length == 0)
	{
		BossData.BossMonster = None;
		BossData.BossClass = None;

		BossData.PlayInRatio = 0.f;
		BossData.PlayOutRatio = 0.f;

		return;
	}

	for (Index = BossList.Length - 1; Index >= 0; Index--)
	{
		if (BossList[Index] == None || BossList[Index] == BossData.BossMonster)
		{
			BossList.Remove(Index, 1);
		}
	}

	BossData.BossMonster = None;
	BossData.BossClass = None;

	BossData.PlayInRatio = 0.f;
	BossData.PlayOutRatio = 0.f;

	if (BossList.Length == 0)
	{
		return;
	}

	InitializeBossData(BossList[0]);
}

simulated function TickBossData(float DeltaTime)
{
	local P_ZombieBoss BossMonster;
	local float NewHealthPercent, NewLowestHealthPercent;
	local int SyringeIndex;

	if (bIsTestGameMode)
	{
		return;
	}

	//No boss monster and we're not playing out a boss monster.
	if (BossData.BossClass == None || (BossData.BossMonster == None && BossData.PlayOutRatio <= 0.f))
	{
		return;
	}

	if (BossData.PlayOutRatio > 0.f)
	{
		BossData.PlayOutRatio = Lerp(DeltaTime * BossDataFadeOutRate, BossData.PlayOutRatio, 0.f);

		if (Abs(BossData.PlayOutRatio) < 0.001f)
		{
			OnPlayOutComplete();
		}
	}

	if (BossData.PlayInRatio < 1.f)
	{
		BossData.PlayInRatio = Lerp(DeltaTime * BossDataFadeInRate, BossData.PlayInRatio, 1.f);

		if (Abs(BossData.PlayInRatio - 1.f) < 0.0001f)
		{
			BossData.PlayInRatio = 1.f;
		}
	}

	if (BossData.LastHit.Ratio < 1.f)
	{
		BossData.LastHit.Ratio += BossData.LastHit.FadeRate * DeltaTime;
		BossData.LastHit.Ratio = FMin(BossData.LastHit.Ratio, 1.f);
	}

	BossMonster = BossData.BossMonster;
	if (BossMonster != None)
	{
		NewHealthPercent = (float(BossMonster.Health) / BossMonster.BossHealthMax);
		NewLowestHealthPercent = (BossMonster.LowestHealth / BossMonster.BossHealthMax);
		BossData.CurrentSyringeCount = 3 - BossMonster.SyringeCount;
	}
	else
	{
		NewHealthPercent = 0.f;
		NewLowestHealthPercent = 0.f;
	}

	if (NewHealthPercent != BossData.LastCheckedHealth)
	{
		BossData.CurrentHealth = NewHealthPercent;
	
		if (NewHealthPercent < BossData.LastCheckedHealth && BossData.PlayInRatio > 0.9f)
		{
			InitializeHitData(BossData);
		}
		
		BossData.LastCheckedHealth = NewHealthPercent;

		if (NewHealthPercent <= 0.f)
		{
			BossData.PlayOutRatio = 1.f;
		}
	}
		
	if (BossData.CurrentHealth < BossData.PreviousHealth)
	{
		BossData.PreviousHealth = Lerp(BossDataHealthInterpRate * DeltaTime, BossData.PreviousHealth, BossData.CurrentHealth);
	}
	else if (BossData.CurrentHealth > BossData.PreviousHealth)
	{
		BossData.PreviousHealth = Lerp(BossDataHealthInterpRate * DeltaTime * 4.f, BossData.PreviousHealth, BossData.CurrentHealth);
		BossData.LastHit.HitAmount = 0.f;
		BossData.LastHit.Ratio = 1.f;
	}

	if (BossData.LastHit.HitAmount > 0.f)
	{
		BossData.LastHit.HitAmount = Lerp(DeltaTime * BossData.LastHit.FadeRate, BossData.LastHit.HitAmount, BossData.CurrentHealth);
		BossData.LastHit.Ratio = Lerp(DeltaTime * BossData.LastHit.FadeRate, BossData.LastHit.Ratio, 1.f);
	}

	if (NewLowestHealthPercent != BossData.LastLowestRecordedHealth)
	{
		//On lowest recorded health update... do something cool I guess?
		BossData.LastLowestRecordedHealth = NewLowestHealthPercent;
	}

	SyringeIndex = 2;
	while (SyringeIndex >= 0)
	{
		if (SyringeIndex + 1 <= BossData.CurrentSyringeCount)
		{
			break;
		}

		BossData.SyringeList[SyringeIndex].FadeRatio = FMin(BossData.SyringeList[SyringeIndex].FadeRatio + DeltaTime, 1.f);
		SyringeIndex--;
	}
}

simulated final function InitializeHitData(out BossEntry BossInfo)
{	
	BossInfo.LastHit.HitAmount = FMax(BossInfo.CurrentHealth, BossInfo.LastHit.HitAmount);
	BossInfo.LastHit.FadeRate = 0.5f;
	BossInfo.LastHit.Ratio = 0.f;
}

simulated function DrawBossHealthBar(Canvas C)
{
	local float TempX, TempY;
	local float SizeX, SizeY;
	local float TextSizeX, TextSizeY;
	local float FadeRatio;
	local float HealthPercent, DamagePercent;
	local Color BarBackplateColor, FillColor;
	local int SyringeIndex;
	local float SyringeFadeRatio;

	if (bIsTestGameMode)
	{
		return;
	}

	if (BossData.PlayOutRatio <= 0.f)
	{
		FadeRatio = FClamp(BossData.PlayInRatio, 0.f, 1.f);
	}
	else
	{
		FadeRatio = FClamp(BossData.PlayInRatio * BossData.PlayOutRatio, 0.f, 1.f);
	}

	HealthPercent = FClamp(BossData.PreviousHealth * BossData.PlayInRatio, 0.f, 1.f);
	DamagePercent = FMax(BossData.LastHit.HitAmount - HealthPercent, 0.f);

	SizeX = float(C.SizeX) * BossBarSize.X;
	SizeY = float(C.SizeY) * BossBarSize.Y;

	TempX = float(C.SizeX) * (0.5f - (BossBarSize.X / 2.f));
	TempY = (float(C.SizeY) * ((BackplateSpacing.Y * 2.f) + BackplateSize.Y)) + ((1.f - FadeRatio) * SizeY * 2.f);

	BarBackplateColor = MakeColor(0, 0, 0, FadeRatio * 180.f);
	FillColor = MakeColor(255, 255, 255, FadeRatio * 255.f);

	C.SetPos(TempX, TempY);

	C.DrawColor = BarBackplateColor;
	C.DrawTileStretched(BossHealthBarBackplate, SizeX, SizeY);

	if (BossData.PlayInRatio > 0.9f && DamagePercent > 0.f && BossData.LastHit.Ratio < 1.f)
	{
		C.SetPos(TempX + (SizeX * HealthPercent), TempY);
		C.DrawColor = MakeColor(255, 255, 255, FadeRatio * FMin((1.f - BossData.LastHit.Ratio) * 2.f, 1.f) * 255.f);
		C.DrawTileClipped(BossHealthDamageBarFill, SizeX * DamagePercent, SizeY, 0, 0, SizeX * DamagePercent, BossHealthBarFill.MaterialVSize());
	}
	
	C.SetPos(TempX, TempY);
	C.DrawColor = FillColor;
	C.DrawTileClipped(BossHealthBarFill, SizeX * HealthPercent, SizeY, 0, 0, SizeX * HealthPercent, BossHealthBarFill.MaterialVSize());

	TempY += SizeY * 1.1f;
	C.SetPos(TempX, TempY);
	C.Font = TurboHUD.LoadFont(3 + FontSizeOffset);
	C.TextSize("P", TextSizeX, TextSizeY);
	C.DrawText(BossData.BossClass.default.MenuName);

	TempX += SizeX;
	TempY -= SizeY * 0.33f;
	SyringeIndex = 0;
	while(SyringeIndex < 3)
	{
		TempX -= TextSizeY;
		C.DrawColor = BarBackplateColor;
		C.SetPos(TempX, TempY);
		C.DrawRect(BossSyringeBackplateIcon, TextSizeY, TextSizeY);

		SyringeFadeRatio = BossData.SyringeList[SyringeIndex].FadeRatio;
		SyringeIndex++;
		if (SyringeFadeRatio >= 1.f)
		{
			TempX -= TextSizeY * 0.125f;
			continue;
		}
		
		FillColor.A = FadeRatio * 255.f * (1.f - SyringeFadeRatio);
		C.DrawColor = FillColor;
		C.SetPos(TempX - (TextSizeY * 0.125f), TempY - (TextSizeY * 0.125f));
		C.DrawRect(BossSyringeIcon, TextSizeY, TextSizeY);
		TempX -= TextSizeY * 0.125f;
	}
}

simulated function TickVoteInstance(float DeltaTime)
{
	if (TGRI.VoteInstance != CurrentVoteInstance || TGRI.VoteInstance == None || TGRI.VoteInstance.GetVoteState() >= Expired)
	{
		VoteRatio = Lerp(DeltaTime * VoteRatioInterpRate, VoteRatio, 0.f);

		if (VoteRatio <= 0.001f)
		{
			VoteRatio = 0.f;
			CurrentVoteInstance = TGRI.VoteInstance;

			if (CurrentVoteInstance != None)
			{
				OnVoteInstanceChanged(CurrentVoteInstance);
				VoteDurationPercent = CurrentVoteInstance.GetVoteDurationPercentRemaining();
				VoteYesPercent = CurrentVoteInstance.GetYesVotePercent();
				VoteNoPercent = CurrentVoteInstance.GetNoVotePercent();
			}
		}

		return;
	}

	if (TGRI.VoteInstance == None)
	{
		return;
	}

	if (VoteRatio <= 1.f)
	{
		VoteRatio = Lerp(DeltaTime * VoteRatioInterpRate, VoteRatio, 1.f);

		if (VoteRatio >= 0.999f)
		{
			VoteRatio = 1.f;
		}
	}

	VoteDurationPercent = Lerp(DeltaTime * VoteDurationInterpRate, VoteDurationPercent, CurrentVoteInstance.GetVoteDurationPercentRemaining());
	VoteYesPercent = Lerp(DeltaTime * VoteYesInterpRate, VoteYesPercent, CurrentVoteInstance.GetYesVotePercent());
	VoteNoPercent = Lerp(DeltaTime * VoteNoInterpRate, VoteNoPercent, CurrentVoteInstance.GetNoVotePercent());
}

simulated function DrawVoteInstance(Canvas C)
{
	local float TempX, TempY, RootTempX;
	local float SizeX, SizeY, RootSizeX;
	local float TextSizeX, TextSizeY;
	local float PaddingPercent, TimePercent;
	local float VotePercentBarHeight;
	local string TestText;
	local Plane OriginalModulate;
	local Color YesColor, NoColor;

	if (VoteRatio <= 0.001f || CurrentVoteInstance == None)
	{
		return;
	}

	OriginalModulate = C.ColorModulate;
	C.ColorModulate.W = VoteRatio;
	
	PaddingPercent = 0.025f;

	TempY = BackplateSpacing.Y * float(C.SizeY);
	TempX = float(C.SizeX) - (BackplateSpacing.Y * float(C.SizeY));

	TestText = CurrentVoteInstance.GetVoteTitleString();
	C.Font = TurboHUD.LoadFont(FontSizeOffset + 1);
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.TextSize(TestText, TextSizeX, TextSizeY);

	SizeX = TextSizeX + (float(C.SizeY) * PaddingPercent);
	SizeY = (TextSizeY * 1.5f) + (float(C.SizeY) * PaddingPercent * 0.5f);

	TempX -= VoteRatio * SizeX;
	RootTempX = TempX;
	RootSizeX = SizeX;

	if (RoundedContainer != None)
	{
		C.DrawColor = BackplateColor;
		C.SetPos(TempX, TempY);
		C.DrawTileStretched(RoundedContainer, SizeX, SizeY);
	}

	TempX += (float(C.SizeY) * PaddingPercent * 0.5f);
	SizeX -= (float(C.SizeY) * PaddingPercent);
	
	TempY += (float(C.SizeY) * PaddingPercent * 0.25f);
	SizeY -= (float(C.SizeY) * PaddingPercent * 0.5f);

	YesColor = CurrentVoteInstance.GetVoteYesColor();
	NoColor = CurrentVoteInstance.GetVoteNoColor();

	TimePercent = CurrentVoteInstance.GetVoteDurationPercentRemaining();
	if (TimePercent >= 0.f)
	{
		VotePercentBarHeight = TextSizeY * 0.575f;
		C.SetPos(RootTempX, TempY + (VotePercentBarHeight * 0.2f));
		C.DrawColor = class'TurboLocalMessage'.default.KeywordColor;
		C.DrawColor.A = 20;
		C.DrawTileStretched(SquareContainer, RootSizeX, VotePercentBarHeight);
		C.DrawColor.A = 40;
		C.DrawTileStretched(SquareContainer, RootSizeX * TimePercent, VotePercentBarHeight);
	}

	C.DrawColor = CurrentVoteInstance.GetVoteTitleColor();
	C.SetPos(TempX + (SizeX * 0.5f - (TextSizeX * 0.5f)), TempY - (float(C.SizeY) * PaddingPercent * 0.25f));
	C.DrawTextClipped(TestText);

	TempY += SizeY;

	C.FontScaleX = 0.5f;
	C.FontScaleY = 0.5f;

	TestText = CurrentVoteInstance.GetVoteYesString() @ CurrentVoteInstance.GetYesVoteCount();
	C.TextSize(TestText, TextSizeX, TextSizeY);

	VotePercentBarHeight = TextSizeY * 0.8f;
	C.DrawColor = YesColor;
	C.DrawColor.A = float(C.DrawColor.A) * 0.25f;
	C.SetPos(RootTempX, TempY - (TextSizeY * 0.9f));
	C.DrawTileStretched(SquareContainer, RootSizeX * VoteYesPercent, VotePercentBarHeight);

	C.DrawColor = NoColor;
	C.DrawColor.A = float(C.DrawColor.A) * 0.25f;
	C.SetPos((RootTempX + RootSizeX) - (RootSizeX * VoteNoPercent), TempY - (TextSizeY * 0.9f));
	C.DrawTileStretched(SquareContainer, RootSizeX * VoteNoPercent, VotePercentBarHeight);

	C.DrawColor = BackplateColor;
	C.SetPos(TempX + 2.f, (TempY + 2.f) - TextSizeY);
	C.DrawTextClipped(TestText);

	C.SetPos(TempX, TempY - TextSizeY);
	C.DrawColor = YesColor;
	C.DrawTextClipped(TestText);

	TestText = CurrentVoteInstance.GetNoVoteCount() @ CurrentVoteInstance.GetVoteNoString();
	C.TextSize(TestText, TextSizeX, TextSizeY);

	C.DrawColor = BackplateColor;
	C.SetPos(((TempX + SizeX) - TextSizeX) + 2.f, (TempY + 2.f) - TextSizeY);
	C.DrawTextClipped(TestText);

	C.SetPos((TempX + SizeX) - TextSizeX, TempY - TextSizeY);
	C.DrawColor = NoColor;
	C.DrawTextClipped(TestText);

	C.ColorModulate = OriginalModulate;
}

defaultproperties
{
	bNeedTraderWaveInitialization=true
	TraderFadeRate=2.f

	bNeedActiveWaveInitialization=false
	ActiveWaveFadeRate=2.f
	ActiveWaveSizeRate=4.f
	NumberZedsInterpRate=2.f

	BossDataFadeInRate=1.f
	BossDataFadeOutRate=4.f
	BossDataHealthInterpRate=8.f

	VoteRatioInterpRate=4.f
	VoteDurationInterpRate=10.f
	VoteYesInterpRate=4.f
	VoteNoInterpRate=4.f
	VoteStartSound=Sound'Steamland_SND.UI_NewObjective'
	VoteTallyChangeSound=Sound'Steamland_SND.Safe_WheelClick'

	BossBarSize=(X=0.7f,Y=0.03)
	BossHealthBarBackplate=Texture'KFTurbo.HUD.ContainerSquare_D'
	BossHealthBarFill=FinalBlend'KFTurbo.Boss.Bar_FB'
	BossHealthDamageBarFill=Texture'KFTurbo.Boss.DamageBar_D'

	BossSyringeIcon=Texture'KFTurbo.Boss.Syringe_D'
	BossSyringeBackplateIcon=Texture'KFTurbo.Boss.SyringeBack_D'

	BackplateColor=(R=0,G=0,B=0,A=140)

	BackplateSize=(X=0.075f,Y=0.05f)
	BackplateSpacing=(X=0.01f,Y=0.02f)
	BackplateTextSpacing=(X=0.01f,Y=0.f)
	
	RoundedContainer=Texture'KFTurbo.HUD.ContainerRounded_D'
	EdgeContainer=Texture'KFTurbo.HUD.EdgeBackplate_D'
	LeftEdgeContainer=Texture'KFTurbo.HUD.EdgeBackplate_R_D'
	SquareContainer=Texture'KFTurbo.HUD.ContainerSquare_D'
	
	TrashMonsterKillLifeTime=4.f
	TrashMonsterKillCountExtension=0.1f
	EliteMonsterKillLifeTime=8.f
	EliteMonsterKillCountExtension=0.2f
	FontSizeOffset=0

	ActiveWaveIconColor=(R=255,G=255,B=255,A=80)
	ActiveWaveIcon=Texture'KFTurbo.Scoreboard.ScoreboardKill_D'
}