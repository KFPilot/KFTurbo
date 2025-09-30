//Killing Floor Turbo TurboCardOverlay
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardOverlay extends TurboHUDOverlay;

var TurboCardReplicationInfo TCRI;
var TurboPlayerCardCustomInfo PlayerCardCustomInfo;
var ServerTimeActor ServerTimeActor;
struct SelectableCardEntry
{
	var TurboCardActor CardActor;
	var float Ratio;
};
var array<SelectableCardEntry> CardRenderActorList;
var bool bUseLargeCards;
var bool bDrawDarkenedCards;
var int BaseFontSize;

var int CurrentCardCount;
var int VotedCardIndex;
 
struct ActiveCardEntry
{
	var TurboCardActor CardActor;
	var float Ratio;
};
var array<ActiveCardEntry> ActiveCardRenderActorList;

var int CardIndexToDisplay;

var localized string HowToVoteString;
var localized string HowCardsWorkString;

var localized array<string> HowToScrollCardsString;
var float HowToScrollFade;

var Color BackplateColor;
var Texture RoundedContainer;

var PlayerBorrowedTimeActor BorrowedTimeActor;
var bool bHasPlayedMinuteWarning, bHasPlayedThirtySecondsWarning;
var Sound MinuteWarningSound, ThirtySecondsWarningSound, TenSecondWarningSound;
var int LastWarnTime;

var float VoteMenuScale;
var bool bHasShiftPressed;
var bool bReduceCardVisibility;

var float FadeInAndUpRatio;
var float FadeInAndUpRate;
var float FanOutRatio;
var float FanOutRate;

var float RackEmUpRatio; 
var float RackEmUpFadeInRate;
var float RackEmUpFadeOutRate;
var int RackEmUpLastKnownHeadshot;
var float RackEmUpPulseRatio;
var float RackEmUpPulseFadeRate;
var float RackEmUpTimeStart;
var float RackEmUpTimeEnd;

enum EBorrowedTimeWarnLevel
{
	NoWarning,
	OneMinuteLeft,
	ThirtySecondsLeft,
	TenSecondsLeft,
	OutOfTime
};

static final function TurboCardOverlay FindCardOverlay(PlayerController PlayerController)
{
	local int Index;
	local TurboHUDKillingFloor TurboHUD;
	TurboHUD = TurboHUDKillingFloor(PlayerController.myHUD);

	if (TurboHUD == None)
	{
		return None;
	}

	for (Index = 0; Index < TurboHUD.PreDrawOverlays.Length; Index++)
	{
		if (TurboCardOverlay(TurboHUD.PreDrawOverlays[Index]) != None)
		{
			return TurboCardOverlay(TurboHUD.PreDrawOverlays[Index]);
		}
	}

	return None;
}

//Bind to updates.
simulated function InitializeCardGameHUD(TurboCardReplicationInfo CGRI)
{
	TCRI = CGRI;
	CGRI.OnSelectableCardsUpdated = OnSelectableCardsUpdated;
	CGRI.OnActiveCardsUpdated = OnActiveCardsUpdated;

	//Mid-game joiners may need an update.
	if (CGRI.bCurrentlyVoting)
	{
		OnSelectableCardsUpdated(CGRI);
	}

	OnActiveCardsUpdated(CGRI);

	bReduceCardVisibility = class'TurboCardInteraction'.static.ShouldReduceCardVisibility(TurboPlayerController(TurboHUD.PlayerOwner));

	Timer();
}

simulated function bool CanUseLargeCards()
{
	switch(TurboHUD.PlayerOwner.ConsoleCommand("get ini:Engine.Engine.ViewportManager TextureDetailWorld"))
	{
		case "Higher":
		case "High":
		case "VeryHigh":
		case "UltraHigh":
			return true;
	}

	return false;
}

simulated function OnScreenSizeChange(Canvas C, Vector2D CurrentClipSize, Vector2D PreviousClipSize)
{
	Super.OnScreenSizeChange(C, CurrentClipSize, PreviousClipSize);

	bUseLargeCards = false;

	if (CurrentClipSize.Y > 1600)
	{
		BaseFontSize = 3;
	}
	else if (CurrentClipSize.Y > 1400)
	{
		BaseFontSize = 3;
	}
	else if (CurrentClipSize.Y > 1200)
	{
		BaseFontSize = 4;
	}
	else if (CurrentClipSize.Y > 1000)
	{
		BaseFontSize = 4;
	}
	else
	{
		BaseFontSize = 5;
	}

	if (CurrentClipSize.Y >= 1440.f && CanUseLargeCards())
	{
		bUseLargeCards = true;
	}
}

simulated function class<TurboCardActor> GetTurboCardActorClass()
{
	if (bUseLargeCards)
	{
		return class'TurboCardActorLarge';
	}

	return class'TurboCardActor';
}

simulated function int GetVoteIndex()
{
	local CardGamePlayerReplicationInfo CGPRI;
	if (HUD(Owner).PlayerOwner == None)
	{
		return -1;
	}

	CGPRI = class'CardGamePlayerReplicationInfo'.static.GetCardGameLRI(HUD(Owner).PlayerOwner.PlayerReplicationInfo);
	if (CGPRI == None)
	{
		return -1;
	}

	return CGPRI.VoteIndex - 1;
}

