//Killing Floor Turbo KFTurboCardGameMut
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboCardGameMut extends CardGameMutBase
	config(KFTurboCardGame);

#exec obj load file="..\Textures\TurboCardGame.utx" package=KFTurboCardGame

var TurboCardReplicationInfo TurboCardReplicationInfo;
var TurboCardGameplayManager TurboCardGameplayManagerInfo;
var TurboCardGameModifierRepLink TurboCardGameModifier;
var TurboCardClientModifierRepLink TurboCardClientModifier;
var TurboPlayerCardEventHandler PlayerCardEventHandler;
var TurboHealCardEventHandler HealCardEventHandler;
var CardGameRules CardGameRules;
var TurboCardStatsTcpLink TurboCardStatsTcpLink;

var array<TurboPlayerReplicationInfo> PendingPlayerReplicationInfoList;

var array< class<CardGameVinylLabel> > VinylLabelList; //Labels vinyls are selected from.
var array<CardGameVinylLabel> VinylLabelInstanceList; //Spawned label instances - their vinyls have activation delegates bound.
var int VinylSpawnCount; //Number of vinyls offered outside the trader during trader time.
var float VinylSpawnSearchRadius; //Radius around the shop to search for fallback path node spawn locations.
var array<CardGameVinylActor> ActiveVinylList;

var const bool bPerformValidation;

function PostBeginPlay()
{
	AddToPackageMap("KFTurbo");
	AddToPackageMap("KFTurboCardGame");
	
	TurboCardReplicationInfo = CreateTurboCardReplicationInfo();
	AddDeckOverridesToPackageMap();

	CardGameRules = CreateCardGameRules();

	Super.PostBeginPlay();

	AttemptModifyGameLength();

	TurboCardStatsTcpLink = SetupStatTcpLink();
	
	class'CardGameWaveEventHandler'.static.CreateHandler(Self);
	class'CardGameWaveSpawnEventHandler'.static.CreateHandler(Self);
	PlayerCardEventHandler = TurboPlayerCardEventHandler(class'TurboPlayerCardEventHandler'.static.CreateHandler(Self));
	HealCardEventHandler = TurboHealCardEventHandler(class'TurboHealCardEventHandler'.static.CreateHandler(Self));
}

function Tick(float DeltaTime)
{
	local KFTurboMut Mutator;
	Mutator = class'KFTurboMut'.static.FindMutator(Level.Game);
	if (Mutator != None)
	{
		Mutator.SetGameType(Self, "turbocardgame");
		Disable('Tick');
	}
}

function AddDeckOverridesToPackageMap()
{
	local array<string> PackageNameList;
	local string PackageName;
	local int Index;

	PackageName = GetDeckOverridePackageName(TurboCardReplicationInfo.TurboGoodDeckClassOverrideString);
	if (PackageName != "")
	{
		AddUnique(PackageName, PackageNameList);
	}
	
	PackageName = GetDeckOverridePackageName(TurboCardReplicationInfo.TurboSuperDeckClassOverrideString);
	if (PackageName != "")
	{
		AddUnique(PackageName, PackageNameList);
	}
	
	PackageName = GetDeckOverridePackageName(TurboCardReplicationInfo.TurboProConDeckClassOverrideString);
	if (PackageName != "")
	{
		AddUnique(PackageName, PackageNameList);
	}
	
	PackageName = GetDeckOverridePackageName(TurboCardReplicationInfo.TurboEvilDeckClassOverrideString);
	if (PackageName != "")
	{
		AddUnique(PackageName, PackageNameList);
	}

	for (Index = 0; Index < PackageNameList.Length; Index++)
	{
		AddToPackageMap(PackageNameList[Index]);
	}
}

function string GetDeckOverridePackageName(string DeckClassOverrideString)
{
	local Object DeckClassOverride;

	if (DeckClassOverrideString == "")
	{
		return "";
	}

	DeckClassOverride = DynamicLoadObject(DeckClassOverrideString, class'Class');

	if (DeckClassOverride == None)
	{
		return "";
	}
	
	while(DeckClassOverride.Outer != None)
	{
		DeckClassOverride = DeckClassOverride.Outer;
	}

	if (DeckClassOverride.Name == 'KFTurboCardGame')
	{
		return "";
	}
		
	return string(DeckClassOverride.Name);
}

