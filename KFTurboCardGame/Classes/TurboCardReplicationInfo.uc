//Killing Floor Turbo TurboCardReplicationInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardReplicationInfo extends Engine.ReplicationInfo;

var KFTurboCardGameMut OwnerMutator;

var TurboCardDeck GoodGameDeck;
var TurboCardDeck SuperGameDeck;
var TurboCardDeck ProConGameDeck;
var TurboCardDeck EvilGameDeck;

var int SelectionCount;
var int GoodSelectionDelta;
var int ProConSelectionDelta;

struct CardReference
{
    var class<TurboCardDeck> Deck;
    var int CardIndex;
};

//List of cards players can pick from. If any cards are active, we are in card vote mode.
const MAX_SELECTABLE_CARDS = 9;
var TurboCard AuthSelectableCardList[MAX_SELECTABLE_CARDS]; //Needed to call activation delegate on server.
var CardReference SelectableCardList[MAX_SELECTABLE_CARDS];
//List of active cards. Game can have a maximum of 30 active cards.
const MAX_ACTIVE_CARDS = 30;
var TurboCard AuthActiveCardList[MAX_ACTIVE_CARDS];
var CardReference ActiveCardList[MAX_ACTIVE_CARDS];
//Counter that is incremented whenever some action is done to the two above replicated arrays.
var byte SelectionUpdateCounter;

//Starts as false, represents if we were voting on a card last time PostNetReceive was called.
var bool bCurrentlyVoting;
//List of cards that were active last time we received a card list.
var CardReference LastKnownActiveCardList[MAX_ACTIVE_CARDS];

//Will prevent rerolls from triggering themselves.
var bool bIsPerformingReRoll;

var TurboCardOverlay TurboCardOverlay;
var TurboCardInteraction TurboCardInteraction;

delegate OnSelectableCardsUpdated(TurboCardReplicationInfo CGRI);
delegate OnActiveCardsUpdated(TurboCardReplicationInfo CGRI);

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority )
		SelectableCardList, ActiveCardList, SelectionUpdateCounter;
}

//Resolves a card object from a deck CDO. DO NOT CALL INSTANCE FUNCTIONS ON THESE.
static final function TurboCard ResolveCard(CardReference Reference)
{
    if (Reference.Deck == None)
    {
        return None;
    }

    return Reference.Deck.static.GetCardFromReference(Reference);
}

static final function CardReference GetCardReference(TurboCard Card)
{
    local CardReference Reference;
    if (Card.DeckClass == None)
    {
        Reference.Deck = None;
        Reference.CardIndex = -1;
        return Reference;
    }

    Reference.Deck = Card.DeckClass;
    Reference.CardIndex = Card.CardIndex;
    return Reference;
}

//Returns index (usually is wave - 1) that Curse Of Ra was selected.
simulated function int GetCurseOfRaCardIndex()
{
    local int Index;
    local TurboCard Card;

    for (Index = 0; Index < ArrayCount(ActiveCardList); Index++)
    {
        Card = ResolveCard(ActiveCardList[Index]);

        if (Card == None)
        {
            return -1;
        }

        if (TurboCard_Evil_Ra(Card) != None)
        {
            return Index;
        }
    }

    return -1;
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if (Role != ROLE_Authority)
    {
        CheckForSelectableCardUpdates();
        CheckForActiveCardUpdates();
    }
}

simulated function Tick(float DeltaTime)
{
    if (Level.NetMode == NM_DedicatedServer)
    {
        Disable('Tick');
        return;
    }

    if (Level.GetLocalPlayerController() != None)
    {
        if (TurboCardOverlay == None)
        { 
            AddOverlay(Level.GetLocalPlayerController());
        }

        SetupTurboCardInteraction();
        if (TurboCardOverlay != None && TurboCardInteraction != None)
        {
            Disable('Tick');
        }
    }
}