simulated function Timer()
{
	if (ServerTimeActor == None)
	{
		ServerTimeActor = class'ServerTimeActor'.static.FindServerTimeActor(Self);
	}

	if (PlayerCardCustomInfo == None)
	{
		PlayerCardCustomInfo = TurboPlayerCardCustomInfo(class'TurboPlayerCardCustomInfo'.static.FindCustomInfo(TurboPlayerReplicationInfo(GetController().PlayerReplicationInfo)));
	}

	if (ServerTimeActor == None || PlayerCardCustomInfo == None)
	{
		SetTimer(0.1f, false);
	}
}

simulated function Tick(float DeltaTime)
{
	local int Index;

	Super.Tick(DeltaTime);

	DeltaTime = FMin(DeltaTime, 0.1f);

	if (TCRI == None)
	{
		return;
	}

	if (TCRI.bCurrentlyVoting && CurrentCardCount > 0)
	{
		TickSelectableCards(DeltaTime);
	}

	if (!HUD(Owner).bShowScoreboard)
	{
		CardIndexToDisplay = -1;
		HowToScrollFade = FMax(Lerp(DeltaTime * 4.f, HowToScrollFade, 0.f), 0.f);
	}
	else if (ActiveCardRenderActorList.Length > 0)
	{
		if (CardIndexToDisplay == -1)
		{
			CardIndexToDisplay = ActiveCardRenderActorList.Length - 1;
		}

		if (ActiveCardRenderActorList.Length > 1)
		{
			HowToScrollFade = FMin(Lerp(DeltaTime * 6.f, HowToScrollFade, 1.f), 1.f);
		}

		ActiveCardRenderActorList[CardIndexToDisplay].Ratio = FMin(Lerp(DeltaTime * 10.f, ActiveCardRenderActorList[CardIndexToDisplay].Ratio, 1.f), 1.f);
	}

	for (Index = 0; Index < ActiveCardRenderActorList.Length; Index++)
	{
		if (Index == CardIndexToDisplay)
		{
			continue;
		}

		ActiveCardRenderActorList[Index].Ratio = FMax(Lerp(DeltaTime * 8.f, ActiveCardRenderActorList[Index].Ratio, 0.f), 0.f);
	}

	if (PlayerCardCustomInfo != None && (RackEmUpRatio > 0.f || PlayerCardCustomInfo.RackEmUpHeadshotCount != 0))
	{
		TickRackEmUp(DeltaTime);
	}
}

simulated function TickSelectableCards(float DeltaTime)
{
	local int Index;

	if (FadeInAndUpRatio < 1.f)
	{
		FadeInAndUpRatio = FMin(Lerp(DeltaTime * FadeInAndUpRate, FadeInAndUpRatio, 1.f), 1.f);
		if (Abs(FadeInAndUpRatio - 1.f) < 0.001f)
		{
			FadeInAndUpRatio = 1.f;
		}

		if (FadeInAndUpRatio < 0.9f)
		{
			return;
		}
	}

	if (FanOutRatio < 1.f)
	{
		FanOutRatio = FMin(Lerp(DeltaTime * FanOutRate, FanOutRatio, 1.f), 1.f);
		if (Abs(FanOutRatio - 1.f) < 0.001f)
		{
			FanOutRatio = 1.f;
		}
	}

	VotedCardIndex = GetVoteIndex();

	for (Index = 0; Index < CardRenderActorList.Length; Index++)
	{
		if (Index == VotedCardIndex)
		{
			CardRenderActorList[Index].Ratio = FMin(Lerp(DeltaTime * 20.f, CardRenderActorList[Index].Ratio, 1.f), 1.f);
		}
		else
		{
			CardRenderActorList[Index].Ratio = FMax(Lerp(DeltaTime * 4.f, CardRenderActorList[Index].Ratio, 0.f), 0.f);
		}
	}

	if (bHasShiftPressed || GetVoteIndex() == -1)
	{
		VoteMenuScale = FMin(Lerp(DeltaTime * 10.f, VoteMenuScale, 1.f), 1.f);
	}
	else
	{
		VoteMenuScale = FMax(Lerp(DeltaTime * 10.f, VoteMenuScale, 0.f), 0.f);
	}
}

//Mouse wheel key events are forwarded here. Returns true if the key event should be consumed.
simulated function bool ReceivedKeyEvent(Interactions.EInputKey Key, Interactions.EInputAction Action)
{
	if (TCRI.bCurrentlyVoting)
	{
		if (Key == IK_Shift)
		{
			if (Action == IST_Press)
			{
				bHasShiftPressed = true;
			}
			else if (Action == IST_Release)
			{
				bHasShiftPressed = false;
			}
		}
	}
	
	if (!HUD(Owner).bShowScoreboard)
	{
		return false;
	}

	switch(Key)
	{
		case IK_MouseWheelUp:
			CardIndexToDisplay = (CardIndexToDisplay - 1) % ActiveCardRenderActorList.Length;
			break;
		case IK_MouseWheelDown:
			CardIndexToDisplay = (CardIndexToDisplay + 1) % ActiveCardRenderActorList.Length;
			break;
	}

	return true;
}

