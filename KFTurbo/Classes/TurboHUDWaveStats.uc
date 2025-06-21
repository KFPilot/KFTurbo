//Killing Floor Turbo TurboHUDWaveStats
//Handles wave player stats UI.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHUDWaveStats extends TurboHUDOverlay
    hidecategories(Advanced,Collision,Display,Events,Force,Karma,LightColor,Lighting,Movement,Object,Sound);

var TurboGameReplicationInfo TGRI;

var int ProcessingWave;

struct WaveStats
{
	var int ShotsFired, ShotsHit, ShotsHeadshot;

	var int Kills, KillsFleshpound, KillsScrake;

	var int HealAmount;
	var int Damage, FleshpoundDamage, ScrakeDamage;

	var int Reloads;
};

var WaveStats ProcessedWavePlayerStats;
var WaveStats ProcessedWaveTeamStats;

struct PlayerAmountEntry
{
	var PlayerReplicationInfo Player;
	var int Amount;
};
var array<PlayerAmountEntry> TeammateKillsList;
var array<PlayerAmountEntry> TeammateDamageList;
var array<PlayerAmountEntry> TeammateShotsFiredList;
var array<PlayerAmountEntry> TeammateHealthHealedList;
var array<PlayerAmountEntry> TeammateReloadsList;
var array<PlayerAmountEntry> TeammateFleshpoundDamageList;

var float FadeInRate;
var float DisplayDuration;
var float FadeOutRate;
var float DisplayRatio;

var int FontSizeOffset;

var(Turbo) Vector2D WaveStatsSize;
var(Turbo) Vector2D WaveStatsPosition;
var(Turbo) float StatsHeaderSizeY;
var(Turbo) float StatsSubheaderSizeY;
var(Turbo) float StatsBarOffsetY;

var Texture SquareContainer;
var Color BackplateColor;

var localized string StatsHeaderString;
var localized string StatsKillsString;
var localized string StatsDamageString;
var localized string StatsShotsFiredString;
var localized string StatsHealString;
var localized string StatsAccuracyString;
var localized string StatsFleshpoundDamageString;
var localized string StatsReloadsString;

var localized string StatsAccuracyMissString;
var localized string StatsAccuracyHitString;
var localized string StatsAccuracyHeadshotString;

struct TeamStatBarConfig
{
	var Color BarColor;
	var Color FillColor;
	var bool bDrawFillMarker;
};

var TeamStatBarConfig KillsBar;
var TeamStatBarConfig DamageBar;
var TeamStatBarConfig ShotsFiredBar;
var TeamStatBarConfig HealBar;
var TeamStatBarConfig ReloadsBar;
var Color TeamBarSeparatorColor;

var Color StatSubtitleTextColor;
var Color StatSubtitleTextShadowColor;
var Color StatTextColor;

var Color ShotsFiredColor;
var Color ShotsHitColor;
var Color ShotsHeadshotColor;

var Texture BarTexture;
var Texture MarkerTexture;

//Moves stats into a process wave stats struct.
static final function ProcessStatReplicator(out WaveStats ProcessedStats, TurboWavePlayerStatReplicator Replicator)
{
	ProcessedStats.ShotsFired += Replicator.ShotsFired;
	ProcessedStats.ShotsHit += Replicator.ShotsHit;
	ProcessedStats.ShotsHeadshot += Replicator.ShotsHeadshot;

	ProcessedStats.Kills += Replicator.Kills;
	ProcessedStats.KillsFleshpound += Replicator.KillsFleshpound;
	ProcessedStats.KillsScrake += Replicator.KillsScrake;

	ProcessedStats.HealAmount += Replicator.HealingDone;

	ProcessedStats.Damage += Replicator.DamageDone;
	ProcessedStats.FleshpoundDamage += Replicator.DamageDoneFleshpound;
	
	ProcessedStats.Reloads += Replicator.Reloads;
}

simulated function Initialize(TurboHUDKillingFloor OwnerHUD)
{
	Super.Initialize(OwnerHUD);

	TGRI = TurboGameReplicationInfo(Level.GRI);
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (Level.GRI != None)
	{
		BindToNewPlayerStates(DeltaTime);
	}
}

