//Killing Floor Turbo TurboHUDKillingFloor
//KFTurbo's HUD. Leverages TurboHUDOverlays for most of the UI elements.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHUDKillingFloor extends TurboHUDKillingFloorBase;

var Sound WinSound, LoseSound;
var float EndGameHUDAnimationDuration;
var Material EndGameHUDMaterial;
var bool bHasInitializedEndGameHUD;
var float EndGameHUDAnimationProgress;

var bool bSortedEmoteList;
var bool bUseBaseGameFontForChat;

var class<TurboHUDOverlay> PlayerInfoHUDClass;
var TurboHUDOverlay PlayerInfoHUD;

var class<TurboHUDWaveInfo> WaveInfoHUDClass;
var TurboHUDWaveInfo WaveInfoHUD;

var class<TurboHUDOverlay> PlayerHUDClass;
var TurboHUDOverlay PlayerHUD;

var class<TurboHUDOverlay> MarkInfoHUDClass;
var TurboHUDOverlay MarkInfoHUD;

var class<TurboHUDOverlay> WaveStatsHUDClass;
var TurboHUDOverlay WaveStatsHUD;

var class<TextReactionSettings> TextReactionSettingsClass;
var TextReactionSettings TextReactionSettings;

//Overlays that are drawn before the player HUD but after victory/game over HUD.
var array<HudOverlay> PreDrawOverlays;

var Texture MerchantPortrait;
var localized string MerchantString;

var(Turbo) Plane InvactiveModulate;
var(Turbo) Plane ActiveModulate;

simulated function Destroyed()
{
	Super.Destroyed();

	CleanupFontPackage();
}

simulated event PostRender(Canvas Canvas)
{
	ResScaleX = Canvas.SizeX / 640.0;
	ResScaleY = Canvas.SizeY / 480.0;

	BuildMOTD();
	LinkActors();

	CheckCountDown(PlayerOwner.GameReplicationInfo);

	if (bHideHud)
	{
		Canvas.ColorModulate = InvactiveModulate;
		return;
	}
	
	bUseBloom = bool(ConsoleCommand("get ini:Engine.Engine.ViewportManager Bloom"));

	CalculateModulation();
	Canvas.ColorModulate = ActiveModulate;

	PlayerOwner.PostFX_SetActive(0, false);

	if (PawnOwner != None && PawnOwner.bSpecialHUD)
	{
		PawnOwner.DrawHud(Canvas); //As far as I can tell, this is never implemented.
	}

	if (bShowDebugInfo)
	{
		ShowDebugInfo(Canvas);
	}
	else
	{
		if (PlayerOwner == None || PawnOwner == None || PawnOwnerPRI == None || (PlayerOwner.IsSpectating() && PlayerOwner.bBehindView))
		{
			DrawSpectatingHud(Canvas);
		}
		else if (!PawnOwner.bHideRegularHUD)
		{
			DrawHud(Canvas); 
		}

		RenderHUDOverlays(Canvas);

		if (!DrawLevelAction(Canvas))
		{
			if ( PlayerOwner != None )
			{
				if ( PlayerOwner.ProgressTimeOut > Level.TimeSeconds )
				{
					DisplayProgressMessages(Canvas);
				}
				else if ( MOTDState == 1 )
				{
					MOTDState=2;
				}
			}
		}

		if ( bShowBadConnectionAlert )
		{
			DisplayBadConnectionAlert(Canvas);
		}

		DisplayMessages(Canvas);

		if ( bShowVoteMenu && VoteMenu != None )
		{
			VoteMenu.RenderOverlays(Canvas);
		}
	}

	PlayerOwner.RenderOverlays(Canvas);

	if (PlayerConsole != None && PlayerConsole.bTyping)
	{
		DrawTypingPrompt(Canvas, PlayerConsole.TypedStr, PlayerConsole.TypedStrPos);
	}

	if (bDrawHint && !bHideHud)
	{
	    DrawHint(Canvas);
	}

	HudLastRenderTime = Level.TimeSeconds;

	OnPostRender(Self, Canvas);

	if (bUseBloom)
	{
		PlayerOwner.PostFX_SetActive(0, bUseBloom);
	}
}

simulated final function ShowDebugInfo(Canvas Canvas)
{
	local float XPos, YPos;

	Canvas.Font = GetConsoleFont(Canvas);
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = ConsoleColor;

	PlayerOwner.ViewTarget.DisplayDebug(Canvas, XPos, YPos);
	if  (PlayerOwner.ViewTarget != PlayerOwner && (Pawn(PlayerOwner.ViewTarget) == None ||
			Pawn(PlayerOwner.ViewTarget).Controller == None) )
	{
		YPos += XPos * 2;
		Canvas.SetPos(4, YPos);
		Canvas.DrawText("----- VIEWER INFO -----");
		YPos += XPos;
		Canvas.SetPos(4, YPos);
		PlayerOwner.DisplayDebug(Canvas, XPos, YPos);
	}
}

simulated final function RenderHUDOverlays(Canvas Canvas)
{
	local int Index;

	for (Index = 0; Index < Overlays.length; Index++)
	{
		Overlays[Index].Render(Canvas);
	}
}