simulated function OnSelectableCardsUpdated(TurboCardReplicationInfo CGRI)
{
	local int Index;
	local TurboCard TurboCard;

	if (class'TurboCardReplicationInfo'.static.ResolveCard(CGRI.SelectableCardList[0]) == None)
	{
		CurrentCardCount = 0;
		VotedCardIndex = -1;
		return;
	}

	for (Index = 0; Index < ArrayCount(CGRI.SelectableCardList); Index++)
	{
		TurboCard = class'TurboCardReplicationInfo'.static.ResolveCard(CGRI.SelectableCardList[Index]);

		if (TurboCard == None)
		{
			break;
		}

		if (CardRenderActorList.Length > Index)
		{
			//Create a new card if we don't have one, or the one we had became an active card.
			if (CardRenderActorList[Index].CardActor == None || CardRenderActorList[Index].CardActor.bIsActiveCard)
			{
				CardRenderActorList[Index].CardActor = Spawn(GetTurboCardActorClass(), Self);
			}

			CardRenderActorList[Index].CardActor.SetCardClass(TurboCard);
			CardRenderActorList[Index].Ratio = 0.f;
			continue;
		}

		CardRenderActorList.Length = Index + 1;
		CardRenderActorList[Index].CardActor = Spawn(GetTurboCardActorClass(), Self);
		CardRenderActorList[Index].CardActor.SetCardClass(TurboCard);
	}

	CurrentCardCount = Index;

	bHasShiftPressed = true;
	VoteMenuScale = 1.f;

	FadeInAndUpRatio = 0.f;
	FanOutRatio = 0.f;
}

simulated function Render(Canvas C)
{
	Super.Render(C);

	if (TCRI == None)
	{
		return;
	}
	
	class'TurboHUDKillingFloor'.static.ResetCanvas(C);

	if (TCRI.bCurrentlyVoting && CurrentCardCount > 0)
	{
		DrawSelectableCardList(C);
	}

	DrawActiveCardList(C);

	if (BorrowedTimeActor != None)
	{
		DrawBorrowedTime(C);
	}

	if (PlayerCardCustomInfo != None && (RackEmUpRatio > 0.f || PlayerCardCustomInfo.RackEmUpHeadshotCount != 0))
	{
		DrawRackEmUp(C);
	}

	class'TurboHUDKillingFloor'.static.ResetCanvas(C);
}

simulated function DrawVoter(Canvas C, PlayerReplicationInfo PRI, float X, float Y, float XOffset, out array<int> VoteList)
{
	local CardGamePlayerReplicationInfo CGPRI;
	local float TextSizeX, TextSizeY;
	local String PlayerName;
	local int VoteIndex;
	local int Opacity;

	PlayerName = PRI.PlayerName;
	if (PlayerName == "")
	{ 
		return;
	}

	CGPRI = class'CardGamePlayerReplicationInfo'.static.GetCardGameLRI(PRI);

	if (CGPRI == None)
	{
		return;
	}

	VoteIndex = CGPRI.VoteIndex - 1;

	if (VoteIndex < 0)
	{
		return;
	}

	if (Len(PlayerName) > 15)
	{
		PlayerName = Left(PlayerName, 15);
	}

	X += XOffset * VoteIndex;
	C.TextSize(PlayerName, TextSizeX, TextSizeY);
	Y -= TextSizeY;

	if (VoteList.Length > VoteIndex)
	{
		Y -= float(VoteList[VoteIndex]) * TextSizeY;
		VoteList[VoteIndex]++;
	}
	else
	{
		VoteList[VoteIndex] = 1;
	}

	//Dim spectator selection (as their votes are not counted).
	if (!PRI.bOnlySpectator)
	{
		Opacity = 255;
	}
	else
	{
		Opacity = 120;
	}

	C.SetDrawColor(0, 0, 0, 120);
	X -= TextSizeX * 0.5f;
	C.SetPos(X + 2.f, Y + 2.f);
	C.DrawText(PlayerName);

	C.SetDrawColor(255, 255, 255, Opacity);
	C.SetPos(X, Y);
	C.DrawText(PlayerName);
}

