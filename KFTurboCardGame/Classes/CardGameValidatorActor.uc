//Killing Floor Turbo CardGameValidatorActor
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardGameValidatorActor extends Info;

var KFTurboCardGameMut Mutator;
var int CurrentRound;

var array<TurboCard> AllCards;
var TurboCardGameplayManager GameplayManager;

auto state PerformValidation
{
Begin:
    Sleep(1.0);

    if (Mutator == None || Mutator.TurboCardReplicationInfo == None || Mutator.TurboCardGameplayManagerInfo == None)
    {
        log("CardGameValidatorActor: Mutator, TurboCardReplicationInfo, or TurboCardGameplayManagerInfo is None. Aborting validation.");
        Destroy();
        Stop;
    }

    GameplayManager = Mutator.TurboCardGameplayManagerInfo;
    GatherAllCards(Mutator.TurboCardReplicationInfo);

    if (AllCards.Length == 0)
    {
        log("CardGameValidatorActor: No cards found in decks. Aborting.");
        Destroy();
        Stop;
    }

    log("CardGameValidatorActor: Gathered"@AllCards.Length@"cards from all decks.");

    log("CardGameValidatorActor: Beginning individual card validation...");
    if (!RunIndividualCardValidation())
    {
        log("CardGameValidatorActor: Individual card validation failed. Stopping tests.");
        GotoState('');
    }
    log("CardGameValidatorActor: Individual card validation complete.");
    log("CardGameValidatorActor: Beginning random batch validation...");
    CurrentRound = 0;

ValidationLoop:
    Sleep(0.1f);
    CurrentRound++;
    log("==============================================================================");
    log("============= Performing validation round"@CurrentRound$" =============");
    log("==============================================================================");
    RunValidationRound();
    if (ValidateStateIsReset())
    {
        log("CardGameValidatorActor: Card round validation failed. Stopping tests.");
        GotoState('');
    }
    Goto('ValidationLoop');
}

function bool RunIndividualCardValidation()
{
    local int Index;
    local int PassCount, FailCount;
    local TurboCard Card;

    return true;
    PassCount = 0;
    FailCount = 0;

    for (Index = 0; Index < AllCards.Length; Index++)
    {
        Card = AllCards[Index];

        if (Card == None)
        {
            continue;
        }

        log("Activating"@Card.CardID);
        Card.OnActivateCard(GameplayManager, Card, true);
        Card.OnActivateCard(GameplayManager, Card, false);

        if (!ValidateStateIsResetQuiet(Card.CardID))
        {
            FailCount++;
            break;
        }
        else
        {
            PassCount++;
        }
    }

    log("Individual card validation concluded."@PassCount@"passed out of "@AllCards.Length$".");
    return FailCount == 0;
}

function bool ValidateStateIsResetQuiet(string CardID)
{
    local int Index;
    local bool bPassed;
    local CardModifierStack ModifierStack;
    local CardDeltaStack DeltaStack;
    local CardFlag FlagStack;

    bPassed = true;

    for (Index = Mutator.TurboCardGameplayManagerInfo.CardModifierList.Length - 1; Index >= 0; Index--)
    {
        ModifierStack = Mutator.TurboCardGameplayManagerInfo.CardModifierList[Index];

        if (ModifierStack == None)
        {
            continue;
        }

        if (!ModifierStack.IsDefaultValue())
        {
            log(" - INDIVIDUAL FAIL ["$CardID$"]"@string(ModifierStack)@"Was"@ModifierStack.GetModifier()@"instead of"@ModifierStack.GetDefaultModifier()$"."@ModifierStack.Describe());
            bPassed = false;
        }
    }

    for (Index = Mutator.TurboCardGameplayManagerInfo.CardDeltaList.Length - 1; Index >= 0; Index--)
    {
        DeltaStack = Mutator.TurboCardGameplayManagerInfo.CardDeltaList[Index];

        if (DeltaStack == None)
        {
            continue;
        }

        if (!DeltaStack.IsDefaultValue())
        {
            log(" - INDIVIDUAL FAIL ["$CardID$"]"@string(DeltaStack)@"Was"@DeltaStack.GetDelta()@"instead of"@DeltaStack.GetDefaultDelta()$"."@DeltaStack.Describe());
            bPassed = false;
        }
    }

    for (Index = Mutator.TurboCardGameplayManagerInfo.CardFlagList.Length - 1; Index >= 0; Index--)
    {
        FlagStack = Mutator.TurboCardGameplayManagerInfo.CardFlagList[Index];

        if (FlagStack == None)
        {
            continue;
        }

        if (!FlagStack.IsFlagSetToDefault())
        {
            log(" - INDIVIDUAL FAIL ["$CardID$"]"@string(FlagStack)@"Was"@FlagStack.IsFlagSet()@"instead of"@FlagStack.IsFlagSetDefault()$"."@FlagStack.Describe());
            bPassed = false;
        }
    }

    return bPassed;
}

function RunValidationRound()
{
    local int NumToActivate;

    if (IsOutOfCards())
    {
        Mutator.TurboCardReplicationInfo.InitializeCardDecks();
    }

    NumToActivate = 14;

    //Activate random cards.
    while (NumToActivate > 0)
    {
        Mutator.TurboCardReplicationInfo.ActivateRandomCard();
        NumToActivate--;
    }

    Mutator.TurboCardReplicationInfo.RemoveAllCards();
}

function bool IsOutOfCards()
{
    return ((Mutator.TurboCardReplicationInfo.GoodGameDeck.DeckCardObjectList.Length
        + Mutator.TurboCardReplicationInfo.SuperGameDeck.DeckCardObjectList.Length
        + Mutator.TurboCardReplicationInfo.ProConGameDeck.DeckCardObjectList.Length
        + Mutator.TurboCardReplicationInfo.EvilGameDeck.DeckCardObjectList.Length) == 0);
}