simulated function CalculateModulation()
{
	local float Brightness;
	local float Gamma;
	local float Multiplier;

	ActiveModulate = default.ActiveModulate;
	if (PlayerOwner == None || !bool(PlayerOwner.ConsoleCommand("ISFULLSCREEN")))
	{
		return;
	}

	Multiplier = 1.f;

	Brightness = float(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.ViewportManager Brightness"));

	if (Brightness > 0.5f)
	{
		Multiplier *= Lerp((Brightness - 0.5f) * 2.f, 1.f, 0.5f); 
	}
	
	Gamma = float(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.ViewportManager Gamma"));

	if (Gamma > 1.f)
	{
		Multiplier *= Lerp((Gamma - 1.f), 1.f, 0.5f); 
	}

	Multiplier = FMax(Multiplier, 0.6f);
	
	ActiveModulate.X *= Multiplier;
	ActiveModulate.Y *= Multiplier;
	ActiveModulate.Z *= Multiplier;
}

simulated function ReduceModulation(Canvas C, float Interpolation)
{
	C.ColorModulate.X = Lerp(Interpolation, C.ColorModulate.X, 1.f);
	C.ColorModulate.Y = Lerp(Interpolation, C.ColorModulate.Y, 1.f);
	C.ColorModulate.Z = Lerp(Interpolation, C.ColorModulate.Z, 1.f);
}

//Adds overlay that will draw under the player HUD.
//Helpful for stuff like Card Game where it doesn't want to draw on top of other HUD widgets.
simulated function AddPreDrawOverlay(HudOverlay Overlay)
{
	local int i;

	for (i = 0; i < PreDrawOverlays.Length; i++)
	{
		if (PreDrawOverlays[i] == Overlay)
		{
			return;
		}
	}

	PreDrawOverlays[PreDrawOverlays.length] = Overlay;
	Overlay.SetOwner(self);
}

simulated function RemoveHudOverlay(HudOverlay Overlay)
{
	local int i;
	Super.RemoveHudOverlay(Overlay);

	for (i = 0; i < PreDrawOverlays.length; i++)
	{
		if (PreDrawOverlays[i] == Overlay)
		{
			Overlays.Remove(i, 1);
			Overlay.SetOwner(None);
			return;
		}
	}
}

simulated function RenderPreDrawOverlays(Canvas C)
{
	local int i;
	for (i = 0; i < PreDrawOverlays.length; i++)
	{
		PreDrawOverlays[i].Render(C);
	}
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (PlayerInfoHUDClass == None)
	{
		PlayerInfoHUDClass = class'TurboHUDPlayerInfo';
	}

	if (WaveInfoHUDClass == None)
	{
		WaveInfoHUDClass = class'TurboHUDWaveInfo';
	}

	if (PlayerHUDClass == None)
	{
		PlayerHUDClass = class'TurboHUDPlayer';
	}

	if (MarkInfoHUDClass == None)
	{
		MarkInfoHUDClass = class'TurboHUDMarkInfo';
	}

	if (WaveStatsHUDClass == None)
	{
		WaveStatsHUDClass = class'TurboHUDWaveStats';
	}

	PlayerInfoHUD = Spawn(PlayerInfoHUDClass, Self);
	PlayerInfoHUD.Initialize(Self);
	
	WaveInfoHUD = Spawn(WaveInfoHUDClass, Self);
	WaveInfoHUD.Initialize(Self);

	PlayerHUD = Spawn(PlayerHUDClass, Self);
	PlayerHUD.Initialize(Self);

	MarkInfoHUD = Spawn(MarkInfoHUDClass, Self);
	MarkInfoHUD.Initialize(Self);
	
	WaveStatsHUD = Spawn(WaveStatsHUDClass, Self);
	WaveStatsHUD.Initialize(Self);

	if (TextReactionSettingsClass != None)
	{
		TextReactionSettings = Spawn(TextReactionSettingsClass, Self);
		TextReactionSettings.Initialize(Self);
	}

	bUseBaseGameFontForChat = class'TurboInteraction'.static.ShouldUseBaseGameFontForChat(TurboPlayerController(PlayerOwner));
	SetFontLocale(class'TurboInteraction'.static.GetFontLocale(TurboPlayerController(PlayerOwner)));
}

simulated function SetScoreBoardClass(class<Scoreboard> ScoreBoardClass)
{
	if (ScoreBoardClass == class'KFScoreBoard' || ScoreBoardClass == class'SRScoreBoard')
	{
		ScoreBoardClass = class'TurboHUDScoreboard';
	}

	Super.SetScoreboardClass(ScoreBoardClass);
}

simulated function Tick(float DeltaTime)
{
	if( ClientRep == None )
	{
		ClientRep = Class'ClientPerkRepLink'.Static.FindStats(PlayerOwner);

		if( ClientRep != None )
		{
			SmileyMsgs = ClientRep.SmileyTags;
		}
	}

	if( bDisplayingProgress )
	{
		bDisplayingProgress = false;
		if( VisualProgressBar<LevelProgressBar )
		{
			VisualProgressBar = FMin(VisualProgressBar+DeltaTime,LevelProgressBar);
		}
		else if( VisualProgressBar>LevelProgressBar )
		{
			VisualProgressBar = FMax(VisualProgressBar-DeltaTime,LevelProgressBar);
		}
	}

	Super(HUD_StoryMode).Tick(DeltaTime);

	if (bHasInitializedEndGameHUD)
	{
		EndGameHUDAnimationProgress += DeltaTime;
	}

	if (!bSortedEmoteList)
	{
		bSortedEmoteList = true;
	}
}

simulated function DrawHud(Canvas C)
{
	local KFGameReplicationInfo CurrentGame;
	if (bHideHud)
	{
		return;
	}

	RenderDelta = Level.TimeSeconds - LastHUDRenderTime;
    LastHUDRenderTime = Level.TimeSeconds;

	ResetCanvas(C);

	if (!KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bViewingMatineeCinematic)
	{
		CurrentGame = KFGameReplicationInfo(Level.GRI);
		if (CurrentGame != None && CurrentGame.EndGameType > 0)
		{
			DrawEndGameHUD(C, (CurrentGame.EndGameType==2));
		}
	}

	ResetCanvas(C);

	RenderPreDrawOverlays(C);
	
	ResetCanvas(C);

	if (FontsPrecached < 2)
	{
		PrecacheFonts(C);
	}

	if (!KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bViewingMatineeCinematic)
	{
		DrawGameHud(C);
	}
	else
	{
		DrawCinematicHUD(C);
	}

	ResetCanvas(C);

	if ( bShowNotification )
	{
		DrawPopupNotification(C);
	}
}

simulated function DrawGameHud(Canvas C)
{
	local KFGameReplicationInfo CurrentGame;
	local Plane Modulation;

	if ( bShowTargeting )
	{
		DrawTargeting(C);
	}

	if (MarkInfoHUD != None)
	{
		MarkInfoHUD.Render(C);
	}

	if (PlayerInfoHUD != None)
	{
		PlayerInfoHUD.Render(C);
	}

	DrawDamageIndicators(C);
	DrawHudPassA(C);
	DrawHudPassC(C);

	if ( KFPlayerController(PlayerOwner) != None && KFPlayerController(PlayerOwner).ActiveNote != None )
	{
		if( PlayerOwner.Pawn == none )
		{
			KFPlayerController(PlayerOwner).ActiveNote = None;
		}
		else
		{
			KFPlayerController(PlayerOwner).ActiveNote.RenderNote(C);
		}
	}

	Modulation = C.ColorModulate;
	DisplayLocalMessages(C);
	C.ColorModulate = Modulation;

	CurrentGame = KFGameReplicationInfo(Level.GRI);
	if (CurrentGame != None && CurrentGame.EndGameType > 0)
	{
		return;
	}
	
	DrawKFHUDTextElements(C);
}

simulated function DrawKFHUDTextElements(Canvas C)
{
	local vector Pos, FixedZPos;
	local rotator  ShopDirPointerRotation;

	if ( PlayerOwner == none || KFGRI == none || !KFGRI.bMatchHasBegun )
	{
		return;
	}

	ResetCanvas(C);

	if (WaveInfoHUD != None)
	{
		WaveInfoHUD.Render(C);
	}

	ResetCanvas(C);

	if ( KFPRI == none || KFPRI.Team == none || KFPRI.bOnlySpectator || PawnOwner == none )
	{
		return;
	}

	// Draw the shop pointer
	if ( ShopDirPointer == None )
	{
		ShopDirPointer = Spawn(Class'KFShopDirectionPointer');
		ShopDirPointer.bHidden = bHideHud;
	}

	Pos.X = C.SizeX / 18.0;
	Pos.Y = C.SizeX / 18.0;
	Pos = PlayerOwner.Player.Console.ScreenToWorld(Pos) * 10.f * (PlayerOwner.default.DefaultFOV / PlayerOwner.FovAngle) + PlayerOwner.CalcViewLocation;
	ShopDirPointer.SetLocation(Pos);

	if ( KFGRI.CurrentShop != none )
	{
		// Let's check for a real Z difference (i.e. different floor) doesn't make sense to rotate the arrow
		// only because the trader is a midget or placed slightly wrong
		if ( KFGRI.CurrentShop.Location.Z > PawnOwner.Location.Z + 50.f || KFGRI.CurrentShop.Location.Z < PawnOwner.Location.Z - 50.f )
		{
		    ShopDirPointerRotation = rotator(KFGRI.CurrentShop.Location - PawnOwner.Location);
		}
		else
		{
		    FixedZPos = KFGRI.CurrentShop.Location;
		    FixedZPos.Z = PawnOwner.Location.Z;
		    ShopDirPointerRotation = rotator(FixedZPos - PawnOwner.Location);
		}
	}
	else
	{
		ShopDirPointer.bHidden = true;
		return;
	}

   	ShopDirPointer.SetRotation(ShopDirPointerRotation);

	if ( Level.TimeSeconds > Hint_45_Time && Level.TimeSeconds < Hint_45_Time + 2 )
	{
		if ( KFPlayerController(PlayerOwner) != none )
		{
			KFPlayerController(PlayerOwner).CheckForHint(45);
		}
	}

	C.DrawActor(None, False, True); // Clear Z.
	ShopDirPointer.bHidden = false;
	C.DrawActor(ShopDirPointer, False, false);
	ShopDirPointer.bHidden = true;
	DrawTurboTraderDistance(C);
}

simulated function DrawModOverlay(Canvas C) {}

simulated function DrawSpectatingHud(Canvas C)
{
	local KFGameReplicationInfo CurrentGame;

	if (bHideHud)
	{
		return;
	}
	
	ResetCanvas(C);

	CurrentGame = KFGameReplicationInfo(Level.GRI);
	if (CurrentGame != None && CurrentGame.EndGameType > 0)
	{
		DrawEndGameHUD(C, CurrentGame.EndGameType == 2);

		if (CurrentGame.EndGameType == 2)
		{
			DrawStoryHUDInfo(C);
		}
	}
	
	ResetCanvas(C);

	RenderPreDrawOverlays(C);

	ResetCanvas(C);

	if (MarkInfoHUD != None)
	{
		MarkInfoHUD.Render(C);
	}

	if (PlayerInfoHUD != None)
	{
		PlayerInfoHUD.Render(C);
	}

	if (WaveInfoHUD != None)
	{
		WaveInfoHUD.Render(C);
	}

	if (KFPlayerController(PlayerOwner) != None && KFPlayerController(PlayerOwner).ActiveNote != None)
	{
		KFPlayerController(PlayerOwner).ActiveNote = None;
	}

	if (CurrentGame != none && CurrentGame.EndGameType == 2)
	{
		return;
	}

	DrawKFHUDTextElements(C);
	DisplayLocalMessages(C);

	if ( bShowScoreBoard && ScoreBoard != None )
	{
		ScoreBoard.DrawScoreboard(C);
	}

	ReduceModulation(C, 0.5f);
	if ( bShowPortrait && Portrait != None )
	{
		DrawPortraitX(C);
	}
	C.ColorModulate = ActiveModulate;
	
	if ( bDrawHint )
	{
		DrawHint(C);
	}
	
	DrawStoryHUDInfo(C);
}


simulated final function DrawTurboTraderDistance(Canvas C)
{
	local int       FontSize;
	local float     StrWidth, StrHeight;
	local string    TraderDistanceText;

	if (PawnOwner == None || KFGRI == None)
	{
		return;
	}

	if ( KFGRI.CurrentShop != none )
	{
		TraderDistanceText = int(VSize(KFGRI.CurrentShop.Location - PawnOwner.Location) / 50) $ DistanceUnitString;
	}
	else
	{
		return;
	}

	if ( C.ClipX <= 800 )
	{
		FontSize = 7;
	}
	else if ( C.ClipX <= 1024 )
	{
		FontSize = 6;
	}
	else if ( C.ClipX <= 1280 )
	{
		FontSize = 5;
	}
	else
	{
		FontSize = 4;
	}

	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = LoadFont(FontSize);
	C.SetDrawColor(255, 255, 255, 200);
	C.StrLen(class'TurboHUDOverlay'.static.GetStringOfZeroes(Len(TraderDistanceText)), StrWidth, StrHeight);
	C.SetPos((C.SizeX / 18.0) - ((StrWidth + float((Len(TraderDistanceText) - 1) * 4)) / 2.0), C.SizeX / 10.0);
	class'TurboHUDOverlay'.static.DrawTextMeticulous(C, TraderDistanceText, StrWidth + float((Len(TraderDistanceText) - 1) * 4));
}

simulated function DrawEndGameHUD(Canvas C, bool bVictory)
{
	local float YScalar, XScalar, FadeAlpha, ScaleAlpha;

	InitializeEndGameUI(bVictory);

	ResetCanvas(C);

	FadeAlpha = FMin(EndGameHUDAnimationProgress / (EndGameHUDAnimationDuration * 0.5f), 1.f);
	ScaleAlpha = FMin(EndGameHUDAnimationProgress / EndGameHUDAnimationDuration, 1.f);

	YScalar = FClamp(C.ClipY, 256, 2056) * Lerp(1.f - Square(Square(ScaleAlpha - 1.f)), 0.9f, 1.f); //Scale is based on screen Y size.
	XScalar = YScalar * 2.f;

	C.DrawColor.A = Lerp(FadeAlpha, 0, 255);

	C.CurX = C.ClipX / 2 - XScalar / 2;
	C.CurY = C.ClipY / 2 - YScalar / 2;

	C.DrawTile(EndGameHUDMaterial, XScalar, YScalar, 0, 0, 2048, 1024);

	if ( bShowScoreBoard && ScoreBoard != None )
	{
		ScoreBoard.DrawScoreboard(C);
	}
}

simulated function InitializeEndGameUI(bool bVictory)
{
	if (bHasInitializedEndGameHUD)
	{
		return;
	}

	bHasInitializedEndGameHUD = true;

	if ( bVictory )
	{
		EndGameHUDMaterial = Texture'KFTurbo.EndGame.You_Won_D';
		PlayerOwner.PlaySound(WinSound, SLOT_None, 255.0,,,, false);
	}
	else
	{
		EndGameHUDMaterial = Texture'KFTurbo.EndGame.You_Died_D';
		PlayerOwner.PlaySound(LoseSound, SLOT_None, 255.0,,,, false);
	}
}

simulated function DrawHudPassA(Canvas C)
{	
	DrawStoryHUDInfo(C);

	DrawDoorHealthBars(C);

	if (KFPlayerReplicationInfo(PawnOwnerPRI) != None && Class<SRVeterancyTypes>(KFPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill) != None)
	{
		Class<SRVeterancyTypes>(KFPlayerReplicationInfo(PawnOwnerPRI).ClientVeteranSkill).static.SpecialHUDInfo(KFPlayerReplicationInfo(PawnOwnerPRI), C);
	}

	if ( Level.TimeSeconds - LastVoiceGainTime < 0.333 )
	{
		if ( !bUsingVOIP && PlayerOwner != None && PlayerOwner.ActiveRoom != None &&
			 PlayerOwner.ActiveRoom.GetTitle() == "Team" )
		{
			bUsingVOIP = true;
			PlayerOwner.NotifySpeakingInTeamChannel();
		}

		DisplayVoiceGain(C);
	}
	else
	{
		bUsingVOIP = false;
	}

	if ( bDisplayInventory || bInventoryFadingOut )
	{
		C.Style = ERenderStyle.STY_Normal;
		DrawInventory(C);

		ResetCanvas(C);
	}

	if (PlayerHUD != None)
	{
		PlayerHUD.Render(C);
	}

	if (WaveStatsHUD != None)
	{
		WaveStatsHUD.Render(C);
	}
}

simulated function DrawHudPassC(Canvas C)
{
	if (bShowScoreBoard && ScoreBoard != None)
	{
		ScoreBoard.DrawScoreboard(C);
	}
	
	ResetCanvas(C);
	
	ReduceModulation(C, 0.5f);
	if (bShowPortrait && (Portrait != None))
	{
		DrawPortraitX(C);
	}
	C.ColorModulate = ActiveModulate;
	
	ResetCanvas(C);
}

simulated final function float GetTextMessageLifeTime(string M, class<LocalMessage> MessageClass, PlayerReplicationInfo PRI)
{
	//Player messages should last a lil longer.
	if (class<SayMessagePlus>(MessageClass) != None)
	{
		return float(MessageClass.Default.LifeTime) * 1.5f;
	}

	return MessageClass.Default.LifeTime;
}

function AddTextMessage(string M, class<LocalMessage> MessageClass, PlayerReplicationInfo PRI)
{
	local int i;

	if (TextReactionSettings != None)
	{
		TextReactionSettings.ReceivedMessage(TurboPlayerController(PlayerOwner), M, MessageClass, PRI);
	}

	if( bMessageBeep && MessageClass.Default.bBeep )
	{
		PlayerOwner.PlayBeepSound();
	}

    for( i=0; i<ConsoleMessageCount; i++ )
    {
        if ( TextMessages[i].Text == "" )
		{
            break;
		}
    }

    if( i == ConsoleMessageCount )
    {
        for( i=0; i<ConsoleMessageCount-1; i++ )
		{
            TextMessages[i] = TextMessages[i+1];
		}
    }

	TextMessages[i].Text = M;
	TextMessages[i].MessageLife = Level.TimeSeconds + GetTextMessageLifeTime(M, MessageClass, PRI);
	TextMessages[i].TextColor = MessageClass.static.GetConsoleColor(PRI);

	if(MessageClass==class'SayMessagePlus' || MessageClass == class'TeamSayMessagePlus')
	{
		TextMessages[i].PRI = PRI;
	}
	else
	{
		TextMessages[i].PRI = None;
	}
}

//Added drop shadow.
function DisplayMessages(Canvas C)
{
	local int i, j, XPos, YPos,MessageCount;
	local float XL, YL, XXL, YYL;
	local float InitialClip;
	InitialClip = C.ClipX;
	C.ClipX = C.SizeX;

	for( i = 0; i < ConsoleMessageCount; i++ )
	{
		if ( TextMessages[i].Text == "" )
			break;
		else if( TextMessages[i].MessageLife < Level.TimeSeconds )
		{
			TextMessages[i].Text = "";

			if( i < ConsoleMessageCount - 1 )
			{
				for( j=i; j<ConsoleMessageCount-1; j++ )
					TextMessages[j] = TextMessages[j+1];
			}
			TextMessages[j].Text = "";
			break;
		}
		else
			MessageCount++;
	}

	YPos = (ConsoleMessagePosY * HudCanvasScale * C.SizeY) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeY);
	if ( PlayerOwner == none || PlayerOwner.PlayerReplicationInfo == none || !PlayerOwner.PlayerReplicationInfo.bWaitingPlayer )
	{
		XPos = (ConsoleMessagePosX * HudCanvasScale * C.SizeX) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeX);
	}
	else
	{
		XPos = (0.005 * HudCanvasScale * C.SizeX) + (((1.0 - HudCanvasScale) / 2.0) * C.SizeX);
	}

	if (bUseBaseGameFontForChat)
	{
		C.Font = GetDefaultConsoleFont(C);
	}
	else
	{
		C.Font = GetChatFont(C);
	}
	C.DrawColor = LevelActionFontColor;

	C.TextSize ("A", XL, YL);

	YPos -= YL * MessageCount+1; // DP_LowerLeft
	YPos -= YL; // Room for typing prompt

	for( i=0; i<MessageCount; i++ )
	{
		if ( TextMessages[i].Text == "" )
		{
			break;
		}

		C.DrawColor = C.MakeColor(0, 0, 0, 120);
		C.SetPos(XPos + 2.f, YPos + 2.f);
		if( TextMessages[i].PRI!=None )
		{
			XL = Class'SRScoreBoard'.Static.DrawCountryName(C,TextMessages[i].PRI,XPos + 2.f,YPos + 2.f);
			C.SetPos( XPos + XL + 2.f, YPos + 2.f );
		}

		if( SmileyMsgs.Length!=0 )
		{
			DrawScaledSmileyText(class'GUIComponent'.static.StripColorCodes(TextMessages[i].Text),C,,YYL);
		}
		else
		{
			C.DrawText(class'GUIComponent'.static.StripColorCodes(TextMessages[i].Text),false);
		}

		C.DrawColor = C.MakeColor(255, 255, 255, 255);
		YYL = 0;
		XXL = 0;
		
		C.SetPos(XPos, YPos);
		if( TextMessages[i].PRI!=None )
		{
			XL = Class'SRScoreBoard'.Static.DrawCountryName(C,TextMessages[i].PRI,XPos,YPos);
			C.SetPos( XPos+XL, YPos );
		}

		if( SmileyMsgs.Length!=0 )
		{
			DrawScaledSmileyText(TextMessages[i].Text,C,,YYL);
		}
		else
		{
			C.DrawText(TextMessages[i].Text,false);
		}
		YPos += (YL+YYL);
	}
	
	C.ClipX = InitialClip;
}