simulated function DrawSelectableCardList(Canvas C)
{
	local int Index;
	local float CardSize, CardOffset, CardScale;
	local float CenterIndex;
	local float TempX, TempY, VotedCardX, CardSelectionScale;
	local float TextSizeX, TextSizeY;
	local array<int> VoteList;
	local string ColorString, StrippedString;
	local Color WhiteColor, BlackColor;
	WhiteColor = MakeColor(255, 255, 255, 255);
	BlackColor = MakeColor(0, 0, 0, 120);
	
	C.DrawColor = WhiteColor;

	C.Font = TurboHUD.LoadBoldFont(BaseFontSize);

	CenterIndex = float(CurrentCardCount) / 2.f;
	CardSize = FMin(C.ClipX / 10.f, (C.ClipY / 4.f)) * Lerp(VoteMenuScale, 0.5f, 1.f);
	CardOffset = CardSize * 1.1f * Lerp(FanOutRatio, 0.1f, 1.f);
	TempY = ((C.ClipY / 1.75f) - (CardSize * 0.5f * Lerp(VoteMenuScale, -0.5f, 1.f))) + (CardSize * 4.f *  (1.f - FadeInAndUpRatio));
	TempX = (C.ClipX / 2.f) - (CenterIndex * CardOffset);

	for (Index = 0; Index < CurrentCardCount; Index++)
	{
		if (VotedCardIndex == Index)
		{
			VotedCardX = TempX;
			TempX += CardOffset;
			continue;	
		}

		if (CardRenderActorList[Index].CardActor == None)
		{
			continue;	
		}

		CardSelectionScale = Lerp(CardRenderActorList[Index].Ratio, 1.f, 1.15f);

		CardRenderActorList[Index].CardActor.RenderOverlays(C);
		
		CardScale = CardSize / float(CardRenderActorList[Index].CardActor.CardScriptedTexture.USize);
		C.SetPos(TempX + (CardOffset * 0.5f) - (CardSize * CardSelectionScale * 0.5f), TempY - ((CardSelectionScale - 1.f) * CardSize));
		C.DrawTileScaled(CardRenderActorList[Index].CardActor.CardShader, CardScale * CardSelectionScale, CardScale * CardSelectionScale);
		TempX += CardOffset;
	}

	if (VotedCardIndex != -1)
	{
		CardSelectionScale = Lerp(CardRenderActorList[VotedCardIndex].Ratio, 1.f, 1.15f);
		CardScale = CardSize / float(CardRenderActorList[VotedCardIndex].CardActor.CardScriptedTexture.USize);
		C.SetPos(VotedCardX + (CardOffset * 0.5f) - (CardSize * CardSelectionScale * 0.5f), TempY - ((CardSelectionScale - 1.f) * CardSize));
		C.DrawTileScaled(CardRenderActorList[VotedCardIndex].CardActor.CardShader, CardScale * CardSelectionScale, CardScale * CardSelectionScale);
	}

	C.FontScaleX = Lerp(VoteMenuScale, 0.6f, 1.f);
	C.FontScaleY = C.FontScaleX;

	TempX = ((C.ClipX / 2.f) - (CenterIndex * CardOffset)) + (CardOffset * 0.5f);
	TempY += CardSize * 0.01f;

	if (FadeInAndUpRatio > 0.9f)
	{
		for (Index = Level.GRI.PRIArray.Length - 1; Index >= 0; Index--)
		{
			DrawVoter(C, Level.GRI.PRIArray[Index], TempX, TempY, CardOffset, VoteList);
		}
	}

	ColorString = class'TurboLocalMessage'.static.FormatString(HowToVoteString);
	StrippedString = class'GUIComponent'.static.StripColorCodes(ColorString);

	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	TempY += CardSize * 1.9f;
	TempX = (C.ClipX / 2.f);

	C.TextSize(StrippedString, TextSizeX, TextSizeY);
	TempX -= TextSizeX * 0.5f;

	TempX += 1.f + (Sin(Level.TimeSeconds * PI * 0.8f) * 6.3f);
	TempY += 1.f + (Sin(Level.TimeSeconds * PI * 0.6f) * 4.125f);

	C.DrawColor = BlackColor;
	C.SetPos(TempX + 2.f, TempY + 2.f);
	C.DrawText(StrippedString);

	C.DrawColor = WhiteColor;
	C.SetPos(TempX, TempY);
	C.DrawText(ColorString);

	C.Font = TurboHUD.LoadBoldFont(BaseFontSize + 2);
	TempX += TextSizeX * 0.5f;
	TempY += TextSizeY;

	ColorString = class'TurboLocalMessage'.static.FormatString(HowCardsWorkString);
	StrippedString = class'GUIComponent'.static.StripColorCodes(ColorString);

	C.TextSize(StrippedString, TextSizeX, TextSizeY);
	TempX -= TextSizeX * 0.5f;

	C.DrawColor = BlackColor;
	C.SetPos(TempX + 2.f, TempY + 2.f);
	C.DrawText(StrippedString);

	C.DrawColor = WhiteColor;
	C.SetPos(TempX, TempY);
	C.DrawText(ColorString);
}

