//Killing Floor Turbo TurboHUDPerkEntryDrawer
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHUDPerkEntryDrawer extends Object;

var float ItemBorderRatio, PerkSpacingRatio;

var Texture NameplateBackground, SelectedNameplateBackground, HighlightedNameplateBackground;

var Texture PerkBackground, SelectedPerkBackground, HighlightedPerkBackground;
var float PerkNameOffsetRatio;

var	Texture	ProgressBarBackground, ProgressBarFill;
var float ProgressBarHeight;

var Color PerkTextColor;

static final function SetupNameFont(Canvas Canvas, TurboHUDKillingFloor TurboHUD, float Width, float Height)
{
	local float TextSizeX, TextSizeY;
	if (Height < 50)
	{
		Canvas.Font = TurboHUD.LoadBoldFont(4);
	}
	else if (Height < 80)
	{
		Canvas.Font = TurboHUD.LoadBoldFont(3);
	}
	else if (Height < 150)
	{
		Canvas.Font = TurboHUD.LoadBoldFont(2);
	}
	else
	{
		Canvas.Font = TurboHUD.LoadBoldFont(1);
	}

	Canvas.FontScaleX = 1.f;
	Canvas.FontScaleY = 1.f;
	Canvas.TextSize("A", TextSizeX, TextSizeY);
	Canvas.FontScaleY = (Height * 0.7f) / TextSizeY;
	Canvas.FontScaleX = Canvas.FontScaleY;
}

static final function SetupProgressFont(Canvas Canvas, TurboHUDKillingFloor TurboHUD, float BarWidth, float BarHeight)
{
	local float TextSizeX, TextSizeY;
	if (BarWidth < 50)
	{
		Canvas.Font = TurboHUD.LoadBoldFont(3);
	}
	else if (BarWidth < 80)
	{
		Canvas.Font = TurboHUD.LoadBoldFont(3);
	}
	else if (BarWidth < 150)
	{
		Canvas.Font = TurboHUD.LoadBoldFont(2);
	}
	else
	{
		Canvas.Font = TurboHUD.LoadBoldFont(1);
	}

	Canvas.FontScaleX = 1.f;
	Canvas.FontScaleY = 1.f;
	Canvas.TextSize("A", TextSizeX, TextSizeY);
	Canvas.FontScaleY = (BarHeight * 1.9f) / TextSizeY;
	Canvas.FontScaleX = Canvas.FontScaleY;
}