simulated function SetupTurboCardInteraction()
{
    if (TurboCardInteraction != None || Level.GetLocalPlayerController() == None || Level.GetLocalPlayerController().Player == None)
    {
        return;
    }
    
    TurboCardInteraction = TurboCardInteraction(Level.GetLocalPlayerController().Player.InteractionMaster.AddInteraction("KFTurboCardGame.TurboCardInteraction", Level.GetLocalPlayerController().Player));

    if (TurboCardInteraction != None)
    {
        TurboCardInteraction.InitializeInteraction();
    }
}

simulated function Destroyed()
{
    if (TurboCardOverlay != None)
    {
        TurboCardOverlay.Destroy();
    }

    Super.Destroyed();
}

simulated function AddOverlay(PlayerController PlayerController)
{
    local TurboHUDKillingFloor TurboHUD;
    TurboHUD = TurboHUDKillingFloor(PlayerController.myHUD);

    if (TurboHUD == None)
    {
        return;
    }

    TurboCardOverlay = Spawn(class'TurboCardOverlay', TurboHUD);
    TurboCardOverlay.Initialize(TurboHUD);
    TurboCardOverlay.InitializeCardGameHUD(Self);
    TurboHUD.AddPreDrawOverlay(TurboCardOverlay);
}

simulated function PostNetReceive()
{
    Super.PostNetReceive();

    CheckForActiveCardUpdates();
    CheckForSelectableCardUpdates();
}

simulated function CheckForActiveCardUpdates()
{
    local int ActiveCardIndex;
    local TurboCard NewActiveCard, LastKnownActiveCard;
    local bool bHasNewActiveCards;

    bHasNewActiveCards = false;
    for (ActiveCardIndex = 0; ActiveCardIndex < ArrayCount(ActiveCardList); ActiveCardIndex++)
    {
        NewActiveCard = ResolveCard(ActiveCardList[ActiveCardIndex]);
        LastKnownActiveCard = ResolveCard(LastKnownActiveCardList[ActiveCardIndex]);
        //Update the entry after resolving the reference.
        LastKnownActiveCardList[ActiveCardIndex] = ActiveCardList[ActiveCardIndex];

        if (NewActiveCard != LastKnownActiveCard)
        {
            bHasNewActiveCards = true;
        }

        if (NewActiveCard == None && LastKnownActiveCard == None)
        {
            break;
        }
    }

    if (!bHasNewActiveCards)
    {
        return;
    }

    OnActiveCardsUpdated(Self);
}

simulated function CheckForSelectableCardUpdates()
{
    local bool bHasSelectableCards;
    bHasSelectableCards = ResolveCard(SelectableCardList[0]) != None;

    if (bHasSelectableCards == bCurrentlyVoting)
    {
        return;
    }
    
    bCurrentlyVoting = bHasSelectableCards;
    OnSelectableCardsUpdated(Self);
}

function Initialize(KFTurboCardGameMut Mutator)
{
    OwnerMutator = Mutator;
    InitializeCardDecks();
}