function GatherAllCards(TurboCardReplicationInfo TCRI)
{
    local int Index;

    AllCards.Length = 0;

    if (TCRI.GoodGameDeck != None)
    {
        TCRI.GoodGameDeck.OnDeckDraw(TCRI);
        for (Index = 0; Index < TCRI.GoodGameDeck.OriginalDeckCardObjectList.Length; Index++)
        {
            if (TCRI.GoodGameDeck.OriginalDeckCardObjectList[Index] != None)
            {
                AllCards[AllCards.Length] = TCRI.GoodGameDeck.OriginalDeckCardObjectList[Index];
            }
        }
    }

    if (TCRI.SuperGameDeck != None)
    {
        TCRI.SuperGameDeck.OnDeckDraw(TCRI);
        for (Index = 0; Index < TCRI.SuperGameDeck.OriginalDeckCardObjectList.Length; Index++)
        {
            if (TCRI.SuperGameDeck.OriginalDeckCardObjectList[Index] != None)
            {
                AllCards[AllCards.Length] = TCRI.SuperGameDeck.OriginalDeckCardObjectList[Index];
            }
        }
    }

    if (TCRI.ProConGameDeck != None)
    {
        TCRI.ProConGameDeck.OnDeckDraw(TCRI);
        for (Index = 0; Index < TCRI.ProConGameDeck.OriginalDeckCardObjectList.Length; Index++)
        {
            if (TCRI.ProConGameDeck.OriginalDeckCardObjectList[Index] != None)
            {
                AllCards[AllCards.Length] = TCRI.ProConGameDeck.OriginalDeckCardObjectList[Index];
            }
        }
    }

    if (TCRI.EvilGameDeck != None)
    {
        TCRI.EvilGameDeck.OnDeckDraw(TCRI);
        for (Index = 0; Index < TCRI.EvilGameDeck.OriginalDeckCardObjectList.Length; Index++)
        {
            if (TCRI.EvilGameDeck.OriginalDeckCardObjectList[Index] != None)
            {
                AllCards[AllCards.Length] = TCRI.EvilGameDeck.OriginalDeckCardObjectList[Index];
            }
        }
    }
}

function bool ValidateStateIsReset()
{
    local int Index;
    local int ValidationCount, FailedValidationCount;
    local bool bFailed;
    local CardModifierStack ModifierStack;
    local CardDeltaStack DeltaStack;
    local CardFlag FlagStack;

    bFailed = false;

    log("Attempting to validate modifier stacks...");
    ValidationCount = 0;
    FailedValidationCount = 0;
    for (Index = Mutator.TurboCardGameplayManagerInfo.CardModifierList.Length - 1; Index >= 0; Index--)
    {
        ModifierStack = Mutator.TurboCardGameplayManagerInfo.CardModifierList[Index];

        if (ModifierStack == None)
        {
            continue;
        }

        ValidationCount++;
        if (!ModifierStack.IsDefaultValue())
        {
            log(" - FAILED VALIDATION"@string(ModifierStack)@"WAS NOT DEFAULT VALUE. Was"@ModifierStack.GetModifier()@"instead of"@ModifierStack.GetDefaultModifier()$".");
            log(" - - "$ModifierStack.Describe());
            FailedValidationCount++;
        }
    }
    bFailed = bFailed || FailedValidationCount > 0;
    log("Modifier stack validation concluded. Validated modifier stacks"@ValidationCount@"and found"@FailedValidationCount@"modifiers not reset.");

    log("Attempting to validate delta stacks...");
    ValidationCount = 0;
    FailedValidationCount = 0;
    for (Index = Mutator.TurboCardGameplayManagerInfo.CardDeltaList.Length - 1; Index >= 0; Index--)
    {
        DeltaStack = Mutator.TurboCardGameplayManagerInfo.CardDeltaList[Index];

        if (DeltaStack == None)
        {
            continue;
        }

        ValidationCount++;
        if (!DeltaStack.IsDefaultValue())
        {
            log(" - FAILED VALIDATION"@string(DeltaStack)@"WAS NOT DEFAULT VALUE. Was"@DeltaStack.GetDelta()@"instead of"@DeltaStack.GetDefaultDelta()$".");
            log(" - - "$DeltaStack.Describe());
            FailedValidationCount++;
        }
    }
    bFailed = bFailed || FailedValidationCount > 0;
    log("Delta stack validation concluded. Validated delta stacks"@ValidationCount@"and found"@FailedValidationCount@"deltas not reset.");

    log("Attempting to validate flag stacks...");
    ValidationCount = 0;
    FailedValidationCount = 0;
    for (Index = Mutator.TurboCardGameplayManagerInfo.CardFlagList.Length - 1; Index >= 0; Index--)
    {
        FlagStack = Mutator.TurboCardGameplayManagerInfo.CardFlagList[Index];

        if (FlagStack == None)
        {
            continue;
        }

        ValidationCount++;
        if (!FlagStack.IsFlagSetToDefault())
        {
            log(" - FAILED VALIDATION"@string(FlagStack)@"WAS NOT DEFAULT VALUE. Was"@FlagStack.IsFlagSet()@"instead of"@FlagStack.IsFlagSetDefault()$".");
            log(" - - "$FlagStack.Describe());
            FailedValidationCount++;
        }
    }
    bFailed = bFailed || FailedValidationCount > 0;
    log("Flag stack validation concluded. Validated flag stacks"@ValidationCount@"and found"@FailedValidationCount@"flags not reset.");
    return bFailed;
}

defaultproperties
{

}
