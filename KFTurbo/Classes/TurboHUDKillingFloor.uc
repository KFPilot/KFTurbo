class TurboHUDKillingFloor extends SRHUDKillingFloor;

var Sound WinSound, LoseSound;
var float EndGameHUDAnimationDuration;
var Material EndGameHUDMaterial;
var bool bHasInitializedEndGameHUD;
var float EndGameHUDAnimationProgress;

var class<TurboHUDOverlay> PlayerInfoHUDClass;
var TurboHUDOverlay PlayerInfoHUD;

var class<TurboHUDOverlay> WaveInfoHUDClass;
var TurboHUDOverlay WaveInfoHUD;

var class<TurboHUDOverlay> PlayerHUDClass;
var TurboHUDOverlay PlayerHUD;

var class<TurboHUDOverlay> MarkInfoHUDClass;
var TurboHUDOverlay MarkInfoHUD;

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

	PlayerInfoHUD = Spawn(PlayerInfoHUDClass, Self);
	PlayerInfoHUD.Initialize(Self);
	
	WaveInfoHUD = Spawn(WaveInfoHUDClass, Self);
	WaveInfoHUD.Initialize(Self);

	PlayerHUD = Spawn(PlayerHUDClass, Self);
	PlayerHUD.Initialize(Self);

	MarkInfoHUD = Spawn(MarkInfoHUDClass, Self);
	MarkInfoHUD.Initialize(Self);
}

simulated function SetScoreBoardClass (class<Scoreboard> ScoreBoardClass)
{
	if (ScoreBoardClass == class'KFScoreBoard' || ScoreBoardClass == class'SRScoreBoard')
	{
		ScoreBoardClass = class'TurboHUDScoreboard';
	}

	Super.SetScoreboardClass(ScoreBoardClass);
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (bHasInitializedEndGameHUD)
	{
		EndGameHUDAnimationProgress += DeltaTime;
	}
}

simulated function DrawHud(Canvas C)
{
	RenderDelta = Level.TimeSeconds - LastHUDRenderTime;
    LastHUDRenderTime = Level.TimeSeconds;

	if ( FontsPrecached < 2 )
	{
		PrecacheFonts(C);
	}

	UpdateHud();

	PassStyle = STY_Modulated;
	DrawModOverlay(C);

	if ( bUseBloom )
	{
		PlayerOwner.PostFX_SetActive(0, true);
	}

	if ( bHideHud )
	{
		// Draw fade effects even if the hud is hidden so poeple can't just turn off thier hud
		C.Style = ERenderStyle.STY_Alpha;
		DrawFadeEffect(C);
		return;
	}

	if ( !KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bViewingMatineeCinematic )
	{
		DrawGameHud(C);
	}
	else
	{
		PassStyle = STY_Alpha;
		DrawCinematicHUD(C);
	}

	if ( bShowNotification )
	{
		DrawPopupNotification(C);
	}
}

simulated function DrawGameHud(Canvas C)
{
	local KFGameReplicationInfo CurrentGame;

	CurrentGame = KFGameReplicationInfo(Level.GRI);

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

	PassStyle = STY_Alpha;
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

	PassStyle = STY_None;
	DisplayLocalMessages(C);
	DrawVehicleName(C);

	PassStyle = STY_Alpha;

	if ( CurrentGame!=None && CurrentGame.EndGameType > 0 )
	{
		DrawEndGameHUD(C, (CurrentGame.EndGameType==2));
		return;
	}

	RenderFlash(C);
	C.Style = PassStyle;
	DrawKFHUDTextElements(C);
}


