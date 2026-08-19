//Killing Floor Turbo CardGameVinylLabel
//A record label vinyls are selected from. Works like a deck - vinyls are defined as inline objects
//and referred to via VinylReference. The server spawns an instance of each label; clients resolve
//references against label CDOs.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardGameVinylLabel extends Info;

//SRVeterancyTypes convention - PerkIndex 255 means no perk. References with this index resolve to the general purpose list.
const PERK_INDEX_NONE = 255;

struct VinylReference
{
	var class<CardGameVinylLabel> Label;
	var byte PerkIndex; //Which of the label's lists the vinyl lives in - PERK_INDEX_NONE is the general purpose list.
	var int VinylIndex; //Index within that list.
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

var ELabelRarity LabelRarity;

var array<TurboVinyl> VinylObjectList; //General purpose vinyls - in the pool for every player.

//Per-perk vinyl lists - pooled with the general list when selecting for a player of that perk.
var array<TurboVinyl> BerserkerVinylList;
var array<TurboVinyl> CommandoVinylList;
var array<TurboVinyl> DemolitionsVinylList;
var array<TurboVinyl> FieldMedicVinylList;
var array<TurboVinyl> FirebugVinylList;
var array<TurboVinyl> SharpshooterVinylList;
var array<TurboVinyl> SupportVinylList;

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

//Resolves against this label instance's vinyl objects (delegates bound). Server-side use only.
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

//Resolves a reference by dispatching to the referenced label class - GetVinylFromReference compares
//against default.Class, so it must be called through Reference.Label for subclasses to match.
static simulated final function TurboVinyl ResolveVinyl(VinylReference Reference)
{
	if (Reference.Label == None || Reference.VinylIndex < 0)
	{
		return None;
	}

	return Reference.Label.static.GetVinylFromReference(Reference);
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

//Sets up a HUD drawn actor to display a vinyl.
static simulated final function ConfigureDrawnActor(TurboVinyl Vinyl, TurboCardDrawnActor DrawnActor)
{
	local int Index;

	if (Vinyl == None || DrawnActor == None)
	{
		return;
	}

	DrawnActor.SetStaticMesh(Vinyl.VinylMesh);

	DrawnActor.Skins.Length = Vinyl.SkinList.Length;
	for (Index = 0; Index < Vinyl.SkinList.Length; Index++)
	{
		DrawnActor.Skins[Index] = Vinyl.SkinList[Index];
	}
}