static final function Draw(Canvas Canvas, TurboHUDKillingFloor TurboHUD, float X, float Y, float Width, float Height, class<TurboVeterancyTypes> PerkClass, byte Level, float Progress, float SelectionRatio, float HighlightRatio, bool bScaleTextToFit)
{
	local float TempX, TempY;
    local float TempNameX, TempNameY;
	local float PerkIconOffset;
	local float IconSize, ProgressBarWidth;
	local float TempWidth, TempHeight, LevelTextX;
	local Material M,SM;
    local Color TextColor;
    local string PerkLevelString;
    
    TempX = X;
    TempY = Y;

	// Initialize the Canvas
	Canvas.Style = 1;
	Canvas.SetDrawColor(255, 255, 255, 255);

	// Draw Item Background
	PerkIconOffset = Height;
	IconSize = PerkIconOffset - (default.ItemBorderRatio * 0.5f * Height);
	if (SelectionRatio > 0.f)
	{
		Canvas.SetPos(TempX + PerkIconOffset, Y + 7.0);
		Canvas.DrawTileStretched(default.SelectedNameplateBackground, Width - PerkIconOffset, Height - 14);
		Canvas.SetPos(TempX, TempY);
		Canvas.DrawTileStretched(default.SelectedPerkBackground, PerkIconOffset, PerkIconOffset);
	}
	else
	{
		Canvas.SetPos(TempX + PerkIconOffset, Y + 7.0);
		Canvas.DrawTileStretched(default.NameplateBackground, Width - PerkIconOffset, Height - 14);
		Canvas.SetPos(TempX, TempY);
		Canvas.DrawTileStretched(default.PerkBackground, PerkIconOffset, PerkIconOffset);
		
		if (HighlightRatio > 0.f)
		{
			Canvas.DrawColor = class'TurboHUDOverlay'.static.MakeColor(255, 255, 255, byte(255.f * HighlightRatio));

			Canvas.SetPos(TempX + PerkIconOffset, Y + 7.0);
			Canvas.DrawTileStretched(default.HighlightedNameplateBackground, Width - PerkIconOffset, Height - 14);
			Canvas.SetPos(TempX, TempY);
			Canvas.DrawTileStretched(default.HighlightedPerkBackground, PerkIconOffset, PerkIconOffset);

			Canvas.SetDrawColor(255, 255, 255);
		}
	}

	// Offset and Calculate Icon's Size
	TempX += default.ItemBorderRatio * Height * 0.25f;
	TempY += default.ItemBorderRatio * Height * 0.25f;

	// Draw Icon
	Canvas.SetPos(TempX, TempY);
	PerkClass.Static.PreDrawPerk(Canvas, Max(Level, 1) - 1, M, SM);
	Canvas.DrawTile(M, IconSize, IconSize, 0, 0, M.MaterialUSize(), M.MaterialVSize());

	TempX += IconSize + (default.PerkSpacingRatio * IconSize);
	TempY += default.ItemBorderRatio * Height * 0.75f;

    TempNameX = TempX;
    TempNameY = TempY - default.ItemBorderRatio * Height * 0.1f;

	TempY += default.PerkNameOffsetRatio * IconSize;

	ProgressBarWidth = Width - (TempX - X) - (default.PerkSpacingRatio * IconSize);


	TempY = (Y + Height) - (default.ItemBorderRatio * Height * 2.f);
	TempY -= default.ProgressBarHeight * Height * 0.667f;

	// Draw Progress Bar
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawTileStretched(default.ProgressBarBackground, ProgressBarWidth, default.ProgressBarHeight * Height * 0.667f);
	Canvas.DrawColor = class'TurboLocalMessage'.default.KeywordColor;
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawTileStretched(default.ProgressBarFill, ProgressBarWidth * FClamp(Progress, 0.f, 1.f), default.ProgressBarHeight * Height * 0.667f);

	SetupNameFont(Canvas, TurboHUD, Width, Height);
	
    PerkLevelString = class'KFPerkSelectList'.default.LvAbbrString @ Level;
    Canvas.TextSize(PerkLevelString, LevelTextX, TempHeight);
	Canvas.TextSize(PerkClass.default.VeterancyName, TempWidth, TempHeight);

	if (bScaleTextToFit)
	{
		if (ProgressBarWidth - LevelTextX < TempWidth)
		{
			Canvas.FontScaleX *= (ProgressBarWidth - LevelTextX) / TempWidth;
			Canvas.FontScaleY = Canvas.FontScaleX;
		}
	}

	// Select Text Color
	if (HighlightRatio > 0.f)
	{
        TextColor = class'TurboHUDOverlay'.static.LerpColor(HighlightRatio, default.PerkTextColor, class'TurboLocalMessage'.default.KeywordColor);
	}
	else 
	{
        TextColor = default.PerkTextColor;
	}

	// Draw the Perk's Level Name
    Canvas.SetDrawColor(0, 0, 0, 128);
	Canvas.SetPos(TempNameX + 2.f, TempNameY + 2.f);
	Canvas.ClipX = (TempNameX + ProgressBarWidth - LevelTextX);
	Canvas.DrawTextClipped(PerkClass.default.VeterancyName);
    Canvas.DrawColor = TextColor;
	Canvas.SetPos(TempNameX, TempNameY);
	Canvas.DrawTextClipped(PerkClass.default.VeterancyName);
	Canvas.ClipX = Canvas.SizeX;

	// Draw the Perk's Level
    TempNameX = (TempNameX + ProgressBarWidth - LevelTextX);

    Canvas.SetDrawColor(0, 0, 0, 128);
    Canvas.SetPos(TempNameX + 2.f, TempNameY + 2.f);
    Canvas.DrawText(PerkLevelString);
    Canvas.DrawColor = TextColor;
    Canvas.SetPos(TempNameX, TempNameY);
    Canvas.DrawText(PerkLevelString);

	return;

	//Draws a percent on the bar. Might be worth trying to get this to look good sometime.
	SetupProgressFont(Canvas, TurboHUD, ProgressBarWidth * FClamp(Progress, 0.f, 1.f), default.ProgressBarHeight * Height * 0.667f);
	PerkLevelString = int(Progress * 100.f)$"%";
	Canvas.TextSize(PerkLevelString, TempWidth, TempHeight);

	TempX += (ProgressBarWidth * FClamp(Progress, 0.f, 1.f)) - TempWidth;
	TempY += (default.ProgressBarHeight * Height * 0.667f) - TempHeight;

	Canvas.SetPos(TempX + 1.f, TempY + 1.f);
    Canvas.SetDrawColor(0, 0, 0, 128);
	Canvas.DrawText(PerkLevelString);
	
	Canvas.SetPos(int(TempX), int(TempY));
	Canvas.DrawColor = default.PerkTextColor;
	Canvas.DrawText(PerkLevelString);
}

defaultproperties
{
    ItemBorderRatio=0.1f
    PerkSpacingRatio=0.1f
    PerkNameOffsetRatio=0.1f

    ProgressBarHeight=0.225f

	PerkBackground=Texture'KFTurbo.Perk.PerkBoxUnselected_D'
	SelectedPerkBackground=Texture'KFTurbo.Perk.PerkBoxSelected_D'
	HighlightedPerkBackground=Texture'KFTurbo.Perk.PerkBoxHighlighted_D'

	NameplateBackground=Texture'KFTurbo.Perk.PerkBackplateUnselected_D'
	SelectedNameplateBackground=Texture'KFTurbo.Perk.PerkBackplateSelected_D'
	HighlightedNameplateBackground=Texture'KFTurbo.Perk.PerkBackplateHighlighted_D'

	ProgressBarBackground=Texture'KF_InterfaceArt_tex.Menu.Innerborder'
	ProgressBarFill=Texture'KFTurbo.HUD.ContainerSquare_D'

	PerkTextColor=(R=200,G=200,B=200,A=255)
}