simulated function BindToNewPlayerStates(float DeltaTime)
{
	local int Index;
	local TurboPlayerReplicationInfo TPRI;

	for (Index = 0; Index < Level.GRI.PRIArray.Length; Index++)
	{
		TPRI = TurboPlayerReplicationInfo(Level.GRI.PRIArray[Index]);
		if (TPRI == None)
		{
			continue;
		}

		if (!TPRI.bHasRegisteredOnReceiveStatReplicator)
		{
			TPRI.OnReceiveStatReplicator = OnReceiveStatReplicator;
			TPRI.bHasRegisteredOnReceiveStatReplicator = true;
		}
	}
}

simulated function OnReceiveStatReplicator(TurboPlayerReplicationInfo PlayerReplicationInfo, TurboPlayerStatCollectorBase Replicator)
{
	local TurboWavePlayerStatReplicator WavePlayerStatReplicator;
	WavePlayerStatReplicator = TurboWavePlayerStatReplicator(Replicator);
	if (WavePlayerStatReplicator == None)
	{
		return;
	}

	//If we've detected a new wave player stats round, zero out the processed stats.
	if (ProcessingWave < WavePlayerStatReplicator.Wave)
	{
		ProcessedWavePlayerStats = default.ProcessedWavePlayerStats;
		ProcessedWaveTeamStats = default.ProcessedWaveTeamStats;
		TeammateKillsList.Length = 0;
		TeammateDamageList.Length = 0;
		TeammateShotsFiredList.Length = 0;
		TeammateHealthHealedList.Length = 0;
		TeammateReloadsList.Length = 0;
		TeammateFleshpoundDamageList.Length = 0;

		ProcessingWave = WavePlayerStatReplicator.Wave;
	}
	
	ProcessStatReplicator(ProcessedWaveTeamStats, WavePlayerStatReplicator);
	
	if (PlayerReplicationInfo == TurboHUD.PlayerOwner.PlayerReplicationInfo)
	{
		ProcessStatReplicator(ProcessedWavePlayerStats, WavePlayerStatReplicator);
	}
	else
	{
		OnReceiveTeammateReplicator(WavePlayerStatReplicator);
	}

	//Each time we receive a replicator, delay showing stats by 3 seconds.
	SetTimer(3.f, false);
}

static final function AddTeammateToStatList(PlayerReplicationInfo PRI, int Amount, out array<PlayerAmountEntry> StatList)
{
	local int Index;

	if (Amount == 0)
	{
		return;
	}

	for (Index = 0; Index < StatList.Length; Index++)
	{
		if (StatList[Index].Amount > Amount)
		{
			StatList.Insert(Index, 1);
			StatList[Index].Player = PRI;
			StatList[Index].Amount = Amount;
			return;
		}
	}

	Index = StatList.Length;
	StatList.Length = Index + 1;
	StatList[Index].Player = PRI;
	StatList[Index].Amount = Amount;
}

simulated function OnReceiveTeammateReplicator(TurboWavePlayerStatReplicator Replicator)
{
	AddTeammateToStatList(Replicator.PlayerTPRI, Replicator.Kills, TeammateKillsList);
	AddTeammateToStatList(Replicator.PlayerTPRI, Replicator.DamageDone, TeammateDamageList);
	AddTeammateToStatList(Replicator.PlayerTPRI, Replicator.ShotsFired, TeammateShotsFiredList);
	AddTeammateToStatList(Replicator.PlayerTPRI, Replicator.HealingDone, TeammateHealthHealedList);
	AddTeammateToStatList(Replicator.PlayerTPRI, Replicator.Reloads, TeammateReloadsList);
	AddTeammateToStatList(Replicator.PlayerTPRI, Replicator.DamageDoneFleshpound, TeammateFleshpoundDamageList);
}

simulated function Timer()
{
	if (ProcessingWave < 0)
	{
		return;
	}

	GotoState('DisplayWaveStats');
}

