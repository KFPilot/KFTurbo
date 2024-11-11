//Killing Floor Turbo TurboCardOverlay
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardOverlay extends TurboHUDOverlay;

var TurboCardReplicationInfo TCRI;
struct SelectableCardEntry
{
	var TurboCardActor CardActor;
	var float Ratio;
};
var array<SelectableCardEntry> CardRenderActorList;
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

var localized array<string> HowToScrollCardsString;
var float HowToScrollFade;

var Color BackplateColor;
var Texture RoundedContainer;

var PlayerBorrowedTimeActor BorrowedTimeActor;
var bool bHasPlayedMinuteWarning, bHasPlayedThirtySecondsWarning;
var Sound MinuteWarningSound, ThirtySecondsWarningSound, TenSecondWarningSound;
var int LastWarnTime;

enum EBorrowedTimeWarnLevel
{
	NoWarning,
	OneMinuteLeft,
	ThirtySecondsLeft,
	TenSecondsLeft,
	OutOfTime
};

//Bind to updates.
simulated function InitializeCardGameHUD(TurboCardReplicationInfo CGRI)
{
	TCRI = CGRI;
	CGRI.OnSelectableCardsUpdated = OnSelectableCardsUpdated;
	CGRI.OnActiveCardsUpdated = OnActiveCardsUpdated;
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

simulated function Tick(float DeltaTime)
{
	local int Index;

	Super.Tick(DeltaTime);

	if (TCRI == None)
	{
		return;
	}

	if (TCRI.bCurrentlyVoting)
	{
		VotedCardIndex = GetVoteIndex();

		for (Index = 0; Index < CardRenderActorList.Length; Index++)
		{
			if (Index == VotedCardIndex)
			{
				CardRenderActorList[Index].Ratio = FMin(Lerp(DeltaTime * 4.f, CardRenderActorList[Index].Ratio, 1.f), 1.f);
			}
			else
			{
				CardRenderActorList[Index].Ratio = FMax(Lerp(DeltaTime * 6.f, CardRenderActorList[Index].Ratio, 0.f), 0.f);
			}
		}
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
}

//Mouse wheel key events are forwarded here. Returns true if the key event should be consumed.
simulated function bool ReceivedKeyEvent(Interactions.EInputKey Key)
{
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
				CardRenderActorList[Index].CardActor = Spawn(class'TurboCardActor', Self);
			}

			CardRenderActorList[Index].CardActor.SetCardClass(TurboCard);
			CardRenderActorList[Index].Ratio = 0.f;
			continue;
		}

		CardRenderActorList.Length = Index + 1;
		CardRenderActorList[Index].CardActor = Spawn(class'TurboCardActor', Self);
		CardRenderActorList[Index].CardActor.SetCardClass(TurboCard);
	}

	CurrentCardCount = Index;
    log ("OnSelectableCardsUpdated - CurrentCardCount:"@CurrentCardCount);
}

simulated function Render(Canvas C)
{
	if (TCRI == None)
	{
		return;
	}
	
	C.Reset();
	C.DrawColor = class'HudBase'.default.WhiteColor;
	C.Style = ERenderStyle.STY_Alpha;

	if (TCRI.bCurrentlyVoting)
	{
		DrawSelectableCardList(C);
	}

	DrawActiveCardList(C);

	if (BorrowedTimeActor != None)
	{
		DrawBorrowedTime(C);
	}

	C.Reset();
	C.DrawColor = class'HudBase'.default.WhiteColor;
	C.Style = ERenderStyle.STY_Alpha;
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

	X += XOffset * VoteIndex;
	C.TextSize(PlayerName, TextSizeX, TextSizeY);
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
	if (!PRI.bIsSpectator)
	{
		Opacity = 255;
	}
	else
	{
		Opacity = 160;
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
	
	C.SetDrawColor(255, 255, 255, 255);
	C.Font = class'KFTurboFontHelper'.static.LoadBoldFontStatic(4);

	CenterIndex = float(CurrentCardCount) / 2.f;
	CardSize = FMin(C.ClipX / 9.f, 256.f);
	CardOffset = CardSize * 1.1f;
	CardScale = CardSize / 256.f;
	TempY = (C.ClipY / 1.75f) - (CardSize * 0.5f);
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

		CardSelectionScale = Lerp(CardRenderActorList[Index].Ratio, 1.f, 1.08f);

		CardRenderActorList[Index].CardActor.RenderOverlays(C);
		
		C.SetPos(TempX + (CardOffset * 0.5f) - (CardSize * CardSelectionScale * 0.5f), TempY - ((CardSelectionScale - 1.f) * CardSize));
		C.DrawTileScaled(CardRenderActorList[Index].CardActor.CardShader, CardScale * CardSelectionScale, CardScale * CardSelectionScale);
		TempX += CardOffset;
	}

	if (VotedCardIndex != -1)
	{
		CardSelectionScale = Lerp(CardRenderActorList[VotedCardIndex].Ratio, 1.f, 1.08f);
		C.SetPos(VotedCardX + (CardOffset * 0.5f) - (CardSize * CardSelectionScale * 0.5f), TempY - ((CardSelectionScale - 1.f) * CardSize));
		C.DrawTileScaled(CardRenderActorList[VotedCardIndex].CardActor.CardShader, CardScale * CardSelectionScale, CardScale * CardSelectionScale);
	}

	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;

	TempX = ((C.ClipX / 2.f) - (CenterIndex * CardOffset)) + (CardOffset * 0.5f);
	for (Index = Level.GRI.PRIArray.Length - 1; Index >= 0; Index--)
	{
		if (Level.GRI.PRIArray[Index].bIsSpectator)
		{
			continue;
		}

		DrawVoter(C, Level.GRI.PRIArray[Index], TempX, TempY, CardOffset, VoteList);
	}

	TempY += CardSize * 1.85f;
	TempX = (C.ClipX / 2.f);

	C.TextSize(HowToVoteString, TextSizeX, TextSizeY);
	TempX -= TextSizeX * 0.5f;

	TempX += 1.f + (Sin(Level.TimeSeconds * PI * 0.8f) * 6.f);
	TempY += 1.f + (Sin(Level.TimeSeconds * PI * 0.6f) * 8.f);

	C.SetDrawColor(0, 0, 0, 120);
	C.SetPos(TempX + 2.f, TempY + 2.f);
	C.DrawText(HowToVoteString);

	C.SetDrawColor(255, 255, 255, 255);
	C.SetPos(TempX, TempY);
	C.DrawText(HowToVoteString);
}