simulated function DrawTypingPrompt(Canvas C, String Text, optional int Pos)
{
    local float XPos, YPos;
    local float XL, YL;
	local string PromptText;
	
	if (bUseBaseGameFontForChat)
	{
		C.Font = GetDefaultConsoleFont(C);
	}
	else
	{
		C.Font = GetChatFont(C);
	}

    C.Style = ERenderStyle.STY_Alpha;

    C.TextSize("A", XL, YL);

    XPos = (ConsoleMessagePosX * HudCanvasScale * C.SizeX) + (((1.0 - HudCanvasScale) * 0.5) * C.SizeX);
    YPos = (ConsoleMessagePosY * HudCanvasScale * C.SizeY) + (((1.0 - HudCanvasScale) * 0.5) * C.SizeY) - YL;

	PromptText = "(>"@Left(Text, Pos)$chr(4)$Eval(Pos < Len(Text), Mid(Text, Pos), "_");

    C.SetDrawColor(0, 0, 0, 120);
    C.SetPos(XPos + 2.f, YPos + 2.f);
    C.DrawTextClipped(PromptText, true);
    C.SetDrawColor(255, 255, 255, 255);
    C.SetPos(XPos, YPos);
    C.DrawTextClipped(PromptText, true);

	if (Pos >= Len(Text))
	{
		DrawEmoteHintPrompt(C, Text, XPos, YPos);
	}
}

