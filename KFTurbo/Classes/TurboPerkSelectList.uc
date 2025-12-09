//Killing Floor Turbo TurboPerkSelectList
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPerkSelectList extends SRPerkSelectList;

var int HoverIndex;

var float LastUpdateTime;
var array<float> HoverRatioList;
var array<float> SelectRatioList;

var array< class<TurboVeterancyTypes> > PerkList;
var array<int> PerkLevelList;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
}

function InitList(KFSteamStatsAndAchievements StatsAndAchievements)
{
	local int PerkIndex;
	local TurboPlayerController KFPC;
	local ClientPerkRepLink CPRL;
	local class<KFVeterancyTypes> CurCL;
	local bool bFoundVeterancy;

	KFPC = TurboPlayerController(PlayerOwner());

	if (KFPC == None)
	{
		return;
	}

	if (KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo) != None)
	{
		CurCL = KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).ClientVeteranSkill;
	}
	
	CPRL = KFPC.GetClientPerkRepLink();

	if (CPRL == None)
	{
		return;
	}

	ItemCount = CPRL.CachePerks.Length;
	bFoundVeterancy = false;

	PerkName.Remove(0, PerkName.Length);
	PerkLevelString.Remove(0, PerkLevelString.Length);
	PerkProgress.Remove(0, PerkProgress.Length);
	PerkList.Remove(0, PerkList.Length);
	PerkLevelList.Remove(0, PerkLevelList.Length);

	for (PerkIndex = 0; PerkIndex < ItemCount; PerkIndex++)
	{
		PerkList[PerkIndex] = class<TurboVeterancyTypes>(CPRL.CachePerks[PerkIndex].PerkClass);
		PerkLevelList[PerkIndex] = CPRL.CachePerks[PerkIndex].CurrentLevel;
		PerkName[PerkIndex] = PerkList[PerkIndex].Static.GetVetInfoText(PerkLevelList[PerkIndex] - 1, 3);

		if (PerkLevelList[PerkIndex] == 0)
		{
			PerkLevelString[PerkIndex] = "N/A";
		}
		else
		{
			PerkLevelString[PerkIndex] = LvAbbrString @ (PerkLevelList[PerkIndex] - 1);
		}

		PerkProgress[PerkIndex] = PerkList[PerkIndex].Static.GetTotalProgress(CPRL, PerkLevelList[PerkIndex]);

		if (PerkList[PerkIndex] == CurCL)
		{
			SetIndex(PerkIndex);
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

	if (PerkList.Length <= CurIndex)
	{
		return;
	}

	PerkClass = PerkList[CurIndex];

	if (PerkClass == None)
	{
		return;
	}

	Y = Y + ItemSpacing / 2.0;
	Canvas.Style = 1;

	class'TurboHUDPerkEntryDrawer'.static.Draw(Canvas, TurboHUDKillingFloor(PlayerOwner().myHUD), X, Y + 7.0, Width, Height, PerkClass, PerkLevelList[CurIndex] - 1, PerkProgress[CurIndex], SelectRatioList[CurIndex], HoverRatioList[CurIndex], false);
	class'TurboHUDKillingFloor'.static.ResetCanvas(Canvas);
}

defaultproperties
{
	OnRendered=PostDraw
}
