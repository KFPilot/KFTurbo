//Killing Floor Turbo TurboCardDeck
//It is important to note that clients spawn their own local copy of active decks.
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

function InitializeDeck(TurboCardReplicationInfo TCRI)
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

static simulated function TurboCard GetCardFromReference(TurboCardReplicationInfo.CardReference Reference)
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

simulated function TurboCard GetCardInstanceFromReference(TurboCardReplicationInfo.CardReference Reference)
{
    if (Reference.Deck != Class || Reference.CardIndex < 0)
    {
        return None;
    }

    //If out of bounds of DeckCardOriginalDeckCardObjectListObjectList, offset and check OriginalOptionalCardList.
    if (Reference.CardIndex >= DeckCardObjectList.Length)
    {
        Reference.CardIndex -= DeckCardObjectList.Length;
        if (Reference.CardIndex >= OptionalCardList.Length)
        {
            return None;
        }

        return OptionalCardList[Reference.CardIndex].Card;
    }

    return DeckCardObjectList[Reference.CardIndex];
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

    if (CurrentDeckCardObjectList.Length == 0)
    {
        return None;
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

    bEnabled = bEnabled || class'KFTurboCardGameMut'.default.bPerformValidation; //Always add optional cards when performing validation.

    Card = OriginalOptionalCardList[OriginalOptionalIndex].Card;

    for (Index = 0; Index < OptionalCardList.Length; Index++)
    {
        if (OptionalCardList[Index].Card == Card)
        {
            OptionalCardList[Index].bEnabled = bEnabled;
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

static final function DrawBox(Canvas C, Material Material, float SizeX, float SizeY)
{
	C.DrawTile(Material, SizeX, SizeY, 0.f, 0.f, Material.MaterialUSize(), Material.MaterialVSize());
}

static function DrawCardInfoIcon(Canvas C, Material Icon, float DrawX, float DrawY, float DrawHeight, float Ratio)
{
	C.SetPos(DrawX, DrawY);
	C.DrawColor = class'TurboHUDOverlay'.static.MakeColor(0, 0, 0, 80.f * Ratio);
	DrawBox(C, class'TurboHUDKillingFloor'.default.WhiteMaterial, DrawHeight, DrawHeight);
	
	C.SetPos(DrawX, DrawY);
	C.DrawColor = class'TurboHUDOverlay'.static.MakeColor(255, 255, 255, 255.f * Ratio);
	DrawBox(C, Icon, DrawHeight, DrawHeight);
}

static function DrawCardInfoProgress(Canvas C, Material Icon, float Progress, float DrawX, float DrawY, float DrawHeight, float Ratio)
{
	DrawCardInfoIcon(C, Icon, DrawX, DrawY, DrawHeight, Ratio);

	if (Progress <= 0.001f)
	{
		return;
	}

	C.SetPos(DrawX, DrawY + (DrawHeight * 0.8));
	C.DrawColor = class'TurboHUDOverlay'.static.MakeColor(255, 0, 0, 180.f * Ratio);
	DrawBox(C, class'TurboHUDKillingFloor'.default.WhiteMaterial, DrawHeight * Progress, DrawHeight * 0.2f);
}

static function DrawCardInfoNumberProgress(Canvas C, Material Icon, float Progress, coerce string String, float DrawX, float DrawY, float DrawHeight, float Ratio, float TextScale)
{
	local float TextSizeX, TextSizeY;
	local float OriginalTextScale;

	DrawCardInfoProgress(C, Icon, Progress, DrawX, DrawY, DrawHeight, Ratio);

	if (String == "")
	{
		return;
	}

	OriginalTextScale = C.FontScaleX;
	C.FontScaleX *= TextScale;
	C.FontScaleY = C.FontScaleX;
	C.TextSize(String, TextSizeX, TextSizeY);
	DrawX = ((DrawX + DrawHeight) - TextSizeX) + (DrawHeight * 0.1f);
	DrawY = DrawY - (DrawHeight * 0.2f);

	C.DrawColor = class'TurboHUDOverlay'.static.MakeColor(0, 0, 0, 120.f * Ratio);
	C.SetPos(DrawX + (TextSizeY * 0.025f), DrawY + (TextSizeY * 0.025f));
	C.DrawText(String);
	C.DrawColor = class'TurboHUDOverlay'.static.MakeColor(255.f, 0, 0, 240.f * Ratio);
	C.SetPos(DrawX, DrawY);
	C.DrawText(String);

	C.FontScaleX = OriginalTextScale;
	C.FontScaleY = OriginalTextScale;
}

defaultproperties
{
    
}