state DisplayWaveStats
{
	simulated function BeginState()
	{
		DisplayRatio = 0.f;
		DisplayDuration = default.DisplayDuration;
	}

	simulated function Render(Canvas C)
	{
		Global.Render(C);

		class'TurboHUDKillingFloor'.static.ResetCanvas(C);

		DrawStats(C);
	}

	simulated function Tick(float DeltaTime)
	{
		local bool bIsWaveInProgress;
		local bool bHasScoreboardOpen;
		bIsWaveInProgress = KFGameReplicationInfo(Level.GRI) != None && KFGameReplicationInfo(Level.GRI).bWaveInProgress;
		bHasScoreboardOpen = TurboHUD.bShowScoreboard;

		if (bIsWaveInProgress || (DisplayDuration <= 0.f && !bHasScoreboardOpen))
		{
			DisplayRatio = Lerp(FadeOutRate * DeltaTime, DisplayRatio, 0.f);

			if (DisplayRatio <= 0.001f)
			{
				DisplayRatio = 0.f;
				if (bIsWaveInProgress)
				{
					GotoState('');
				}
			}
			return;
		}
		
		DisplayDuration = FMax(DisplayDuration - DeltaTime, 0.f);

		if (DisplayRatio < 1.f)
		{
			DisplayRatio = Lerp(FadeInRate * DeltaTime, DisplayRatio, 1.f);

			if (DisplayRatio > 0.999f)
			{
				DisplayRatio = 1.f;
			}
			return;
		}
	}	
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

	if (CurrentClipSize.Y <= 720)
	{
		FontSizeOffset++;
	}
}

