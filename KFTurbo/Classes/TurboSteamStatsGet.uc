//Killing Floor Turbo TurboSteamStatsGet
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboSteamStatsGet extends KFSteamStatsAndAchievements
	transient;

var TurboRepLink Link;

simulated event PostBeginPlay()
{
	PCOwner = Level.GetLocalPlayerController();
	Initialize(PCOwner);
	GetStatsAndAchievements();
}

simulated event PostNetBeginPlay();

simulated event OnStatsAndAchievementsReady()
{
	local int WeaponIndex, VariantIndex, WeaponLockID;
	local class<KFWeapon> WeaponClass;
	local ClientPerkRepLink CPRL;

	if (Link == None || PCOwner == None)
	{
		LifeSpan = 1.f;
		return;
	}

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

	CPRL = class'ClientPerkRepLink'.static.FindStats(PCOwner);
	for(WeaponIndex = (CPRL.ShopInventory.Length - 1); WeaponIndex>=0; --WeaponIndex)
	{
		if(CPRL.ShopInventory[WeaponIndex].bDLCLocked == 0 )
		{
			continue;
		}
		
		WeaponLockID = class<KFWeapon>(CPRL.ShopInventory[WeaponIndex].PC.Default.InventoryType).Default.AppID;
		if(WeaponLockID != 0)
		{
			if(PlayerOwnsWeaponDLC(WeaponLockID))
			{
				CPRL.ShopInventory[WeaponIndex].bDLCLocked = 0;
			}
			else if(class<KFWeapon>(CPRL.ShopInventory[WeaponIndex].PC.Default.InventoryType).Default.UnlockedByAchievement != -1)
			{
				CPRL.ShopInventory[WeaponIndex].bDLCLocked = 2; // Special hack for dwarf axe.
			}
			else
			{
				CPRL.ShopInventory[WeaponIndex].bDLCLocked = 1;
			}

			continue;
		}

		WeaponLockID = class<KFWeapon>(CPRL.ShopInventory[WeaponIndex].PC.Default.InventoryType).Default.UnlockedByAchievement;

		if( Achievements[WeaponLockID].bCompleted == 1 )
		{
			CPRL.ShopInventory[WeaponIndex].bDLCLocked = 0;
		}
		else
		{
			CPRL.ShopInventory[WeaponIndex].bDLCLocked = 2;
		}
	}

	UpdatePerkStats();

	LifeSpan = 1.f;
}

//Since we don't push these anymore, we need to do so now.
simulated function UpdatePerkStats()
{
	local TurboPlayerController PlayerController;
	local TurboSteamStatsHandler Handler;
	PlayerController = TurboPlayerController(PCOwner);
	if (PlayerController == None)
	{
		return;
	}

	//This guy will take our stats and wait patiently for server perks to finish reading from the ftp before notifying stats of their value.
	Handler = Spawn(class'TurboSteamStatsHandler', PCOwner);
	
	GetStatInt(DamageHealedStat, SteamNameStat[KFSTAT_DamageHealed]);
	Handler.SteamDamageHealedStat = DamageHealedStat.Value;
	GetStatInt(WeldingPointsStat, SteamNameStat[KFSTAT_WeldingPoints]);
	Handler.SteamWeldingPointsStat = WeldingPointsStat.Value;
	GetStatInt(ShotgunDamageStat, SteamNameStat[KFSTAT_ShotgunDamage]);
	Handler.SteamShotgunDamageStat = ShotgunDamageStat.Value;
	GetStatInt(HeadshotKillsStat, SteamNameStat[KFSTAT_HeadshotKills]);
	Handler.SteamHeadshotKillsStat = HeadshotKillsStat.Value;
	GetStatInt(StalkerKillsStat, SteamNameStat[KFSTAT_StalkerKills]);
	Handler.SteamStalkerKillsStat = StalkerKillsStat.Value;
	GetStatInt(BullpupDamageStat, SteamNameStat[KFSTAT_BullpupDamage]);
	Handler.SteamBullpupDamageStat = BullpupDamageStat.Value;
	GetStatInt(MeleeDamageStat, SteamNameStat[KFSTAT_MeleeDamage]);
	Handler.SteamMeleeDamageStat = MeleeDamageStat.Value;
	GetStatInt(FlameThrowerDamageStat, SteamNameStat[KFSTAT_FlameThrowerDamage]);
	Handler.SteamFlameThrowerDamageStat = FlameThrowerDamageStat.Value;
	GetStatInt(ExplosivesDamageStat, SteamNameStat[KFSTAT_ExplosivesDamage]);
	Handler.SteamExplosivesDamageStat = ExplosivesDamageStat.Value;
}

defaultproperties
{
	RemoteRole=ROLE_None
	LifeSpan=10.000000
}
