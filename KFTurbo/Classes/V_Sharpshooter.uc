//Killing Floor Turbo V_Sharpshooter
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class V_Sharpshooter extends TurboVeterancyTypes
	abstract;

static function AddCustomStats(ClientPerkRepLink Other)
{
	Super.AddCustomStats(Other);

	Other.AddCustomValue(class'VP_HeadshotKills');
}

static function int GetPerkProgressInt(ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum)
{
	switch (CurLevel)
	{
	case 0:
		FinalInt = 10;
		break;
	case 1:
		FinalInt = 30;
		break;
	case 2:
		FinalInt = 100;
		break;
	case 3:
		FinalInt = 700;
		break;
	case 4:
		FinalInt = 2500;
		break;
	case 5:
		FinalInt = 5500;
		break;
	case 6:
		FinalInt = 8500;
		break;
	default:
		FinalInt = 8000 + GetScaledRequirement(CurLevel - 4, 500);
	}
	return Min(StatOther.RHeadshotKillsStat + StatOther.GetCustomValueInt(class'VP_HeadshotKills'), FinalInt);
}

static function bool IsPerkAmmunition(class<Ammunition> AmmoType)
{
	switch (AmmoType)
	{
		case class'WeaponSingleAmmo':
		case class'WeaponDualiesAmmo':
		case class'WeaponWinchesterAmmo':
		case class'W_Magnum44_Ammo':
		case class'W_Deagle_Ammo':
		case class'W_M32_Ammo':
		case class'W_Crossbow_Ammo':
		case class'W_SPSniper_Ammo':
		case class'W_M14_Ammo':
		case class'W_M99_Ammo':
			return true;
	}
	
	return false;
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	return Super.AddExtraAmmoFor(KFPRI, AmmoType);
}

static function ApplyAdjustedExtraAmmo(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType, out float Multiplier)
{
	Super.ApplyAdjustedExtraAmmo(KFPRI, AmmoType, Multiplier);
}

static function float GetHeadShotDamMulti(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType)
{
	local float Multiplier;

	Multiplier = Super.GetHeadShotDamMulti(KFPRI, Pawn, DamageType);

	switch (DamageType)
	{
	case class'DamageTypeCrossbow' :
	case class'DamageTypeCrossbowHeadShot' :
	case class'DamageTypeWinchester' :
	case class'DamageTypeDeagle' :
	case class'DamageTypeDualDeagle' :
	case class'DamageTypeM14EBR' :
	case class'DamageTypeMagnum44Pistol' :
	case class'DamageTypeDual44Magnum' :
	case class'DamageTypeMK23Pistol' :
	case class'DamageTypeDualMK23Pistol' :
	case class'DamageTypeM99SniperRifle' :
	case class'DamageTypeM99HeadShot' :
	case class'DamageTypeSPSniper' :
	case class'W_SPSniper_DT' :
		Multiplier = LerpStat(KFPRI, 1.05f, 1.6f);
		break;
	case class'W_NailGun_DT' :	
		Multiplier = LerpStat(KFPRI, 1.05f, 1.2f);
		break;
	case class'W_Magnum44_DT' :
	case class'W_Dual44_DT' :
		return LerpStat(KFPRI, 1.05f, 1.45f);
		break;
	case class'DamageTypeDualies' :
		return LerpStat(KFPRI, 1.05f, 1.4f);
	}

	return Multiplier * LerpStat(KFPRI, 1.1f, 1.5f);
}

static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	Recoil = Super.ModifyRecoilSpread(KFPRI, Other, Recoil);

	if (WeaponCrossbow(Other.Weapon) != none || WeaponWinchester(Other.Weapon) != none
		|| WeaponSingle(Other.Weapon) != none || WeaponDualies(Other.Weapon) != none
		|| WeaponDeagle(Other.Weapon) != none || WeaponDualDeagle(Other.Weapon) != none
		|| WeaponM14EBRBattleRifle(Other.Weapon) != none || WeaponM99SniperRifle(Other.Weapon) != none
		|| WeaponSPSniperRifle(Other.Weapon) != none)
	{
		Recoil *= 0.25;
	}

	return Recoil;
}