//Sets up card deck. Can called after initial setup to "reset" all decks.
function InitializeCardDecks()
{
    local class<TurboCardDeck> GoodTurboDeckClass;
    local class<TurboCardDeck> SuperTurboDeckClass;
    local class<TurboCardDeck> ProConTurboDeckClass;
    local class<TurboCardDeck> EvilTurboDeckClass;

    if (Level.bLevelChange)
    {
        return;
    }

    GoodTurboDeckClass = class'TurboCardDeck_Good';
	if (OwnerMutator.TurboGoodDeckClassOverrideString != "")
	{
		GoodTurboDeckClass = class<TurboCardDeck>(DynamicLoadObject(OwnerMutator.TurboGoodDeckClassOverrideString, class'Class'));

        if (GoodTurboDeckClass == None)
        {
            GoodTurboDeckClass = class'TurboCardDeck_Good';
        }
	}

    SuperTurboDeckClass = class'TurboCardDeck_Super';
	if (OwnerMutator.TurboSuperDeckClassOverrideString != "")
	{
		SuperTurboDeckClass = class<TurboCardDeck>(DynamicLoadObject(OwnerMutator.TurboSuperDeckClassOverrideString, class'Class'));

        if (SuperTurboDeckClass == None)
        {
            SuperTurboDeckClass = class'TurboCardDeck_Super';
        }
	}

    ProConTurboDeckClass = class'TurboCardDeck_ProCon';
	if (OwnerMutator.TurboProConDeckClassOverrideString != "")
	{
		ProConTurboDeckClass = class<TurboCardDeck>(DynamicLoadObject(OwnerMutator.TurboProConDeckClassOverrideString, class'Class'));

        if (ProConTurboDeckClass == None)
        {
            ProConTurboDeckClass = class'TurboCardDeck_ProCon';
        }
	}

    EvilTurboDeckClass = class'TurboCardDeck_Evil';
	if (OwnerMutator.TurboEvilDeckClassOverrideString != "")
	{
		EvilTurboDeckClass = class<TurboCardDeck>(DynamicLoadObject(OwnerMutator.TurboEvilDeckClassOverrideString, class'Class'));

        if (EvilTurboDeckClass == None)
        {
            EvilTurboDeckClass = class'TurboCardDeck_Evil';
        }
	}

    if (GoodGameDeck != None)
    {
        GoodGameDeck.Destroy();
    }

    if (SuperGameDeck != None)
    {
        SuperGameDeck.Destroy();
    }

    if (ProConGameDeck != None)
    {
        ProConGameDeck.Destroy();
    }

    if (EvilGameDeck != None)
    {
        EvilGameDeck.Destroy();
    }

    GoodGameDeck = Spawn(GoodTurboDeckClass, self);
    SuperGameDeck = Spawn(SuperTurboDeckClass, self);
    ProConGameDeck = Spawn(ProConTurboDeckClass, self);
    EvilGameDeck = Spawn(EvilTurboDeckClass, self);

    GoodGameDeck.InitializeDeck();
    SuperGameDeck.InitializeDeck();
    ProConGameDeck.InitializeDeck();
    EvilGameDeck.InitializeDeck();
}

final function array<TurboCard> GetActiveCardList()
{
    local int Index;
    local array<TurboCard> CardList;

    CardList.Length = ArrayCount(AuthActiveCardList);

    for (Index = 0; Index < ArrayCount(AuthActiveCardList); Index++)
    {
        if (AuthActiveCardList[Index] == None)
        {
            break;
        }

        CardList[Index] = AuthActiveCardList[Index];
    }

    CardList.Length = Index;
    return CardList;
}

final function array<TurboCard> GetSelectableCardList()
{
    local int Index;
    local array<TurboCard> CardList;

    CardList.Length = ArrayCount(AuthSelectableCardList);

    for (Index = 0; Index < ArrayCount(AuthSelectableCardList); Index++)
    {
        if (AuthSelectableCardList[Index] == None)
        {
            break;
        }

        CardList[Index] = AuthSelectableCardList[Index];
    }

    CardList.Length = Index;
    return CardList;
}

//Sends vote result to stats.
function SendVoteResult(TurboCard SelectedCard)
{
    local TurboCardStatsTcpLink StatsTcpLink;

    StatsTcpLink = class'TurboCardStatsTcpLink'.static.FindCardStatsTcpLink(Level.Game);

    if (StatsTcpLink == None)
    {
        return;
    }

    StatsTcpLink.OnVoteComplete(GetActiveCardList(), GetSelectableCardList(), SelectedCard);
}