simulated function DrawStats(Canvas C)
{
	local float TempX, TempY;
	local float SizeX, SizeY;
	local float TextScale, TextSizeX, TextSizeY;
	local float SizeYPerEntry;

	local Font SubtitleFont;
	local float SubtitleFontScale;

	local string DrawString;
	
	TempX = C.ClipX * (WaveStatsPosition.X - (WaveStatsSize.X * 0.5f));
	TempY = C.ClipY * (WaveStatsPosition.Y - (WaveStatsSize.Y * DisplayRatio));

	SizeX = C.ClipX * WaveStatsSize.X;
	SizeY = C.ClipY * WaveStatsSize.Y;

	if (SquareContainer != None)
	{
		C.DrawColor = BackplateColor;
		C.SetPos(TempX, TempY);
		C.DrawTileStretched(SquareContainer, SizeX, SizeY + 2.f);
	}

	//Calculate box title size.
	C.Font = TurboHUD.LoadFont(1 + FontSizeOffset);
	C.FontScaleX = 1.f;
	C.FontScaleX = 1.f;
	C.TextSize("000", TextSizeX, TextSizeY);

	TextScale = (SizeY * StatsHeaderSizeY) / TextSizeY;
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;
	C.TextSize("000", TextSizeX, TextSizeY);


	//Draw box title.	
	if (SquareContainer != None)
	{
		C.DrawColor = KillsBar.FillColor;
		C.DrawColor.A = 20;
		C.SetPos(TempX, TempY + (SizeY * 0.05f));
		C.DrawTileStretched(SquareContainer, SizeX, TextSizeY - (SizeY * 0.06f));
		C.DrawColor.A = 80;
		C.DrawTileStretched(SquareContainer, SizeX * (DisplayDuration / default.DisplayDuration), TextSizeY - (SizeY * 0.06f));
	}

	C.DrawColor = TurboHUD.WhiteColor;
	C.SetPos(TempX + (SizeX * 0.05f), TempY + (SizeY * 0.02f));
	C.DrawText(StatsHeaderString);
	
	TempY += TextSizeY;
	SizeYPerEntry = (SizeY - TextSizeY) / 5.5f;
	
	C.Font = TurboHUD.LoadFont(1 + FontSizeOffset);
	C.FontScaleX = 1.f;
	C.FontScaleX = 1.f;
	C.TextSize("000", TextSizeX, TextSizeY);

	TextScale = (SizeY * StatsSubheaderSizeY) / TextSizeY;
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;

	SubtitleFont = C.Font;
	SubtitleFontScale = C.FontScaleX;

	if (ProcessedWaveTeamStats.Kills > 0)
	{
		//Draw Kills Stats
		DrawTeamBar(C, TempX, TempY, SizeX, SizeYPerEntry, KillsBar, ProcessedWavePlayerStats.Kills, ProcessedWaveTeamStats.Kills, TeammateKillsList);
		DrawString = StatsKillsString@ProcessedWavePlayerStats.Kills;
		C.Font = SubtitleFont;
		C.FontScaleX = SubtitleFontScale;
		C.FontScaleY = SubtitleFontScale;
		C.DrawColor = StatSubtitleTextShadowColor;
		C.SetPos(TempX + (SizeX * 0.025f) + 2.f, TempY + 2.f);
		C.DrawText(DrawString);
		C.DrawColor = StatSubtitleTextColor;
		C.SetPos(TempX + (SizeX * 0.025f), TempY);
		C.DrawText(DrawString);
	}

	TempY += SizeYPerEntry;
	if (ProcessedWaveTeamStats.Damage > 0)
	{
		//Draw Damage Stats
		DrawTeamBar(C, TempX, TempY, SizeX, SizeYPerEntry, DamageBar, ProcessedWavePlayerStats.Damage, ProcessedWaveTeamStats.Damage, TeammateDamageList);
		DrawString = StatsDamageString@ProcessedWavePlayerStats.Damage;
		C.Font = SubtitleFont;
		C.FontScaleX = SubtitleFontScale;
		C.FontScaleY = SubtitleFontScale;
		C.DrawColor = StatSubtitleTextShadowColor;
		C.SetPos(TempX + (SizeX * 0.025f) + 2.f, TempY + 2.f);
		C.DrawText(DrawString);
		C.DrawColor = StatSubtitleTextColor;
		C.SetPos(TempX + (SizeX * 0.025f), TempY);
		C.DrawText(DrawString);
	}

	TempY += SizeYPerEntry;
	if (ProcessedWaveTeamStats.ShotsFired > 0)
	{
		//Draw Shots Fired Stats
		DrawTeamBar(C, TempX, TempY, SizeX, SizeYPerEntry, ShotsFiredBar, ProcessedWavePlayerStats.ShotsFired, ProcessedWaveTeamStats.ShotsFired, TeammateShotsFiredList);
		DrawString = StatsShotsFiredString@ProcessedWavePlayerStats.ShotsFired;
		C.Font = SubtitleFont;
		C.FontScaleX = SubtitleFontScale;
		C.FontScaleY = SubtitleFontScale;
		C.DrawColor = StatSubtitleTextShadowColor;
		C.SetPos(TempX + (SizeX * 0.025f) + 2.f, TempY + 2.f);
		C.DrawText(DrawString);
		C.DrawColor = StatSubtitleTextColor;
		C.SetPos(TempX + (SizeX * 0.025f), TempY);
		C.DrawText(DrawString);
	}
	
	//Try to find something to display!
	TempY += SizeYPerEntry;
	if (ProcessedWaveTeamStats.HealAmount > 0)
	{
		//Draw Health Healed
		DrawTeamBar(C, TempX, TempY, SizeX, SizeYPerEntry, HealBar, ProcessedWavePlayerStats.HealAmount, ProcessedWaveTeamStats.HealAmount, TeammateHealthHealedList);
		DrawString = StatsHealString@ProcessedWavePlayerStats.HealAmount;
		C.Font = SubtitleFont;
		C.FontScaleX = SubtitleFontScale;
		C.FontScaleY = SubtitleFontScale;
		C.DrawColor = StatSubtitleTextShadowColor;
		C.SetPos(TempX + (SizeX * 0.025f) + 2.f, TempY + 2.f);
		C.DrawText(DrawString);
		C.DrawColor = StatSubtitleTextColor;
		C.SetPos(TempX + (SizeX * 0.025f), TempY);
		C.DrawText(DrawString);
	}
	else if (ProcessedWaveTeamStats.FleshpoundDamage > 0)
	{
		//Draw Fleshpound Damage
		DrawTeamBar(C, TempX, TempY, SizeX, SizeYPerEntry, DamageBar, ProcessedWavePlayerStats.FleshpoundDamage, ProcessedWaveTeamStats.FleshpoundDamage, TeammateFleshpoundDamageList);
		DrawString = StatsFleshpoundDamageString@ProcessedWavePlayerStats.FleshpoundDamage;
		C.Font = SubtitleFont;
		C.FontScaleX = SubtitleFontScale;
		C.FontScaleY = SubtitleFontScale;
		C.DrawColor = StatSubtitleTextShadowColor;
		C.SetPos(TempX + (SizeX * 0.025f) + 2.f, TempY + 2.f);
		C.DrawText(DrawString);
		C.DrawColor = StatSubtitleTextColor;
		C.SetPos(TempX + (SizeX * 0.025f), TempY);
		C.DrawText(DrawString);
	}
	else if (ProcessedWaveTeamStats.Reloads > 0)
	{
		//Draw Reloads
		DrawTeamBar(C, TempX, TempY, SizeX, SizeYPerEntry, ReloadsBar, ProcessedWavePlayerStats.Reloads, ProcessedWaveTeamStats.Reloads, TeammateReloadsList);
		DrawString = StatsReloadsString@ProcessedWavePlayerStats.Reloads;
		C.Font = SubtitleFont;
		C.FontScaleX = SubtitleFontScale;
		C.FontScaleY = SubtitleFontScale;
		C.DrawColor = StatSubtitleTextShadowColor;
		C.SetPos(TempX + (SizeX * 0.025f) + 2.f, TempY + 2.f);
		C.DrawText(DrawString);
		C.DrawColor = StatSubtitleTextColor;
		C.SetPos(TempX + (SizeX * 0.025f), TempY);
		C.DrawText(DrawString);
	}
	
	TempY += SizeYPerEntry;
	if (ProcessedWavePlayerStats.ShotsFired > 0)
	{
		//Draw Accuracy Stats
		DrawAccuracyBar(C, TempX, TempY, SizeX, SizeYPerEntry, ProcessedWavePlayerStats.ShotsFired, ProcessedWavePlayerStats.ShotsHit, ProcessedWavePlayerStats.ShotsHeadshot);
		C.Font = SubtitleFont;
		C.FontScaleX = SubtitleFontScale;
		C.FontScaleY = SubtitleFontScale;
		C.DrawColor = StatSubtitleTextShadowColor;
		C.SetPos(TempX + (SizeX * 0.025f) + 2.f, TempY + 2.f);
		C.DrawText(StatsAccuracyString);
		C.DrawColor = StatSubtitleTextColor;
		C.SetPos(TempX + (SizeX * 0.025f), TempY);
		C.DrawText(StatsAccuracyString);
	}
}

