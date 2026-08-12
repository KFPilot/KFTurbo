//Killing Floor Turbo CardGameVinylLabel
//A record label vinyls are selected from. Works like a deck - vinyls are defined as inline objects
//and referred to via VinylReference. The server spawns an instance of each label; clients resolve
//references against label CDOs.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardGameVinylLabel extends Info;

struct VinylReference
{
	var class<CardGameVinylLabel> Label;
	var int VinylIndex;
};

var array<TurboVinyl> VinylObjectList;

function InitializeLabel()
{
	local int Index;

	for (Index = 0; Index < VinylObjectList.Length; Index++)
	{
		VinylObjectList[Index].LabelClass = Class;
		VinylObjectList[Index].VinylIndex = Index;
	}
}

//Subclasses can override to define how they randomly pick a vinyl to give.
function TurboVinyl GetRandomVinyl()
{
	if (VinylObjectList.Length == 0)
	{
		return None;
	}

	return VinylObjectList[Rand(VinylObjectList.Length)];
}

//Resolves a vinyl object from a label CDO. DO NOT CALL INSTANCE FUNCTIONS ON THESE.
static simulated function TurboVinyl GetVinylFromReference(VinylReference Reference)
{
	if (Reference.Label != default.Class || Reference.VinylIndex < 0 || Reference.VinylIndex >= default.VinylObjectList.Length)
	{
		return None;
	}

	return default.VinylObjectList[Reference.VinylIndex];
}

//Resolves against this label instance's vinyl objects (delegates bound). Server-side use only.
simulated final function TurboVinyl ResolveVinylInstance(VinylReference Reference)
{
    if (Reference.Label != Class || Reference.VinylIndex < 0 || Reference.VinylIndex >= VinylObjectList.Length)
	{
		return None;
	}

	return VinylObjectList[Reference.VinylIndex];
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
		Reference.VinylIndex = -1;
		return Reference;
	}

	Reference.Label = Vinyl.LabelClass;
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
