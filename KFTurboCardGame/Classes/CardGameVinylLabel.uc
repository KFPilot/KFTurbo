//Killing Floor Turbo CardGameVinylLabel
//Actor that defines and stores vinyls. Like TurboCardDeck for TurboCard.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardGameVinylLabel extends Info;

const PERK_INDEX_NONE = 255;

struct VinylReference
{
	var class<CardGameVinylLabel> Label;
	var byte PerkIndex; //Will be PERK_INDEX_NONE if vinyl is in general purpose list.
	var int VinylIndex; //Index within the list this vinyl is in.
};

enum ELabelRarity
{
    Common,
    Uncommon,
    Rare,
    Gold,
    Platinum
};
const MAX_RARITY = 5;

var const localized string LabelName;
var ELabelRarity LabelRarity;

//These are const because they must not be mutated at runtime so that lookups are correct.
var const array<TurboVinyl> VinylObjectList; //General purpose vinyls.
var const array<TurboVinyl> BerserkerVinylList;
var const array<TurboVinyl> CommandoVinylList;
var const array<TurboVinyl> DemolitionsVinylList;
var const array<TurboVinyl> FieldMedicVinylList;
var const array<TurboVinyl> FirebugVinylList;
var const array<TurboVinyl> SharpshooterVinylList;
var const array<TurboVinyl> SupportVinylList;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    Disable('Tick');
}

function InitializeLabel()
{
	InitializeVinylList(VinylObjectList, PERK_INDEX_NONE);
	InitializeVinylList(BerserkerVinylList, class'V_Berserker'.default.PerkIndex);
	InitializeVinylList(CommandoVinylList, class'V_Commando'.default.PerkIndex);
	InitializeVinylList(DemolitionsVinylList, class'V_Demolitions'.default.PerkIndex);
	InitializeVinylList(FieldMedicVinylList, class'V_FieldMedic'.default.PerkIndex);
	InitializeVinylList(FirebugVinylList, class'V_Firebug'.default.PerkIndex);
	InitializeVinylList(SharpshooterVinylList, class'V_Sharpshooter'.default.PerkIndex);
	InitializeVinylList(SupportVinylList, class'V_SupportSpec'.default.PerkIndex);
}

//Entries are object references, so stamping them sticks despite the array being passed by value.
final function InitializeVinylList(array<TurboVinyl> List, byte PerkIndex)
{
	local int Index;

	for (Index = 0; Index < List.Length; Index++)
	{
		List[Index].LabelClass = Class;
		List[Index].PerkIndex = PerkIndex;
		List[Index].VinylIndex = Index;
	}
}

function ActivateBasic(TurboPlayerCardCustomInfo PlayerInfo, TurboVinyl Vinyl, bool bActivate)
{
    if (bActivate)
    {
        TurboVinylBasic(Vinyl).ApplyAugmentList(PlayerInfo);
    }
}

//Subclasses can override to define how they randomly pick a vinyl to give.
//The pool is the general purpose list plus the list matching the player's current perk.
function TurboVinyl GetRandomVinyl(PlayerController Player)
{
	local array<TurboVinyl> Pool;
	local byte PlayerPerkIndex;

	AppendVinylList(VinylObjectList, Pool);

	PlayerPerkIndex = GetPlayerPerkIndex(Player);

	if (PlayerPerkIndex != PERK_INDEX_NONE)
	{
		AppendVinylList(GetVinylList(PlayerPerkIndex), Pool);
	}

	if (Pool.Length == 0)
	{
		return None;
	}

	return Pool[Rand(Pool.Length)];
}

static final function bool IsValidVinylReference(VinylReference VinylReference)
{
    return VinylReference.Label != None && VinylReference.VinylIndex > 0;
}

static final function byte GetPlayerPerkIndex(PlayerController Player)
{
	local class<SRVeterancyTypes> Perk;

	if (Player == None || KFPlayerReplicationInfo(Player.PlayerReplicationInfo) == None)
	{
		return PERK_INDEX_NONE;
	}

	Perk = class<SRVeterancyTypes>(KFPlayerReplicationInfo(Player.PlayerReplicationInfo).ClientVeteranSkill);

	if (Perk == None)
	{
		return PERK_INDEX_NONE;
	}

	return Perk.default.PerkIndex;
}