simulated function DrawActiveCardList(Canvas C)
{
	local int Index;
	local float CardSize, CardOffset, CardScale;
	local float CenterIndex;
	local float TempX, TempY;
	local float CardX;
	local float CardBonusScale;
	local float DisplayCardY, ScrollDisplayY;
	local float TextSizeX, TextSizeY, MaxTextSizeX;

	if (ActiveCardRenderActorList.Length == 0)
	{
		return;
	}

	C.SetDrawColor(255, 255, 255, 255);
	
	CenterIndex = float(ActiveCardRenderActorList.Length) / 2.f;

	CardSize = C.ClipY / 10.f;
	CardOffset = CardSize * 0.33f;

	TempX = C.ClipX;
	TempY = (C.ClipY / 2.f) - (CenterIndex * CardOffset);
	for (Index = 0; Index < ActiveCardRenderActorList.Length; Index++)
	{
		if (CardIndexToDisplay == Index)
		{
			DisplayCardY = TempY;
			TempY += CardOffset;
			continue;
		}

		if (ActiveCardRenderActorList[Index].CardActor == None)
		{
			continue;
		}

		//For some reason we have a card actor but not an active card?
		if (class'TurboCardReplicationInfo'.static.ResolveCard(TCRI.ActiveCardList[Index]) == None)
		{
			log("Attempted to draw a card that wasn't real.", 'KFTurboCardGame');
			continue;
		}

		CardBonusScale = Lerp(ActiveCardRenderActorList[Index].Ratio, 1.f, 1.75f);

		ActiveCardRenderActorList[Index].CardActor.RenderOverlays(C);
		
		CardScale = CardSize / float(ActiveCardRenderActorList[Index].CardActor.CardScriptedTexture.USize);

		CardX = (TempX - (CardSize * 0.95f)) - ((CardBonusScale - 1.f) * CardSize * 0.95f);

		if (bReduceCardVisibility)
		{
			CardX += Lerp(ActiveCardRenderActorList[Index].Ratio, 1.f, 0.f) * CardSize * 0.8f;
		}

		C.SetPos(CardX, TempY + (CardOffset * 0.5f) - (CardSize * CardBonusScale));
		C.DrawTileScaled(ActiveCardRenderActorList[Index].CardActor.CardShader, CardScale * CardBonusScale, CardScale * CardBonusScale);
		ScrollDisplayY = FMax(ScrollDisplayY, TempY + (CardSize * CardBonusScale));
		TempY += CardOffset;
	}

	if (CardIndexToDisplay != -1)
	{
		CardBonusScale = Lerp(ActiveCardRenderActorList[CardIndexToDisplay].Ratio, 1.f, 1.75f);

		CardScale = CardSize / float(ActiveCardRenderActorList[CardIndexToDisplay].CardActor.CardScriptedTexture.USize);

		CardX = (TempX - (CardSize * 0.95f)) - ((CardBonusScale - 1.f) * CardSize * 0.95f);
		
		if (bReduceCardVisibility)
		{
			CardX += Lerp(ActiveCardRenderActorList[CardIndexToDisplay].Ratio, 1.f, 0.f) * CardSize * 0.8f;
		}

		C.SetPos(CardX, DisplayCardY + (CardOffset * 0.5f) - (CardSize * CardBonusScale));
		C.DrawTileScaled(ActiveCardRenderActorList[CardIndexToDisplay].CardActor.CardShader, CardScale * CardBonusScale, CardScale * CardBonusScale);
		
		ScrollDisplayY = FMax(ScrollDisplayY, DisplayCardY + (CardSize * CardBonusScale));
	}

	if (ActiveCardRenderActorList.Length <= 1 || HowToScrollFade < 0.01f)
	{
		return;
	}

	C.Font = TurboHUD.LoadFont(BaseFontSize + 1);
	TempX = C.ClipX - 2.f;
	TempY = ScrollDisplayY; //Remainder of CardSize for a given CardOffset, plus some extra padding.

	MaxTextSizeX = 0.f;
	for (Index = 0; Index < HowToScrollCardsString.Length; Index++)
	{
		C.TextSize(HowToScrollCardsString[Index], TextSizeX, TextSizeY);
		MaxTextSizeX = FMax(MaxTextSizeX, TextSizeX);
	}

	TempX += (MaxTextSizeX) * (1.f - HowToScrollFade) * 1.1f;
	TempX -= MaxTextSizeX * 0.5f;
	for (Index = 0; Index < HowToScrollCardsString.Length; Index++)
	{
		C.TextSize(HowToScrollCardsString[Index], TextSizeX, TextSizeY);
		
		C.SetDrawColor(0, 0, 0);
		C.DrawColor.A = Lerp(HowToScrollFade, 0, 120);
		C.SetPos((TempX - (TextSizeX * 0.5f)) + 2.f, TempY + 2.f);
		C.DrawTextClipped(HowToScrollCardsString[Index]);

		C.SetDrawColor(255, 255, 255);
		C.DrawColor.A = Lerp(HowToScrollFade, 0, 255);
		C.SetPos((TempX - (TextSizeX * 0.5f)), TempY);
		C.DrawTextClipped(HowToScrollCardsString[Index]);
		TempY += TextSizeY;
	}
}

simulated function TurboCardActor GetCardFromSelectableList(TurboCard TurboCard)
{
	local int Index;
	for (Index = 0; Index < CardRenderActorList.Length; Index++)
	{
		if (CardRenderActorList[Index].CardActor == None || CardRenderActorList[Index].CardActor.Card != TurboCard)
		{
			continue;
		}

		return CardRenderActorList[Index].CardActor;
	}

	return None;
}