//Append to end of active card list this newly selected card. DO NOT PASS CARDREFERENCE-RESOLVED CARDS HERE.
function SelectCard(TurboCard SelectedCard, optional bool bFromVote)
{
    local int Index;

    if (Level.bLevelChange)
    {
        return;
    }
    
    if (SelectedCard == None)
    {
        return;
    }

    if (bFromVote)
    {
        SendVoteResult(SelectedCard);
    }
    
    for (Index = 0; Index < ArrayCount(ActiveCardList); Index++)
    {
        if (ResolveCard(ActiveCardList[Index]) != None)
        {
            continue;
        }

        ActiveCardList[Index] = GetCardReference(SelectedCard);
        AuthActiveCardList[Index] = SelectedCard;
        break;
    }

    SelectionUpdateCounter++;
    ClearSelection();

    log("Executing OnActivateCard delegate for"@SelectedCard.CardID, 'KFTurboCardGame');
    SelectedCard.OnActivateCard(OwnerMutator.TurboCardGameplayManagerInfo, SelectedCard, true);
    
    CheckForActiveCardUpdates();
}

function SelectRandomCard()
{
    local int Index;
    for (Index = 0; Index < ArrayCount(AuthSelectableCardList); Index++)
    {
        if (AuthSelectableCardList[Index] != None)
        {
            continue;
        }

        break;
    }

    Index = Rand(Index);
    SelectCard(AuthSelectableCardList[Index], true);
}

//Populates the SelectableCardList with pickable cards.
function StartSelection(int WaveNumber)
{
    local TurboCardDeck Deck;
    local int Count;

    if (Level.bLevelChange)
    {
        return;
    }

    ClearSelection();

    Deck = None;
    WaveNumber++;

    log ("Selecting for wave number:"@WaveNumber);
    switch(WaveNumber)
    {
        case 0:
        case 1:
            Deck = SuperGameDeck;
            break;
        case 2:
            Deck = EvilGameDeck;
            break;
        case 3:
            Deck = ProConGameDeck;
            break;
        case 4:
            Deck = GoodGameDeck;
            break;
        case 5:
            Deck = SuperGameDeck;
            break;
        case 6:
            Deck = EvilGameDeck;
            break;
        case 7:
            Deck = ProConGameDeck;
            break;
        case 8:
            Deck = GoodGameDeck;
            break;
        case 9:
            Deck = EvilGameDeck;
            break;
        case 10:
            Deck = ProConGameDeck;
            break;
        case 11:
            Deck = EvilGameDeck;
            break;
        case 12:
            Deck = GoodGameDeck;
            break;
        case 13:
            Deck = EvilGameDeck;
            break;
        case 14:
            Deck = SuperGameDeck;
            break;
        case 15:
            Deck = EvilGameDeck;
            break;
    }

    //We pick specific card order for the first 15 waves.
    //After that, space out card occurances in a way that leans towards more difficulty.
    if (Deck == None)
    {
        if (WaveNumber % 3 == 0)
        {
            Deck = EvilGameDeck;
        }
        else if (WaveNumber % 5 == 0)
        {
            Deck = SuperGameDeck;
        }
        else if (WaveNumber % 2 == 0)
        {
            Deck = ProConGameDeck;
        }
        else 
        {
            Deck = GoodGameDeck;
        }
    }

    Deck.OnDeckDraw(Self);

    log ("Selected Deck:"@Deck);
    Count = GetSelectionCount(Deck);
    Count--;
    while (Count >= 0)
    {
        AuthSelectableCardList[Count] = Deck.DrawRandomCard();
        SelectableCardList[Count] = GetCardReference(AuthSelectableCardList[Count]);
        log ("- Selected Card:"@Count@AuthSelectableCardList[Count].CardName[0]);
        Count--;
    }
    
    SelectionUpdateCounter++;
    CheckForSelectableCardUpdates();
}

