//Killing Floor Turbo KFTurboCardGameMut
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboCardGameMut extends CardGameMutBase
		config(KFTurboCardGame);

#exec obj load file="..\Textures\TurboCardGame.utx" package=KFTurboCardGame

var TurboCardReplicationInfo TurboCardReplicationInfo;
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

	TurboCardReplicationInfo = CreateTurboCardReplicationInfo();
	CardGameRules = CreateCardGameRules();

	Super.PostBeginPlay();

	AttemptModifyGameLength();

	SetupStatTcpLink();
}

//Make game 14 waves long, with first few waves being very small.
function AttemptModifyGameLength()
{
	if (KFGameType(Level.Game) == None)
	{
		return;
	}

	class'TurboWaveEventHandler'.static.RegisterWaveHandler(Self, class'CardGameWaveEventHandler');
	KFTurboGameType(Level.Game).SetFinalWaveOverride(14);
}

function SetupStatTcpLink()
{
	local class<TurboCardStatsTcpLink> TcpLinkClass;
	if (!class'TurboCardStatsTcpLink'.static.ShouldBroadcastAnalytics())
	{
		return;
	}

	TcpLinkClass = class'TurboCardStatsTcpLink'.static.GetCardStatsTcpLinkClass();

	if (TcpLinkClass == None)
	{
		return;
	}

	TurboCardStats = Spawn(TcpLinkClass, Self);
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

function AddTurboCardGameModifier(TurboGameReplicationInfo TGRI)
{
	local TurboGameModifierReplicationLink LastGRL;
	local TurboClientModifierReplicationLink LastCRL;

	LastGRL = TGRI.CustomTurboModifier;
	while (LastGRL.NextGameModifierLink != None)
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
	while (LastCRL.NextClientModifierLink != None)
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
}

function ModifyPlayer(Pawn Other)
{
	Super.ModifyPlayer(Other);
	
	if (CardGameRules != None)
	{
		CardGameRules.ModifyPlayer(Other);
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
