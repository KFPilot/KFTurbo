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

static final function float SetupNameFont(Canvas Canvas, TurboHUDKillingFloor TurboHUD, float Width, float Height)
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
	Canvas.FontScaleY = (Height * 0.5f) / TextSizeY;
	Canvas.FontScaleX = Canvas.FontScaleY;

	return TextSizeX * Canvas.FontScaleX;
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
	local float TempWidth, TempHeight, LevelTextX, CharacterSizeX;
	local Material M,SM;
    local Color TextColor, AccentColor;
    local string PerkLevelString;

	AccentColor = PerkClass.Static.GetPerkTierColor(PerkClass.Static.GetPerkTier(Level));
    
    TempX = X;
    TempY = Y;

	// Initialize the Canvas
	Canvas.Style = 1;
	Canvas.SetDrawColor(255, 255, 255, 255);

	// Draw Item Background
	PerkIconOffset = Height;
	IconSize = PerkIconOffset - (default.ItemBorderRatio * 0.5f * Height);

	if (SelectionRatio >= 1.f)
	{
		Canvas.SetDrawColor(255, 255, 255);
		Canvas.SetPos(TempX + PerkIconOffset, Y + 7.0);
		Canvas.DrawTileStretched(default.SelectedNameplateBackground, Width - PerkIconOffset, Height - 14);
		Canvas.SetPos(TempX, TempY);
		Canvas.DrawTileStretched(default.SelectedPerkBackground, PerkIconOffset, PerkIconOffset);
	}
	else if (HighlightRatio >= 1.f)
	{
		Canvas.SetDrawColor(255, 255, 255);
		Canvas.SetPos(TempX + PerkIconOffset, Y + 7.0);
		Canvas.DrawTileStretched(default.HighlightedNameplateBackground, Width - PerkIconOffset, Height - 14);
		Canvas.SetPos(TempX, TempY);
		Canvas.DrawTileStretched(default.HighlightedPerkBackground, PerkIconOffset, PerkIconOffset);
	}
	else
	{
		Canvas.SetDrawColor(255, 255, 255);
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
		}

		if (SelectionRatio > 0.f)
		{
			Canvas.DrawColor = class'TurboHUDOverlay'.static.MakeColor(255, 255, 255, byte(255.f * SelectionRatio));
			Canvas.SetPos(TempX + PerkIconOffset, Y + 7.0);
			Canvas.DrawTileStretched(default.SelectedNameplateBackground, Width - PerkIconOffset, Height - 14);
			Canvas.SetPos(TempX, TempY);
			Canvas.DrawTileStretched(default.SelectedPerkBackground, PerkIconOffset, PerkIconOffset);
		}
	}

	Canvas.SetDrawColor(255, 255, 255);

	// Offset and Calculate Icon's Size
	TempX += default.ItemBorderRatio * Height * 0.25f;
	TempY += default.ItemBorderRatio * Height * 0.25f;

	// Draw Icon
	DrawPerkStars(Canvas, TempX, TempY, IconSize, PerkClass.Static.PreDrawPerk(Canvas, Level, M, SM), SM);
	Canvas.SetPos(TempX, TempY);
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
	Canvas.DrawColor = AccentColor;
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawTileStretched(default.ProgressBarFill, ProgressBarWidth * FClamp(Progress, 0.f, 1.f), default.ProgressBarHeight * Height * 0.667f);

	CharacterSizeX = SetupNameFont(Canvas, TurboHUD, Width, Height);
	
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
        TextColor = class'TurboHUDOverlay'.static.LerpColor(HighlightRatio, default.PerkTextColor, AccentColor);
	}
	else 
	{
        TextColor = default.PerkTextColor;
	}

	// Draw the Perk's Level Name
    Canvas.SetDrawColor(0, 0, 0, 128);
	Canvas.SetPos(TempNameX + 2.f + (CharacterSizeX * 0.2f), TempNameY + 2.f);
	Canvas.ClipX = (TempNameX + ProgressBarWidth - LevelTextX);

	Canvas.TextSize(PerkClass.default.VeterancyName, TempWidth, TempHeight);
	class'TurboHUDOverlay'.static.DrawTextSpaced(Canvas, PerkClass.default.VeterancyName, CharacterSizeX * 0.1f);

	//Canvas.DrawTextClipped(PerkClass.default.VeterancyName);
    Canvas.DrawColor = TextColor;
	Canvas.SetPos(TempNameX + (CharacterSizeX * 0.2f), TempNameY);
	class'TurboHUDOverlay'.static.DrawTextSpaced(Canvas, PerkClass.default.VeterancyName, CharacterSizeX * 0.1f);
	//Canvas.DrawTextClipped(PerkClass.default.VeterancyName);
	Canvas.ClipX = Canvas.SizeX;

	// Draw the Perk's Level
    TempNameX = (TempNameX + ProgressBarWidth - LevelTextX);

    Canvas.SetDrawColor(0, 0, 0, 128);
    Canvas.SetPos(TempNameX + 2.f, TempNameY + 2.f);
    Canvas.DrawText(PerkLevelString);
    Canvas.DrawColor = TextColor;
    Canvas.SetPos(TempNameX, TempNameY);
    Canvas.DrawText(PerkLevelString);

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