//Returns index where the emote starts in the string. Returns -1 if no emote was present.
static final function int CheckEmotePrompt(string EmoteText)
{
	local int Index, StringSize;
	local int ColonCount, LastColonIndex;
	local string Char;
	local bool bIsSay;
	bIsSay = false;

	if (StrCmp(EmoteText, "Say ", 4) == 0)
	{
		bIsSay = true;
		Index = 4;
	}
	else if(StrCmp(EmoteText, "TeamSay ", 8) == 0)
	{
		bIsSay = true;
		Index = 8;
	}

	if (!bIsSay)
	{
		return -1;
	}
	
	StringSize = Len(EmoteText);
	ColonCount = 0;
	LastColonIndex = -1;

	while(Index < StringSize)
	{
		Char = Mid(EmoteText, Index, 1);
		if (Char == ":")
		{
			ColonCount++;
			LastColonIndex = Index;
		}
		else if (Char == " ")
		{
			ColonCount = 0;
		}

		Index++;
	}

	if (ColonCount == 0 || (ColonCount & 1) == 0)
	{
		return -1;
	}

	return LastColonIndex;
}

static final function bool GetEmoteHintList(string EmoteText, array<SmileyMessageType> EmoteList, out array<string> HintList)
{
	local int Index, LastAllocatedIndex;
	local int EmoteTextLength;
	local string CapsEmoteText;

	CapsEmoteText = Caps(EmoteText);
	EmoteTextLength = Len(EmoteText);
	HintList.Length = Min(EmoteList.Length, 8);
	LastAllocatedIndex = -1;

	Index = EmoteList.Length - 1;
	while(Index >= 0 && LastAllocatedIndex < 8)
	{
		if (EmoteList[Index].bInCAPS)
		{
			if (StrCmp(EmoteList[Index].SmileyTag, CapsEmoteText, EmoteTextLength) == 0)
			{
				LastAllocatedIndex++;
				HintList[LastAllocatedIndex] = Locs(EmoteList[Index].SmileyTag);
			}
		}
		else
		{
			if (StrCmp(EmoteList[Index].SmileyTag, EmoteText, EmoteTextLength) == 0)
			{
				LastAllocatedIndex++;
				HintList[LastAllocatedIndex] = EmoteList[Index].SmileyTag;
			}
		}
		
		Index--;
	}

	HintList.Length = LastAllocatedIndex + 1;
	if (LastAllocatedIndex == -1)
	{
		return false;
	}

	return true;
}

