//Killing Floor Turbo TurboCardDeck
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardDeck extends Info;

var array< TurboCard > DeckCardObjectList;
var array< TurboCard > OriginalDeckCardObjectList;

function InitializeDeck()
{
    local int Index;

    for (Index = 0; Index < DeckCardObjectList.Length; Index++)
    {
        InitializeCard(DeckCardObjectList[Index], Index);
    }

    OriginalDeckCardObjectList = DeckCardObjectList;
}

final function InitializeCard(TurboCard Card, int Index)
{
    Card.DeckClass = Class;
    Card.CardIndex = Index;
}

static function TurboCard GetCardFromReference(TurboCardReplicationInfo.CardReference Reference)
{
    if (Reference.Deck != default.Class || Reference.CardIndex < 0 || Reference.CardIndex >= default.DeckCardObjectList.Length)
    {
        return None;
    }

    return default.DeckCardObjectList[Reference.CardIndex];
}

function TurboCard DrawRandomCard()
{
    local TurboCard Card;
    local int Index;
    Index = Rand(DeckCardObjectList.Length);
    Card = DeckCardObjectList[Index];
    DeckCardObjectList.Remove(Index, 1);
    return Card;
}

//Not guaranteed to be from the same deck object so we compare card IDs.
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
        bRemovedCard = true;
    }

    return bRemovedCard;
}

//Allows for decks to optionally do something like adding/removing cards based on game state/wave number.
function OnWaveStarted(TurboCardReplicationInfo TCRI, int StartedWave)
{
    
}

//Called right before we intend to draw card(s) from this deck. Can be for vote selection or other reasons (like Re-Roll or Deal With The Devil).
function OnDeckDraw(TurboCardReplicationInfo TCRI)
{
    
}

defaultproperties
{
    
}
