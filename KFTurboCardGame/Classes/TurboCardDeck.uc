//Killing Floor Turbo TurboCardDeck
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardDeck extends Info;

struct OptionalCardData
{
    var bool bEnabled;
    var TurboCard Card;
};

var array< TurboCard > DeckCardObjectList;
var array< TurboCard > OriginalDeckCardObjectList;
var array< OptionalCardData > OptionalCardList;
var array< OptionalCardData > OriginalOptionalCardList;

function InitializeDeck()
{
    local int Index;

    for (Index = 0; Index < DeckCardObjectList.Length; Index++)
    {
        InitializeCard(DeckCardObjectList[Index], Index);
    }

    //Optional cards are indexed at the end of the card list.
    for (Index = 0; Index < OptionalCardList.Length; Index++)
    {
        InitializeOptionalCard(OptionalCardList[Index], Index + DeckCardObjectList.Length);
    }

    OriginalDeckCardObjectList = DeckCardObjectList;
    OriginalOptionalCardList = OptionalCardList;
}

final function InitializeCard(TurboCard Card, int Index)
{
    Card.DeckClass = Class;
    Card.CardIndex = Index;
}

final function InitializeOptionalCard(out OptionalCardData OptionalCard, int Index)
{
    OptionalCard.Card.DeckClass = Class;
    OptionalCard.Card.CardIndex = Index;
    OptionalCard.bEnabled = false;
}

static function TurboCard GetCardFromReference(TurboCardReplicationInfo.CardReference Reference)
{
    if (Reference.Deck != default.Class || Reference.CardIndex < 0)
    {
        return None;
    }

    //If out of bounds of DeckCardObjectList, offset and check OptionalCardList.
    if (Reference.CardIndex >= default.DeckCardObjectList.Length)
    {
        Reference.CardIndex -= default.DeckCardObjectList.Length;
        if (Reference.CardIndex >= default.OptionalCardList.Length)
        {
            return None;
        }

        return default.OptionalCardList[Reference.CardIndex].Card;
    }

    return default.DeckCardObjectList[Reference.CardIndex];
}

function TurboCard DrawRandomCard()
{
    local array< TurboCard > CurrentDeckCardObjectList;
    local TurboCard Card;
    local int Index;

    CurrentDeckCardObjectList = DeckCardObjectList;

    //Append any optional cards to the card list.
    for (Index = 0; Index < OptionalCardList.Length; Index++)
    {
        if (!OptionalCardList[Index].bEnabled)
        {
            continue;
        }

        CurrentDeckCardObjectList.Length = CurrentDeckCardObjectList.Length + 1;
        CurrentDeckCardObjectList[CurrentDeckCardObjectList.Length - 1] = OptionalCardList[Index].Card;
    }

    Index = Rand(CurrentDeckCardObjectList.Length);
    Card = CurrentDeckCardObjectList[Index];

    if (Index < DeckCardObjectList.Length)
    {
        DeckCardObjectList.Remove(Index, 1);
    }
    else
    {
        //Because it's not guaranteed all cards from the optional list are present, we have to search for it.
        for (Index = 0; Index < OptionalCardList.Length; Index++)
        {
            if (OptionalCardList[Index].Card != Card)
            {
                continue;
            }
            
            OptionalCardList.Remove(Index, 1);
        }
    }

    return Card;
}

//Not guaranteed to be from the same deck object so we compare card IDs.
//Assumes cards are unique.
function bool RemoveCardFromDeck(TurboCard Card)
{
    local int Index;
    local string CardID;
    local bool bRemovedCard;

    CardID = Card.CardID;
    bRemovedCard = false;

    for (Index = DeckCardObjectList.Length - 1; Index >= 0; Index--)
    {
        if (DeckCardObjectList[Index].CardID != CardID)
        {
            continue;
        }

        DeckCardObjectList.Remove(Index, 1);
        return true;
    }
    
    for (Index = OptionalCardList.Length - 1; Index >= 0; Index--)
    {
        if (OptionalCardList[Index].Card.CardID != CardID)
        {
            continue;
        }

        OptionalCardList.Remove(Index, 1);
        return true;
    }

    return false;
}

//Allows for decks to optionally do something like adding/removing cards based on game state/wave number.
function OnWaveStarted(TurboCardReplicationInfo TCRI, int StartedWave)
{
    
}

//Called right before we intend to draw card(s) from this deck. Can be for vote selection or other reasons (like Re-Roll or Deal With The Devil).
function OnDeckDraw(TurboCardReplicationInfo TCRI)
{
    
}

//Given the original index of an optional card, sets the state of that card in the current optional card list (if it hasn't already been activated).
function SetOptionalCardEnabled(int OriginalOptionalIndex, bool bEnabled)
{
    local TurboCard Card;
    local int Index;

    Card = OriginalOptionalCardList[OriginalOptionalIndex].Card;

    for (Index = 0; Index < OptionalCardList.Length; Index++)
    {
        if (OptionalCardList[Index].Card == Card)
        {
            OptionalCardList[Index].bEnabled = bEnabled;
            log("Set optional card "+Card.CardID+" state to "+bEnabled, 'KFTurboCardVerbose');
            return;
        }
    }
}

//Returns a card given a card ID.
function TurboCard FindCardByCardID(string CardID)
{
    local int Index;

    for (Index = 0; Index < OriginalDeckCardObjectList.Length; Index++)
    {
        if (OriginalDeckCardObjectList[Index].CardID ~= CardID)
        {
            return OriginalDeckCardObjectList[Index];
        }
    }
    
    for (Index = OriginalOptionalCardList.Length - 1; Index >= 0; Index--)
    {
        if (OriginalOptionalCardList[Index].Card.CardID ~= CardID)
        {
            return OriginalOptionalCardList[Index].Card;
        }
    }

    return None;
}

defaultproperties
{
    
}