static final function DrawPerkStars(Canvas Canvas, float IconX, float IconY, float IconSize, int StarCount, Material StarMaterial)
{
	local float TempX, TempY;
	local float StarSize;
	local int Index;

	TempX = IconX + (IconSize * 0.8f);
	TempY = IconY + (IconSize * 0.75f);

	StarSize = IconSize * (0.1667f);

	for (Index = 0; Index < StarCount; Index++)
	{
		Canvas.SetPos(TempX, TempY - (float(Index) * StarSize));
		Canvas.DrawTile(StarMaterial, StarSize, StarSize, 0, 0, StarMaterial.MaterialUSize(), StarMaterial.MaterialVSize());
	}
}

static final function DrawSimple(Canvas Canvas, TurboHUDKillingFloor TurboHUD, float X, float Y, float Width, float Height, class<TurboVeterancyTypes> PerkClass, byte Level, float HighlightRatio)
{
	local float TempX, TempY;
    local float TempNameX, TempNameY;
	local float PerkIconOffset;
	local float IconSize, ProgressBarWidth;
	local float TempWidth, TempHeight, LevelTextX, CharacterSizeX;
	local Material M,SM;
    local Color TextColor, AccentColor;
    local string PerkLevelString;

	AccentColor = PerkClass.Static.GetPerkTierColor(PerkClass.Static.GetPerkTier(Level));
    
    TempX = X;
    TempY = Y;

	// Initialize the Canvas
	Canvas.Style = 1;
	Canvas.SetDrawColor(255, 255, 255, 255);

	// Draw Item Background
	PerkIconOffset = Height;
	IconSize = PerkIconOffset - (default.ItemBorderRatio * 0.5f * Height);

	if (HighlightRatio >= 1.f)
	{
		Canvas.SetDrawColor(255, 255, 255);
		Canvas.SetPos(TempX + PerkIconOffset, Y + 7.0);
		Canvas.DrawTileStretched(default.HighlightedNameplateBackground, Width - PerkIconOffset, Height - 14);
		Canvas.SetPos(TempX, TempY);
		Canvas.DrawTileStretched(default.HighlightedPerkBackground, PerkIconOffset, PerkIconOffset);
	}
	else
	{
		Canvas.SetDrawColor(255, 255, 255);
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
		}
	}

	Canvas.SetDrawColor(255, 255, 255);

	// Offset and Calculate Icon's Size
	TempX += default.ItemBorderRatio * Height * 0.25f;
	TempY += default.ItemBorderRatio * Height * 0.25f;

	// Draw Icon
	DrawPerkStars(Canvas, TempX, TempY, IconSize, PerkClass.Static.PreDrawPerk(Canvas, Level, M, SM), SM);
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawTile(M, IconSize, IconSize, 0, 0, M.MaterialUSize(), M.MaterialVSize());

	TempX += IconSize + (default.PerkSpacingRatio * IconSize);
	TempY += default.ItemBorderRatio * Height * 0.75f;

    TempNameX = TempX;
    TempNameY = TempY - default.ItemBorderRatio * Height * 0.1f;

	TempY += default.PerkNameOffsetRatio * IconSize;

	ProgressBarWidth = Width - (TempX - X) - (default.PerkSpacingRatio * IconSize);


	TempY = (Y + Height) - (default.ItemBorderRatio * Height * 2.f);
	TempY -= default.ProgressBarHeight * Height * 0.667f;

	CharacterSizeX = SetupNameFont(Canvas, TurboHUD, Width, Height);
	
    PerkLevelString = class'KFPerkSelectList'.default.LvAbbrString @ Level;
    Canvas.TextSize(PerkLevelString, LevelTextX, TempHeight);
	Canvas.TextSize(PerkClass.default.VeterancyName, TempWidth, TempHeight);

	// Select Text Color
	if (HighlightRatio > 0.f)
	{
        TextColor = class'TurboHUDOverlay'.static.LerpColor(HighlightRatio, default.PerkTextColor, AccentColor);
	}
	else 
	{
        TextColor = default.PerkTextColor;
	}

	// Draw the Perk's Level Name
    Canvas.SetDrawColor(0, 0, 0, 128);
	Canvas.SetPos(TempNameX + 2.f + (CharacterSizeX * 0.2f), TempNameY + 2.f);
	Canvas.ClipX = (TempNameX + ProgressBarWidth - LevelTextX);

	Canvas.TextSize(PerkClass.default.VeterancyName, TempWidth, TempHeight);
	class'TurboHUDOverlay'.static.DrawTextSpaced(Canvas, PerkClass.default.VeterancyName, CharacterSizeX * 0.1f);

	//Canvas.DrawTextClipped(PerkClass.default.VeterancyName);
    Canvas.DrawColor = TextColor;
	Canvas.SetPos(TempNameX + (CharacterSizeX * 0.2f), TempNameY);
	class'TurboHUDOverlay'.static.DrawTextSpaced(Canvas, PerkClass.default.VeterancyName, CharacterSizeX * 0.1f);
	//Canvas.DrawTextClipped(PerkClass.default.VeterancyName);
	Canvas.ClipX = Canvas.SizeX;

	// Draw the Perk's Level
    TempNameX = (TempNameX + ProgressBarWidth - LevelTextX);

    Canvas.SetDrawColor(0, 0, 0, 128);
    Canvas.SetPos(TempNameX + 2.f, TempNameY + 2.f);
    Canvas.DrawText(PerkLevelString);
    Canvas.DrawColor = TextColor;
    Canvas.SetPos(TempNameX, TempNameY);
    Canvas.DrawText(PerkLevelString);
}

defaultproperties
{
    ItemBorderRatio=0.1f
    PerkSpacingRatio=0.1f
    PerkNameOffsetRatio=0.1f

    ProgressBarHeight=0.225f

	PerkBackground=Texture'KFTurboGUI.Perk.PerkBoxUnselected_D'
	SelectedPerkBackground=Texture'KFTurboGUI.Perk.PerkBoxSelected_D'
	HighlightedPerkBackground=Texture'KFTurboGUI.Perk.PerkBoxHighlighted_D'

	NameplateBackground=Texture'KFTurboGUI.Perk.PerkBackplateUnselected_D'
	SelectedNameplateBackground=Texture'KFTurboGUI.Perk.PerkBackplateSelected_D'
	HighlightedNameplateBackground=Texture'KFTurboGUI.Perk.PerkBackplateHighlighted_D'

	ProgressBarBackground=Texture'KF_InterfaceArt_tex.Menu.Innerborder'
	ProgressBarFill=Texture'KFTurbo.HUD.ContainerSquare_D'

	PerkTextColor=(R=200,G=200,B=200,A=255)
}