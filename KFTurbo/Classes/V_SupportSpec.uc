class V_SupportSpec extends KFTurbo.SRVetSupportSpec
	abstract;

static function AddCustomStats(ClientPerkRepLink Other)
{
	Super.AddCustomStats(Other);

	Other.AddCustomValue(class'VP_ShotgunDamage');
}

//Used to grant shotgun damage for doing damage through zeds.
static function RewardPenetrationShotgunDamage(PlayerController Target, int Amount)
{
	local ClientPerkRepLink TargetCPRL;
	if (Target == None || Target.Role != ROLE_Authority)
	{
		return;
	}

	TargetCPRL = class'ClientPerkRepLink'.static.FindStats(Target);

	if (TargetCPRL == None || TargetCPRL.StatObject == None)
	{
		return;
	}

	//Give an extra 33% of damage dealt with a shotgun from a penetrated hit.
	TargetCPRL.StatObject.AddShotgunDamage(int(float(Amount) * 0.33f));
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
		FinalInt = 5500000 + GetScaledRequirement(CurLevel - 5, 250000);
		break;
	}

	return Min(StatOther.RShotgunDamageStat + StatOther.GetCustomValueInt(class'VP_ShotgunDamage'),FinalInt);
}

static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	return Super(TurboVeterancyTypes).AddCarryMaxWeight(KFPRI) + 9;
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

	ApplyAdjustedExtraAmmo(KFPRI, AmmoType, Multiplier);
	return Multiplier;
}

static function ApplyAdjustedExtraAmmo(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType, out float Multiplier)
{
	if (!IsHighDifficulty(KFPRI))
	{
		Super.ApplyAdjustedExtraAmmo(KFPRI, AmmoType, Multiplier);
		return;
	}

	switch (AmmoType)
	{
		case class'FragAmmo':
			Multiplier *= 1.3334f;
			break;
	}
	
	Super.ApplyAdjustedExtraAmmo(KFPRI, AmmoType, Multiplier);
}

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	switch (DmgType)
	{
	case class'W_NailGun_DT' :
	case class'DamTypeShotgun' :
	case class'W_BoomStick_DT' :
	case class'W_AA12_DT' :
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
	local float ReductionAmount;
	ReductionAmount = LerpStat(KFPRI, 1.f, 6.f);
	ReductionAmount *= GetWeaponPenetrationMultiplier(KFPRI, None);
	return DefaultPenDamageReduction ** (1.f / ((1.75f * ReductionAmount) - 0.775f));
}

static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float Multiplier;
	Multiplier = 1.f;
	
	switch (Item)
	{
	case class'W_AA12_Pickup' :
	case class'W_Benelli_Pickup' :
	case class'W_Boomstick_Pickup' :
	case class'W_KSG_Pickup' :
	case class'W_Shotgun_Pickup' :
	case class'W_NailGun_Pickup' :
	case class'W_SPShotgun_Pickup' :
		Multiplier *= LerpStat(KFPRI, 0.9f, 0.3f);
		break;
	}

	ApplyCostScalingModifier(KFPRI, Item, Multiplier);
	return Multiplier;
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
	OnHUDIconMaxTier=Shader'KFTurbo.Perks.Support_SHDR'
	SRLevelEffects(6)="60% more damage with shotguns|90% better shotgun penetration|30% extra shotgun ammo|50% more damage with grenades|120% increase in grenade capacity|60% increased carry weight|150% faster welding/unwelding|70% discount on shotguns|Spawn with a Shotgun"
}
