//Killing Floor Turbo TurboVeterancyTypes
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVeterancyTypes extends SRVeterancyTypes
	abstract;

const MAX_PERK_TIER = 7;

var int LevelRankRequirement; //Denotes levels between new rank names.
var float HighDifficultyExtraAmmoMultiplier; //On-perk weapon ammo bonus on high difficulty.
var float HighDifficultyExtraGrenadeAmmoMultiplier; //Grenade ammo bonus on high difficulty. Demo's HighDifficultyExtraAmmoMultiplier will stack on top of this.

var	Texture StarTexture;

var() Color LevelColors[MAX_PERK_TIER];

var() localized string MaxTierTitle;
var() Color MaxTierColor;
var() Material OnHUDIconMaxTier;

//Are we playing KFTurbo+? Fixed to be callable by clients.
static final function bool IsHighDifficulty( Actor Actor )
{
	return class'KFTurboGameType'.static.StaticIsHighDifficulty(Actor);
}

static final function bool IsPerkWeapon( class<KFWeapon> Weapon )
{
	local class<KFWeaponPickup> WeaponPickupClass;

	if (Weapon == None || default.PerkIndex == 255)
	{
		return false;
	}

	WeaponPickupClass = class<KFWeaponPickup>(Weapon.default.PickupClass);

	if (WeaponPickupClass != None)
	{
		if (WeaponPickupClass.default.CorrespondingPerkIndex == default.PerkIndex)
		{
			return true;
		}
		else if (default.PerkIndex == class'V_Commando'.default.PerkIndex && (class<W_M4203_Weap>(Weapon) != None || class<W_ThompsonSMG_Weap>(Weapon) != None))
		{
			return true;
		}
	}

	return false;
}

static final function bool IsPerkDamageType( class<KFWeaponDamageType> WeaponDamageType )
{
	if (WeaponDamageType == None || default.PerkIndex == 255 || class<KFWeapon>(WeaponDamageType.default.WeaponClass) == None)
	{
		return false;
	}

	return IsPerkWeapon(class<KFWeapon>(WeaponDamageType.default.WeaponClass));
}

static function bool IsPerkAmmunition(class<Ammunition> AmmoType)
{
	return false;
}

static function ApplyAdjustedMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI, out float Multiplier)
{
	Multiplier *= TurboGameReplicationInfo(KFGRI).GetPlayerMovementSpeedMultiplier(KFPRI, KFGRI);
}

static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
	local float Multiplier;
	Multiplier = 1.f;
	ApplyAdjustedMovementSpeedModifier(KFPRI, KFGRI, Multiplier);
	return Multiplier;
}

static function ApplyAdjustedHeadshotDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType, out float Multiplier)
{
	Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetHeadshotDamageMultiplier(KFPRI, Pawn, DamageType);
}

static function float GetSyringeChargeRate(KFPlayerReplicationInfo KFPRI)
{
	return TurboGameReplicationInfo(KFPRI.Level.GRI).GetHealRechargeMultiplier(KFPRI);
}

static function float GetHealPotency(KFPlayerReplicationInfo KFPRI)
{
	return TurboGameReplicationInfo(KFPRI.Level.GRI).GetHealPotencyMultiplier(KFPRI);
}

static function float GetWeldSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	return 1.f;
}

static function float GetHeadShotDamMulti(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType)
{
	local float Multiplier;
	Multiplier = 1.f;
	ApplyAdjustedHeadshotDamageMultiplier(KFPRI, Pawn, DamageType, Multiplier);
	return Multiplier;
}

//Split off from AddExtraAmmoFor. Applies HighDifficultyExtraAmmoMultiplier on High Difficulty game types and anyone else who wants to mutate ammo amounts separately from perk bonuses.
static function ApplyAdjustedExtraAmmo(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType, out float Multiplier)
{
	if (IsHighDifficulty(KFPRI))
	{
		if (IsPerkAmmunition(AmmoType))
		{
			Multiplier *= default.HighDifficultyExtraAmmoMultiplier;
		}
		
		if (class<FragAmmo>(AmmoType) != None)
		{
			Multiplier *= default.HighDifficultyExtraGrenadeAmmoMultiplier;
		}
	}

	Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetMaxAmmoMultiplier(KFPRI, AmmoType);
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType)
{
	local float Multiplier;
	Multiplier = 1.f;
	ApplyAdjustedExtraAmmo(KFPRI, AmmoType, Multiplier);
	return Multiplier;
}

