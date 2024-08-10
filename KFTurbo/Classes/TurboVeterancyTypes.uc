class TurboVeterancyTypes extends SRVeterancyTypes
	abstract;

var int LevelRankRequirement; //Denotes levels between new rank names.

var	Texture StarTexture;

//Are we playing KFTurbo+? Fixed to be callable by clients.
static final function bool IsHighDifficulty( Actor Actor )
{
	return class'KFTurboGameType'.static.StaticIsHighDifficulty(Actor);
}

//Default behaviour for increasing extra ammo is 50% more than perk bonus.
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
}

static final function int GetScaledRequirement(byte CurLevel, int InValue)
{
	return CurLevel*CurLevel*InValue;
}

static function class<DamageType> GetMAC10DamageType(KFPlayerReplicationInfo KFPRI)
{
	return none; //We no longer use this function anymore, W_MAC10_Fire extends KFFire
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
		return class'Canvas'.static.MakeColor(10,120,255,255); //Blue
	case 3:
		return class'Canvas'.static.MakeColor(255,0,255,255); //Pink
	case 4:
		return class'Canvas'.static.MakeColor(150,30,255,255); //Purple
	case 5:
		return class'Canvas'.static.MakeColor(255,110,0,255); //Orange
	case 6:
		return class'Canvas'.static.MakeColor(255,190,10,255); //Gold
	case 7:
		return class'Canvas'.static.MakeColor(255,235,225,255); //Platinum
	case 8:
		return class'Canvas'.static.MakeColor(255,235,225, 255); //Platinum
	}
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
     StarTexture=Texture'KFTurbo.Perks.Star_D'
     LevelNames(1)="Experienced"
     LevelNames(2)="Skilled"
     LevelNames(3)="Adept"
     LevelNames(4)="Masterful"
     LevelNames(5)="Inhuman"
     LevelNames(6)="Godlike"
}