function array<TurboCard_Super> GetActiveSuperCardList(optional bool bCheckCanDeactivate)
{
    local int Index;
    local int SuperCount;
    local array<TurboCard_Super> ActiveSuperCardList;

    ActiveSuperCardList.Length = ArrayCount(AuthActiveCardList);
    SuperCount = 0;

    for (Index = 0; Index < ArrayCount(AuthActiveCardList); Index++)
    {
        if (AuthActiveCardList[Index] == None || (bCheckCanDeactivate && AuthActiveCardList[Index].bCanBeDeactivated))
        {
            break;
        }

        if (TurboCard_Super(AuthActiveCardList[Index]) == None)
        {
            continue;
        }

        ActiveSuperCardList[SuperCount] = TurboCard_Super(AuthActiveCardList[Index]);
        SuperCount++;
    }

    ActiveSuperCardList.Length = SuperCount;
    return ActiveSuperCardList;
}

function array<TurboCard_Evil> GetActiveEvilCardList(optional bool bCheckCanDeactivate)
{
    local int Index;
    local int EvilCount;
    local array<TurboCard_Evil> ActiveEvilCardList;

    ActiveEvilCardList.Length = ArrayCount(AuthActiveCardList);
    EvilCount = 0;

    for (Index = 0; Index < ArrayCount(AuthActiveCardList); Index++)
    {
        if (AuthActiveCardList[Index] == None || (bCheckCanDeactivate && !AuthActiveCardList[Index].bCanBeDeactivated))
        {
            break;
        }

        if (TurboCard_Evil(AuthActiveCardList[Index]) == None)
        {
            continue;
        }

        ActiveEvilCardList[EvilCount] = TurboCard_Evil(AuthActiveCardList[Index]);
        EvilCount++;
    }

    ActiveEvilCardList.Length = EvilCount;
    return ActiveEvilCardList;
}

//Card object must be the one in the AuthActiveCardList.
//Will shift all cards after the removed card back by one to maintain the array.
function RemoveActiveCard(TurboCard Card)
{
    local int Index;
    local bool bRemovedCard;
    local CardReference EmptyReference;
    EmptyReference.Deck = None;
    EmptyReference.CardIndex = -1;

    if (Card == None)
    {
        return;
    }
    
    log("Attempting to remove card"@Card.CardID$".", 'KFTurboCardGame');

    bRemovedCard = false;

    for (Index = 0; Index < ArrayCount(AuthActiveCardList); Index++)
    {
        if (AuthActiveCardList[Index] != Card)
        {
            continue;
        }

        bRemovedCard = true;
        log("- Found card. Deactivating...", 'KFTurboCardGame');
        AuthActiveCardList[Index].OnActivateCard(OwnerMutator.TurboCardGameplayManagerInfo, AuthActiveCardList[Index], false);
        AuthActiveCardList[Index] = None;
        ActiveCardList[Index] = EmptyReference;
        break;
    }

    if (!bRemovedCard)
    {
        return;
    }

    //If there are no cards after the one we removed, return.
    if (Index >= (ArrayCount(AuthActiveCardList) - 1) || AuthActiveCardList[Index + 1] == None)
    {
        return;    
    }

    log("- Shifting cards down one index.", 'KFTurboCardGame');
    for (Index = Index; (Index + 1) < ArrayCount(AuthActiveCardList); Index++)
    {
        if (AuthActiveCardList[Index + 1] == None)
        {
            break;
        }

        AuthActiveCardList[Index] = AuthActiveCardList[Index + 1];
        ActiveCardList[Index] = ActiveCardList[Index + 1];
        AuthActiveCardList[Index + 1] = None;
        ActiveCardList[Index + 1] = EmptyReference;
    }
}

function ActivateRandomSuperCard()
{
    local TurboCard Card;
    if (SuperGameDeck == None)
    {
        return;
    }

    SuperGameDeck.OnDeckDraw(Self);
    Card = SuperGameDeck.DrawRandomCard();
    SelectCard(Card);
}

function ActivateRandomEvilCard()
{
    local TurboCard Card;
    if (EvilGameDeck == None)
    {
        return;
    }

    EvilGameDeck.OnDeckDraw(Self);
    Card = EvilGameDeck.DrawRandomCard();
    SelectCard(Card);
}