static function ApplyAdjustedFireRate(KFPlayerReplicationInfo KFPRI, Weapon Other, out float Multiplier)
{
	Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetFireRateMultiplier(KFPRI, Other);
}

static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	local float Multiplier;
	Multiplier = 1.f;
	ApplyAdjustedFireRate(KFPRI, Other, Multiplier);
	return Multiplier;
}

static function ApplyAdjustedReloadRate(KFPlayerReplicationInfo KFPRI, Weapon Other, out float Multiplier)
{
	Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetReloadRateMultiplier(KFPRI, Other);
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float Multiplier;
	Multiplier = 1.f;
	ApplyAdjustedReloadRate(KFPRI, Other, Multiplier);
	return Multiplier;
}

static function ApplyAdjustedMagCapacityModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other, out float Multiplier)
{
	if (Other.default.MagCapacity > 2)
	{
		Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetMagazineAmmoMultiplier(KFPRI, Other);
	}
}

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	local float Multiplier;
	Multiplier = 1.f;
	ApplyAdjustedMagCapacityModifier(KFPRI, Other, Multiplier);
	return Multiplier;
}

static function ApplyAdjustedRecoilSpreadModifier(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Multiplier)
{
	Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetWeaponSpreadRecoilMultiplier(KFPRI, Other);
}

static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	Recoil = 1.f;
	ApplyAdjustedRecoilSpreadModifier(KFPRI, Other, Recoil);
	return Recoil;
}

static function float GetBodyArmorDamageModifier(KFPlayerReplicationInfo KFPRI)
{
	local float Multiplier;
	Multiplier = 1.f;
	TurboGameReplicationInfo(KFPRI.Level.GRI).GetBodyArmorDamageModifier(KFPRI, Multiplier);
	return Multiplier;
}

static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float Multiplier;
	Multiplier = 1.f;
	ApplyCostScalingModifier(KFPRI, Item, Multiplier);
	return Multiplier;
}

static function ApplyCostScalingModifier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item, out float Multiplier)
{
	Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetTraderCostMultiplier(KFPRI, Item);
}

static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	local float Multiplier;
	Multiplier = 1.f;
	ApplyAmmoCostScalingModifier(KFPRI, Item, Multiplier);
	return Multiplier;
}

static function ApplyAmmoCostScalingModifier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item, out float Multiplier)
{
	Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetTraderCostMultiplier(KFPRI, Item);

	if (class<FragPickup>(Item) != None)
	{
		Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetTraderGrenadeCostMultiplier(KFPRI, Item);
	}
}

static function float GetShotgunPenetrationDamageMulti(KFPlayerReplicationInfo KFPRI, float DefaultPenDamageReduction)
{
	return DefaultPenDamageReduction ** (1.f / ((1.75f * GetWeaponPenetrationMultiplier(KFPRI, None)) - 0.775f));
}

//Other can be none when called from GetShotgunPenetrationDamageMulti.
static function float GetWeaponPenetrationMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other)
{
	local float Multiplier;
	Multiplier = 1.f;

	Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetWeaponPenetrationMultiplier(KFPRI, Other);

	return Multiplier;
}

static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	local int CarryWeightBonus;
	CarryWeightBonus = 0;

	TurboGameReplicationInfo(KFPRI.Level.GRI).GetPlayerCarryWeightModifier(KFPRI, CarryWeightBonus);

	return CarryWeightBonus;
}

static function int ZedTimeExtensions(KFPlayerReplicationInfo KFPRI)
{
	local int Extensions;
	Extensions = 0;

	TurboGameReplicationInfo(KFPRI.Level.GRI).GetPlayerZedExtensionModifier(KFPRI, Extensions);

	return Extensions;
}

static final function int GetScaledRequirement(byte CurLevel, int InValue)
{
	return CurLevel * CurLevel * InValue;
}

static function class<DamageType> GetMAC10DamageType(KFPlayerReplicationInfo KFPRI)
{
	return none; //We no longer use this function anymore, W_MAC10_Fire extends KFFire
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'W_Frag_Proj';
}

