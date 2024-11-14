class V_Berserker extends KFTurbo.SRVetBerserker
	abstract;

static function AddCustomStats(ClientPerkRepLink Other)
{
	Super.AddCustomStats(Other);

	Other.AddCustomValue(class'VP_MeleeDamage');
}

static function int GetPerkProgressInt(ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum)
{
	switch (CurLevel)
	{
	case 0:
		FinalInt = 5000;
		break;
	case 1:
		FinalInt = 25000;
		break;
	case 2:
		FinalInt = 100000;
		break;
	case 3:
		FinalInt = 500000;
		break;
	case 4:
		FinalInt = 1500000;
		break;
	case 5:
		FinalInt = 3500000;
		break;
	case 6:
		FinalInt = 5500000;
		break;
	default:
		FinalInt = 5500000 + GetScaledRequirement(CurLevel - 5, 500000);
	}
	return Min(StatOther.RMeleeDamageStat + StatOther.GetCustomValueInt(class'VP_MeleeDamage'), FinalInt);
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float Multiplier;
	Multiplier = 1.f;

	switch (AmmoType)
	{
	case class'FragAmmo' :
		Multiplier *= LerpStat(KFPRI, 1.f, 1.2f);
		break;
	}

	ApplyAdjustedExtraAmmo(KFPRI, AmmoType, Multiplier);

	return Multiplier;
}

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if (class<KFWeaponDamageType>(DmgType) != none && class<KFWeaponDamageType>(DmgType).default.bIsMeleeDamage)
	{
		return float(InDamage) * LerpStat(KFPRI, 1.1f, 2.f);
	}

	return InDamage;
}


static function ApplyAdjustedFireRate(KFPlayerReplicationInfo KFPRI, Weapon Other, out float Multiplier)
{
	if (TurboGameReplicationInfo(KFPRI.Level.GRI) != None)
	{
		Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetFireRateMultiplier(KFPRI, Other);

		if (KFMeleeGun(Other) != None)
		{
			Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetBerserkerFireRateMultiplier(KFPRI, Other);
		}
	}
}

static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	local float Multiplier;
	Multiplier = 1.f;

	if (KFMeleeGun(Other) != none || Crossbuzzsaw(Other) != none)
	{
		Multiplier *= LerpStat(KFPRI, 1.f, 1.15f);
	}

	ApplyAdjustedFireRate(KFPRI, Other, Multiplier);

	return Multiplier;
}

static function float GetMeleeMovementSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	return LerpStat(KFPRI, 0.f, 0.25f);
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	switch(DmgType)
	{
		case class'DamTypeVomit':
			return float(InDamage) * static.GetBloatDamageReduction(KFPRI);
			break;
		case class'SirenScreamDamage':
			return float(InDamage) * static.GetSirenDamageReduction(KFPRI);
			break;
	}

	InDamage = float(InDamage) * LerpStat(KFPRI, 1.f, 0.85f);

	if (ZombieBoss(Instigator) != None)
	{
		InDamage = Min(InDamage, 95); //Boss will never one-shot a player
	}

	return InDamage;
}

static function float GetBloatDamageReduction(KFPlayerReplicationInfo KFPRI)
{
	return LerpStat(KFPRI, 1.f, 0.3f);
}

static function float GetSirenDamageReduction(KFPlayerReplicationInfo KFPRI)
{
	return LerpStat(KFPRI, 1.f, 0.6f);
}

static function bool CanMeleeStun()
{
	return true;
}

static function bool CanBeGrabbed(KFPlayerReplicationInfo KFPRI, KFMonster Other)
{
	return Super.CanBeGrabbed(KFPRI, Other);
}

static function int ZedTimeExtensions(KFPlayerReplicationInfo KFPRI)
{
	return Super(TurboVeterancyTypes).ZedTimeExtensions(KFPRI) + LerpStat(KFPRI, 1, 4);
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'V_Berserker_Grenade';
}

static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float Multiplier;
	Multiplier = 1.f;
	switch (Item)
	{
	case class'W_Axe_Pickup' :
	case class'W_Katana_Pickup' :
	case class'W_Chainsaw_Pickup' :
	case class'W_Crossbuzzsaw_Pickup' :

	case class'W_Claymore_Pickup' :
	case class'W_Scythe_Pickup' :
	case class'MachetePickup' :
	case class'DwarfAxePickup' :
		Multiplier *= LerpStat(KFPRI, 0.9f, 0.3f);
		break;
	}

	ApplyCostScalingModifier(KFPRI, Item, Multiplier);
	return Multiplier;
}

static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	KFHumanPawn(P).CreateInventoryVeterancy(string(class'Machete'), default.StartingWeaponSellPriceLevel6);
}

static function string GetCustomLevelInfo(byte Level)
{
	return default.SRLevelEffects[6];
}

defaultproperties
{
     OnHUDGoldIcon=Texture'KFTurbo.Perks.Berserker_D'
	 SRLevelEffects(6)="100% extra melee damage|15% faster melee attacks|20% faster melee movement|20% less damage from Siren scream|60% less damage from Bloat bile|10% resistance to all damage|70% discount on melee weapons|20% increase in grenade capacity|Grenades put zeds into Stasis, increasing the damage they take|Spawn with a Machete|Can't be grabbed by Clots|Up to 4 zed-time extensions"
}