simulated function OnActiveCardsUpdated(TurboCardReplicationInfo CGRI)
{
	local int Index;
	local TurboCard TurboCard;
	log("Active cards updated.", 'KFTurboCardGame');
	for (Index = 0; Index < ArrayCount(CGRI.ActiveCardList); Index++)
	{
		TurboCard = class'TurboCardReplicationInfo'.static.ResolveCard(CGRI.ActiveCardList[Index]);

		if (TurboCard == None)
		{
			if (ActiveCardRenderActorList.Length > Index)
			{
				if (ActiveCardRenderActorList[Index].CardActor != None)
				{
					ActiveCardRenderActorList[Index].CardActor.Destroy();
					ActiveCardRenderActorList[Index].CardActor = None;
					ActiveCardRenderActorList[Index].Ratio = 0.f;
				}

				continue;
			}

			break;
		}

		if (ActiveCardRenderActorList.Length > Index && ActiveCardRenderActorList[Index].CardActor != None)
		{
			if (ActiveCardRenderActorList[Index].CardActor.Card != TurboCard)
			{
				ActiveCardRenderActorList[Index].CardActor.SetCardClass(TurboCard);
				ActiveCardRenderActorList[Index].Ratio = 1.f;
			}

			continue;
		}

		ActiveCardRenderActorList.Length = Index + 1;
		ActiveCardRenderActorList[Index].CardActor = GetCardFromSelectableList(TurboCard);

		if (ActiveCardRenderActorList[Index].CardActor == None)
		{
			ActiveCardRenderActorList[Index].CardActor = Spawn(class'TurboCardActor', Self);
			ActiveCardRenderActorList[Index].CardActor.SetCardClass(TurboCard);
		}

		ActiveCardRenderActorList[Index].CardActor.bIsActiveCard = true;
		log("New active card"@ActiveCardRenderActorList[Index].CardActor.Card, 'KFTurboCardGame');
	}
}

static final function EBorrowedTimeWarnLevel GetWarningForTime(float TimeRemaining)
{
	if (TimeRemaining < 1.f)
	{
		return OutOfTime;
	}
	if (TimeRemaining <= 10.f)
	{
		return TenSecondsLeft;
	}
	else if (TimeRemaining <= 30.f)
	{
		return ThirtySecondsLeft;
	}
	else if (TimeRemaining < 60.f)
	{
		return OneMinuteLeft;
	}

	return NoWarning;
}

static final function Color GetTextColorForWarnLevel(EBorrowedTimeWarnLevel WarnLevel)
{
	switch (WarnLevel)
	{
		case NoWarning:
			return class'Canvas'.static.MakeColor(255, 255, 255, 220);
		case OneMinuteLeft:
			return class'Canvas'.static.MakeColor(255, 100, 100, 220);
		case ThirtySecondsLeft:
			return class'Canvas'.static.MakeColor(255, 50, 50, 220);
		case TenSecondsLeft:
			return class'Canvas'.static.MakeColor(255, 0, 0, 220);
		case OutOfTime:
			return class'Canvas'.static.MakeColor(255, 0, 0, 255);
	}

	return class'Canvas'.static.MakeColor(255, 255, 255, 220);
}

static final function float GetTextScaleForWarnLevel(EBorrowedTimeWarnLevel WarnLevel)
{
	switch (WarnLevel)
	{
		case NoWarning:
			return 1.f;
		case OneMinuteLeft:
			return 1.25f;
		case ThirtySecondsLeft:
			return 1.5f;
		case TenSecondsLeft:
			return 2.f;
		case OutOfTime:
			return 4.f;
	}

	return 1.f;
}

static final function int GetFontSizeForWarnLevel(EBorrowedTimeWarnLevel WarnLevel)
{
	switch (WarnLevel)
	{
		case NoWarning:
			return 2;
		case OneMinuteLeft:
			return 2;
		case ThirtySecondsLeft:
			return 1;
		case TenSecondsLeft:
			return 1;
		case OutOfTime:
			return 0;
	}

	return 2;
}