static final function Color BlendColor(Color A, Color B, float Amount)
{
	A.R = Lerp(Amount, A.R, B.R);
	A.G = Lerp(Amount, A.G, B.G);
	A.B = Lerp(Amount, A.B, B.B);
	return A;
}

final function DrawTeamBar(Canvas C, float PositionX, float PositionY, float SizeX, float SizeY, TeamStatBarConfig Config, int PlayerAmount, int TotalAmount, array<PlayerAmountEntry> TeamAmount)
{
	local float PlayerBarPercent;
	local float TeammateBarPercent;
	local float RemainingPercent;
	local int Index;
	local float TextSizeX, TextSizeY;
	
	local Color TeammateBarColor;
	local string TeammateString;

	PositionX += SizeX * 0.05f;
	SizeX *= 0.9f;

	PositionY += SizeY * StatsBarOffsetY;
	SizeY *= 0.33f;

	C.DrawColor = Config.BarColor;
	C.SetPos(PositionX, PositionY);
	C.DrawTileStretched(SquareContainer, SizeX, SizeY);

	if (TotalAmount <= 0.f)
	{
		return;
	}
	
	C.Font = TurboHUD.LoadFont(3 + FontSizeOffset);
	C.FontScaleX = 1.f;
	C.FontScaleX = 1.f;
	C.TextSize("000", TextSizeX, TextSizeY);
	C.FontScaleX = (SizeY * 1.f) / TextSizeY;
	C.FontScaleY = C.FontScaleX;	

	TeammateBarColor = BlendColor(TurboHUD.WhiteColor, Config.FillColor, 0.25f);
	RemainingPercent = 1.f;

	for (Index = 0; Index < TeamAmount.Length; Index++)
	{
		if (TeamAmount[Index].Player == None)
		{
			continue;
		}
		
		TeammateBarPercent = float(TeamAmount[Index].Amount) / float(TotalAmount);
		
		if (TeammateBarPercent <= 0.f)
		{
			continue;
		}

		TeammateBarColor = BlendColor(TeammateBarColor, Config.FillColor, 0.25f);
		C.DrawColor = TeammateBarColor;
		C.SetPos(PositionX + ((SizeX * (RemainingPercent - TeammateBarPercent)) - 2.f), PositionY);
		C.DrawTileStretched(SquareContainer, (SizeX * TeammateBarPercent) + 2.f, SizeY);

		if (Index < TeamAmount.Length - 1)
		{
			C.DrawColor = TeamBarSeparatorColor;
			C.SetPos(PositionX + ((SizeX * (RemainingPercent - TeammateBarPercent)) - 2.f) - 2.f, PositionY);
			C.DrawTileStretched(SquareContainer, 2.f, SizeY);
		}

		TeammateString = class'TurboHUDScoreboard'.static.GetCompressedNumber(TeamAmount[Index].Amount) @ TeamAmount[Index].Player.PlayerName;
		C.DrawColor = StatTextColor;
		C.TextSize(TeammateString, TextSizeX, TextSizeY);
		C.SetPos(PositionX + (SizeX * RemainingPercent) - TextSizeX, (PositionY + (SizeY * 0.5f)) - (TextSizeY * 0.5f));
		C.DrawTextClipped(TeammateString);
		
		RemainingPercent -= TeammateBarPercent;
	}

	PlayerBarPercent = float(PlayerAmount) / float(TotalAmount);

	if (PlayerBarPercent <= 0.f)
	{
		return;
	}

	C.DrawColor = Config.FillColor;
	C.SetPos(PositionX, PositionY);
	C.DrawTileStretched(SquareContainer, SizeX * PlayerBarPercent, SizeY);

	if (!Config.bDrawFillMarker)
	{
		return;
	}

	PositionX += SizeX * PlayerBarPercent;
	SizeX = SizeY * 0.75f;
	
	C.SetPos(PositionX - (SizeX * 0.5f), PositionY - (SizeX * 0.8f));
	C.DrawColor = BackplateColor;
	C.DrawRect(MarkerTexture, SizeX, SizeX);

	C.SetPos(PositionX - (SizeX * 0.5f), PositionY - (SizeX * 0.9f));
	C.DrawColor = Config.FillColor;
	C.DrawRect(MarkerTexture, SizeX, SizeX);
}

