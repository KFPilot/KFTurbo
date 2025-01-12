class V_FieldMedic extends KFTurbo.TurboVeterancyTypes
	abstract;

static final function bool IsFieldMedic(KFPlayerReplicationInfo KFPRI)
{
	return KFPRI != None && class<V_FieldMedic>(KFPRI.ClientVeteranSkill) != None;
}

static function AddCustomStats(ClientPerkRepLink Other)
{
	Super.AddCustomStats(Other);

	Other.AddCustomValue(class'VP_DamageHealed');
}

static function int GetPerkProgressInt(ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum)
{
	switch (CurLevel)
	{
	case 0:
		FinalInt = 100;
		break;
	case 1:
		FinalInt = 200;
		break;
	case 2:
		FinalInt = 750;
		break;
	case 3:
		FinalInt = 4000;
		break;
	case 4:
		FinalInt = 12000;
		break;
	case 5:
		FinalInt = 25000;
		break;
	case 6:
		FinalInt = 100000;
		break;
	default:
		FinalInt = 100000 + GetScaledRequirement(CurLevel - 5, 3500);
	}
	return Min(StatOther.RDamageHealedStat + StatOther.GetCustomValueInt(class'VP_DamageHealed'), FinalInt);
}

static function bool IsPerkAmmunition(class<Ammunition> AmmoType)
{
	switch (AmmoType)
	{
		case class'FragAmmo':
		case class'W_MP7M_Ammo':
		case class'W_MP5M_Ammo':
		case class'W_KrissM_Ammo':
		case class'W_M7A3M_Ammo':
		case class'BlowerThrowerAmmo':
			return true;
	}

	return false;
}

static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	if (IsHighDifficulty(KFPRI))
	{
		return Super.AddCarryMaxWeight(KFPRI) + 2;
	}

	return Super.AddCarryMaxWeight(KFPRI);
}

static function ApplyAdjustedExtraAmmo(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType, out float Multiplier)
{
	Super.ApplyAdjustedExtraAmmo(KFPRI, AmmoType, Multiplier);

	if (TurboGameReplicationInfo(KFPRI.Level.GRI) != None && IsPerkAmmunition(AmmoType))
	{	
		Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetMaxAmmoMultiplier(KFPRI, AmmoType);
	}
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float Multiplier;
	Multiplier = 1.f;

	switch(AmmoType)
	{
	case class'W_M7A3M_Ammo' :
		Multiplier *= LerpStat(KFPRI, 1.f, 1.2f);
		break;
	case class'FragAmmo' :
		Multiplier *= LerpStat(KFPRI, 1.f, 1.2f);
		break;
	}

	ApplyAdjustedExtraAmmo(KFPRI, AmmoType, Multiplier);

	return Multiplier;
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'V_FieldMedic_Grenade';
}

static function float GetSyringeChargeRate(KFPlayerReplicationInfo KFPRI)
{
	return Super.GetHealPotency(KFPRI) * LerpStat(KFPRI, 1.1f, 3.f);
}

static function float GetHealPotency(KFPlayerReplicationInfo KFPRI)
{
	return Super.GetHealPotency(KFPRI) * LerpStat(KFPRI, 1.1f, 1.75f);
}

static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
	local float Multiplier;
	Multiplier = 1.f;
	ApplyAdjustedMovementSpeedModifier(KFPRI, KFGRI, Multiplier);
	return Multiplier * LerpStat(KFPRI, 1.f, 1.2f);
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	if (class<DamTypeVomit>(DmgType) != none)
	{
		if (Injured == Instigator)
		{
			return 0.f;
		}

		return float(InDamage) * LerpStat(KFPRI, 0.9f, 0.25f);
	}

	return InDamage;
}
static function ApplyAdjustedMagCapacityModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other, out float Multiplier)
{
	if (Other.default.MagCapacity <= 2)
	{
		return;
	}

	if (IsPerkWeapon(Other.Class) && TurboGameReplicationInfo(KFPRI.Level.GRI) != None)
	{
		Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetMedicMagazineAmmoMultiplier(KFPRI, Other);
	}

	Super.ApplyAdjustedMagCapacityModifier(KFPRI, Other, Multiplier);
}

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float Multiplier;
	Multiplier = 1.f;

	if(W_M7A3M_Weap(Other) != None)
	{
		Multiplier *= LerpStat(KFPRI, 1.f, 1.5f);
	}
	else if (KFMedicGun(Other) != None)
	{
		Multiplier *= LerpStat(KFPRI, 1.f, 2.f);
	}

	ApplyAdjustedMagCapacityModifier(KFPRI, Other, Multiplier);
	return Multiplier;
}

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	if(W_M7A3M_Ammo(Other) != None)
	{
		return LerpStat(KFPRI, 1.f, 1.5f);
	}
	else if (MP7MAmmo(Other) != None || MP5MAmmo(Other) != None || KrissMAmmo(Other) != None)
	{
		return LerpStat(KFPRI, 1.f, 2.f);
	}
	else if (BlowerThrowerAmmo(Other) != None)
	{
		return LerpStat(KFPRI, 1.f, 2.f);
	}

	return 1.f;
}

static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float Multiplier;
	Multiplier = 1.f;
	
	switch(Item)
	{
	case class'W_MP7M_Pickup' :
	case class'W_MP5M_Pickup' :
	case class'W_KrissM_Pickup' :
	case class'W_M7A3M_Pickup' :
	case class'W_BlowerThrower_Pickup' :
		Multiplier *= LerpStat(KFPRI, 0.75f, 0.5f);
		break;
	case class'Vest':
		Multiplier *= LerpStat(KFPRI, 0.9f, 0.3f);
		break;
	}

	ApplyCostScalingModifier(KFPRI, Item, Multiplier);
	return Multiplier;
}

static function float GetBodyArmorDamageModifier(KFPlayerReplicationInfo KFPRI)
{
	return Super.GetBodyArmorDamageModifier(KFPRI) * LerpStat(KFPRI, 1.f, 0.25f);
}

static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	P.ShieldStrength = 100;
	KFHumanPawn(P).CreateInventoryVeterancy(string(class'W_MP7M_Weap'), default.StartingWeaponSellPriceLevel6);
}

static function string GetCustomLevelInfo(byte Level)
{
	return default.SRLevelEffects[6];
}

defaultproperties
{
	HighDifficultyExtraAmmoMultiplier=1.5f
	HighDifficultyExtraGrenadeAmmoMultiplier=1.2f

	OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_Medic'
	OnHUDGoldIcon=Texture'KFTurbo.Perks.Medic_D'
	OnHUDIconMaxTier=Shader'KFTurbo.Perks.Medic_SHDR'
	
	VeterancyName="Field Medic"
	PerkIndex=0
	CustomLevelInfo=""
	Requirements(0)="Heal %x HP on your teammates."
	SRLevelEffects(6)="200% faster syringe recharge|75% more potent healing|75% less damage from Bloat bile|20% faster movement speed|100% larger medic gun clips|75% better body armor|70% discount on body armor|50% discount on medic guns|Grenades heal teammates and hurt enemies|Spawn with full armor and MP7M"
}
