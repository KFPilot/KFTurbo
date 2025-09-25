//Killing Floor Turbo TurboPerkProgressList
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPerkProgressList extends SRPerkProgressList;

var TurboHUDKillingFloor TurboHUD;
var Color AccentColor;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	TurboHUD = TurboHUDKillingFloor(PlayerOwner().myHUD);
}

function PerkChanged(KFSteamStatsAndAchievements KFStatsAndAchievements, int NewPerkIndex)
{
	local ClientPerkRepLink ST;
	local class<TurboVeterancyTypes> TurboVeterancy;

	Super.PerkChanged(KFStatsAndAchievements, NewPerkIndex);

	ST = TurboPlayerController(PlayerOwner()).GetClientPerkRepLink();
	TurboVeterancy = class<TurboVeterancyTypes>(ST.CachePerks[NewPerkIndex].PerkClass);
	AccentColor = TurboVeterancy.Static.GetPerkTierColor(TurboVeterancy.Static.GetPerkTier(Max(ST.CachePerks[NewPerkIndex].CurrentLevel, 1) - 1));
}

function bool PreDraw(canvas Canvas)
{
    return true;
}

static final function UpdateFont(Canvas Canvas, TurboHUDKillingFloor TurboHUD, float Width, float Height)
{
	local float TextSizeX, TextSizeY;
	if (Height < 70)
	{
		Canvas.Font = TurboHUD.LoadFont(5);
	}
	if (Height < 100)
	{
		Canvas.Font = TurboHUD.LoadFont(4);
	}
    else if (Height < 160)
    {
		Canvas.Font = TurboHUD.LoadFont(3);
    }
	else
	{
		Canvas.Font = TurboHUD.LoadFont(2);
	}

	Canvas.FontScaleX = 1.f;
	Canvas.FontScaleY = 1.f;
	Canvas.TextSize("A", TextSizeX, TextSizeY);
	Canvas.FontScaleY = (Height * 0.275f) / TextSizeY;
	Canvas.FontScaleX = Canvas.FontScaleY;
}

function DrawPerk(Canvas Canvas, int CurIndex, float X, float Y, float Width, float Height, bool bSelected, bool bPending)
{
	local float TempX, TempY;
    local float TextSizeX, TextSizeY;
    local float Padding, BarHeight;

	class'TurboHUDKillingFloor'.static.ResetCanvas(Canvas);
    Padding = Height / 16.f;
    BarHeight = Height * 0.25f;
    
    UpdateFont(Canvas, TurboHUD, Width, Height);

    TempX = X;
	TempY = Y + Padding;
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawTileStretched(ItemBackground, Width, Height - (Padding * 2.f));
    
    Canvas.ClipX = (X + Width) - Padding;
    Canvas.OrgX = TempX + Padding;

    Canvas.SetPos((TempX + (Padding * 2.f)) - Canvas.OrgX, TempY + Padding);
    Canvas.DrawText(RequirementString[CurIndex]);

    //Restore clipping and origin.
    Canvas.ClipX = Canvas.SizeX;
    Canvas.OrgX = 0.f;

    TempX = X + (Padding * 2.f);
    TempY = (Y + Height) - (Padding * 2.f);
    TempY -= BarHeight;
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawTileStretched(ProgressBarBackground, Width - (Padding * 4.f), BarHeight);
	Canvas.DrawColor = AccentColor;
	Canvas.SetPos(TempX + 2.f, TempY + 2.f);
	Canvas.DrawTileStretched(ProgressBarForeground, ((Width - (Padding * 4.f)) - 4.f) * RequirementProgress[CurIndex], BarHeight - 4.f);

    TempX += Width - (Padding * 4.f);
    
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.TextSize(RequirementProgressString[Index], TextSizeX, TextSizeY);
    Canvas.FontScaleX *= ((BarHeight * 1.1f) / TextSizeY);
    Canvas.FontScaleY = Canvas.FontScaleX;
	Canvas.TextSize(RequirementProgressString[Index], TextSizeX, TextSizeY);
    TempX -= TextSizeX;
    TempY -= (TextSizeY * 0.05f);
	Canvas.SetPos(TempX, TempY);
    Canvas.DrawText(RequirementProgressString[CurIndex]);
}

defaultproperties
{
	ProgressBarForeground=Texture'KFTurbo.HUD.ContainerSquare_D'
}