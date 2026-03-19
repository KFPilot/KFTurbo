//Killing Floor Turbo TurboTypingPrompt
//Handles the drawing of messages and the typing prompt.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTypingPrompt extends Object
    instanced;

var array<SRHUDKillingFloor.SmileyMessageType> SortedEmoteList;

simulated function Initialize(TurboHUDKillingFloor HUD)
{
    SortedEmoteList = HUD.SmileyMsgs;
    SortEmoteList();
}

simulated function OnEmoteListUpdate(TurboHUDKillingFloor HUD)
{
    SortedEmoteList = HUD.SmileyMsgs;
    SortEmoteList();
}

//Insertion sort. Forces all emotes in SortedEmoteList to lowercase.
simulated function SortEmoteList()
{
	local int Index, InnerIndex;
	local SRHUDKillingFloor.SmileyMessageType Temp;

	for (Index = 0; Index < SortedEmoteList.Length; Index++)
	{
		SortedEmoteList[Index].SmileyTag = Locs(SortedEmoteList[Index].SmileyTag);
	}

	for (Index = 1; Index < SortedEmoteList.Length; Index++)
	{
		Temp = SortedEmoteList[Index];
		InnerIndex = Index - 1;

		while (InnerIndex >= 0 && StrCmp(SortedEmoteList[InnerIndex].SmileyTag, Temp.SmileyTag) > 0)
		{
			SortedEmoteList[InnerIndex + 1] = SortedEmoteList[InnerIndex];
			InnerIndex--;
		}

		SortedEmoteList[InnerIndex + 1] = Temp;
	}
}

function DisplayMessages(TurboHUDKillingFloor HUD, Canvas C)
{
	local int i, j, XPos, YPos,MessageCount;
	local float XL, YL, XXL, YYL;
	local float InitialClip;
	InitialClip = C.ClipX;
	C.ClipX = C.SizeX;

	for( i = 0; i < HUD.ConsoleMessageCount; i++ )
	{
		if ( HUD.TextMessages[i].Text == "" )
			break;
		else if( HUD.TextMessages[i].MessageLife < HUD.Level.TimeSeconds )
		{
			HUD.TextMessages[i].Text = "";

			if( i < HUD.ConsoleMessageCount - 1 )
			{
				for( j=i; j<HUD.ConsoleMessageCount-1; j++ )
					HUD.TextMessages[j] = HUD.TextMessages[j+1];
			}
			HUD.TextMessages[j].Text = "";
			break;
		}
		else
			MessageCount++;
	}

	YPos = (HUD.ConsoleMessagePosY * HUD.HudCanvasScale * C.SizeY) + (((1.0 - HUD.HudCanvasScale) / 2.0) * C.SizeY);
	if ( HUD.PlayerOwner == none || HUD.PlayerOwner.PlayerReplicationInfo == none || !HUD.PlayerOwner.PlayerReplicationInfo.bWaitingPlayer )
	{
		XPos = (HUD.ConsoleMessagePosX * HUD.HudCanvasScale * C.SizeX) + (((1.0 - HUD.HudCanvasScale) / 2.0) * C.SizeX);
	}
	else
	{
		XPos = (0.005 * HUD.HudCanvasScale * C.SizeX) + (((1.0 - HUD.HudCanvasScale) / 2.0) * C.SizeX);
	}

	if (HUD.bUseBaseGameFontForChat)
	{
		C.Font = HUD.GetDefaultConsoleFont(C);
	}
	else
	{
		C.Font = HUD.GetChatFont(C);
	}
	C.DrawColor = HUD.LevelActionFontColor;

	C.TextSize ("A", XL, YL);

	YPos -= YL * MessageCount+1; // DP_LowerLeft
	YPos -= YL; // Room for typing prompt

	for( i=0; i<MessageCount; i++ )
	{
		if ( HUD.TextMessages[i].Text == "" )
		{
			break;
		}

		C.DrawColor = C.MakeColor(0, 0, 0, 120);
		C.SetPos(XPos + 2.f, YPos + 2.f);
		if( HUD.TextMessages[i].PRI!=None )
		{
			XL = Class'SRScoreBoard'.Static.DrawCountryName(C,HUD.TextMessages[i].PRI,XPos + 2.f,YPos + 2.f);
			C.SetPos( XPos + XL + 2.f, YPos + 2.f );
		}

		if( SortedEmoteList.Length!=0 )
		{
			DrawScaledSmileyText(class'GUIComponent'.static.StripColorCodes(HUD.TextMessages[i].Text),C,,YYL);
		}
		else
		{
			C.DrawText(class'GUIComponent'.static.StripColorCodes(HUD.TextMessages[i].Text),false);
		}

		C.DrawColor = C.MakeColor(255, 255, 255, 255);
		YYL = 0;
		XXL = 0;
		
		C.SetPos(XPos, YPos);
		if( HUD.TextMessages[i].PRI!=None )
		{
			XL = Class'SRScoreBoard'.Static.DrawCountryName(C,HUD.TextMessages[i].PRI,XPos,YPos);
			C.SetPos( XPos+XL, YPos );
		}

		if( SortedEmoteList.Length!=0 )
		{
			DrawScaledSmileyText(HUD.TextMessages[i].Text,C,,YYL);
		}
		else
		{
			C.DrawText(HUD.TextMessages[i].Text,false);
		}
		YPos += (YL+YYL);
	}
	
	C.ClipX = InitialClip;
}