function ActivateRandomCard()
{
    local float Random;
    local TurboCardDeck RandomDeck;
    local TurboCard Card;

    Random = FRand();
    if (Random < 0.25f)
    {
        RandomDeck = GoodGameDeck;
    }
    else if (Random < 0.5f)
    {
        RandomDeck = SuperGameDeck;
    }
    else if (Random < 0.75f)
    {
        RandomDeck = ProConGameDeck;
    }
    else
    {
        RandomDeck = EvilGameDeck;
    }

    RandomDeck.OnDeckDraw(Self);
    Card = RandomDeck.DrawRandomCard();
    SelectCard(Card);
}

function DeactivateRandomSuperCard()
{
    local array<TurboCard_Super> ActiveSuperCardList;
    ActiveSuperCardList = GetActiveSuperCardList(false); //Let the random super we deactivate have bCanBeDeactivated be false as a "lucky" deactivation.
    
    if (ActiveSuperCardList.Length == 0)
    {
        return;
    }

    RemoveActiveCard(ActiveSuperCardList[Rand(ActiveSuperCardList.Length)]);
}

function DeactivateRandomEvilCard()
{
    local array<TurboCard_Evil> ActiveEvilCardList;
    ActiveEvilCardList = GetActiveEvilCardList(true); //Only deactivate evil cards that can be deactivated to avoid "unlucky" deactivation.

    if (ActiveEvilCardList.Length == 0)
    {
        return;
    }

    RemoveActiveCard(ActiveEvilCardList[Rand(ActiveEvilCardList.Length)]);
}

//Resets decks and rerolls all cards. Optionally will place a specific card at the top of the active list.
function ResetDecksAndReRollCards(optional TurboCard TopCard)
{
    local int Index;

    local int NumSuper;
    local int NumEvil;
    local int NumGood;
    local int NumProCon;
    
    local CardReference EmptyReference;
    EmptyReference.Deck = None;
    EmptyReference.CardIndex = -1;

    if (bIsPerformingReRoll)
    {
        return;
    }

    log("Attempting card reroll...", 'KFTurboCardGame');

    bIsPerformingReRoll = true;

    for (Index = 0; Index < ArrayCount(AuthActiveCardList); Index++)
    {
        if (AuthActiveCardList[Index] == None)
        {
            break;
        }

        //Would be nice if we had a better way to do this.
        if (TurboCard_Super(AuthActiveCardList[Index]) != None)
        {
            NumSuper++;
        }
        else if (TurboCard_Evil(AuthActiveCardList[Index]) != None)
        {
            NumEvil++;
        }
        else if (TurboCard_Good(AuthActiveCardList[Index]) != None)
        {
            NumGood++;
        }
        else if (TurboCard_ProCon(AuthActiveCardList[Index]) != None)
        {
            NumProCon++;
        }

        log("Attempting card deactivation of"@AuthActiveCardList[Index].CardID$".", 'KFTurboCardGame');
        AuthActiveCardList[Index].OnActivateCard(OwnerMutator.TurboCardGameplayManagerInfo, AuthActiveCardList[Index], false);
        AuthActiveCardList[Index] = None;
        ActiveCardList[Index] = EmptyReference;
    }

    InitializeCardDecks(); //Resets all card decks.

    if (TopCard != None)
    {
        log("Placing top card..."@TopCard.CardID$".", 'KFTurboCardGame');
        AuthActiveCardList[0] = TopCard;
        ActiveCardList[0] = GetCardReference(TopCard);

        SuperGameDeck.RemoveCardFromDeck(TopCard);
        GoodGameDeck.RemoveCardFromDeck(TopCard);
        ProConGameDeck.RemoveCardFromDeck(TopCard);
        EvilGameDeck.RemoveCardFromDeck(TopCard);
    }

    log("Rolling cards... (Evil:"@NumEvil@")(ProCon:"@NumProCon@")(Good:"@NumGood@")(Super:"@NumSuper@").", 'KFTurboCardGame');

    //We'll do card activations in order of Evil -> Pro Con -> Good -> Super. Should minimize really bad outcomes.
    EvilGameDeck.OnDeckDraw(Self);
    while(NumEvil > 0)
    {
        SelectCard(EvilGameDeck.DrawRandomCard());
        NumEvil--;
    }

    ProConGameDeck.OnDeckDraw(Self);
    while(NumProCon > 0)
    {
        SelectCard(ProConGameDeck.DrawRandomCard());
        NumProCon--;
    }

    GoodGameDeck.OnDeckDraw(Self);
    while(NumGood > 0)
    {
        SelectCard(GoodGameDeck.DrawRandomCard());
        NumGood--;
    }

    SuperGameDeck.OnDeckDraw(Self);
    while(NumSuper > 0)
    {
        SelectCard(SuperGameDeck.DrawRandomCard());
        NumSuper--;
    }
    
    bIsPerformingReRoll = false;
}

