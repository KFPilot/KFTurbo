class V_SupportSpec extends SRVetSupportSpec
	abstract;

static function AddCustomStats(ClientPerkRepLink Other)
{
	Super.AddCustomStats(Other);

	Other.AddCustomValue(class'VP_ShotgunDamage');
}

static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	switch( CurLevel )
	{
	case 0:
		FinalInt = 1000;
		break;
	case 1:
		FinalInt = 5000;
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
		break;
	}

	return Min(StatOther.RShotgunDamageStat + StatOther.GetCustomValueInt(class'VP_ShotgunDamage'),FinalInt);
}

static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	switch (KFPRI.ClientVeteranSkillLevel)
	{
	case 0:
		return 0;
	case 1:
		return 2;
	case 2:
		return 3;
	case 3:
		return 4;
	case 4:
		return 5;
	case 5:
		return 8;
	default:
		return 9;
	}

	return 0;
}

static function float GetWeldSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	return LerpStat(KFPRI, 1.f, 2.5f);
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	local float Multiplier;

	Multiplier = 1.f;

	switch (AmmoType)
	{
	case class'W_AA12_Ammo' :
	case class'W_Benelli_Ammo' :
	case class'W_Boomstick_Ammo' :
	case class'W_KSG_Ammo' :
	case class'W_Shotgun_Ammo' :
	case class'TrenchgunAmmo' :
	case class'W_SPShotgun_Ammo' :
		Multiplier = LerpStat(KFPRI, 1.f, 1.3f);
		break;
	case class'W_NailGun_Ammo' :
		Multiplier = LerpStat(KFPRI, 1.f, 1.29f);
		break;
	case class'FragAmmo' :
		Multiplier = LerpStat(KFPRI, 1.f, 2.2f);
		break;
	}

	AddAdjustedExtraAmmoFor(KFPRI, AmmoType, Multiplier);

	return Multiplier;
}

static function AddAdjustedExtraAmmoFor(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType, out float Multiplier)
{
	if (!IsHighDifficulty(KFPRI))
	{
		return;
	}

	if (Multiplier > 1.f)
	{
		Multiplier *= 1.5f;
	}
	else if (AmmoType == class'FragAmmo')
	{
		Multiplier *= 2.f;
	}
}

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	switch (DmgType)
	{
	case class'W_NailGun_DT' :
	case class'DamTypeShotgun' :
	case class'DamTypeDBShotgun' :
	case class'DamTypeAA12Shotgun' :
	case class'DamTypeBenelli' :
	case class'DamTypeKSGShotgun' :
	case class'DamTypeSPShotgun' :
		return float(InDamage) * LerpStat(KFPRI, 1.1f, 1.6f);
	case class'DamTypeFrag' :
		return float(InDamage) * LerpStat(KFPRI, 1.05f, 1.5f);
	}

	return InDamage;
}

static function float GetShotgunPenetrationDamageMulti(KFPlayerReplicationInfo KFPRI, float DefaultPenDamageReduction)
{
	local float PenDamageInverse;

	PenDamageInverse = 1.0 - FMax(0, DefaultPenDamageReduction);

	switch (KFPRI.ClientVeteranSkillLevel)
	{
	case 0:
		return DefaultPenDamageReduction + (PenDamageInverse / 10.0);
	default:
		return DefaultPenDamageReduction + ((PenDamageInverse / 5.5555) * float(Min(KFPRI.ClientVeteranSkillLevel, 5)));
	}
}

static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	switch (Item)
	{
	case class'W_AA12_Pickup' :
	case class'W_Benelli_Pickup' :
	case class'W_Boomstick_Pickup' :
	case class'W_KSG_Pickup' :
	case class'W_Shotgun_Pickup' :
	case class'W_NailGun_Pickup' :
	case class'W_SPShotgun_Pickup' :
		return LerpStat(KFPRI, 0.9f, 0.3f);
	}

	return 1.f;
}

static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	KFHumanPawn(P).CreateInventoryVeterancy(string(class'W_Shotgun_Weap'), default.StartingWeaponSellPriceLevel6);
}

static function string GetCustomLevelInfo(byte Level)
{
	return default.SRLevelEffects[6];
}

defaultproperties
{
     OnHUDGoldIcon=Texture'KFTurbo.Perks.Support_D'
}
