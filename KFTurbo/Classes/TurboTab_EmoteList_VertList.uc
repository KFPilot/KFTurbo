//Killing Floor Turbo TurboTab_EmoteList_VertList
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTab_EmoteList_VertList extends GUIVertList;

var Texture IconBackground;
var	Texture EntryBackplate;

var array<SRHUDKillingFloor.SmileyMessageType> SmileyTags;

const EMOTES_PER_ENTRY = 3;

function bool PreDraw(Canvas Canvas)
{
	return false;
}

function InitList(ClientPerkRepLink CPRL)
{
	SetIndex(0);

	if (SmileyTags.Length >= CPRL.SmileyTags.Length)
	{
		return;
	}

	SmileyTags = CPRL.SmileyTags;
	ItemCount = Ceil(float(SmileyTags.Length) / 3.f);

	if (bNotify)
 	{
		CheckLinkedObjects(Self);
	}

	if (MyScrollBar != None)
	{
		MyScrollBar.AlignThumb();
	}
}

function DrawEmote(Canvas Canvas, int CurIndex, float X, float Y, float Width, float Height, bool bSelected, bool bPending)
{
	local int EmoteIndex;
	local float EmoteEntryWidth;
	local float TempX, TempY;
	local float TextSizeX, TextSizeY;
	local string EmoteText;
	local float RatioX;

	if (Canvas.Style != 1)
	{
		Canvas.Style = 1;
	}

	Height *= 0.95f;
	EmoteEntryWidth = Width / float(EMOTES_PER_ENTRY);

	for (EmoteIndex = (CurIndex * EMOTES_PER_ENTRY) + (EMOTES_PER_ENTRY - 1); EmoteIndex >= (CurIndex * EMOTES_PER_ENTRY); EmoteIndex--)
	{
		if (EmoteIndex >= SmileyTags.Length)
		{
			X -= EmoteEntryWidth;
			continue;
		}

		RatioX = float(SmileyTags[EmoteIndex].SmileyTex.USize) / float(SmileyTags[EmoteIndex].SmileyTex.VSize);

		TempX = (X + Width) - EmoteEntryWidth;
		TempY = Y;

		Canvas.SetDrawColor(255, 255, 255, 255);
		Canvas.SetPos(TempX + (Height * RatioX), TempY + (Height * 0.05f));
		Canvas.DrawTileStretched(EntryBackplate, (EmoteEntryWidth - (Height * RatioX)) - 2.f, Height * 0.9f);

		Canvas.SetPos(TempX, TempY);
		Canvas.DrawTileStretched(IconBackground, Height * RatioX, Height);

		TempX += Height * RatioX * 0.1f;

		Canvas.SetPos(TempX, TempY + (0.1f * Height));

		Canvas.DrawRect(SmileyTags[EmoteIndex].SmileyTex, (RatioX * Height * 0.8f), (0.8f * Height));
		
		TempX += RatioX * Height * 0.9f;

		Canvas.SetDrawColor(0, 0, 0, 255);
		Canvas.Font = class'TurboHUDKillingFloor'.Static.GetSmallMenuFont(Canvas);
		EmoteText = Locs(SmileyTags[EmoteIndex].SmileyTag);
		Canvas.TextSize(EmoteText, TextSizeX, TextSizeY);

		TempY += (Height * 0.5f) - (TextSizeY * 0.5f);
		Canvas.SetPos(((X + Width) - (Height * 0.2f)) - TextSizeX, TempY);
		Canvas.DrawText(EmoteText);

		X -= EmoteEntryWidth;
	}
}

function float GetEmoteEntryHeight(Canvas C)
{
	return (MenuOwner.ActualHeight() / 10.f) - 1.f;
}

defaultproperties
{
	IconBackground=Texture'KF_InterfaceArt_tex.Menu.Item_box_box'
	EntryBackplate=Texture'KF_InterfaceArt_tex.Menu.Item_box_bar'
	FontScale=FNS_Medium

	OnPreDraw=PreDraw
	GetItemHeight=GetEmoteEntryHeight
	OnDrawItem=DrawEmote
}
