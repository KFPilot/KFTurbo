class KFPVeterancyTypes extends SRVeterancyTypes
	abstract;

var int LevelRankRequirement; //Denotes levels between new rank names.

var	Texture StarTexture;

//Are we playing KFPro+? Fixed to be callable by clients.
static function bool IsHighDifficulty( Actor Actor )
{
	if(Actor == None || Actor.Level == None)
	{
		return false;
	}

	return ClassIsChildOf(Actor.Level.GetGameClass(), class'KFProGameType');
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
//1 - always returns KFPVeterancyTypes::GetCustomLevelInfo()'s result
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


static function byte PreDrawPerk(Canvas C, byte Level, out Material PerkIcon, out Material StarIcon)
{
	local int Index;
	Index = Level / Default.LevelRankRequirement;

	StarIcon = Default.StarTexture;
	PerkIcon = Default.OnHUDGoldIcon;

	switch (Index)
	{
	case 0:
		C.SetDrawColor(255, 64, 64, C.DrawColor.A);
		break;
	case 1:
		C.SetDrawColor(64, 179, 255, C.DrawColor.A);
		break;
	case 2:
		C.SetDrawColor(64, 255, 64, C.DrawColor.A);
		break;
	case 3:
		C.SetDrawColor(255, 207, 75, C.DrawColor.A);
		break;
	case 4:
		C.SetDrawColor(218, 116, 255, C.DrawColor.A);
		break;
	case 5:
		C.SetDrawColor(224, 211, 179, C.DrawColor.A);
		break;
	case 6:
		C.SetDrawColor(255, 119, 0, C.DrawColor.A);
		break;
	}

	return Level % Default.LevelRankRequirement;
}

defaultproperties
{
     LevelRankRequirement=10
     StarTexture=Texture'KFTurbo.Perks.PerkStar_D'
     LevelNames(1)="Experienced"
     LevelNames(2)="Skilled"
     LevelNames(3)="Adept"
     LevelNames(4)="Masterful"
     LevelNames(5)="Inhuman"
     LevelNames(6)="Godlike"
}