simulated function DrawKFHUDTextElements(Canvas C)
{
	local vector Pos, FixedZPos;
	local rotator  ShopDirPointerRotation;
	local float    CircleSize;
	local float    ResScale;

	if ( PlayerOwner == none || KFGRI == none || !KFGRI.bMatchHasBegun || KFPlayerController(PlayerOwner).bShopping )
	{
		return;
	}

	if (WaveInfoHUD != None)
	{
		WaveInfoHUD.Render(C);
	}

    ResScale =  C.SizeX / 1024.0;
    CircleSize = FMin(128 * ResScale,128);
	C.FontScaleX = FMin(ResScale,1.f);
	C.FontScaleY = FMin(ResScale,1.f);

	C.FontScaleX = 1;
	C.FontScaleY = 1;


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


simulated function DrawSpectatingHud(Canvas C)
{
	DrawModOverlay(C);

	if( bHideHud )
	{
		return;
	}

	PlayerOwner.PostFX_SetActive(0, false);

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

	DrawFadeEffect(C);

	if ( KFPlayerController(PlayerOwner) != None && KFPlayerController(PlayerOwner).ActiveNote != None )
	{
		KFPlayerController(PlayerOwner).ActiveNote = None;
	}

	if( KFGameReplicationInfo(Level.GRI) != none && KFGameReplicationInfo(Level.GRI).EndGameType > 0 )
	{
		if( KFGameReplicationInfo(Level.GRI).EndGameType == 2 )
		{
			DrawEndGameHUD(C, True);
			DrawStoryHUDInfo(C);
			return;
		}
		else
		{
			DrawEndGameHUD(C, False);
		} 
	}

	DrawKFHUDTextElements(C);
	DisplayLocalMessages(C);

	if ( bShowScoreBoard && ScoreBoard != None )
	{
		ScoreBoard.DrawScoreboard(C);
	}

	if ( bShowPortrait && Portrait != None )
	{
		DrawPortraitX(C);
	}
	
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

	//Reset draw.
	C.DrawColor = WhiteColor;
	C.Style = ERenderStyle.STY_Alpha;

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
		PlayerOwner.PlaySound(WinSound, SLOT_Talk, 255.0,,,, false);
	}
	else
	{
		EndGameHUDMaterial = Texture'KFTurbo.EndGame.You_Died_D';
		PlayerOwner.PlaySound(LoseSound, SLOT_Talk,255.0,,,, false);
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
		PassStyle = STY_Alpha;
		DrawInventory(C);
	}

	if (PlayerHUD != None)
	{
		PlayerHUD.Render(C);
	}
}

//Added drop shadow.
function DisplayMessages(Canvas C)
{
	local int i, j, XPos, YPos,MessageCount;
	local float XL, YL, XXL, YYL;

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

	C.Font = GetConsoleFont(C);
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
		C.SetPos(XPos + 1.f, YPos + 1.f);
		if( TextMessages[i].PRI!=None )
		{
			XL = Class'SRScoreBoard'.Static.DrawCountryName(C,TextMessages[i].PRI,XPos + 1.f,YPos + 1.f);
			C.SetPos( XPos + XL + 1.f, YPos + 1.f );
		}

		if( SmileyMsgs.Length!=0 )
		{
			DrawSmileyText(class'GUIComponent'.static.StripColorCodes(TextMessages[i].Text),C,,YYL);
		}
		else
		{
			C.DrawText(class'GUIComponent'.static.StripColorCodes(TextMessages[i].Text),false);
		}

		C.DrawColor = C.MakeColor(255, 255, 255, 255);
		YYL = 0;
		XXL = 0;
		
		C.SetPos( XPos, YPos );
		if( TextMessages[i].PRI!=None )
		{
			XL = Class'SRScoreBoard'.Static.DrawCountryName(C,TextMessages[i].PRI,XPos,YPos);
			C.SetPos( XPos+XL, YPos );
		}

		if( SmileyMsgs.Length!=0 )
		{
			DrawSmileyText(TextMessages[i].Text,C,,YYL);
		}
		else
		{
			C.DrawText(TextMessages[i].Text,false);
		}
		YPos += (YL+YYL);
	}
}

static function Font LoadFontStatic(int i)
{
	return class'KFTurboFonts'.static.LoadFontStatic(i);
}

simulated function Font LoadFont(int i)
{
	return class'KFTurboFonts'.static.LoadFontStatic(i);
}

defaultproperties
{
	WinSound=Sound'KFTurbo.YouWin_S'
	LoseSound=Sound'KFTurbo.YouLose_S'
	EndGameHUDAnimationDuration=8.f

	bHasInitializedEndGameHUD=false
	EndGameHUDAnimationProgress=0.f

	BarLength=70.000000
	BarHeight=10.000000
}