simulated function DrawActiveCardList(Canvas C)
{
	local int Index;
	local float CardSize, CardOffset, CardScale;
	local float CenterIndex;
	local float TempX, TempY;
	local float CardBonusScale;
	local float DisplayCardY;
	local float TextSizeX, TextSizeY, MaxTextSizeX;

	C.SetDrawColor(255, 255, 255, 255);

	CenterIndex = float(ActiveCardRenderActorList.Length) / 2.f;

	CardSize = FMin(C.ClipY / 6.f, 256.f);
	CardScale = CardSize / 512.f;
	CardOffset = CardSize * 0.175f;

	TempX = C.ClipX - (256.f * 0.9f * CardScale);
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

		CardBonusScale = Lerp(ActiveCardRenderActorList[Index].Ratio, 1.f, 2.f);

		ActiveCardRenderActorList[Index].CardActor.RenderOverlays(C);
		
		C.SetPos(TempX - (CardScale * (CardBonusScale - 1.f) * 256.f), TempY + (CardOffset * 0.5f) - (CardSize * 0.5f * CardBonusScale));
		C.DrawTileScaled(ActiveCardRenderActorList[Index].CardActor.CardShader, CardScale * CardBonusScale, CardScale * CardBonusScale);
		TempY += CardOffset;
	}

	if (CardIndexToDisplay != -1)
	{
		CardBonusScale = Lerp(ActiveCardRenderActorList[CardIndexToDisplay].Ratio, 1.f, 2.f);
		C.SetPos(TempX - (CardScale * (CardBonusScale - 1.f) * 256.f), DisplayCardY + (CardOffset * 0.5f) - (CardSize * 0.5f * CardBonusScale));
		C.DrawTileScaled(ActiveCardRenderActorList[CardIndexToDisplay].CardActor.CardShader, CardScale * CardBonusScale, CardScale * CardBonusScale);
	}

	if (ActiveCardRenderActorList.Length <= 1 || HowToScrollFade < 0.01f)
	{
		return;
	}

	C.Font = class'KFTurboFontHelper'.static.LoadFontStatic(5);
	TempX = C.ClipX - 2.f;
	TempY += CardSize * 0.7f; //Remainder of CardSize for a given CardOffset, plus some extra padding.

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
		
		C.SetDrawColor(0, 0, 0, Lerp(HowToScrollFade, 0, 120));
		C.SetPos((TempX - (TextSizeX * 0.5f)) + 2.f, TempY + 2.f);
		C.DrawTextClipped(HowToScrollCardsString[Index]);
		C.SetDrawColor(255, 255, 255, Lerp(HowToScrollFade, 0, 255));
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
	log("Active cards updated.");
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
				}

				continue;
			}
			else
			{
				break;
			}
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
		log("New active card"@ActiveCardRenderActorList[Index].CardActor.Card);
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

	if (BorrowedTimeActor.BorrowedTimeEnd == -1)
	{
		bHasPlayedMinuteWarning = false;
		bHasPlayedThirtySecondsWarning = false;
		return;
	}

	TimeRemaining = float(BorrowedTimeActor.BorrowedTimeEnd) - (BorrowedTimeActor.CurrentServerTime);
	TimeRemaining = FMax(TimeRemaining, 0.f);

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
	C.Font = class'KFTurboFontHelper'.static.LoadLargeNumberFont(GetFontSizeForWarnLevel(WarnLevel));
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
		KFPHUD.PlayerOwner.ClientPlaySound(TenSecondWarningSound,,, SLOT_Interface);
	}
	else if (!bHasPlayedThirtySecondsWarning && TimeRemaining < 30)
	{
		bHasPlayedThirtySecondsWarning = true;
		KFPHUD.PlayerOwner.ClientPlaySound(ThirtySecondsWarningSound,,, SLOT_Interface);
	}
	else if (!bHasPlayedMinuteWarning && TimeRemaining <= 60)
	{
		bHasPlayedMinuteWarning = true;
		KFPHUD.PlayerOwner.ClientPlaySound(MinuteWarningSound,,, SLOT_Interface);
	}
}

defaultproperties
{
	VotedCardIndex=-1
	CardIndexToDisplay=-1

	HowToVoteString="Press shift and a number to vote for a card!"
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
}