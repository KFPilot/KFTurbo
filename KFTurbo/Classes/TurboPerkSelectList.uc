//Killing Floor Turbo TurboPerkSelectList
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPerkSelectList extends SRPerkSelectList;

function InitList(KFSteamStatsAndAchievements StatsAndAchievements)
{
	local int i;
	local TurboPlayerController KFPC;
	local ClientPerkRepLink ST;
	local class<KFVeterancyTypes> CurCL;

	// Grab the Player Controller for later use
	KFPC = TurboPlayerController(PlayerOwner());

	if (KFPC == None)
	{
		return;
	}

	if (KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo) != None)
	{
		CurCL = KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).ClientVeteranSkill;
	}

	// Hold onto our reference
	ST = KFPC.GetClientPerkRepLink();

	if (ST == None)
	{
		return;
	}

	// Update the ItemCount and select the first item
	ItemCount = ST.CachePerks.Length;
	SetIndex(0);

	PerkName.Remove(0, PerkName.Length);
	PerkLevelString.Remove(0, PerkLevelString.Length);
	PerkProgress.Remove(0, PerkProgress.Length);

	for ( i = 0; i < ItemCount; i++ )
	{
		PerkName[PerkName.Length] = ST.CachePerks[i].PerkClass.Static.GetVetInfoText(ST.CachePerks[i].CurrentLevel - 1, 3);

		if (ST.CachePerks[i].CurrentLevel == 0)
		{
			PerkLevelString[PerkLevelString.Length] = "N/A";
		}
		else
		{
			PerkLevelString[PerkLevelString.Length] = LvAbbrString @ (ST.CachePerks[i].CurrentLevel - 1);
		}

		PerkProgress[PerkProgress.Length] = ST.CachePerks[i].PerkClass.Static.GetTotalProgress(ST,ST.CachePerks[i].CurrentLevel);

		if (ST.CachePerks[i].PerkClass == CurCL)
		{
			SetIndex(i);
		}
	}

	if (bNotify)
	{
		CheckLinkedObjects(Self);
	}

	if (MyScrollBar != none)
	{
		MyScrollBar.AlignThumb();
	}
}

function DrawPerk(Canvas Canvas, int CurIndex, float X, float Y, float Width, float Height, bool bSelected, bool bPending)
{
	local float TempX, TempY;
	local float PerkIconOffset;
	local float IconSize, ProgressBarWidth;
	local float TempWidth, TempHeight;
	local ClientPerkRepLink CPRL;
	local Material M,SM;

	CPRL = TurboPlayerController(Canvas.Viewport.Actor).GetClientPerkRepLink();

	if (CPRL == None)
	{
		return;
	}

	// Offset for the Background
	TempX = X;
	TempY = Y + ItemSpacing / 2.0;

	// Initialize the Canvas
	Canvas.Style = 1;
	Canvas.Font = class'ROHUD'.Static.GetSmallMenuFont(Canvas);
	Canvas.SetDrawColor(255, 255, 255, 255);

	// Draw Item Background
	PerkIconOffset = Height - ItemSpacing;
	IconSize = PerkIconOffset - (ItemBorder * 0.5f * Height);
	Canvas.SetPos(TempX + PerkIconOffset, Y + 7.0);
	if (bSelected)
	{
		Canvas.DrawTileStretched(SelectedInfoBackground, Width - PerkIconOffset, Height - ItemSpacing - 14);
	}
	else
	{
		Canvas.DrawTileStretched(InfoBackground, Width - PerkIconOffset, Height - ItemSpacing - 14);
	}

	Canvas.SetPos(TempX, TempY);
	if (bSelected)
	{
		Canvas.DrawTileStretched(SelectedPerkBackground, PerkIconOffset, PerkIconOffset);
	}
	else
	{
		Canvas.DrawTileStretched(PerkBackground, PerkIconOffset, PerkIconOffset);
	}

	// Offset and Calculate Icon's Size
	TempX += ItemBorder * Height * 0.25f;
	TempY += ItemBorder * Height * 0.25f;

	// Draw Icon
	Canvas.SetPos(TempX, TempY);
	CPRL.CachePerks[CurIndex].PerkClass.Static.PreDrawPerk(Canvas, Max(CPRL.CachePerks[CurIndex].CurrentLevel, 1) - 1, M, SM);
	Canvas.DrawTile(M, IconSize, IconSize, 0, 0, M.MaterialUSize(), M.MaterialVSize());

	TempX += IconSize + (IconToInfoSpacing * Width);
	TempY += TextTopOffset * Height;
	TempY += ItemBorder * Height * 0.75f;

	ProgressBarWidth = Width - (TempX - X) - (IconToInfoSpacing * Width);

	// Select Text Color
	if (CurIndex == MouseOverIndex)
	{
		Canvas.SetDrawColor(255, 0, 0, 255);
	}
	else 
	{
		Canvas.SetDrawColor(0, 0, 0, 255);
	}

	// Draw the Perk's Level Name
	Canvas.StrLen(PerkName[CurIndex], TempWidth, TempHeight);
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawText(PerkName[CurIndex]);

	// Draw the Perk's Level
	if ( PerkLevelString[CurIndex] != "" )
	{
		Canvas.StrLen(PerkLevelString[CurIndex], TempWidth, TempHeight);
		Canvas.SetPos(TempX + ProgressBarWidth - TempWidth, TempY);
		Canvas.DrawText(PerkLevelString[CurIndex]);
	}

	TempY = (Y + Height) - (ItemBorder * Height * 2.f);
	TempY -= ProgressBarHeight * Height;

	// Draw Progress Bar
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawTileStretched(ProgressBarBackground, ProgressBarWidth, ProgressBarHeight * Height);
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawTileStretched(ProgressBarForeground, ProgressBarWidth * PerkProgress[CurIndex], ProgressBarHeight * Height);
}

defaultproperties
{
	
}
