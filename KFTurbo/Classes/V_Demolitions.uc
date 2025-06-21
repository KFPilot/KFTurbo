//Killing Floor Turbo V_Demolitions
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class V_Demolitions extends TurboVeterancyTypes
	abstract;

static function AddCustomStats(ClientPerkRepLink Other)
{
	Super.AddCustomStats(Other);

	Other.AddCustomValue(class'VP_ExplosiveDamage');
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
	return Min(StatOther.RExplosivesDamageStat + StatOther.GetCustomValueInt(class'VP_ExplosiveDamage'), FinalInt);
}

static function bool IsPerkAmmunition(class<Ammunition> AmmoType)
{
	switch (AmmoType)
	{
		case class'FragAmmo':
		case class'W_LAW_Ammo':
		case class'W_SealSqueal_Ammo':
		case class'W_M79_Ammo':
		case class'W_M32_Ammo':
		case class'W_M4203_Ammo':
		case class'W_SPGrenade_Ammo':
		case class'W_SeekerSix_Ammo':
		case class'W_Pipebomb_Ammo':
			return true;
	}

	return false;
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float Multiplier;
	Multiplier = 1.f;

	switch (AmmoType)
	{
	case class'W_LAW_Ammo' :
		Multiplier *= LerpStat(KFPRI, 1.f, 1.5f);
		break;
	case class'W_Pipebomb_Ammo' :
		Multiplier *= LerpStat(KFPRI, 1.f, 4.f);
		break;
	case class'W_M4203_Ammo' :
		Multiplier *= LerpStat(KFPRI, 1.f, 1.5f);
		break;
	case class'FragAmmo' :
		Multiplier *= LerpStat(KFPRI, 1.f, 2.2f);
		break;
	}

	ApplyAdjustedExtraAmmo(KFPRI, AmmoType, Multiplier);

	return Multiplier;
}

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if (class<DamTypeM203Grenade>(DmgType) != none)
	{
		return float(InDamage) * LerpStat(KFPRI, 1.f, 1.9f);
	}

	if (class<DamTypeFrag>(DmgType) != none || class<DamTypePipeBomb>(DmgType) != none ||
		class<DamTypeM79Grenade>(DmgType) != none || class<DamTypeM32Grenade>(DmgType) != none
		|| class<DamTypeM203Grenade>(DmgType) != none || class<DamTypeRocketImpact>(DmgType) != none
		|| class<DamTypeSPGrenade>(DmgType) != none || class<DamTypeSealSquealExplosion>(DmgType) != none
		|| class<DamTypeSeekerSixRocket>(DmgType) != none)
	{
		return float(InDamage) * LerpStat(KFPRI, 1.05f, 1.6f);
	}

	return InDamage;
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DamageType)
{
	local class<KFWeaponDamageType> KFWeaponDamageType;
	local float DamageMultiplier;

	DamageMultiplier = 1.f;

	KFWeaponDamageType = class<KFWeaponDamageType>(DamageType);
	if (KFWeaponDamageType != None)
	{
		if (KFWeaponDamageType.default.bIsExplosive)
		{
			DamageMultiplier *= LerpStat(KFPRI, 1.f, 0.45f);
		}

		//This guy is meant to be used at closer range and can get dangerous.
		if (class<DamTypeSeekerSixRocket>(DamageType) != none)
		{
			DamageMultiplier *= LerpStat(KFPRI, 1.f, 0.75f);
		}
	}

	return float(InDamage) * DamageMultiplier;
}

static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	local float Multiplier;
	Multiplier = 1.f;

	if (LAW(Other) != None)
	{
		Multiplier *= LerpStat(KFPRI, 1.f, 1.4f);
	}

	ApplyAdjustedFireRate(KFPRI, Other, Multiplier);

	return Multiplier;
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float Multiplier;
	Multiplier = 1.f;

	if (LAW(Other) != None)
	{
		Multiplier *= LerpStat(KFPRI, 1.f, 1.4f);
	}

	ApplyAdjustedReloadRate(KFPRI, Other, Multiplier);
	return Multiplier;
}

static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float Multiplier;
	Multiplier = 1.f;

	switch(Item)
	{
		case class'W_LAW_Pickup':
		case class'W_SealSqueal_Pickup' :
		case class'W_M79_Pickup' :
		case class'W_M32_Pickup' :
		case class'W_M4203_Pickup' :
		case class'W_SPGrenade_Pickup' :
		case class'W_SeekerSix_Pickup' :
			Multiplier *= LerpStat(KFPRI, 0.9f, 0.5f);
			break;
		case class'W_Pipebomb_Pickup' :
			Multiplier *= LerpStat(KFPRI, 0.5f, 0.26f);
			break;
	}

	ApplyCostScalingModifier(KFPRI, Item, Multiplier);
	return Multiplier;
}

static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float Multiplier;
	Multiplier = 1.f;

	switch(Item)
	{
		case class'W_LAW_Pickup':
		case class'W_SealSqueal_Pickup' :
		case class'W_M79_Pickup' :
		case class'W_M32_Pickup' :

		case class'W_SPGrenade_Pickup' :
		case class'W_SeekerSix_Pickup' :
			Multiplier *= LerpStat(KFPRI, 1.f, 0.7f);
			break;
		case class'W_Pipebomb_Pickup' :
			Multiplier *= LerpStat(KFPRI, 0.5f, 0.26f);
			break;
	}

	ApplyAmmoCostScalingModifier(KFPRI, Item, Multiplier);
	return Multiplier;
}

static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	KFHumanPawn(P).CreateInventoryVeterancy(string(class'W_PipeBomb_Weap'), default.StartingWeaponSellPriceLevel5);
	KFHumanPawn(P).CreateInventoryVeterancy(string(class'W_M4203_Weap'), default.StartingWeaponSellPriceLevel6);
}

static function string GetCustomLevelInfo(byte Level)
{
	return default.SRLevelEffects[6];
}

defaultproperties
{
	HighDifficultyExtraAmmoMultiplier=1.25f
	HighDifficultyExtraGrenadeAmmoMultiplier=1.5f

	StartingWeaponSellPriceLevel5=0.000000
	StartingWeaponSellPriceLevel6=255.000000

	OnHUDIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Demolition'
	OnHUDGoldIcon=Texture'KFTurbo.Perks.Demolitions_D'
	OnHUDIconMaxTier=Shader'KFTurbo.Perks.Demolitions_SHDR'

	VeterancyName="Demolitions"
	PerkIndex=6
	CustomLevelInfo=""
	Requirements(0)="Deal %x damage with the explosives."
	SRLevelEffects(6)="60% extra explosives damage|55% resistance to explosives|50% increased capacity for M4 203 Grenades and LAW Rockets|40% faster firing rate with LAW|30% faster reload speed with LAW|120% increase in grenade capacity|Can carry 8 Pipe Bombs|30% discount on explosives|74% discount on Pipe Bombs|Spawn with an M4 203 Rifle and Pipe Bomb"
}
