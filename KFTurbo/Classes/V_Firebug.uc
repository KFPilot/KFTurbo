class V_Firebug extends TurboVeterancyTypes
	abstract;

static function AddCustomStats(ClientPerkRepLink Other)
{
	Super.AddCustomStats(Other);

	Other.AddCustomValue(class'VP_FlamethrowerDamage');
}

static function int GetPerkProgressInt(ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum)
{
	switch (CurLevel)
	{
	case 0:
		FinalInt = 10000;
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
		FinalInt = 5500000 + GetScaledRequirement(CurLevel - 5, 250000);
	}
	return Min(StatOther.RFlameThrowerDamageStat + StatOther.GetCustomValueInt(class'VP_FlamethrowerDamage'), FinalInt);
}

static function bool IsPerkAmmunition(class<Ammunition> AmmoType)
{
	switch (AmmoType)
	{
		case class'FragAmmo':
		case class'W_MAC10_Ammo':
		case class'W_FlareRevolver_Ammo':
		case class'W_Flamethrower_Ammo':
		case class'W_ThompsonSMG_Ammo':
		case class'W_Trenchgun_Ammo':
		case class'W_Huskgun_Ammo':
			return true;
	}
	
	return false;
}

static function ApplyAdjustedFireRate(KFPlayerReplicationInfo KFPRI, Weapon Other, out float Multiplier)
{
	Super.ApplyAdjustedFireRate(KFPRI, Other, Multiplier);

	if (TurboGameReplicationInfo(KFPRI.Level.GRI) != None && IsPerkWeapon(class<KFWeapon>(Other.Class)))
	{
		Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetFirebugFireRateMultiplier(KFPRI, Other);
	}
}

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float Multiplier;
	Multiplier = 1.f;

	if (Flamethrower(Other) != None)
	{
		Multiplier *= LerpStat(KFPRI, 1.f, 1.2f);
	}
	else if (MAC10MP(Other) != None || ThompsonSMG(Other) != None)
	{
		Multiplier *= LerpStat(KFPRI, 1.f, 1.6f);
	}

	ApplyAdjustedMagCapacityModifier(KFPRI, Other, Multiplier);
	return Multiplier;
}

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	if ((W_Flamethrower_Ammo(Other) != none || W_MAC10_Ammo(Other) != none || W_Huskgun_Ammo(Other) != none || W_Trenchgun_Ammo(Other) != none || W_ThompsonSMG_Ammo(Other) != none || W_FlareRevolver_Ammo(Other) != none))
		return LerpStat(KFPRI, 1.f, 1.6f);
	return 1.0;
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float Multiplier;
	Multiplier = 1.f;

	ApplyAdjustedExtraAmmo(KFPRI, AmmoType, Multiplier);

	if (class<FragAmmo>(AmmoType) != None)
	{
		Multiplier *= LerpStat(KFPRI, 1.f, 1.2f);
	}
	else if (class<W_Flamethrower_Ammo>(AmmoType) != None)
	{
		Multiplier *= LerpStat(KFPRI, 1.f, 1.2f);
	}
	else if (IsPerkAmmunition(AmmoType))
	{
		Multiplier *= LerpStat(KFPRI, 1.f, 1.6f);
	}

	return Multiplier;
}

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	switch (DmgType)
	{
	case class'W_MAC10_DT' :
	case class'W_Trenchgun_DT' :
	case class'W_ThompsonSMG_DT' :
		return float(InDamage) * LerpStat(KFPRI, 1.f, 1.15);
	}

	if (class<DamTypeBurned>(DmgType) != none || class<DamTypeFlamethrower>(DmgType) != none || class<DamTypeHuskGunProjectileImpact>(DmgType) != none || class<W_FlareRevolver_Impact_DT>(DmgType) != none)
	{
		return float(InDamage) * LerpStat(KFPRI, 1.05f, 1.6f);
	}

	return InDamage;
}

static function int ExtraRange(KFPlayerReplicationInfo KFPRI)
{
	return 2;
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	if (class<DamTypeBurned>(DmgType) != none || class<DamTypeFlamethrower>(DmgType) != none || class<DamTypeHuskGunProjectileImpact>(DmgType) != none || class<W_FlareRevolver_Impact_DT>(DmgType) != none)
	{
		return float(InDamage) * LerpStat(KFPRI, 0.5f, 0.f);
	}

	return InDamage;
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'V_Firebug_Grenade';
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float Multiplier;
	Multiplier = 1.f;

	if (Flamethrower(Other) != none || MAC10MP(Other) != none || Trenchgun(Other) != none || FlareRevolver(Other) != none || DualFlareRevolver(Other) != none|| ThompsonSMG(Other) != none)
	{
		Multiplier *= LerpStat(KFPRI, 1.f, 1.6f);
	}

	ApplyAdjustedReloadRate(KFPRI, Other, Multiplier);
	return Multiplier;
}

static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float Multiplier;
	Multiplier = 1.f;
	
	switch (Item)
	{
	case class'W_FlameThrower_Pickup' :
	case class'W_MAC10_Pickup' :
	case class'W_ThompsonSMG_Pickup' :
	case class'W_Huskgun_Pickup' :
	case class'W_Trenchgun_Pickup' :
	case class'W_FlareRevolver_Pickup' :
	case class'W_DualFlare_Pickup' :
		Multiplier *= LerpStat(KFPRI, 0.9f, 0.3f);
		break;
	}

	ApplyCostScalingModifier(KFPRI, Item, Multiplier);
	return Multiplier;
}

static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	KFHumanPawn(P).CreateInventoryVeterancy(string(class'KFTurbo.W_MAC10_Weap'), default.StartingWeaponSellPriceLevel6);
}

static function class<DamageType> GetMAC10DamageType(KFPlayerReplicationInfo KFPRI)
{
	return class'W_MAC10_DT';
}

static function string GetCustomLevelInfo(byte Level)
{
	return default.SRLevelEffects[6];
}

defaultproperties
{
	HighDifficultyExtraAmmoMultiplier=1.5f
	HighDifficultyExtraGrenadeAmmoMultiplier=1.2f

	StartingWeaponSellPriceLevel5=255.000000
	StartingWeaponSellPriceLevel6=255.000000

	OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_Firebug'
	OnHUDGoldIcon=Texture'KFTurbo.Perks.Firebug_D'
	OnHUDIconMaxTier=Shader'KFTurbo.Perks.Firebug_SHDR'

    VeterancyName="Firebug"
	PerkIndex=5
	CustomLevelInfo=""
	Requirements(0)="Deal %x damage with weapons that cause Burning."
	SRLevelEffects(6)="60% extra damage with Flamethrower and Husk Gun|15% extra damage with MAC10, Trenchgun and Thompson Incendiary|60% faster reload speed with perk weapons|60% larger magazine for MAC-10 and Thompson Incendiary|60% more ammo for MAC-10 and Thompson Incendiary|20% more ammo and tank capacity for Flamethrower|100% extra Flamethrower range|Grenades set enemies on fire|70% discount on perk weapons|100% resistance to fire|Spawn with a MAC-10"
}