simulated function DrawEmoteHintPrompt(Canvas C, String Text, float DrawX, float DrawY)
{
	local int Index;
	local array<string> HintList;
	local int LastColonIndex;

	local float XL, YL;
	local float TextSizeX, TextSizeY;
	local float LargestTextSizeX, TotalTextSizeY;

	LastColonIndex = CheckEmotePrompt(Text);
	if (LastColonIndex == -1)
	{
		return;
	}
    
    C.TextSize(Left(Text, LastColonIndex), XL, YL);
	DrawX += XL;
	Text = Mid(Text, LastColonIndex);

	if (!GetEmoteHintList(Text, SmileyMsgs, HintList))
	{
		return;
	}

	C.TextSize(HintList[0], TextSizeX, TextSizeY);
	TotalTextSizeY = TextSizeY * float(HintList.Length + 1);

	for (Index = 0; Index < HintList.Length; Index++)
	{
		C.TextSize(HintList[Index], TextSizeX, TextSizeY);
		LargestTextSizeX = FMax(LargestTextSizeX, TextSizeX);
	}

	LargestTextSizeX += TextSizeY;
	C.SetPos(DrawX, DrawY - TotalTextSizeY);
	C.SetDrawColor(0, 0, 0, 120);
	C.DrawTile(Texture'Engine.WhiteSquareTexture', LargestTextSizeX, TotalTextSizeY, 0.f, 0.f, 1.f, 1.f);

	DrawX += TextSizeY * 0.5f;
	DrawY = (DrawY - TotalTextSizeY) + (TextSizeY * 0.5f);
	C.SetDrawColor(255, 255, 255, 255);

	for (Index = 0; Index < HintList.Length; Index++)
	{
		C.SetPos(DrawX, DrawY);

		//Last hint is autocomplete one.
		if (Index == HintList.Length - 1)
		{
			C.SetDrawColor(244, 67, 54, 255);
		}

		C.DrawText(HintList[Index]);
		DrawY += TextSizeY;
	}
}