final function DrawAccuracyBar(Canvas C, float PositionX, float PositionY, float SizeX, float SizeY, int ShotAmount, int HitAmount, int HeadshotAmount)
{
	local float HitPercent;
	local float HeadshotPercent;
	local float TextSizeX, TextSizeY;
	local string DisplayString;

	PositionX += SizeX * 0.05f;
	SizeX *= 0.9f;

	PositionY += SizeY * StatsBarOffsetY;
	SizeY *= 0.33f;

	C.DrawColor = ShotsFiredColor;
	C.SetPos(PositionX, PositionY);
	C.DrawTileStretched(SquareContainer, SizeX, SizeY);
	
	C.Font = TurboHUD.LoadFont(3 + FontSizeOffset);
	C.FontScaleX = 1.f;
	C.FontScaleX = 1.f;
	C.TextSize("000", TextSizeX, TextSizeY);
	C.FontScaleX = (SizeY * 1.f) / TextSizeY;
	C.FontScaleY = C.FontScaleX;

	if (ShotAmount <= 0)
	{
		return;
	}

	HitAmount = Min(HitAmount, ShotAmount);
	
	HitPercent = float(HitAmount) / float(ShotAmount);
	
	DisplayString = Repl(StatsAccuracyMissString, "%p", int(Round(100.f * (1.f - HitPercent))));
	C.DrawColor = StatTextColor;
	C.TextSize(DisplayString, TextSizeX, TextSizeY);
	C.SetPos((PositionX + SizeX) - (TextSizeX + (SizeY * 0.1f)), (PositionY + (SizeY * 0.5f)) - (TextSizeY * 0.45f));
	C.DrawTextClipped(DisplayString);

	if (HitAmount <= 0)
	{
		return;
	}

	C.DrawColor = ShotsHitColor;
	C.SetPos(PositionX, PositionY);
	C.DrawTileStretched(SquareContainer, SizeX * HitPercent, SizeY);
	
	DisplayString = Repl(StatsAccuracyHitString, "%p", int(Round(100.f * HitPercent)));
	C.DrawColor = StatTextColor;
	C.TextSize(DisplayString, TextSizeX, TextSizeY);

	//Only draw if can fit.
	if (SizeX * HitPercent >= TextSizeX)
	{
		C.SetPos((PositionX + (SizeX * HitPercent)) - (TextSizeX + (SizeY * 0.1f)), (PositionY + (SizeY * 0.5f)) - (TextSizeY * 0.45f));
		C.DrawTextClipped(DisplayString);
	}

	if (HeadshotAmount <= 0)
	{
		return;
	}
	
	HeadshotPercent = float(HeadshotAmount) / float(ShotAmount);

	C.DrawColor = ShotsHeadshotColor;
	C.SetPos(PositionX, PositionY);
	C.DrawTileStretched(SquareContainer, SizeX * HeadshotPercent, SizeY);
	
	DisplayString = Repl(StatsAccuracyHeadshotString, "%p", int(Round(100.f * HeadshotPercent)));
	C.DrawColor = StatTextColor;
	C.TextSize(DisplayString, TextSizeX, TextSizeY);
	
	if (SizeX * HeadshotPercent >= TextSizeX)
	{
		C.SetPos((PositionX + (SizeX * HeadshotPercent)) - (TextSizeX + (SizeY * 0.1f)), (PositionY + (SizeY * 0.5f)) - (TextSizeY * 0.45f));
		C.DrawTextClipped(DisplayString);
	}
}

