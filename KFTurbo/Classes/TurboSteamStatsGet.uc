Class TurboSteamStatsGet extends KFSteamStatsAndAchievements
	transient;

var TurboRepLink Link;

simulated event PostBeginPlay()
{
	PCOwner = Level.GetLocalPlayerController();
	Initialize(PCOwner);
	GetStatsAndAchievements();
	//log("Called GetStatsAndAchievements", 'KFTurbo');
}

simulated event PostNetBeginPlay();

simulated event OnStatsAndAchievementsReady()
{
	local int WeaponIndex, VariantIndex, WeaponLockID;
	local class<KFWeapon> WeaponClass;
	//log("Calling OnStatsAndAchievementsReady", 'KFTurbo');

	InitStatInt(OwnedWeaponDLC, GetOwnedWeaponDLC());

	for (WeaponIndex = Link.PlayerVariantList.Length - 1; WeaponIndex >= 0; --WeaponIndex)
	{
		for (VariantIndex = Link.PlayerVariantList[WeaponIndex].VariantList.Length - 1; VariantIndex >= 0; --VariantIndex)
		{
			//Skip items that don't need a lock.
			if (Link.PlayerVariantList[WeaponIndex].VariantList[VariantIndex].ItemStatus == 0)
			{
				continue;
			}

			WeaponClass = class<KFWeapon>(Link.PlayerVariantList[WeaponIndex].VariantList[VariantIndex].VariantClass.default.InventoryType);

			//Test DLC status.
			WeaponLockID = WeaponClass.default.AppID;
			if (WeaponLockID != 0)
			{
				if (PlayerOwnsWeaponDLC(WeaponLockID))
				{
					Link.PlayerVariantList[WeaponIndex].VariantList[VariantIndex].ItemStatus = 0;
				}
				else if (WeaponClass.default.UnlockedByAchievement != -1)
				{
					Link.PlayerVariantList[WeaponIndex].VariantList[VariantIndex].ItemStatus = 2;
				}
				else
				{
					Link.PlayerVariantList[WeaponIndex].VariantList[VariantIndex].ItemStatus = 1;
				}

				continue;
			}
			
			//Test achievement status.
			WeaponLockID = WeaponClass.default.UnlockedByAchievement;
			if (WeaponLockID != -1)
			{
				if (Achievements[WeaponLockID].bCompleted == 1)
				{
					Link.PlayerVariantList[WeaponIndex].VariantList[VariantIndex].ItemStatus = 0;
				}
				else
				{
					Link.PlayerVariantList[WeaponIndex].VariantList[VariantIndex].ItemStatus = 2;
				}

				continue;
			}

			Link.PlayerVariantList[WeaponIndex].VariantList[VariantIndex].ItemStatus = 0;
		}
	}

	//Link.DebugVariantInfo(false);

	UpdatePerkStats();

	LifeSpan = 1.f;
}

//Since we don't push these anymore, we need to do so now.
simulated function UpdatePerkStats()
{
	local TurboPlayerController PlayerController;
	PlayerController = TurboPlayerController(PCOwner);
	if (PlayerController == None)
	{
		return;
	}

	GetStatInt(DamageHealedStat, SteamNameStat[0]);
	SavedDamageHealedStat = DamageHealedStat.Value;
	PlayerController.InitializeSteamStatInt(0, DamageHealedStat.Value);

	GetStatInt(WeldingPointsStat, SteamNameStat[1]);
	SavedWeldingPointsStat = WeldingPointsStat.Value;
	PlayerController.InitializeSteamStatInt(1, WeldingPointsStat.Value);

	GetStatInt(ShotgunDamageStat, SteamNameStat[2]);
	SavedShotgunDamageStat = ShotgunDamageStat.Value;
	PlayerController.InitializeSteamStatInt(2, ShotgunDamageStat.Value);

	GetStatInt(HeadshotKillsStat, SteamNameStat[3]);
	SavedHeadshotKillsStat = HeadshotKillsStat.Value;
	PlayerController.InitializeSteamStatInt(3, HeadshotKillsStat.Value);

	GetStatInt(StalkerKillsStat, SteamNameStat[4]);
	SavedStalkerKillsStat = StalkerKillsStat.Value;
	PlayerController.InitializeSteamStatInt(4, StalkerKillsStat.Value);

	GetStatInt(BullpupDamageStat, SteamNameStat[5]);
	SavedBullpupDamageStat = BullpupDamageStat.Value;
	PlayerController.InitializeSteamStatInt(5, BullpupDamageStat.Value);

	GetStatInt(MeleeDamageStat, SteamNameStat[6]);
	SavedMeleeDamageStat = MeleeDamageStat.Value;
	PlayerController.InitializeSteamStatInt(6, MeleeDamageStat.Value);

	GetStatInt(FlameThrowerDamageStat, SteamNameStat[7]);
	SavedFlameThrowerDamageStat = FlameThrowerDamageStat.Value;
	PlayerController.InitializeSteamStatInt(7, FlameThrowerDamageStat.Value);

	GetStatInt(ExplosivesDamageStat, SteamNameStat[21]);
	SavedExplosivesDamageStat = ExplosivesDamageStat.Value;
	PlayerController.InitializeSteamStatInt(21, ExplosivesDamageStat.Value);
}

defaultproperties
{
	RemoteRole=ROLE_None
	LifeSpan=10.000000
}