//Returns this label instance's vinyl list for a perk index.
simulated final function array<TurboVinyl> GetVinylList(byte PerkIndex)
{
	local array<TurboVinyl> EmptyList;

	switch (PerkIndex)
	{
		case PERK_INDEX_NONE:
			return VinylObjectList;
		case class'V_Berserker'.default.PerkIndex:
			return BerserkerVinylList;
		case class'V_Commando'.default.PerkIndex:
			return CommandoVinylList;
		case class'V_Demolitions'.default.PerkIndex:
			return DemolitionsVinylList;
		case class'V_FieldMedic'.default.PerkIndex:
			return FieldMedicVinylList;
		case class'V_Firebug'.default.PerkIndex:
			return FirebugVinylList;
		case class'V_Sharpshooter'.default.PerkIndex:
			return SharpshooterVinylList;
		case class'V_SupportSpec'.default.PerkIndex:
			return SupportVinylList;
	}

	return EmptyList;
}

//Returns the label CDO's vinyl list for a perk index.
static simulated final function array<TurboVinyl> GetDefaultVinylList(byte PerkIndex)
{
	local array<TurboVinyl> EmptyList;

	switch (PerkIndex)
	{
		case PERK_INDEX_NONE:
			return default.VinylObjectList;
		case class'V_Berserker'.default.PerkIndex:
			return default.BerserkerVinylList;
		case class'V_Commando'.default.PerkIndex:
			return default.CommandoVinylList;
		case class'V_Demolitions'.default.PerkIndex:
			return default.DemolitionsVinylList;
		case class'V_FieldMedic'.default.PerkIndex:
			return default.FieldMedicVinylList;
		case class'V_Firebug'.default.PerkIndex:
			return default.FirebugVinylList;
		case class'V_Sharpshooter'.default.PerkIndex:
			return default.SharpshooterVinylList;
		case class'V_SupportSpec'.default.PerkIndex:
			return default.SupportVinylList;
	}

	return EmptyList;
}

static final function AppendVinylList(array<TurboVinyl> List, out array<TurboVinyl> Pool)
{
	local int Index;

	for (Index = 0; Index < List.Length; Index++)
	{
		Pool[Pool.Length] = List[Index];
	}
}

//Resolves a vinyl object from a label CDO. DO NOT CALL INSTANCE FUNCTIONS ON THESE.
static simulated function TurboVinyl GetVinylFromReference(VinylReference Reference)
{
	local array<TurboVinyl> List;

	if (Reference.Label != default.Class || Reference.VinylIndex < 0)
	{
		return None;
	}

	List = GetDefaultVinylList(Reference.PerkIndex);

	if (Reference.VinylIndex >= List.Length)
	{
		return None;
	}

	return List[Reference.VinylIndex];
}

//Resolves TurboVinyl for a given VinylReference.
static simulated final function TurboVinyl ResolveVinyl(VinylReference Reference)
{
	if (Reference.Label == None || Reference.VinylIndex < 0)
	{
		return None;
	}

	return Reference.Label.static.GetVinylFromReference(Reference);
}

//Resolves against this label instance's vinyl objects.
simulated final function TurboVinyl ResolveVinylInstance(VinylReference Reference)
{
	local array<TurboVinyl> List;

	if (Reference.Label != Class || Reference.VinylIndex < 0)
	{
		return None;
	}

	List = GetVinylList(Reference.PerkIndex);

	if (Reference.VinylIndex >= List.Length)
	{
		return None;
	}

	return List[Reference.VinylIndex];
}

static final function VinylReference MakeVinylReference(TurboVinyl Vinyl)
{
	local VinylReference Reference;

	if (Vinyl == None)
	{
		Reference.Label = None;
		Reference.PerkIndex = PERK_INDEX_NONE;
		Reference.VinylIndex = -1;
		return Reference;
	}

	Reference.Label = Vinyl.LabelClass;
	Reference.PerkIndex = Vinyl.PerkIndex;
	Reference.VinylIndex = Vinyl.VinylIndex;
	return Reference;
}

//Sets up an actor to display a vinyl.
static simulated function ConfigureVinylActor(VinylReference VinylReference, Actor VinylDisplayActor)
{
	local int Index;
	local TurboVinyl VinylCDO;
	VinylCDO = ResolveVinyl(VinylReference);

	if (VinylCDO == None || VinylDisplayActor == None)
	{
		return;
	}

	VinylDisplayActor.SetStaticMesh(VinylCDO.VinylMesh);

	VinylDisplayActor.Skins.Length = VinylCDO.SkinNameList.Length;
	for (Index = 0; Index < VinylCDO.SkinNameList.Length; Index++)
	{
		if (VinylCDO.SkinNameList[Index] == "")
		{
			VinylDisplayActor.Skins[Index] = None;
			continue;
		}

		VinylDisplayActor.Skins[Index] = Material(DynamicLoadObject(VinylCDO.SkinNameList[Index], class'Material'));
	}
}
