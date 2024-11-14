class TurboHUDScoreboard extends SRScoreBoard
	dependson(TurboHUDOverlay)
    hidecategories(Advanced,Display,Events,Object,Sound);

var(Layout) TurboHUDOverlay.Vector2D ScoreboardHeaderSize;
var(Layout) TurboHUDOverlay.Vector2D ScoreboardSize;

var(Color) Color ScoreboardBackplateColor;
var Texture ScoreboardBackplate;
var(Color) Color ScoreboardBackplateLeftColor;
var Texture ScoreboardBackplateLeft;

var(Color) Color ScoreboardTextColor;
var(Layout) float ScoreboardTextY;

//Perk
var(Layout) float PerkIconSizeY;
var(Layout) float PerkIconOffsetX;

//Username
var(Layout) float UsernameSizeY;
var(Layout) float UsernameOffsetX;

//Health
var(Layout) float HealthOffsetX;
var(Layout) float HealthSizeY;
var(Color) Color HealthIconColor;
var Texture HealthIcon;

//Kills
var(Layout) float KillsOffsetX;
var(Layout) float KillSizeY;
var(Color) Color KillIconColor;
var Texture KillIcon;

//Healed Health
var(Layout) float HealedHealthOffsetX;
var(Layout) float HealedHealthSizeY;
var(Color) Color HealedHealthIconColor;
var Texture HealedHealthIcon;

//Cash
var(Layout) float CashOffsetX;
var(Layout) float CashSizeY;
var(Color) Color CashIconColor;
var Texture CashIcon;

//Ping
var(Layout) float PingOffsetX;
var(Layout) float PingSizeY;
var(Layout) float PingTextSizeY;
var(Color) Color PingIconColor;
var Texture PingIcon;

var localized string ThousandSuffix;
var localized string MillionSuffix;
var localized string SeparatorCharacter;

simulated function UpdateScoreBoard(Canvas Canvas)
{
	local TurboPlayerReplicationInfo OwnerPRI, TPRI;
	local int Index, PlayerCount;
	local float EntrySizeY, TempY;

	Canvas.Reset();
	Canvas.DrawColor = class'HudBase'.default.WhiteColor;
	Canvas.Style = ERenderStyle.STY_Alpha;

	PlayerCount = 0;
	OwnerPRI = TurboPlayerReplicationInfo(KFPlayerController(Owner).PlayerReplicationInfo);
	TempY = ((1.f - ScoreboardSize.Y) * 0.3f) * Canvas.ClipY;
	DrawScoreboardHeader(Canvas, TempY, ((1.f - ScoreboardSize.Y) * 0.25f) * Canvas.ClipY);

	for ( Index = 0; Index < GRI.PRIArray.Length; Index++)
	{
		TPRI = TurboPlayerReplicationInfo(GRI.PRIArray[Index]);

		if (TPRI == None || TPRI.bOnlySpectator)
		{
			continue;
		}

		PlayerCount++;
	}

	if (PlayerCount <= 0)
	{
		return;
	}

	TempY = ((1.f - ScoreboardSize.Y) * 0.5f) * Canvas.ClipY;
	
	EntrySizeY = (ScoreboardSize.Y * Canvas.ClipY) / float(PlayerCount);
	EntrySizeY = Max(Min(EntrySizeY, Canvas.ClipY * 0.035f), 32.f);

	for ( Index = 0; Index < GRI.PRIArray.Length; Index++)
	{
		TPRI = TurboPlayerReplicationInfo(GRI.PRIArray[Index]);

		if (TPRI == None || TPRI.bOnlySpectator)
		{
			continue;
		}

		DrawPlayerEntry(Canvas, TPRI, EntrySizeY, TempY, OwnerPRI == TPRI, Index == 0);
		TempY += EntrySizeY * 1.2f;	
	}

	Canvas.Reset();
	Canvas.DrawColor = class'HudBase'.default.WhiteColor;
	Canvas.Style = ERenderStyle.STY_Alpha;
}

