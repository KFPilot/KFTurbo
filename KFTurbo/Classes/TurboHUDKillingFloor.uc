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

var class<TurboHUDOverlay> PlayerHealthHUDClass;
var TurboHUDOverlay PlayerHealthHUD;

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

	if (PlayerHealthHUDClass == None)
	{
		PlayerHealthHUDClass = class'TurboHUDPlayerHealth';
	}

	if (MarkInfoHUDClass == None)
	{
		MarkInfoHUDClass = class'TurboHUDMarkInfo';
	}

	PlayerInfoHUD = Spawn(PlayerInfoHUDClass, Self);
	PlayerInfoHUD.Initialize(Self);
	
	WaveInfoHUD = Spawn(WaveInfoHUDClass, Self);
	WaveInfoHUD.Initialize(Self);

	PlayerHealthHUD = Spawn(PlayerHealthHUDClass, Self);
	PlayerHealthHUD.Initialize(Self);

	MarkInfoHUD = Spawn(MarkInfoHUDClass, Self);
	MarkInfoHUD.Initialize(Self);
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
	DrawWeaponName(C);
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
	DrawTraderDistance(C);
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
	Super.DrawHudPassA(C);

	/*
	if (PlayerHealthHUD != None)
	{
		PlayerHealthHUD.Render(C);
	}
	*/
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
