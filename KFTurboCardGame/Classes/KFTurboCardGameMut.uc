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
var CardGameRules CardGameRules;
var TurboCardStatsTcpLink TurboCardStats;

var globalconfig string TurboGoodDeckClassOverrideString;
var globalconfig string TurboSuperDeckClassOverrideString;
var globalconfig string TurboProConDeckClassOverrideString;
var globalconfig string TurboEvilDeckClassOverrideString;

function PostBeginPlay()
{
	AddToPackageMap("KFTurbo");
	AddToPackageMap("KFTurboCardGame");
	AddDeckOverridesToPackageMap();

	TurboCardReplicationInfo = CreateTurboCardReplicationInfo();
	CardGameRules = CreateCardGameRules();

	Super.PostBeginPlay();

	AttemptModifyGameLength();

	TurboCardStats = SetupStatTcpLink();
	
	class'TurboWaveEventHandler'.static.RegisterWaveHandler(Self, class'CardGameWaveEventHandler');
	class'TurboWaveSpawnEventHandler'.static.RegisterWaveHandler(Self, class'CardGameWaveSpawnEventHandler');
}

function Tick(float DeltaTime)
{
	class'KFTurboMut'.static.FindMutator(Level.Game).SetGameType(Self, "turbocardgame");

	Disable('Tick');
}

function AddDeckOverridesToPackageMap()
{
	local array<string> PackageNameList;
	local string PackageName;
	local int Index;

	PackageName = GetDeckOverridePackageName(TurboGoodDeckClassOverrideString);
	if (PackageName != "")
	{
		AddUnique(PackageName, PackageNameList);
	}
	
	PackageName = GetDeckOverridePackageName(TurboSuperDeckClassOverrideString);
	if (PackageName != "")
	{
		AddUnique(PackageName, PackageNameList);
	}
	
	PackageName = GetDeckOverridePackageName(TurboProConDeckClassOverrideString);
	if (PackageName != "")
	{
		AddUnique(PackageName, PackageNameList);
	}
	
	PackageName = GetDeckOverridePackageName(TurboEvilDeckClassOverrideString);
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
	if (KFGameType(Level.Game) == None)
	{
		return;
	}

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
	local GameRules GameRules;
	local CardGameRules CGR;
	CGR = Spawn(class'CardGameRules', Self);
	CGR.MutatorOwner = Self;

	if (Level.Game.GameRulesModifiers == None)
	{
    	Level.Game.GameRulesModifiers = CGR;
		return CGR;
	}

	GameRules = Level.Game.GameRulesModifiers;
	
	while(GameRules.NextGameRules != None)
	{
		GameRules = GameRules.NextGameRules;
	}
    
	GameRules.NextGameRules = CGR;
	
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
}

//Should only be spawned after all the other actors are spun up.
function TurboCardGameplayManager CreateCardGameplayManager()
{
	return Spawn(class'TurboCardGameplayManager', Self);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (KFPlayerReplicationInfo(Other) != None)
	{
		AddCardGamePlayerReplicationInfo(KFPlayerReplicationInfo(Other));
	}

	if (TurboGameReplicationInfo(Other) != None)
	{
		AddTurboCardGameModifier(TurboGameReplicationInfo(Other));
	}
	
	if (CardGameRules != None)
	{
		CardGameRules.ModifyActor(Other);
	}

	return true;
}

function AddCardGamePlayerReplicationInfo(KFPlayerReplicationInfo PlayerReplicationInfo)
{
	local CardGamePlayerReplicationInfo CardGamePRI;
	local LinkedReplicationInfo LastLRI;

	LastLRI = PlayerReplicationInfo.CustomReplicationInfo;
	while (LastLRI != None && LastLRI.NextReplicationInfo != None)
	{
		LastLRI = LastLRI.NextReplicationInfo;
	}

	CardGamePRI = Spawn(class'CardGamePlayerReplicationInfo', PlayerReplicationInfo.Owner);
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
	bAddToServerPackages=True
	GroupName="KF-CardGame" //Used by TurboGameplayAchievementPack to determine if a card game is being played.
	FriendlyName="Killing Floor Turbo Card Game"
	Description="Killing Floor Turbo's card game mutator. Before each wave, users are asked to vote between a selection of gameplay modifiers (cards)."
}