simulated final function DrawScoreboardHeader(Canvas Canvas, float CenterY, float SizeY)
{
	local string DrawString;
	local float TextSizeX, TextSizeY;
	local float CenterX;
	local KF_StoryObjective Objective;

	CenterX = Canvas.ClipX * 0.5f;

	Canvas.DrawColor = Canvas.MakeColor(255, 255, 255, 255);

	//Draw Difficulty
	Canvas.FontScaleX = 1.f;
	Canvas.FontScaleY = 1.f;
	Canvas.Font = class'KFTurboFontHelper'.static.LoadFontStatic(2);
	DrawString = SkillLevel[Clamp(InvasionGameReplicationInfo(GRI).BaseDifficulty, 0, 7)];
	Canvas.TextSize(DrawString, TextSizeX, TextSizeY);
	Canvas.FontScaleY = (SizeY * 0.125f) / (TextSizeY * 0.5f);
	Canvas.FontScaleX = Canvas.FontScaleY;
	Canvas.TextSize(DrawString, TextSizeX, TextSizeY);
	Canvas.SetPos(CenterX - (TextSizeX * 0.5f), CenterY - (SizeY * 0.25f));
	Canvas.DrawText(DrawString);

	//Draw Map Name
	DrawString = Level.Title;
	Canvas.TextSize(DrawString, TextSizeX, TextSizeY);
	Canvas.SetPos(CenterX - (TextSizeX * 0.5f), CenterY - (SizeY * 0.05f));
	Canvas.DrawText(DrawString);

	//Draw Wave
	if(KF_StoryGRI(GRI) != none)
	{
		Objective = KF_StoryGRI(GRI).GetCurrentObjective();
		if(Objective != none)
		{
			DrawString = Objective.HUD_Header.Header_Text;
		}
	}
	else
	{
		DrawString = WaveString @ (InvasionGameReplicationInfo(GRI).WaveNumber + 1);
	}

	Canvas.TextSize(DrawString, TextSizeX, TextSizeY);
	Canvas.SetPos(CenterX - (TextSizeX * 0.5f), CenterY + (SizeY * 0.15f));
	Canvas.DrawText(DrawString);
	
	//Draw Time
	DrawString = FormatTime(GRI.ElapsedTime);
	Canvas.TextSize(class'TurboHUDOverlay'.static.GetStringOfZeroes(Len(DrawString)), TextSizeX, TextSizeY);
	Canvas.SetPos(CenterX - (TextSizeX * 0.5f), CenterY + (SizeY * 0.35f));
	class'TurboHUDOverlay'.static.DrawCounterTextMeticulous(Canvas, DrawString, TextSizeX, 1.f);
}

static final function string GetCompressedNumber(int Number)
{
	local string Result;
	if (Number < 10000)
	{
		return string(Number);
	}
	else if (Number < 1000000)
	{
		Number = Number / 100;
		Result = string(Number);
		Result = Left(Result, Len(Result) - 1)$default.SeparatorCharacter$Right(Result, 1)$default.ThousandSuffix;
		return Result;
	}
	else
	{
		Number = Number / 100000;
		Result = string(Number);
		Result = Left(Result, Len(Result) - 1)$default.SeparatorCharacter$Right(Result, 1)$default.ThousandSuffix;
		return Result;
	}
}