simulated final function DrawScaledSmileyText( string S, canvas C, optional out float XXL, optional out float XYL )
{
	local int i,n;
	local float PX,PY,XL,YL,CurX,CurY,SScale,Sca,AdditionalY;
	local string D;

	// Initilize
	C.TextSize("T",XL,YL);
	SScale = YL;
	PX = C.CurX;
	PY = C.CurY;
	CurX = PX;
	CurY = PY;

	// Search for smiles in text
	i = FindNextSmile(S,n);
	While( i!=-1 )
	{
		D = Left(S,i);
		S = Mid(S,i+Len(SmileyMsgs[n].SmileyTag));
		// Draw text behind
		C.SetPos(CurX,CurY);
		C.DrawText(D);
		// Draw smile
		C.StrLen(StripColorForTTS(D),XL,YL);
		CurX+=XL;
		While( CurX>C.ClipX )
		{
			CurY+=(YL+AdditionalY);
			XYL+=(YL+AdditionalY);
			AdditionalY = 0;
			CurX-=C.ClipX;
		}
		
		C.SetPos(CurX,CurY);

		Sca = SScale;

		C.DrawRect(SmileyMsgs[n].SmileyTex, Sca * (float(SmileyMsgs[n].SmileyTex.USize) / float(SmileyMsgs[n].SmileyTex.VSize)), Sca);
		CurX += Sca * (float(SmileyMsgs[n].SmileyTex.USize) / float(SmileyMsgs[n].SmileyTex.VSize));

		While( CurX>C.ClipX )
		{
			CurY+=(YL+AdditionalY);
			XYL+=(YL+AdditionalY);
			AdditionalY = 0;
			CurX-=C.ClipX;
		}
		// Then go for next smile
		
		i = FindNextSmile(S,n);
	}
	// Then draw rest of text remaining
	C.SetPos(CurX,CurY);
	C.StrLen(StripColorForTTS(S),XL,YL);
	C.DrawText(S);
	CurX+=XL;
	While( CurX>C.ClipX )
	{
		CurY+=(YL+AdditionalY);
		XYL+=(YL+AdditionalY);
		AdditionalY = 0;
		CurX-=C.ClipX;
	}
	XYL+=AdditionalY;
	AdditionalY = 0;
	XXL = CurX;
	C.SetPos(PX,PY);
}