function DeactivateAllGoodCards()
{
    local int Index;
    for (Index = ArrayCount(AuthActiveCardList) - 1; Index >= 0; Index--)
    {
        if (AuthActiveCardList[Index] == None)
        {
            continue;
        }

        if (TurboCard_Good(AuthActiveCardList[Index]) != None)
        {
            RemoveActiveCard(AuthActiveCardList[Index]);
        }
    }
}

function int GetSelectionCount(TurboCardDeck Deck)
{
    if (TurboCardDeck_Good(Deck) != None)
    {
        return Max(SelectionCount + GoodSelectionDelta, 1);
    }
    else if (TurboCardDeck_ProCon(Deck) != None)
    {
        return Max(SelectionCount + ProConSelectionDelta, 1);
    }

    return SelectionCount;
}

//Clears out SelectableCardList.
function ClearSelection()
{
    local int Index;
    local CardReference EmptyReference;
    EmptyReference.Deck = None;
    EmptyReference.CardIndex = -1;
    for (Index = ArrayCount(SelectableCardList) - 1; Index >= 0; Index--)
    {
        SelectableCardList[Index] = EmptyReference;
        AuthSelectableCardList[Index] = None;
    }

    SelectionUpdateCounter++;
    CheckForSelectableCardUpdates();
}

//Called when a majority have voted or the next wave has begun.
function OnSelectionTimeEnd()
{
    local array<int> VotingList;
    local array<int> TiedVotingList;

    local int CardIndex;
    local int Index;
    local int TopVotedCount;
    local CardGamePlayerReplicationInfo CardLRI;

    TopVotedCount = 1;

    //Voting is done via 1-based indexing but the selectable card array and the vote tally array are 0-based so index conversion is done during tally. 
    for (Index = 0; Index < Level.GRI.PRIArray.Length; Index++)
    {
        if (Level.GRI.PRIArray[Index].bOnlySpectator)
        {
            continue;
        }

        CardLRI = class'CardGamePlayerReplicationInfo'.static.GetCardGameLRI(Level.GRI.PRIArray[Index]);

        if (CardLRI == None || CardLRI.VoteIndex <= 0)
        {
            continue;
        }

        CardIndex = CardLRI.VoteIndex - 1;

        if (VotingList.Length > CardIndex)
        {
            VotingList[CardIndex] = VotingList[CardIndex] + 1;

            if (TopVotedCount < VotingList[CardIndex])
            {
                TopVotedCount = VotingList[CardIndex];
            }
        }
        else
        {
            VotingList.Length = CardIndex + 1;
            VotingList[CardIndex] = 1;
        }
    }

    if (VotingList.Length == 0)
    {
        SelectRandomCard();
    }
    else
    {
        for (Index = 0; Index < VotingList.Length; Index++)
        {
            if (VotingList[Index] < TopVotedCount)
            {
                continue;
            }

            TiedVotingList.Length = TiedVotingList.Length + 1;
            TiedVotingList[TiedVotingList.Length - 1] = Index;
        }

        if (TiedVotingList.Length == 1)
        {
            SelectCard(AuthSelectableCardList[TiedVotingList[0]], true);
        }
        else if (TiedVotingList.Length > 1)
        {
            SelectCard(AuthSelectableCardList[TiedVotingList[Rand(TiedVotingList.Length)]], true);
        }
        else 
        {
            SelectRandomCard();
        }
    }

    ResetPlayerVotes();

    NotifyDecksWaveStarted();
}

