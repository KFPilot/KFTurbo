//Killing Floor Turbo TurboVeterancyTypes
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVeterancyTypes extends SRVeterancyTypes
	abstract;

var int LevelRankRequirement; //Denotes levels between new rank names.
var float HighDifficultyExtraAmmoMultiplier;

var	Texture StarTexture;

//Are we playing KFTurbo+? Fixed to be callable by clients.
static final function bool IsHighDifficulty( Actor Actor )
{
	return class'KFTurboGameType'.static.StaticIsHighDifficulty(Actor);
}

static final function bool IsPerkDamageType( class<KFWeaponDamageType> WeaponDamageType )
{
	if (WeaponDamageType == None || default.PerkIndex == 255 || class<KFWeapon>(WeaponDamageType.default.WeaponClass) == None)
	{
		return false;
	}

	return IsPerkWeapon(class<KFWeapon>(WeaponDamageType.default.WeaponClass));
}

static final function bool IsPerkWeapon( class<KFWeapon> Weapon )
{
	if (Weapon == None || default.PerkIndex == 255)
	{
		return false;
	}

	if (class<KFWeaponPickup>(Weapon.default.PickupClass) != none)
	{
		return class<KFWeaponPickup>(Weapon.default.PickupClass).default.CorrespondingPerkIndex == default.PerkIndex;
	}

	return false;
}

static function ApplyAdjustedMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI, out float Multiplier)
{
	if (TurboGameReplicationInfo(KFGRI) != None)
	{
		Multiplier *= TurboGameReplicationInfo(KFGRI).GetPlayerMovementSpeedMultiplier(KFPRI, KFGRI);
	}
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
	if (TurboGameReplicationInfo(KFPRI.Level.GRI) != None)
	{
		Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetHeadshotDamageMultiplier(KFPRI, Pawn, DamageType);
	}
}

static function float GetHealPotency(KFPlayerReplicationInfo KFPRI)
{
	if (TurboGameReplicationInfo(KFPRI.Level.GRI) != None)
	{
		return TurboGameReplicationInfo(KFPRI.Level.GRI).GetHealPotencyMultiplier(KFPRI);
	}

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
	if (!IsHighDifficulty(KFPRI))
	{
		if (TurboGameReplicationInfo(KFPRI.Level.GRI) != None)
		{
			Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetMaxAmmoMultiplier(KFPRI, AmmoType);
		}

		return;
	}

	if (Multiplier > 1.f)
	{
		Multiplier *= default.HighDifficultyExtraAmmoMultiplier;
	}

	if (TurboGameReplicationInfo(KFPRI.Level.GRI) != None)
	{
		Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetMaxAmmoMultiplier(KFPRI, AmmoType);
	}
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
	if (TurboGameReplicationInfo(KFPRI.Level.GRI) != None)
	{
		Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetFireRateMultiplier(KFPRI, Other);
	}
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
	if (TurboGameReplicationInfo(KFPRI.Level.GRI) != None)
	{
		Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetReloadRateMultiplier(KFPRI, Other);
	}
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
	if (Other.default.MagCapacity > 1 && TurboGameReplicationInfo(KFPRI.Level.GRI) != None)
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
	if (TurboGameReplicationInfo(KFPRI.Level.GRI) != None)
	{
		Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetWeaponSpreadRecoilMultiplier(KFPRI, Other);
	}
}

static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	Recoil = 1.f;
	ApplyAdjustedRecoilSpreadModifier(KFPRI, Other, Recoil);
	return Recoil;
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
	if (TurboGameReplicationInfo(KFPRI.Level.GRI) != None)
	{
		Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetTraderCostMultiplier(KFPRI, Item);
	}
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
	if (TurboGameReplicationInfo(KFPRI.Level.GRI) != None)
	{
		Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetTraderCostMultiplier(KFPRI, Item);

		if (class<FragPickup>(Item) != None)
		{
			Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetTraderGrenadeCostMultiplier(KFPRI, Item);
		}
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

	if (TurboGameReplicationInfo(KFPRI.Level.GRI) != None)
	{
		Multiplier *= TurboGameReplicationInfo(KFPRI.Level.GRI).GetWeaponPenetrationMultiplier(KFPRI, Other);
	}

	return Multiplier;
}