final function AddUnique(string String, out array<string> StringList)
{
	local int Index;

	for (Index = 0; Index < StringList.Length; Index++)
	{
		if (StringList[Index] == String)
		{
			return;
		}
	}

	StringList.Length = StringList.Length + 1;
	StringList[StringList.Length - 1] = String;
}

//Make game 14 waves long, with first few waves being very small.
function AttemptModifyGameLength()
{
	if (KFTurboGameType(Level.Game) == None)
	{
		return;
	}

    KFTurboGameType(Level.Game).KFGameLength = 2; //Ensure the game length is correct!
	KFTurboGameType(Level.Game).SetFinalWaveOverride(14);
}

function TurboCardStatsTcpLink SetupStatTcpLink()
{
	if (!class'TurboStatsTcpLink'.static.ShouldBroadcastAnalytics())
	{
		return None;
	}

	return Spawn(class'TurboCardStatsTcpLink', Self);
}

static final function KFTurboCardGameMut FindMutator(GameInfo GameInfo)
{
    local KFTurboCardGameMut CardGameMut;
    local Mutator Mutator;

	if (GameInfo == None)
	{
		return None;
	}

    for ( Mutator = GameInfo.BaseMutator; Mutator != None; Mutator = Mutator.NextMutator )
    {
        CardGameMut = KFTurboCardGameMut(Mutator);

        if (CardGameMut == None)
        {
            continue;
        }

		return CardGameMut;
    }

	return None;
}

function TurboCardReplicationInfo CreateTurboCardReplicationInfo()
{
	local TurboCardReplicationInfo TCRI;
	TCRI = Spawn(class'TurboCardReplicationInfo', Self);
	TCRI.Initialize(Self);
	return TCRI;
}

function CardGameRules CreateCardGameRules()
{
	local CardGameRules CGR;
	CGR = Spawn(class'CardGameRules', Self);
	CGR.MutatorOwner = Self;

	CGR.NextGameRules = Level.Game.GameRulesModifiers;
	Level.Game.GameRulesModifiers = CGR;
	return CGR;
}

function AddTurboCardGameModifier(TurboGameReplicationInfo TGRI)
{
	local TurboGameModifierReplicationLink LastGRL;
	local TurboClientModifierReplicationLink LastCRL;
	
	if (TurboCardGameModifier != None)
	{
		return;
	}

	LastGRL = TGRI.CustomTurboModifier;
	while (LastGRL != None && LastGRL.NextGameModifierLink != None)
	{
		LastGRL = LastGRL.NextGameModifierLink;
	}

	TurboCardGameModifier = Spawn(class'TurboCardGameModifierRepLink', TGRI);
	TurboCardGameModifier.OwnerGRI = TGRI;

	if (LastGRL != None)
	{
		LastGRL.NextGameModifierLink = TurboCardGameModifier;
	}
	else
	{
		TGRI.CustomTurboModifier = TurboCardGameModifier;
	}
	
	LastCRL = TGRI.CustomTurboClientModifier;
	while (LastCRL != None && LastCRL.NextClientModifierLink != None)
	{
		LastCRL = LastCRL.NextClientModifierLink;
	}

	TurboCardClientModifier = Spawn(class'TurboCardClientModifierRepLink', TGRI);
	TurboCardClientModifier.OwnerGRI = TGRI;
	
	if (LastCRL != None)
	{
		LastCRL.NextClientModifierLink = TurboCardClientModifier;
	}
	else
	{
		TGRI.CustomTurboClientModifier = TurboCardClientModifier;
	}

	TGRI.ForceNetUpdate();
	TurboCardGameModifier.ForceNetUpdate();
	TurboCardClientModifier.ForceNetUpdate();
	TurboCardGameplayManagerInfo = CreateCardGameplayManager();

	if (bPerformValidation)
	{
		SpawnCardGameValidator();
	}
}