static final function bool CheckVotePrompt(string VoteText)
{
	local array<string> StringSplitList;
	if (StrCmp(VoteText, "vote ", 5) != 0)
	{
		return false;
	}

	Split(VoteText, " ", StringSplitList);

	if (StringSplitList.Length > 2)
	{
		return false;
	}

	return true;
}

simulated function DrawHealthBar(Canvas C, Actor A, int Health, int MaxHealth, float Height)
{
	local vector CameraLocation, CamDir, TargetLocation, HBScreenPos;
	local rotator CameraRotation;
	local float Distance, HealthPct, BarScale;
	local Color OldDrawColor;

	if (PlayerOwner.Player.GUIController.bActive)
	{
		return;
	}

	OldDrawColor = C.DrawColor;

	C.GetCameraLocation(CameraLocation, CameraRotation);
	TargetLocation = A.Location + (vect(0.f, 0.f, 1.f) * (A.CollisionHeight * 2.f));
	Distance = VSize(TargetLocation - CameraLocation);

	CamDir = vector(CameraRotation);

	if (Distance > HealthBarCutoffDist || (Normal(TargetLocation - CameraLocation) dot CamDir) < 0.f)
	{
		return;
	}

	HBScreenPos = C.WorldToScreen(TargetLocation);

	if (Pawn(A) != None && default.MessageHealthLimit <= Pawn(A).default.Health)
	{
		BarScale = 1.f;
	}
	else
	{
		BarScale = 0.5f;
	}

	if (HBScreenPos.X <= 0 || HBScreenPos.X >= C.SizeX || HBScreenPos.Y <= 0 || HBScreenPos.Y >= C.SizeY)
	{
		return;
	}

	if (!FastTrace(TargetLocation, CameraLocation))
	{
		return;
	}

	C.DrawColor = class'TurboHUDPlayerInfo'.default.BarBackplateColor;
	C.DrawColor.A = int(float(C.DrawColor.A) * (float(255) / 255.f));
	C.SetPos(HBScreenPos.X - (0.5f * BarLength * BarScale), HBScreenPos.Y - (0.33 * BarHeight * BarScale));
	C.DrawTileStretched(WhiteMaterial, BarLength * BarScale, BarHeight * BarScale * 0.66f);

	HealthPct = FClamp(float(Health) / float(MaxHealth), 0.f, 1.f);
	C.DrawColor = class'TurboHUDPlayerInfo'.default.HealthBarColor;
	C.DrawColor.A = int(float(C.DrawColor.A) * (float(255) / 255.f));
	C.SetPos(HBScreenPos.X - (0.5f * BarLength * BarScale), HBScreenPos.Y - (0.33 * BarHeight * BarScale));
	C.DrawTileStretched(WhiteMaterial, BarLength * HealthPct * BarScale, BarHeight * BarScale * 0.66f);

	C.DrawColor = OldDrawColor;
}

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString)
{
	if (class<KillsMessage>(Message) != None)
	{
		if (OptionalObject == None)
		{
			return;
		}

		WaveInfoHUD.ReceivedKillMessage(class<KillsMessage>(Message), class<Monster>(OptionalObject), RelatedPRI_1);
		return;
	}

	Super.LocalizedMessage(Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString);
}