function ResetPlayerVotes()
{
    local int Index;
    local CardGamePlayerReplicationInfo CardLRI;

    //Voting is done via 1-based indexing but the selectable card array and the vote tally array are 0-based so index conversion is done during tally. 
    for ( Index = 0; Index < Level.GRI.PRIArray.Length; Index++)
    {
        CardLRI = class'CardGamePlayerReplicationInfo'.static.GetCardGameLRI(Level.GRI.PRIArray[Index]);

        if (CardLRI == None)
        {
            continue;
        }

        CardLRI.ResetVote();
    }
}

function NotifyDecksWaveStarted()
{
    local int WaveNumber;
    if (KFGameType(Level.Game) == None)
    {
        return;
    }

    WaveNumber = KFGameType(Level.Game).WaveNum;
    GoodGameDeck.OnWaveStarted(Self, WaveNumber);
    SuperGameDeck.OnWaveStarted(Self, WaveNumber);
    ProConGameDeck.OnWaveStarted(Self, WaveNumber);
    EvilGameDeck.OnWaveStarted(Self, WaveNumber);
}

function GetActiveCardCounts(out int GoodCardCount, out int SuperCardCount, out int ProConCardCount, out int EvilCardCount)
{
    local int Index;

    GoodCardCount = 0;
    SuperCardCount = 0;
    ProConCardCount = 0;
    EvilCardCount = 0;

    for (Index = 0; Index < ArrayCount(AuthActiveCardList); Index++)
    {
        if (AuthActiveCardList[Index] == None)
        {
            return;
        }

        if (TurboCard_Good(AuthActiveCardList[Index]) != None)
        {
            GoodCardCount++;
        }
        else if (TurboCard_Super(AuthActiveCardList[Index]) != None)
        {
            SuperCardCount++;
        }
        else if (TurboCard_ProCon(AuthActiveCardList[Index]) != None)
        {
            ProConCardCount++;
        }
        else if (TurboCard_Evil(AuthActiveCardList[Index]) != None)
        {
            EvilCardCount++;
        }
    }
}

function DebugActivateCard(string CardID)
{
    local TurboCard Card;

    Card = GoodGameDeck.FindCardByCardID(CardID);

    if (Card == None)
    {
        Card = SuperGameDeck.FindCardByCardID(CardID);

        if (Card == None)
        {
            Card = ProConGameDeck.FindCardByCardID(CardID);
    
            if (Card == None)
            {
                Card = EvilGameDeck.FindCardByCardID(CardID);
            }
        }
    }

    if (Card == None)
    {
        return;
    }

    SelectCard(Card, false);
}

function DebugDeactivateCard(string CardID)
{
    local int Index;

    for (Index = 0; Index < ArrayCount(AuthActiveCardList); Index++)
    {
        if (AuthActiveCardList[Index] == None)
        {
            break;
        }

        if (!(AuthActiveCardList[Index].CardID ~= CardID))
        {
            continue;
        }

        RemoveActiveCard(AuthActiveCardList[Index]);
        break;
    }
}

defaultproperties
{
    bAlwaysRelevant=true
    bNetNotify=true
    SelectionCount = 3
    GoodSelectionDelta = 0
    ProConSelectionDelta = 0
}