function SpawnCardGameValidator()
{
	local CardGameValidatorActor Validator;
	Validator = Spawn(class'CardGameValidatorActor', Self);
	Validator.Mutator = Self;
}

//Should only be spawned after all the other actors are spun up.
function TurboCardGameplayManager CreateCardGameplayManager()
{
	return Spawn(class'TurboCardGameplayManager', Self);
}

function InitializeVinylLabels()
{
	local CardGameVinylLabel Label;
	local int Index;

	if (VinylLabelInstanceList.Length != 0)
	{
		return;
	}

	for (Index = 0; Index < VinylLabelList.Length; Index++)
	{
		Label = Spawn(VinylLabelList[Index], Self);

		if (Label == None)
		{
			continue;
		}

		Label.InitializeLabel();
		VinylLabelInstanceList[VinylLabelInstanceList.Length] = Label;
	}
}

//Spawns purchasable vinyls just outside the currently open trader.
//A random label is selected for each vinyl, then each label decides which vinyl it gives.
function SpawnVinyls()
{
	local KFGameReplicationInfo KFGRI;
	local array<Vector> SpawnLocationList;
	local CardGameVinylLabel VinylLabel;
	local TurboVinyl Vinyl;
	local CardGameVinylActor VinylActor;
	local int Index;

	DestroyVinyls();
	InitializeVinylLabels();

	if (VinylLabelInstanceList.Length == 0)
	{
		return;
	}

	KFGRI = KFGameReplicationInfo(Level.GRI);

	if (KFGRI == None || KFGRI.CurrentShop == None)
	{
		return;
	}

	GatherVinylSpawnLocations(KFGRI.CurrentShop, SpawnLocationList);

	for (Index = 0; Index < SpawnLocationList.Length; Index++)
	{
		VinylLabel = VinylLabelInstanceList[Rand(VinylLabelInstanceList.Length)];
		Vinyl = VinylLabel.GetRandomVinyl();

		if (Vinyl == None)
		{
			continue;
		}

		VinylActor = Spawn(class'CardGameVinylActor', Self,, SpawnLocationList[Index]);

		if (VinylActor != None)
		{
			VinylActor.SetVinyl(Vinyl);
			ActiveVinylList[ActiveVinylList.Length] = VinylActor;
		}
	}
}

//Prefers a row in front of the shop's first exit teleporter. Falls back to path nodes near the shop.
function GatherVinylSpawnLocations(ShopVolume Shop, out array<Vector> SpawnLocationList)
{
	local Vector X, Y, Z;
	local int Index;

	Shop.InitTeleports();

	if (Shop.TelList.Length > 0 && Shop.TelList[0] != None)
	{
		GetAxes(Shop.TelList[0].Rotation, X, Y, Z);

		for (Index = 0; Index < VinylSpawnCount; Index++)
		{
			SpawnLocationList[SpawnLocationList.Length] = Shop.TelList[0].Location + (X * 100.f) + (Y * ((float(Index) - (float(VinylSpawnCount - 1) * 0.5f)) * 120.f));
		}

		return;
	}

	GatherPathNodeSpawnLocations(Shop, SpawnLocationList);
}

//Fallback - use the path nodes closest to the shop that aren't inside of it.
function GatherPathNodeSpawnLocations(ShopVolume Shop, out array<Vector> SpawnLocationList)
{
	local PathNode PathNode;
	local array<PathNode> NodeList;
	local array<float> NodeDistanceList;
	local float Distance;
	local int Index;

	foreach RadiusActors(class'PathNode', PathNode, VinylSpawnSearchRadius, Shop.Location)
	{
		if (Shop.Encompasses(PathNode))
		{
			continue;
		}

		Distance = VSize(PathNode.Location - Shop.Location);

		for (Index = 0; Index < NodeList.Length; Index++)
		{
			if (Distance < NodeDistanceList[Index])
			{
				break;
			}
		}

		NodeList.Insert(Index, 1);
		NodeList[Index] = PathNode;
		NodeDistanceList.Insert(Index, 1);
		NodeDistanceList[Index] = Distance;
	}

	for (Index = 0; Index < Min(NodeList.Length, VinylSpawnCount); Index++)
	{
		SpawnLocationList[SpawnLocationList.Length] = NodeList[Index].Location;
	}
}