defaultproperties
{
	StatsHeaderString="WAVE STATS"
	StatsKillsString="KILLS"
	StatsDamageString="DAMAGE"
	StatsShotsFiredString="SHOTS FIRED"
	StatsHealString="HEALTH HEALED"
	StatsAccuracyString="ACCURACY"
	StatsFleshpoundDamageString="FLESHPOUND DAMAGE"
	StatsReloadsString="RELOADS"

	StatsAccuracyMissString="%p% MISS"
	StatsAccuracyHitString="%p% HIT"
	StatsAccuracyHeadshotString="%p% HEADSHOT"

	ProcessingWave=-1

	FadeInRate=12.f
	FadeOutRate=6.f
	DisplayDuration=15.f

	WaveStatsSize=(X=0.25,Y=0.25f)
	WaveStatsPosition=(X=0.775f,Y=1.f)
	StatsHeaderSizeY=0.2f
	StatsSubheaderSizeY=0.125f
	StatsBarOffsetY=0.75f
	
	SquareContainer=Texture'KFTurbo.HUD.ContainerSquare_D'
	BackplateColor=(R=0,G=0,B=0,A=120)

	StatSubtitleTextColor=(R=255,G=255,B=255,A=255)
	StatSubtitleTextShadowColor=(R=0,G=0,B=0,A=140)
	StatTextColor=(R=0,G=0,B=0,A=200)

	KillsBar=(FillColor=(R=120,G=145,B=255,A=255),BarColor=(R=255,G=255,B=255,A=255),bDrawFillMarker=true)
	DamageBar=(FillColor=(R=255,G=147,B=120,A=255),BarColor=(R=255,G=255,B=255,A=255),bDrawFillMarker=true)
	ShotsFiredBar=(FillColor=(R=255,G=215,B=120,A=255),BarColor=(R=255,G=255,B=255,A=255),bDrawFillMarker=true)
	HealBar=(FillColor=(R=135,G=255,B=120,A=255),BarColor=(R=255,G=255,B=255,A=255),bDrawFillMarker=true)
	ReloadsBar=(FillColor=(R=255,G=215,B=120,A=255),BarColor=(R=255,G=255,B=255,A=255),bDrawFillMarker=true)
	TeamBarSeparatorColor=(R=0,G=0,B=0,A=140)

	ShotsFiredColor=(R=255,G=255,B=255,A=255)
	ShotsHitColor=(R=120,G=145,B=255,A=255)
	ShotsHeadshotColor=(R=255,G=147,B=120,A=255)

	BarTexture=Texture'KFTurbo.HUD.ContainerSquare_D'
	MarkerTexture=Texture'KFTurbo.HUD.BarMarker_D'
}