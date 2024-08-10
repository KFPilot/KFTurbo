class TurboPerkSelectList extends SRPerkSelectList;

function InitList(KFSteamStatsAndAchievements StatsAndAchievements)
{
	local int i;
	local KFPlayerController KFPC;
	local ClientPerkRepLink ST;
	local class<KFVeterancyTypes> CurCL;

	// Grab the Player Controller for later use
	KFPC = KFPlayerController(PlayerOwner());

	if (KFPC == None)
	{
		return;
	}

	if (KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo) != None)
	{
		CurCL = KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).ClientVeteranSkill;
	}

	// Hold onto our reference
	ST = Class'ClientPerkRepLink'.Static.FindStats(PlayerOwner());

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

defaultproperties
{
}
