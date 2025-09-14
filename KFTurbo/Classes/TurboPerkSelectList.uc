//Killing Floor Turbo TurboPerkSelectList
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPerkSelectList extends SRPerkSelectList;

var TurboHUDKillingFloor TurboHUD;
var ClientPerkRepLink CPRL;
var int HoverIndex;

var float LastUpdateTime;
var array<float> HoverRatioList;
var array<float> SelectRatioList;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	TurboHUD = TurboHUDKillingFloor(PlayerOwner().myHUD);
	CPRL = TurboPlayerController(PlayerOwner()).GetClientPerkRepLink();
}

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

	HoverRatioList.Length = ItemCount;
	SelectRatioList.Length = ItemCount;
	LastUpdateTime = KFPC.Level.TimeSeconds;

	if (bNotify)
	{
		CheckLinkedObjects(Self);
	}

	if (MyScrollBar != none)
	{
		MyScrollBar.AlignThumb();
	}
}

function bool PreDraw(Canvas Canvas)
{
	if (CPRL == None)
	{
		CPRL = TurboPlayerController(Canvas.Viewport.Actor).GetClientPerkRepLink();
	}

	if (IsInBounds())
	{
		HoverIndex = CalculateIndex();
	}
	else
	{
		HoverIndex = -1;
	}

	TickHover();
	
	return Super.PreDraw(Canvas);
}


function PostDraw(Canvas Canvas)
{
	class'TurboHUDKillingFloor'.static.ResetCanvas(Canvas);
}

function TickHover()
{
	local float LevelTimeSeconds;
	local float DeltaTime;
	local int ItemIndex;

	if (PlayerOwner().Level.TimeSeconds == LastUpdateTime)
	{
		return;
	}

	LevelTimeSeconds = PlayerOwner().Level.TimeSeconds;
	DeltaTime = LevelTimeSeconds - LastUpdateTime;
	LastUpdateTime = LevelTimeSeconds;

	for (ItemIndex = 0; ItemIndex < HoverRatioList.Length; ItemIndex++)
	{
		if (HoverIndex == ItemIndex)
		{
			HoverRatioList[ItemIndex] = Lerp(DeltaTime * 20.f, HoverRatioList[ItemIndex], 1.f);
		}
		else if (HoverRatioList[ItemIndex] != 0.f)
		{
			HoverRatioList[ItemIndex] = Lerp(DeltaTime * 4.f, HoverRatioList[ItemIndex], 0.f);

			if (Abs(HoverRatioList[ItemIndex]) < 0.001f)
			{
				HoverRatioList[ItemIndex] = 0.f;
			}
		}

		if (Index == ItemIndex)
		{
			SelectRatioList[ItemIndex] = Lerp(DeltaTime * 32.f, SelectRatioList[ItemIndex], 1.f);
		}
		else if (SelectRatioList[ItemIndex] != 0.f)
		{
			SelectRatioList[ItemIndex] = Lerp(DeltaTime * 16.f, SelectRatioList[ItemIndex], 0.f);
		}
	}
}

function DrawPerk(Canvas Canvas, int CurIndex, float X, float Y, float Width, float Height, bool bSelected, bool bPending)
{
	local class<TurboVeterancyTypes> PerkClass;

	if (CPRL == None)
	{
		return;
	}

	PerkClass = class<TurboVeterancyTypes>(CPRL.CachePerks[CurIndex].PerkClass);

	if (PerkClass == None)
	{
		return;
	}

	Y = Y + ItemSpacing / 2.0;
	Canvas.Style = 1;

	class'TurboHUDPerkEntryDrawer'.static.Draw(Canvas, TurboHUD, X, Y + 7.0, Width, Height, PerkClass, CPRL.CachePerks[CurIndex].CurrentLevel - 1, PerkClass.Static.GetTotalProgress(CPRL, CPRL.CachePerks[CurIndex].CurrentLevel), SelectRatioList[CurIndex], HoverRatioList[CurIndex], false);
	class'TurboHUDKillingFloor'.static.ResetCanvas(Canvas);
}

defaultproperties
{
	OnRendered=PostDraw
}