simulated function DrawBorrowedTime(Canvas C)
{
	local float TimeRemaining, SecondTime, MillisecondTime;
	local int MinutesRemaining;
	local string TimeString;
	local bool bLessThanMinuteRemains;
	local EBorrowedTimeWarnLevel WarnLevel;
	
	local float OffsetX, OffsetY, SizeY;
	local float TextSizeX, TextSizeY, TextScale;
	local float SizeX;

	TimeRemaining = BorrowedTimeActor.GetBorrowedTimeRemaining();

	if (TimeRemaining < 0.f)
	{
		bHasPlayedMinuteWarning = false;
		bHasPlayedThirtySecondsWarning = false;
		return;
	}

	WarnLevel = GetWarningForTime(TimeRemaining);
	
	MinutesRemaining = int(TimeRemaining) / 60;
	bLessThanMinuteRemains = MinutesRemaining <= 0;

	if (!bLessThanMinuteRemains)
	{
		SecondTime = Max(int(TimeRemaining) - (MinutesRemaining * 60), 0);
		TimeString = FillStringWithZeroes(MinutesRemaining, 2) $ ":" $ FillStringWithZeroes(int(SecondTime), 2);
	}
	else
	{
		SecondTime = Max(int(TimeRemaining), 0);
		MillisecondTime = TimeRemaining - SecondTime;
		MillisecondTime = MillisecondTime * 100.f;
		TimeString = FillStringWithZeroes(int(SecondTime), 2) $ ":" $ FillStringWithZeroes(string(Max(int(MillisecondTime), 0)), 2);
	}

	//Offset from right needs to match cash widget offset.
	OffsetX = C.ClipX - (C.ClipY * class'TurboHUDPlayer'.default.BackplateSpacing.Y);
	OffsetY = C.ClipY * class'TurboHUDWaveInfo'.default.BackplateSpacing.Y;
	SizeY = C.ClipY * class'TurboHUDWaveInfo'.default.BackplateSize.Y * GetTextScaleForWarnLevel(WarnLevel);

	C.DrawColor = BackplateColor;

	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = TurboHUD.LoadLargeNumberFont(GetFontSizeForWarnLevel(WarnLevel));
	C.TextSize(GetStringOfZeroes(Len(TimeString)), TextSizeX, TextSizeY);
	TextScale = (SizeY) / TextSizeY;
	C.FontScaleX = TextScale;
	C.FontScaleY = TextScale;
	C.TextSize(GetStringOfZeroes(Len(TimeString)), TextSizeX, TextSizeY);

	SizeX = C.ClipX * ((TextSizeX / C.ClipX) + 0.01f);

	C.SetPos(OffsetX - SizeX, OffsetY);

	if (RoundedContainer != None)
	{
		C.DrawTileStretched(RoundedContainer, SizeX, SizeY);
	}
	
	C.DrawColor = GetTextColorForWarnLevel(WarnLevel);
	C.SetPos((OffsetX - (SizeX * 0.5f)) - (TextSizeX * 0.5f), (OffsetY + (SizeY * 0.5f)) - (TextSizeY * 0.5f));
	DrawTextMeticulous(C, TimeString, TextSizeX);

	if (TimeRemaining <= 60)
	{
		CheckSoundWarning(TimeRemaining);
	}
}

simulated function CheckSoundWarning(int TimeRemaining)
{
	TimeRemaining = Max(TimeRemaining, 0);
	if (LastWarnTime == TimeRemaining)
	{
		return;
	}

	LastWarnTime = TimeRemaining;

	if (TimeRemaining < 10)
	{
		bHasPlayedThirtySecondsWarning = true;
		bHasPlayedMinuteWarning = true;
		TurboHUD.PlayerOwner.ClientPlaySound(TenSecondWarningSound,,, SLOT_None);
	}
	else if (!bHasPlayedThirtySecondsWarning && TimeRemaining < 30)
	{
		bHasPlayedThirtySecondsWarning = true;
		TurboHUD.PlayerOwner.ClientPlaySound(ThirtySecondsWarningSound,,, SLOT_None);
	}
	else if (!bHasPlayedMinuteWarning && TimeRemaining <= 60)
	{
		bHasPlayedMinuteWarning = true;
		TurboHUD.PlayerOwner.ClientPlaySound(MinuteWarningSound,,, SLOT_None);
	}
}

simulated function TickRackEmUp(float DeltaTime)
{
	if (PlayerCardCustomInfo.RackEmUpHeadshotCount == 0)
	{
		if (RackEmUpRatio > 0.f)
		{
			RackEmUpRatio = FMax(0.f, RackEmUpRatio - (DeltaTime * RackEmUpFadeOutRate));
		}
		else
		{
			RackEmUpLastKnownHeadshot = 0;
		}
		return;
	}

	if (RackEmUpRatio < 1.f)
	{
		RackEmUpRatio = Lerp(DeltaTime * RackEmUpFadeInRate, RackEmUpRatio, 1.f);
		if (Abs(1.f - RackEmUpRatio) < 0.001f)
		{
			RackEmUpRatio = 1.f;
		}
	}

	if (RackEmUpLastKnownHeadshot != PlayerCardCustomInfo.RackEmUpHeadshotCount)
	{
		if (RackEmUpLastKnownHeadshot < PlayerCardCustomInfo.RackEmUpHeadshotCount)
		{
			RackEmUpPulseRatio = Lerp(0.5f, RackEmUpPulseRatio, 1.f);
		}

		RackEmUpLastKnownHeadshot = PlayerCardCustomInfo.RackEmUpHeadshotCount;
	}
	else
	{
		RackEmUpPulseRatio = Lerp(DeltaTime * RackEmUpPulseFadeRate, RackEmUpPulseRatio, 0.f);
	}

	if (PlayerCardCustomInfo.RackEmUpHeadshotStackExpireTime != RackEmUpTimeEnd)
	{
		RackEmUpTimeEnd = PlayerCardCustomInfo.RackEmUpHeadshotStackExpireTime;
		RackEmUpTimeStart = ServerTimeActor.GetServerTimeSeconds();
	}
}