static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	local float Multiplier;
	Multiplier = 1.f;

	if (WeaponCrossbow(Other) != None || WeaponM99SniperRifle(Other) != None)
	{
		Multiplier *= LerpStat(KFPRI, 1.f, 1.15f);
	}
	else if (WeaponWinchester(Other) != None || WeaponSPSniperRifle(Other) != None)
	{
		Multiplier *= LerpStat(KFPRI, 1.f, 1.6f);
	}

	ApplyAdjustedFireRate(KFPRI, Other, Multiplier);

	return Multiplier;
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float Multiplier;
	Multiplier = 1.f;

	if (WeaponCrossbow(Other) != None || WeaponM99SniperRifle(Other) != None)
	{
		Multiplier *= LerpStat(KFPRI, 1.f, 1.15f);
	}
	else if (WeaponWinchester(Other) != None
		|| WeaponSingle(Other) != None || WeaponDualies(Other) != None
		|| WeaponDeagle(Other) != None || WeaponDualDeagle(Other) != None
		|| WeaponMK23Pistol(Other) != None || WeaponDualMK23Pistol(Other) != None
		|| WeaponM14EBRBattleRifle(Other) != None
		|| WeaponSPSniperRifle(Other) != None || WeaponMagnum44Pistol(Other) != None 
		|| WeaponDual44Magnum(Other) != None) 
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
	
	switch(Item)
	{
		case class'W_MK23_Pickup':
		case class'W_DualMK23_Pickup':
		case class'W_Magnum44_Pickup':
		case class'W_Dual44_Pickup':
		case class'W_Deagle_Pickup':
		case class'W_DualDeagle_Pickup':
		case class'W_V_Deagle_Gold_Pickup':
		case class'W_V_DualDeagle_Gold_Pickup':
		case class'W_M14_Pickup' :
		case class'W_SPSniper_Pickup' :
			Multiplier *= LerpStat(KFPRI, 0.9f, 0.3f);
			break;

		case class'W_Crossbow_Pickup' :
		case class'W_M99_Pickup' :
			Multiplier *= 1.f;
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
		case class'W_Crossbow_Pickup':
		case class'W_M99_Pickup' :
			Multiplier *= LerpStat(KFPRI, 1.f, 0.7f);
			break;
	}

	ApplyAmmoCostScalingModifier(KFPRI, Item, Multiplier);
	return Multiplier;
}

static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	KFHumanPawn(P).CreateInventoryVeterancy(string(class'W_LAR_Weap'), default.StartingWeaponSellPriceLevel6);
	Super.AddDefaultInventory(KFPRI, P);
}

static function string GetCustomLevelInfo(byte Level)
{
	return default.SRLevelEffects[6];
}

defaultproperties
{
	HighDifficultyExtraAmmoMultiplier=1.25f
	HighDifficultyExtraGrenadeAmmoMultiplier=1.2f

	StartingWeaponSellPriceLevel5=255.000000
	StartingWeaponSellPriceLevel6=255.000000

	OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_SharpShooter'
	OnHUDGoldIcon=Texture'KFTurbo.Perks.Sharpshooter_D'
	OnHUDIconMaxTier=Shader'KFTurbo.Perks.Sharpshooter_SHDR'

	VeterancyName="Sharpshooter"
	PerkIndex=2
	CustomLevelInfo=""
	Requirements(0)="Get %x headshot kills with Sharpshooter weapons."
	SRLevelEffects(6)="2.4x bonus headshot multiplier for perk weapons|1.5x bonus headshot multiplier for off-perk weapons|60% faster reload with perk weapons|75% less recoil with perk weapons|70% discount on Pistols, M14 and S.P. Musket|30% faster firing rate on single-shot perk weapons|Spawn with a Lever Action Rifle"
}