function DestroyVinyls()
{
	local int Index;

	for (Index = 0; Index < ActiveVinylList.Length; Index++)
	{
		if (ActiveVinylList[Index] != None)
		{
			ActiveVinylList[Index].Destroy();
		}
	}

	ActiveVinylList.Length = 0;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (TurboPlayerReplicationInfo(Other) != None)
	{
		PendingPlayerReplicationInfoList[PendingPlayerReplicationInfoList.Length] = TurboPlayerReplicationInfo(Other);
		SetTimer(0.01f, false);
		return true;
	}

	if (TurboGameReplicationInfo(Other) != None)
	{
		AddTurboCardGameModifier(TurboGameReplicationInfo(Other));
		return true;
	}
	
	if (CardGameRules != None)
	{
		CardGameRules.ModifyActor(Other);
	}

	return true;
}

function Timer()
{
	local int Index;
	for (Index = PendingPlayerReplicationInfoList.Length - 1; Index >= 0; Index--)
	{
		AddCardGamePlayerReplicationInfo(PendingPlayerReplicationInfoList[Index]);
	}

	PendingPlayerReplicationInfoList.Length = 0;
}

function AddCardGamePlayerReplicationInfo(KFPlayerReplicationInfo PlayerReplicationInfo)
{
	local CardGamePlayerReplicationInfo CardGamePRI;
	local LinkedReplicationInfo LastLRI;

	if (MessagingSpectator(PlayerReplicationInfo.Owner) != None)
	{
		return;
	}

	LastLRI = PlayerReplicationInfo.CustomReplicationInfo;
	while (LastLRI != None && LastLRI.NextReplicationInfo != None)
	{
		LastLRI = LastLRI.NextReplicationInfo;
	}

	CardGamePRI = Spawn(class'CardGamePlayerReplicationInfo', PlayerReplicationInfo);
	CardGamePRI.OwningReplicationInfo = PlayerReplicationInfo;
	CardGamePRI.TurboCardReplicationInfo = TurboCardReplicationInfo;

	if (LastLRI != None)
	{
		LastLRI.NextReplicationInfo = CardGamePRI;
	}
	else
	{
		PlayerReplicationInfo.CustomReplicationInfo = CardGamePRI;
	}

	CardGamePRI.ForceNetUpdate();
	
	Spawn(class'TurboPlayerCardCustomInfo', PlayerReplicationInfo.Owner);
}

function ModifyPlayer(Pawn Other)
{
	Super.ModifyPlayer(Other);
	
	if (CardGameRules != None)
	{
		CardGameRules.ModifyPlayer(Other);
	}

	if (TurboCardGameplayManagerInfo != None)
	{
		TurboCardGameplayManagerInfo.ModifyPlayer(Other);
	}
}

//There isn't a card ID system so we'll just implement cards we card about in particular.
function int HasCard(string CardID)
{
	if (CardID == "CURSEOFRA")
	{
		return TurboCardReplicationInfo.GetCurseOfRaCardIndex();
	}

	return Super.HasCard(CardID);
}

simulated function String GetHumanReadableName()
{
	return FriendlyName;
}

defaultproperties
{
	VinylLabelList(0)=class'VinylLabelAdvancedGenetics'
	VinylLabelList(1)=class'VinylLabelClassic'
	VinylLabelList(2)=class'VinylLabelHorzine'
	VinylSpawnCount=3
	VinylSpawnSearchRadius=1200.f

	bPerformValidation=false
	bAddToServerPackages=True
	GroupName="KF-KFTurboMode"
	FriendlyName="Killing Floor Turbo Card Game"
	Description="Killing Floor Turbo's card game mutator. Before each wave, users are asked to vote between a selection of gameplay modifiers (cards)."
}