static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	local int CarryWeightBonus;
	CarryWeightBonus = 0;
	if (TurboGameReplicationInfo(KFPRI.Level.GRI) != None)
	{
		TurboGameReplicationInfo(KFPRI.Level.GRI).GetPlayerCarryWeightModifier(KFPRI, CarryWeightBonus);
	}

	return CarryWeightBonus;
}

static function int ZedTimeExtensions(KFPlayerReplicationInfo KFPRI)
{
	local int Extensions;
	Extensions = 0;

	if (TurboGameReplicationInfo(KFPRI.Level.GRI) != None)
	{
		TurboGameReplicationInfo(KFPRI.Level.GRI).GetPlayerZedExtensionModifier(KFPRI, Extensions);
	}

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
		return GetPerkTitle(Level);
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

	Title = GetPerkTitle(Level);

	if (Title != "")
	{
		return Title @ Default.VeterancyName;
	}

	return Default.VeterancyName;
}

static function string GetPerkTitle(byte Level)
{
	local int Index;
	Index = Min(Level / Default.LevelRankRequirement, ArrayCount(Default.LevelNames) - 1);
	return Default.LevelNames[Index];
}

//Lerp function but written so that we mutate our exact behaviour in a centralized location.
//Right now just immediately returns the highest value we want.
static function float LerpStat(KFPlayerReplicationInfo KFPRI, float A, float B)
{
	return B;

	/*local float Level;
	Level = FClamp(float(KFPRI.ClientVeteranSkillLevel) / 6.f, 0.f, 1.f);
	return Lerp(Level, A, B);*/
}

static function Color GetPerkColor(byte Level)
{
	local int Index;
	Index = Level / Default.LevelRankRequirement;

	switch (Index)
	{
	case 0:
		return class'Canvas'.static.MakeColor(255,32,32,255); //Red
	case 1:
		return class'Canvas'.static.MakeColor(25,208,0,255); //Green
	case 2:
		return class'Canvas'.static.MakeColor(11,120,255,255); //Blue
	case 3:
		return class'Canvas'.static.MakeColor(255,0,255,255); //Pink
	case 4:
		return class'Canvas'.static.MakeColor(150,30,255,255); //Purple
	case 5:
		return class'Canvas'.static.MakeColor(255,110,0,255); //Orange
	case 6:
		return class'Canvas'.static.MakeColor(255,190,11,255); //Gold
	case 7:
	case 8:
		return class'Canvas'.static.MakeColor(225,235,255,255); //Platinum
	}

	return class'Canvas'.static.MakeColor(225,235,255,255);
}

static function byte PreDrawPerk(Canvas C, byte Level, out Material PerkIcon, out Material StarIcon)
{
	local int Index;
	local byte DrawColorAlpha;
	Index = Level / Default.LevelRankRequirement;

	StarIcon = Default.StarTexture;
	PerkIcon = Default.OnHUDGoldIcon;

	DrawColorAlpha = C.DrawColor.A;
	C.DrawColor = GetPerkColor(Level);
	C.DrawColor.A = DrawColorAlpha;

	return Level % Default.LevelRankRequirement;
}

defaultproperties
{
	LevelRankRequirement=5
	HighDifficultyExtraAmmoMultiplier=1.5f
	
	StarTexture=Texture'KFTurbo.Perks.Star_D'

	LevelNames(1)="Experienced"
	LevelNames(2)="Skilled"
	LevelNames(3)="Adept"
	LevelNames(4)="Masterful"
	LevelNames(5)="Inhuman"
	LevelNames(6)="Godlike"
}
