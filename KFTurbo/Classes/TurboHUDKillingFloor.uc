//Killing Floor Turbo TurboHUDKillingFloor
//KFTurbo's HUD. Leverages TurboHUDOverlays for most of the UI elements.
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHUDKillingFloor extends SRHUDKillingFloor;

var Sound WinSound, LoseSound;
var float EndGameHUDAnimationDuration;
var Material EndGameHUDMaterial;
var bool bHasInitializedEndGameHUD;
var float EndGameHUDAnimationProgress;

var bool bSortedEmoteList;

var class<TurboHUDOverlay> PlayerInfoHUDClass;
var TurboHUDOverlay PlayerInfoHUD;

var class<TurboHUDWaveInfo> WaveInfoHUDClass;
var TurboHUDWaveInfo WaveInfoHUD;

var class<TurboHUDOverlay> PlayerHUDClass;
var TurboHUDOverlay PlayerHUD;

var class<TurboHUDOverlay> MarkInfoHUDClass;
var TurboHUDOverlay MarkInfoHUD;

simulated event PostRender( canvas Canvas )
{
	bUseBloom = bool(ConsoleCommand("get ini:Engine.Engine.ViewportManager Bloom"));
	if (bUseBloom)
	{
		PlayerOwner.PostFX_SetActive(0, false);
	}

	Super.PostRender(Canvas);

	if (bUseBloom)
	{
		PlayerOwner.PostFX_SetActive(0, bUseBloom);
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
	if (bHideHud)
	{
		return;
	}

	RenderDelta = Level.TimeSeconds - LastHUDRenderTime;
    LastHUDRenderTime = Level.TimeSeconds;
	
	C.Reset();
	C.DrawColor = class'HudBase'.default.WhiteColor;
	C.Style = ERenderStyle.STY_Alpha;

	if ( FontsPrecached < 2 )
	{
		PrecacheFonts(C);
	}

	if ( !KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bViewingMatineeCinematic )
	{
		DrawGameHud(C);
	}
	else
	{
		DrawCinematicHUD(C);
	}

	C.Reset();
	C.DrawColor = class'HudBase'.default.WhiteColor;
	C.Style = ERenderStyle.STY_Alpha;

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

	DisplayLocalMessages(C);

	if (CurrentGame != None && CurrentGame.EndGameType > 0)
	{
		DrawEndGameHUD(C, (CurrentGame.EndGameType==2));
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

	C.Reset();
	C.DrawColor = class'HudBase'.default.WhiteColor;
	C.Style = ERenderStyle.STY_Alpha;

	if (WaveInfoHUD != None)
	{
		WaveInfoHUD.Render(C);
	}

	C.Reset();
	C.DrawColor = class'HudBase'.default.WhiteColor;
	C.Style = ERenderStyle.STY_Alpha;

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
	if (bHideHud)
	{
		return;
	}

	C.Reset();
	C.DrawColor = class'HudBase'.default.WhiteColor;
	C.Style = ERenderStyle.STY_Alpha;

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

	C.Reset();
	C.DrawColor = class'HudBase'.default.WhiteColor;
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
		PlayerOwner.PlaySound(LoseSound, SLOT_Talk, 255.0,,,, false);
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

		C.Reset();
		C.DrawColor = class'HudBase'.default.WhiteColor;
		C.Style = ERenderStyle.STY_Alpha;
	}

	if (PlayerHUD != None)
	{
		PlayerHUD.Render(C);
	}
}


simulated function DrawHudPassC(Canvas C)
{
	if (bShowScoreBoard && ScoreBoard != None)
	{
		ScoreBoard.DrawScoreboard(C);
	}
	
	if (bShowPortrait && (Portrait != None))
	{
		DrawPortraitX(C);
	}
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
			DrawScaledSmileyText(class'GUIComponent'.static.StripColorCodes(TextMessages[i].Text),C,,YYL);
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
			DrawScaledSmileyText(TextMessages[i].Text,C,,YYL);
		}
		else
		{
			C.DrawText(TextMessages[i].Text,false);
		}
		YPos += (YL+YYL);
	}
}

simulated function DrawTypingPrompt(Canvas C, String Text, optional int Pos)
{
    local float XPos, YPos;
    local float XL, YL;
	local string PromptText;

    C.Font = GetConsoleFont(C);
    C.Style = ERenderStyle.STY_Alpha;
    C.SetDrawColor(255, 255, 255, 255);

    C.TextSize("A", XL, YL);

    XPos = (ConsoleMessagePosX * HudCanvasScale * C.SizeX) + (((1.0 - HudCanvasScale) * 0.5) * C.SizeX);
    YPos = (ConsoleMessagePosY * HudCanvasScale * C.SizeY) + (((1.0 - HudCanvasScale) * 0.5) * C.SizeY) - YL;

	PromptText = "(>"@Left(Text, Pos)$chr(4)$Eval(Pos < Len(Text), Mid(Text, Pos), "_");

    C.SetPos(XPos, YPos);
    C.DrawTextClipped(PromptText, true);

	if (Pos >= Len(Text))
	{
		DrawEmoteHintPrompt(C, Text, XPos, YPos);
	}
}

static final function bool CheckEmotePrompt(string EmoteText, out int LastColon)
{
	local int Index, StringSize;
	local int ColonCount;
	local int LastSpace;
	local string Char;
 
	Index = 0;
	StringSize = Len(EmoteText);
	ColonCount = 0;
	LastColon = -1;
	LastSpace = -1;

	if (StrCmp(EmoteText, "TeamSay ", Len("TeamSay ")) != 0 && StrCmp(EmoteText, "Say ", Len("Say ")) != 0)
	{
		return false;
	}

	while(Index < StringSize)
	{
		Char = Mid(EmoteText, Index, 1);
		if (Char == ":")
		{
			ColonCount++;
			LastColon = Index;
		}
		else if (Char == " ")
		{
			ColonCount = 0;
			LastSpace = Index;
		}

		Index++;
	}

	if (ColonCount % 2 == 0)
	{
		return false;
	}

	if (LastSpace > LastColon)
	{
		return false;
	}

	return true;
}

static final function bool GetHintList(string EmoteText, out array<SmileyMessageType> EmoteList, out array<string> HintList)
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

	if (!CheckEmotePrompt(Text, LastColonIndex))
	{
		return;
	}
    
    C.TextSize(Left(Text, LastColonIndex), XL, YL);
	DrawX += XL;
	Text = Mid(Text, LastColonIndex);

	if (!GetHintList(Text, SmileyMsgs, HintList))
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

simulated function UpdateKillMessage(Object OptionalObject, PlayerReplicationInfo RelatedPRI_1)
{
	//LocalMessage list no longer handles kill messages.
}

static function Font LoadFontStatic(int i)
{
	return class'KFTurboFontHelper'.static.LoadFontStatic(i);
}

simulated function Font LoadFont(int i)
{
	return class'KFTurboFontHelper'.static.LoadFontStatic(i);
}

defaultproperties
{
	WinSound=Sound'KFTurbo.YouWin_S'
	LoseSound=Sound'KFTurbo.YouLose_S'
	EndGameHUDAnimationDuration=8.f

	bHasInitializedEndGameHUD=false
	EndGameHUDAnimationProgress=0.f

	bSortedEmoteList=false

	BarLength=70.000000
	BarHeight=10.000000
}