simulated function DrawTypingPrompt(TurboHUDKillingFloor HUD, Canvas C, String Text, optional int Pos)
{
    local float XPos, YPos;
    local float XL, YL;
	local string PromptText;
	
	if (HUD.bUseBaseGameFontForChat)
	{
		C.Font = HUD.GetDefaultConsoleFont(C);
	}
	else
	{
		C.Font = HUD.GetChatFont(C);
	}

    C.Style = HUD.ERenderStyle.STY_Alpha;

    C.TextSize("A", XL, YL);

    XPos = (HUD.ConsoleMessagePosX * HUD.HudCanvasScale * C.SizeX) + (((1.0 - HUD.HudCanvasScale) * 0.5) * C.SizeX);
    YPos = (HUD.ConsoleMessagePosY * HUD.HudCanvasScale * C.SizeY) + (((1.0 - HUD.HudCanvasScale) * 0.5) * C.SizeY) - YL;

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

//Returns list of possible emote hints for a given string. Uses binary search on SortedEmoteList.
simulated final function bool GetEmoteHintList(string EmoteText, out array<string> HintList)
{
	local int Low, Mid, High, Index;
	local int EmoteTextLength;
	local string LowerEmoteText;
	local int CompareResult;

	LowerEmoteText = Locs(EmoteText);
	EmoteTextLength = Len(LowerEmoteText);

	HintList.Length = 0;

	if (EmoteTextLength == 0 || SortedEmoteList.Length == 0)
	{
		return false;
	}

	//Binary search for the first entry whose prefix matches.
	Low = 0;
	High = SortedEmoteList.Length - 1;

	while (Low < High)
	{
		Mid = (Low + High) / 2;
		CompareResult = StrCmp(SortedEmoteList[Mid].SmileyTag, LowerEmoteText, EmoteTextLength);

		if (CompareResult < 0)
		{
			Low = Mid + 1;
		}
		else
		{
			High = Mid;
		}
	}

	//Walk forward from first match, collecting up to 8 results.
	for (Index = Low; Index < SortedEmoteList.Length && HintList.Length < 8; Index++)
	{
		if (StrCmp(SortedEmoteList[Index].SmileyTag, LowerEmoteText, EmoteTextLength) != 0)
		{
			break;
		}

        HintList.Insert(0, 1);
		HintList[0] = SortedEmoteList[Index].SmileyTag;
	}

	return HintList.Length > 0;
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

	if (Len(Text) <= 1 || !GetEmoteHintList(Text, HintList))
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

simulated final function DrawScaledSmileyText(string S, canvas C, optional out float XXL, optional out float XYL )
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
		S = Mid(S,i+Len(SortedEmoteList[n].SmileyTag));
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

		C.DrawRect(SortedEmoteList[n].SmileyTex, Sca * (float(SortedEmoteList[n].SmileyTex.USize) / float(SortedEmoteList[n].SmileyTex.VSize)), Sca);
		CurX += Sca * (float(SortedEmoteList[n].SmileyTex.USize) / float(SortedEmoteList[n].SmileyTex.VSize));

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

simulated final function int FindNextSmile( string S, out int SmileNr )
{
	local int Low, MidIndex, High;
	local int ColonStart, ColonEnd, SearchOffset;
	local string CS, EmoteCandidate;
	local int CompareResult, EmoteCandidateLength;

	CS = Locs(S);
	SearchOffset = 0;

	while (SearchOffset < Len(CS))
	{
		ColonStart = InStr(Mid(CS, SearchOffset), ":");
		if (ColonStart == -1)
		{
			return -1;
		}

		ColonStart += SearchOffset;
		ColonEnd = InStr(Mid(CS, ColonStart + 1), ":");
		if (ColonEnd == -1)
		{
			return -1;
		}

		ColonEnd += ColonStart + 1;
		EmoteCandidate = Mid(CS, ColonStart, ColonEnd - ColonStart + 1);
		EmoteCandidateLength = Len(EmoteCandidate);

		//Binary search for exact match.
		Low = 0;
		High = SortedEmoteList.Length - 1;

		while (Low <= High)
		{
			MidIndex = (Low + High) / 2;
			CompareResult = StrCmp(SortedEmoteList[MidIndex].SmileyTag, EmoteCandidate);

			if (CompareResult == 0)
			{
				SmileNr = MidIndex;
				return ColonStart;
			}
			else if (CompareResult < 0)
			{
				Low = MidIndex + 1;
			}
			else
			{
				High = MidIndex - 1;
			}
		}

		//No match for this pair, advance past the first colon.
		SearchOffset = ColonStart + 1;
	}

	return -1;
}
static final function string StripColorForTTS(string s) // Strip color codes.
{
	local int p;

	p = InStr(s,chr(27));
	while ( p>=0 )
	{
		s = left(s,p)$mid(S,p+4);
		p = InStr(s,Chr(27));
	}
	return s;
}