simulated function DrawRackEmUp(Canvas C)
{
	local float SizeX, SizeY;
	local float TempX, TempY;
	local float BarSizeX, BarSizeY;
	local float TextSizeX, TextSizeY, TextScale;

	if (RackEmUpRatio <= 0.f)
	{
		return;
	}

	class'TurboHUDKillingFloor'.static.ResetCanvas(C);

	SizeX = C.SizeX;
	SizeY = C.SizeY;
	BarSizeX = SizeY * class'TurboHUDPlayer'.default.WeightBackplateSize.X * 0.333f;
	BarSizeY = SizeY * class'TurboHUDPlayer'.default.WeightBackplateSize.Y;

	TempX = (SizeX * 0.5f) - (SizeY * (class'TurboHUDPlayer'.default.HealthBackplateSize.X + (class'TurboHUDPlayer'.default.BackplateSpacing.X * 1.5f)));
	TempX -= BarSizeX;

	TempY = SizeY - (BarSizeY + (SizeY * (class'TurboHUDPlayer'.default.BackplateSpacing.Y * 2.f)));

	C.Font = TurboHUD.LoadBoldItalicFont(BaseFontSize - 2);
	C.TextSize("00", TextSizeX, TextSizeY);
	TextScale = (BarSizeY / TextSizeY) * 1.f;

	BarSizeY = SizeY * class'TurboHUDPlayer'.default.WeightBackplateSize.Y * 0.25f;

	if (RackEmUpTimeStart <= 0.f || RackEmUpTimeEnd <= 0.f || RackEmUpTimeStart == RackEmUpTimeEnd || RackEmUpTimeEnd < ServerTimeActor.GetServerTimeSeconds())
	{
		C.SetPos(TempX, TempY - BarSizeY);
		C.DrawColor = MakeColor(0, 0, 0, 120.f * RackEmUpRatio);
		C.DrawTileStretched(TurboHUD.WhiteMaterial, BarSizeX, BarSizeY);
	}
	else
	{
		C.SetPos(TempX, TempY - BarSizeY);
		C.DrawColor = MakeColor(0, 0, 0, 120 * RackEmUpRatio);
		C.DrawTileStretched(TurboHUD.WhiteMaterial, BarSizeX, BarSizeY);
		C.DrawColor = MakeColor(255, 0, 0, 180 * RackEmUpRatio);
		C.DrawTileStretched(TurboHUD.WhiteMaterial, BarSizeX * FClamp((ServerTimeActor.GetServerTimeSecondsUntil(RackEmUpTimeEnd)) / (RackEmUpTimeEnd - RackEmUpTimeStart), 0.f , 1.f), BarSizeY);
	}

	C.FontScaleX = TextScale * (1.f + RackEmUpPulseRatio);
	C.FontScaleY = C.FontScaleX;

	C.TextSize(RackEmUpLastKnownHeadshot$"x", TextSizeX, TextSizeY);
	C.DrawColor = MakeColor(0.f, 0.f, 0.f, 128.f * RackEmUpRatio);
	C.SetPos(TempX + ((BarSizeX * 0.5f) - (TextSizeX * 0.5f)) + (TextSizeY * 0.1f), TempY - (TextSizeY * 0.6f));
	C.DrawColor = MakeColor(255, 255, 255, 255.f * RackEmUpRatio);
	C.SetPos(TempX + (BarSizeX * 0.5f) - (TextSizeX * 0.5f), TempY - (TextSizeY * 0.5f));
	C.DrawText(RackEmUpLastKnownHeadshot$"x");
}

defaultproperties
{
	VotedCardIndex=-1
	CardIndexToDisplay=-1
	VoteMenuScale=1.f

	FadeInAndUpRate=4.f
	FanOutRate=2.f

	HowToVoteString="Press %kshift%d and a %knumber%d to vote for a card!"
	HowCardsWorkString="Choose wisely! The selected card will %klast the whole game%d."
	HowToScrollCardsString(0)="Scroll up and"
	HowToScrollCardsString(1)="down to show"
	HowToScrollCardsString(2)="other cards!"
	
	BackplateColor=(R=0,G=0,B=0,A=140)	
	RoundedContainer=Texture'KFTurbo.HUD.ContainerRounded_D'

	bHasPlayedMinuteWarning=false
	bHasPlayedThirtySecondsWarning=false

	MinuteWarningSound=Sound'KF_FoundrySnd.1Shot.Alarm_BellWarning01'
	ThirtySecondsWarningSound=Sound'KF_FoundrySnd.Alarm_SirenLoop01'
	TenSecondWarningSound=Sound'KF_FoundrySnd.1Shot.Alarm_AlertWarning01'
	LastWarnTime=-1

	RackEmUpRatio=0.f
	RackEmUpFadeInRate=4.f
	RackEmUpFadeOutRate=2.f

	RackEmUpLastKnownHeadshot=0
	RackEmUpPulseRatio=0.f
	RackEmUpPulseFadeRate=6.f
	RackEmUpTimeStart=-1.f
	RackEmUpTimeEnd=-1.f
}