//Slight change to how this works:
//0 - returns this perk's title
//1 - always returns TurboVeterancyTypes::GetCustomLevelInfo()'s result
//2 - returns SRVeterancyTypes::GetVetInfoText()'s result
//3 - returns the full perk name, including perk title.
//4 - returns perk veterancy name, without title.
static function string GetVetInfoText(byte Level, byte Type, optional byte RequirementNum)
{
	switch (Type)
	{
	case 0:
		return GetPerkTierTitle(GetPerkTier(Level));
	case 1:
		return GetCustomLevelInfo(Level);
	case 3:
		return GetFullPerkName(Level);
	case 4:
		return Default.VeterancyName;
	}

	return Super.GetVetInfoText(Level, Type, RequirementNum);
}

//Includes perk's title suffixed to perk name.
static function string GetFullPerkName(byte Level)
{
	local string Title;

	Title = GetPerkTierTitle(GetPerkTier(Level));

	if (Title == "")
	{
		return Default.VeterancyName;
	}

	return Title @ Default.VeterancyName;
}

//Lerp function but written so that we mutate our exact behaviour in a centralized location.
//Right now just immediately returns the highest value we want.
static final function float LerpStat(KFPlayerReplicationInfo KFPRI, float A, float B)
{
	return B;

	/*local float Level;
	Level = FClamp(float(KFPRI.ClientVeteranSkillLevel) / 6.f, 0.f, 1.f);
	return Lerp(Level, A, B);*/
}

static final function byte GetPerkTier(byte Level)
{
	return Level / Default.LevelRankRequirement;
}

static final function byte GetMaxTier()
{
	return MAX_PERK_TIER;
}

static function string GetPerkTierTitle(byte Tier)
{
	if (Tier <= 0)
	{
		return "";
	}

	if (Tier > GetMaxTier())
	{
		return default.MaxTierTitle;
	}

	return default.LevelNames[Tier - 1];
}

static final function Color GetPerkTierColor(byte Tier)
{
	if (Tier <= 0)
	{
		return class'Canvas'.static.MakeColor(255, 32, 32, 255);
	}

	if (Tier > GetMaxTier())
	{
		return default.MaxTierColor;
	}

	return default.LevelColors[Tier - 1];
}

static function byte PreDrawPerk(Canvas C, byte Level, out Material PerkIcon, out Material StarIcon)
{
	local byte DrawColorAlpha;
	local byte PerkTier;
	DrawColorAlpha = C.DrawColor.A;

	PerkTier = GetPerkTier(Level);
	
	if (PerkTier > GetMaxTier())
	{
		PerkIcon = Default.OnHUDIconMaxTier;
	}
	else
	{
		PerkIcon = Default.OnHUDGoldIcon;
	}

	StarIcon = Default.StarTexture;

	C.DrawColor = GetPerkTierColor(PerkTier);
	C.DrawColor.A = DrawColorAlpha;
	
	return Level % Default.LevelRankRequirement;
}

defaultproperties
{
	LevelRankRequirement=5
	HighDifficultyExtraAmmoMultiplier=1.5f
	HighDifficultyExtraGrenadeAmmoMultiplier=1.f
	
	StarTexture=Texture'KFTurbo.Perks.Star_D'
	OnHUDIconMaxTier=None

	LevelNames(0)="Skilled"
	LevelNames(1)="Adept"
	LevelNames(2)="Veteran"
	LevelNames(3)="Masterful"
	LevelNames(4)="Inhuman"
	LevelNames(5)="Godlike"
	LevelNames(6)="Peak"
	
	LevelColors(0)=(R=25,G=208,B=0,A=255)
	LevelColors(1)=(R=11,G=120,B=255,A=255)
	LevelColors(2)=(R=255,G=0,B=255,A=255)
	LevelColors(3)=(R=150,G=30,B=255,A=255)
	LevelColors(4)=(R=255,G=110,B=0,A=255)
	LevelColors(5)=(R=255,G=190,B=11,A=255)
	LevelColors(6)=(R=225,G=235,B=255,A=255)

	MaxTierTitle="";
	MaxTierColor=(R=255,G=255,B=255,A=255)
}