simulated function ReceivedVoiceMessage(PlayerReplicationInfo Sender, Name MessageType, byte MessageIndex, optional Pawn SoundSender, optional vector SenderLocation)
{
	if (TurboHUDPlayerInfo(PlayerInfoHUD) != None)
	{
		TurboHUDPlayerInfo(PlayerInfoHUD).ReceivedVoiceMessage(Sender, MessageType, MessageIndex, SoundSender, SenderLocation);
	}
}

simulated function UpdateKillMessage(Object OptionalObject, PlayerReplicationInfo RelatedPRI_1)
{
	//LocalMessage list no longer handles kill messages.
}

simulated function UpdateTraderPortrait(bool bReplaceWithMerchant)
{
	if (bReplaceWithMerchant)
	{
		TraderPortrait = default.MerchantPortrait;
		TraderString = default.MerchantString;
	}
	else
	{
		TraderPortrait = default.TraderPortrait;
		TraderString = default.TraderString;
	}
}

//Resets all but modulator to expected values.
static final function ResetCanvas(Canvas Canvas)
{
	Canvas.Font        = Canvas.default.Font;
	Canvas.FontScaleX  = Canvas.default.FontScaleX; // gam
	Canvas.FontScaleY  = Canvas.default.FontScaleY; // gam
	Canvas.SpaceX      = Canvas.default.SpaceX;
	Canvas.SpaceY      = Canvas.default.SpaceY;
	Canvas.OrgX        = Canvas.default.OrgX;
	Canvas.OrgY        = Canvas.default.OrgY;
	Canvas.CurX        = Canvas.default.CurX;
	Canvas.CurY        = Canvas.default.CurY;
	Canvas.ClipX       = Canvas.SizeX;
	Canvas.ClipY       = Canvas.SizeY;
	Canvas.Style	   = ERenderStyle.STY_Alpha;
	Canvas.DrawColor   = default.WhiteColor;
	Canvas.CurYL       = Canvas.default.CurYL;
	Canvas.bCenter     = false;
	Canvas.bNoSmooth   = false;
	Canvas.Z           = 1.0;
}

defaultproperties
{
	TextReactionSettingsClass=class'TurboTextReactionSettings'
	FontHelperClass=class'KFTurboFonts.KFTurboFontHelperEN'
	FontHelperClassCYString = "KFTurboFontsCY.KFTurboFontHelperCY"
	FontHelperClassJPString = "KFTurboFontsJP.KFTurboFontHelperJP"
	
	MerchantPortrait=Texture'KFTurbo.Merchant.Merchant_Portrait'
	MerchantString="Merchant"

	WinSound=Sound'KFTurbo.UI.YouWin_S'
	LoseSound=Sound'KFTurbo.UI.YouLose_S'
	EndGameHUDAnimationDuration=8.f

	bHasInitializedEndGameHUD=false
	EndGameHUDAnimationProgress=0.f

	bSortedEmoteList=false

	BarLength=70.000000
	BarHeight=10.000000

	InvactiveModulate=(X=0.f,Y=0.f,Z=0.f,W=0.f)
	ActiveModulate=(X=1.f,Y=1.f,Z=1.f,W=1.f)
}