simulated final function DrawPlayerEntry(Canvas Canvas, TurboPlayerReplicationInfo TurboPRI, float SizeY, float PositionY, bool bIsLocalPlayer, bool bIsFirstEntry)
{
	local float CenterX, CenterY;
	local float SizeX;
	local float TempX, TempY;
	local Material PerkIcon, PerkStarIcon;
	local float PerkX, PerkY, PerkStarSize;
	local int Index, StarCounter, NumStars;
	local float TextSizeX, TextSizeY;
	local string DrawText;

	CenterX = Canvas.ClipX * 0.5f;
	CenterY = PositionY + (SizeY * 0.5f);

	SizeX = (ScoreboardSize.X * Canvas.ClipX);
	
	TempX = CenterX - (SizeX * 0.5f);
	Canvas.DrawColor = ScoreboardBackplateColor;

	if (bIsLocalPlayer)
	{
		Canvas.DrawColor.A = 220;
	}

	Canvas.SetPos(int(TempX), PositionY);
	Canvas.DrawTileScaled(ScoreboardBackplate, ScoreboardSize.X * Canvas.ClipX / float(ScoreboardBackplate.USize), SizeY / float(ScoreboardBackplate.VSize));
	
	Canvas.DrawColor = Canvas.MakeColor(255, 255, 255, 32);
	Canvas.SetPos(TempX + 1.f, ((PositionY + SizeY) - 1.f) - (SizeY * 0.04f));
	Canvas.DrawTileScaled(ScoreboardBackplate, ((ScoreboardSize.X * Canvas.ClipX / float(ScoreboardBackplate.USize)) * FClamp((TurboPRI.PlayerHealth / TurboPRI.HealthMax), 0.f, 1.f)) * (((ScoreboardSize.X * Canvas.ClipX) - 2.f) / (ScoreboardSize.X * Canvas.ClipX)), (SizeY / float(ScoreboardBackplate.VSize)) * 0.04f);

	if (bIsLocalPlayer)
	{
		Canvas.DrawColor.A = 220;
	}
	else
	{
		Canvas.DrawColor.A = ScoreboardBackplateColor.A;
	}

	//Draw Perk
	TempX += SizeX * PerkIconOffsetX;
	if (Class<SRVeterancyTypes>(TurboPRI.ClientVeteranSkill) != None)
	{
		NumStars = Class<SRVeterancyTypes>(TurboPRI.ClientVeteranSkill).static.PreDrawPerk(Canvas, TurboPRI.ClientVeteranSkillLevel, PerkIcon, PerkStarIcon);

		Canvas.SetPos(int(TempX - (SizeX * PerkIconOffsetX)), PositionY);
		Canvas.DrawTileScaled(ScoreboardBackplateLeft, SizeY / float(ScoreboardBackplateLeft.USize), SizeY / float(ScoreboardBackplateLeft.VSize));

		Canvas.SetPos(TempX, CenterY - (SizeY * PerkIconSizeY * 0.5f));
		Canvas.DrawTile(PerkIcon, SizeY * PerkIconSizeY, SizeY * PerkIconSizeY, 0, 0, PerkIcon.MaterialUSize(), PerkIcon.MaterialVSize());

		StarCounter = 0;
		PerkStarSize = SizeY * PerkIconSizeY * 0.15f;
		PerkX = TempX + ((SizeY * PerkIconSizeY) - (PerkStarSize * 1.5f));
		PerkY = PositionY + (((SizeY * PerkIconSizeY) - (PerkStarSize * 0.5f)) * 0.75f);

		for ( Index = 0; Index < NumStars; Index++ )
		{
			Canvas.SetPos(PerkX, PerkY - (float(StarCounter) * SizeY * PerkIconSizeY * 0.15f));
			Canvas.DrawTileScaled(PerkStarIcon, PerkStarSize / float(PerkStarIcon.MaterialUSize()), PerkStarSize / float(PerkStarIcon.MaterialVSize()));
			StarCounter++;
		}
	}

	DrawText = "000";

	Canvas.Font = class'KFTurboFontHelper'.static.LoadFontStatic(2);
	Canvas.FontScaleX = 1.f;
	Canvas.FontScaleY = 1.f;
	Canvas.TextSize(DrawText, TextSizeX, TextSizeY);
	Canvas.FontScaleX = (SizeY * ScoreboardTextY) / TextSizeY;
	Canvas.FontScaleY = Canvas.FontScaleX;

	//Draw Name
	Canvas.DrawColor = ScoreboardTextColor;
	DrawText = Eval(Len(TurboPRI.PlayerName) > 15, Left(TurboPRI.PlayerName, 15), TurboPRI.PlayerName);
	Canvas.TextSize(DrawText, TextSizeX, TextSizeY);
	TempX = (CenterX - (SizeX * 0.5f)) + (SizeX * UsernameOffsetX);
	TempY = CenterY;
	Canvas.SetPos(TempX, CenterY - (TextSizeY * 0.5f));
	Canvas.DrawText(DrawText);

	//Draw Kills
	TempX = (CenterX - (SizeX * 0.5f)) + (SizeX * KillsOffsetX);
	TempY = CenterY - (SizeY * KillSizeY * 0.5f);

	if (bIsFirstEntry)
	{
		Canvas.DrawColor = KillIconColor;
		Canvas.SetPos(TempX - (SizeY * KillSizeY * 0.5f), (TempY - (SizeY * 0.5f)) - (SizeY * KillSizeY * 0.5f));
		Canvas.DrawTileScaled(KillIcon, (SizeY * KillSizeY) / float(KillIcon.USize), (SizeY * KillSizeY) / float(KillIcon.VSize));
	}

	Canvas.DrawColor = ScoreboardTextColor;
	DrawText = string(TurboPRI.Kills);
	Canvas.TextSize(class'TurboHUDOverlay'.static.GetStringOfZeroes(Len(DrawText)), TextSizeX, TextSizeY);
	Canvas.SetPos(TempX - (TextSizeX * 0.5f), CenterY - (TextSizeY * 0.5f));
	class'TurboHUDOverlay'.static.DrawCounterTextMeticulous(Canvas, DrawText, TextSizeX, 1.f);

	Canvas.DrawColor.A = 120;
	DrawText = " ("$TurboPRI.KillAssists$")";
	TempX += (TextSizeX * 0.5f);
	Canvas.TextSize(class'TurboHUDOverlay'.static.GetStringOfZeroes(Len(DrawText)), TextSizeX, TextSizeY);
	Canvas.SetPos(TempX, CenterY - (TextSizeY * 0.5f));
	class'TurboHUDOverlay'.static.DrawCounterTextMeticulous(Canvas, DrawText, TextSizeX, 1.f);

	//Draw Health
	TempX = (CenterX - (SizeX * 0.5f)) + (SizeX * HealthOffsetX);
	TempY = CenterY - (SizeY * HealthSizeY * 0.5f);
	
	if (bIsFirstEntry)
	{
		Canvas.DrawColor = HealthIconColor;
		Canvas.SetPos(TempX - (SizeY * HealthSizeY * 0.5f), (TempY - (SizeY * 0.5f)) - (SizeY * HealthSizeY * 0.5f));
		Canvas.DrawTileScaled(HealthIcon, (SizeY * HealthSizeY) / float(HealthIcon.USize), (SizeY * HealthSizeY) / float(HealthIcon.VSize));
	}

	Canvas.DrawColor = ScoreboardTextColor;
	DrawText = string(TurboPRI.PlayerHealth)$HealthyString;
	Canvas.TextSize(class'TurboHUDOverlay'.static.GetStringOfZeroes(Len(DrawText)), TextSizeX, TextSizeY);
	Canvas.SetPos(TempX - (TextSizeX * 0.5f), CenterY - (TextSizeY * 0.5f));
	class'TurboHUDOverlay'.static.DrawCounterTextMeticulous(Canvas, DrawText, TextSizeX, 1.f);

	//Draw Healing
	TempX = (CenterX - (SizeX * 0.5f)) + (SizeX * HealedHealthOffsetX);
	TempY = CenterY - (SizeY * HealedHealthSizeY * 0.5f);
	
	if (bIsFirstEntry)
	{
		Canvas.DrawColor = HealedHealthIconColor;
		Canvas.SetPos(TempX - (SizeY * HealedHealthSizeY * 0.5f), (TempY - (SizeY * 0.5f)) - (SizeY * HealedHealthSizeY * 0.5f));
		Canvas.DrawTileScaled(HealedHealthIcon, (SizeY * HealedHealthSizeY) / float(HealedHealthIcon.USize), (SizeY * HealedHealthSizeY) / float(HealedHealthIcon.VSize));
	}

	Canvas.DrawColor = ScoreboardTextColor;
	DrawText = GetCompressedNumber(TurboPRI.HealthHealed);

	Canvas.TextSize(class'TurboHUDOverlay'.static.GetStringOfZeroes(Len(DrawText)), TextSizeX, TextSizeY);
	Canvas.SetPos(TempX - (TextSizeX * 0.5f), CenterY - (TextSizeY * 0.5f));
	class'TurboHUDOverlay'.static.DrawCounterTextMeticulous(Canvas, DrawText, TextSizeX, 1.f);

	//Draw Cash
	TempX = (CenterX - (SizeX * 0.5f)) + (SizeX * CashOffsetX);
	TempY = CenterY - (SizeY * CashSizeY * 0.5f);
	
	if (bIsFirstEntry)
	{
		Canvas.DrawColor = CashIconColor;
		Canvas.SetPos(TempX - (SizeY * CashSizeY * 0.5f), (TempY - (SizeY * 0.5f)) - (SizeY * CashSizeY * 0.5f));
		Canvas.DrawTileScaled(CashIcon, (SizeY * CashSizeY) / float(CashIcon.USize), (SizeY * CashSizeY) / float(CashIcon.VSize));
	}
	
	Canvas.DrawColor = ScoreboardTextColor;
	DrawText = GetCompressedNumber(TurboPRI.Score) $ class'KFTab_BuyMenu'.default.MoneyCaption;
	Canvas.TextSize(class'TurboHUDOverlay'.static.GetStringOfZeroes(Len(DrawText)), TextSizeX, TextSizeY);
	Canvas.SetPos(TempX - (TextSizeX * 0.5f), CenterY - (TextSizeY * 0.5f));
	class'TurboHUDOverlay'.static.DrawCounterTextMeticulous(Canvas, DrawText, TextSizeX, 1.f);

	//Draw Ping
	TempX = (CenterX - (SizeX * 0.5f)) + (SizeX * PingOffsetX);
	TempY = CenterY - (SizeY * PingSizeY * 0.5f);
	
	if (bIsFirstEntry)
	{
		Canvas.DrawColor = PingIconColor;
		Canvas.SetPos(TempX - (SizeY * PingSizeY * 0.5f), (TempY - (SizeY * 0.5f)) - (SizeY * PingSizeY * 0.5f));
		Canvas.DrawTileScaled(PingIcon, (SizeY * PingSizeY) / float(PingIcon.USize), (SizeY * PingSizeY) / float(PingIcon.VSize));
	}

	Canvas.DrawColor = ScoreboardTextColor;
	DrawText = Eval(TurboPRI.bBot, Eval(BotText != "", BotText, "BOT"), string(Min(TurboPRI.Ping * 4, 999)));
	Canvas.TextSize(class'TurboHUDOverlay'.static.GetStringOfZeroes(Len(DrawText)), TextSizeX, TextSizeY);
	Canvas.SetPos(TempX - (TextSizeX * 0.5f), CenterY - (TextSizeY * 0.5f));
	class'TurboHUDOverlay'.static.DrawCounterTextMeticulous(Canvas, DrawText, TextSizeX, 1.f);

	if (TurboPRI.bAdmin)
	{
		DrawText = Eval(AdminText != "", AdminText, "ADMIN");

		Canvas.DrawColor = Canvas.MakeColor(255, 0, 0, 255);
		Canvas.FontScaleX = 1.f;
		Canvas.FontScaleY = 1.f;
		Canvas.Font = class'KFTurboFontHelper'.static.LoadFontStatic(6);
		Canvas.TextSize(DrawText, TextSizeX, TextSizeY);
		Canvas.FontScaleX = (SizeY * 0.5f) / TextSizeY;
		Canvas.FontScaleY = Canvas.FontScaleX;
		Canvas.TextSize(DrawText, TextSizeX, TextSizeY);
		Canvas.SetPos(TempX - (TextSizeX * 0.5f), PositionY - (TextSizeY * 0.5f));
		Canvas.DrawText(DrawText);
	}
}

defaultproperties
{
	ScoreboardHeaderSize=(X=0.6f,Y=0.1f)
	ScoreboardSize=(X=0.5f,Y=0.6f)
	ScoreboardBackplateColor=(R=24,G=24,B=24,A=160)
	ScoreboardBackplate=Texture'KFTurbo.Scoreboard.ScoreboardBackplate_D'
	ScoreboardBackplateLeftColor=(R=4,G=4,B=4,A=220)
	ScoreboardBackplateLeft=Texture'KFTurbo.Scoreboard.ScoreboardBackplateLeft_D'

	ScoreboardTextY=0.75f
	ScoreboardTextColor=(R=255,G=255,B=255,A=220)

	PerkIconOffsetX=0.005f
	PerkIconSizeY=1.f
	
	UsernameSizeY=0.8f
	UsernameOffsetX=0.0525f

	HealthOffsetX=0.275f
	HealthSizeY=0.75f
	HealthIconColor=(R=16,G=16,B=16,A=200)
	HealthIcon=Texture'KFTurbo.Scoreboard.ScoreboardHealth_D'

	HealedHealthOffsetX=0.625f
	HealedHealthSizeY=0.75f
	HealedHealthIconColor=(R=16,G=16,B=16,A=200)
	HealedHealthIcon=Texture'KFTurbo.Scoreboard.ScoreboardHealed_D'

	KillsOffsetX=0.45f
	KillSizeY=0.75f
	KillIconColor=(R=16,G=16,B=16,A=200)
	KillIcon=Texture'KFTurbo.Scoreboard.ScoreboardKill_D'

	CashOffsetX=0.8f
	CashSizeY=0.75f
	CashIconColor=(R=16,G=16,B=16,A=200)
	CashIcon=Texture'KFTurbo.Scoreboard.ScoreboardCash_D'

	PingOffsetX = 0.975f
	PingSizeY = 0.75f
	PingIconColor=(R=16,G=16,B=16,A=200)
	PingIcon=Texture'KFTurbo.Scoreboard.ScoreboardPing_D'

	
	ThousandSuffix="K"
	MillionSuffix="M"
	SeparatorCharacter="."
}