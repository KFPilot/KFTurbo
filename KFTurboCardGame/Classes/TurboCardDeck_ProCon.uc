//Killing Floor Turbo TurboCardDeck_ProCon
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardDeck_ProCon extends TurboCardDeck;

//We need a better way to handle conditional cards. This is annoying.
var bool bCanUseTradeIn, bHasUsedTradeIn;
var TurboCard TradeInCard;

var bool bCanUseSoulForASoul, bHasUsedSoulForASoul;
var TurboCard SoulForASoulCard;

function InitializeDeck()
{
    local int Index;

    Super.InitializeDeck();

    Index = DeckCardObjectList.Length;

    InitializeCard(TradeInCard, Index);
    Index++;

    InitializeCard(SoulForASoulCard, Index);
    Index++;
}

static function TurboCard GetCardFromReference(TurboCardReplicationInfo.CardReference Reference)
{
    if (Reference.Deck != default.Class)
    {
        return None;
    }

    if (Reference.CardIndex == default.DeckCardObjectList.Length)
    {
        return default.TradeInCard;
    }
    else if (Reference.CardIndex == default.DeckCardObjectList.Length + 1)
    {
        return default.SoulForASoulCard;
    }

    return Super.GetCardFromReference(Reference);
}

function TurboCard DrawRandomCard()
{
    local int EffectiveDeckSize;
    EffectiveDeckSize = DeckCardObjectList.Length;
    
    if (!bHasUsedTradeIn && bCanUseTradeIn)
    {
        EffectiveDeckSize++;
    }

    if (!bCanUseSoulForASoul && bHasUsedSoulForASoul)
    {
        EffectiveDeckSize++;
    }

    if (!bHasUsedTradeIn && bCanUseTradeIn && FRand() < (1.f / float(EffectiveDeckSize)))
    {
        bHasUsedTradeIn = true;
        return TradeInCard;
    }     

    if (!bCanUseSoulForASoul && bHasUsedSoulForASoul && FRand() < (1.f / float(EffectiveDeckSize)))
    {
        bHasUsedSoulForASoul = true;
        return SoulForASoulCard;
    }

    return Super.DrawRandomCard();
}

function OnDeckDraw(TurboCardReplicationInfo TCRI)
{
    local int GoodCardCount, SuperCardCount, ProConCardCount, EvilCardCount;
    TCRI.GetActiveCardCounts(GoodCardCount, SuperCardCount, ProConCardCount, EvilCardCount);
    bCanUseTradeIn = GoodCardCount >= 3;
    bCanUseSoulForASoul = SuperCardCount > 0 && EvilCardCount > 0;
}

function ActivateTradeIn(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        bHasUsedTradeIn = true;
        GameplayManager.DeactivateAllGoodCards();
        GameplayManager.GrantRandomSuperCard();
    }
}

function ActivateExtraMoneyTraderTime(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.TraderTimeModifier.AddModifier(0.85f, Card);
        GameplayManager.ShortTermRewardFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.TraderTimeModifier.RemoveModifier(Card);
        GameplayManager.ShortTermRewardFlag.ClearFlag();
    }
}

function ActivateFasterReloadSmallerMag(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerReloadRateModifier.AddModifier(1.15f, Card);
        GameplayManager.PlayerMagazineAmmoModifier.AddModifier(0.8f, Card);
    }
    else
    {
        GameplayManager.PlayerReloadRateModifier.RemoveModifier(Card);
        GameplayManager.PlayerMagazineAmmoModifier.RemoveModifier(Card);
    }
}

function ActivateHandSizeWaveSize(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.CardSelectionCountDelta.AddDelta(1, Card);
        GameplayManager.TotalMonstersModifier.AddModifier(1.25f, Card);
    }
    else
    {
        GameplayManager.CardSelectionCountDelta.RemoveDelta(Card);
        GameplayManager.TotalMonstersModifier.RemoveModifier(Card);
    }
}

function ActivateScrakeDamUpFleshpoundDamDown(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerFleshpoundDamageModifier.AddModifier(0.85f, Card);
        GameplayManager.PlayerScrakeDamageModifier.AddModifier(1.1f, Card);
    }
    else
    {
        GameplayManager.PlayerFleshpoundDamageModifier.RemoveModifier(Card);
        GameplayManager.PlayerScrakeDamageModifier.RemoveModifier(Card);
    }
}

function ActivateBriskPace(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.WaveSpeedModifier.AddModifier(3.f, Card);
        GameplayManager.TotalMonstersModifier.AddModifier(0.9f, Card);
    }
    else
    {
        GameplayManager.WaveSpeedModifier.RemoveModifier(Card);
        GameplayManager.TotalMonstersModifier.RemoveModifier(Card);
    }
}

function ActivateSpecialization(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerOnPerkDamageModifier.AddModifier(1.05f, Card);
        GameplayManager.PlayerOffPerkDamageModifier.AddModifier(1.05f, Card);
    }
    else
    {
        GameplayManager.PlayerOnPerkDamageModifier.RemoveModifier(Card);
        GameplayManager.PlayerOffPerkDamageModifier.RemoveModifier(Card);
    }
}

function ActivatePrecisionExplosives(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerExplosiveDamageModifier.AddModifier(1.05f, Card);
        GameplayManager.PlayerExplosiveRadiusModifier.AddModifier(0.75f, Card);
    }
    else
    {
        GameplayManager.PlayerExplosiveDamageModifier.RemoveModifier(Card);
        GameplayManager.PlayerExplosiveRadiusModifier.RemoveModifier(Card);
    }
}

function ActivateVeryDeepAmmoPockets(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMaxAmmoModifier.AddModifier(1.1f, Card);
        GameplayManager.PlayerReloadRateModifier.AddModifier(0.85f, Card);
    }
    else
    {
        GameplayManager.PlayerMaxAmmoModifier.RemoveModifier(Card);
        GameplayManager.PlayerReloadRateModifier.RemoveModifier(Card);
    }
}

function ActivateEscalation(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerDamageModifier.AddModifier(1.05f, Card);
        GameplayManager.MonsterDamageModifier.AddModifier(1.1f, Card);
    }
    else
    {
        GameplayManager.PlayerDamageModifier.RemoveModifier(Card);
        GameplayManager.MonsterDamageModifier.RemoveModifier(Card);
    }
}

function ActivateSurplus(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.CashBonusModifier.AddModifier(1.15f, Card);
        GameplayManager.TotalMonstersModifier.AddModifier(1.1f, Card);
    }
    else
    {
        GameplayManager.CashBonusModifier.RemoveModifier(Card);
        GameplayManager.TotalMonstersModifier.RemoveModifier(Card);
    }
}

function ActivateDoubleEdgeSword(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerDamageModifier.AddModifier(1.05f, Card);
        GameplayManager.FriendlyFireModifier.AddModifier(1.05f, Card);
    }
    else
    {
        GameplayManager.PlayerDamageModifier.RemoveModifier(Card);
        GameplayManager.FriendlyFireModifier.RemoveModifier(Card);
    }
}

function ActivateHeavyAmmunition(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerRangedDamageModifier.AddModifier(1.05f, Card);
        GameplayManager.PlayerMaxAmmoModifier.AddModifier(0.9f, Card);
    }
    else
    {
        GameplayManager.PlayerRangedDamageModifier.RemoveModifier(Card);
        GameplayManager.PlayerMaxAmmoModifier.RemoveModifier(Card);
    }
}

function ActivateMagazineOverclock(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerFireRateModifier.AddModifier(1.15f, Card);
        GameplayManager.PlayerReloadRateModifier.AddModifier(0.9f, Card);
    }
    else
    {
        GameplayManager.PlayerFireRateModifier.RemoveModifier(Card);
        GameplayManager.PlayerReloadRateModifier.RemoveModifier(Card);
    }
}

function ActivatePrecisionFire(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerFireRateModifier.AddModifier(0.9f, Card);
        GameplayManager.PlayerSpreadRecoilModifier.AddModifier(0.7f, Card);
    }
    else
    {
        GameplayManager.PlayerFireRateModifier.RemoveModifier(Card);
        GameplayManager.PlayerSpreadRecoilModifier.RemoveModifier(Card);
    }
}

function ActivateThinSkinned(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMovementSpeedModifier.AddModifier(1.1f, Card);
        GameplayManager.PlayerDamageTakenModifier.AddModifier(1.1f, Card);
    }
    else
    {
        GameplayManager.PlayerMovementSpeedModifier.RemoveModifier(Card);
        GameplayManager.PlayerDamageTakenModifier.RemoveModifier(Card);
    }
}

function ActivatePremiumWeapons(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerFireRateModifier.AddModifier(1.05f, Card);
        GameplayManager.PlayerReloadRateModifier.AddModifier(1.05f, Card);
        GameplayManager.PlayerSpreadRecoilModifier.AddModifier(0.95f, Card);
        GameplayManager.TraderPriceModifier.AddModifier(1.15f, Card);
    }
    else
    {
        GameplayManager.PlayerFireRateModifier.RemoveModifier(Card);
        GameplayManager.PlayerReloadRateModifier.RemoveModifier(Card);
        GameplayManager.PlayerSpreadRecoilModifier.RemoveModifier(Card);
        GameplayManager.TraderPriceModifier.RemoveModifier(Card);
    }
}

function ActivateTurtleShell(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMovementSpeedModifier.AddModifier(0.95f, Card);
        GameplayManager.PlayerDamageTakenModifier.AddModifier(0.9f, Card);
    }
    else
    {
        GameplayManager.PlayerMovementSpeedModifier.RemoveModifier(Card);
        GameplayManager.PlayerDamageTakenModifier.RemoveModifier(Card);
    }
}

function ActivatePaidInBlood(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMaxHealthModifier.AddModifier(0.9f, Card);
        GameplayManager.TraderPriceModifier.AddModifier(0.5f, Card);
    }
    else
    {
        GameplayManager.PlayerMaxHealthModifier.RemoveModifier(Card);
        GameplayManager.TraderPriceModifier.RemoveModifier(Card);
    }
}

function ActivateDealWithDevil(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.GrantRandomSuperCard();
        GameplayManager.GrantRandomEvilCard();
    }
}

function ActivateDistractedDriving(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.MonsterStalkerDistractionModifier.AddModifier(1.75f, Card);
        GameplayManager.MonsterStalkerMeleeDamageModifier.AddModifier(2.f, Card);
    }
    else
    {
        GameplayManager.MonsterStalkerDistractionModifier.RemoveModifier(Card);
        GameplayManager.MonsterStalkerMeleeDamageModifier.RemoveModifier(Card);
    }
}

function ActivateHighSpeedLowDrag(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerCarryCapacityDelta.AddDelta(-1, Card);
        GameplayManager.PlayerMovementSpeedModifier.AddModifier(1.15f, Card);
    }
    else
    {
        GameplayManager.PlayerCarryCapacityDelta.RemoveDelta(Card);
        GameplayManager.PlayerMovementSpeedModifier.RemoveModifier(Card);
    }
}

function ActivateUnlicensedPractitioner(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMedicHealPotencyModifier.AddModifier(1.1f, Card);
        GameplayManager.PlayerNonMedicHealPotencyModifier.AddModifier(0.75f, Card);
    }
    else
    {
        GameplayManager.PlayerMedicHealPotencyModifier.RemoveModifier(Card);
        GameplayManager.PlayerNonMedicHealPotencyModifier.RemoveModifier(Card);
    }
}

function ActivateRussianRoulette(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.RussianRouletteFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.RussianRouletteFlag.ClearFlag();
    }
}

function ActivateConcentratedHeal(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMedicHealPotencyModifier.AddModifier(1.15f, Card);
        GameplayManager.PlayerNonMedicHealPotencyModifier.AddModifier(1.15f, Card);
        GameplayManager.PlayerHealRechargeModifier.AddModifier(0.85f, Card);
    }
    else
    {
        GameplayManager.PlayerMedicHealPotencyModifier.RemoveModifier(Card);
        GameplayManager.PlayerNonMedicHealPotencyModifier.RemoveModifier(Card);
        GameplayManager.PlayerHealRechargeModifier.RemoveModifier(Card);
    }
}

function ActivateDroppingBallast(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerGrenadeMaxAmmoModifier.AddModifier(0.8f, Card);
        GameplayManager.PlayerMaxAmmoModifier.AddModifier(1.1f, Card);
    }
    else
    {
        GameplayManager.PlayerGrenadeMaxAmmoModifier.RemoveModifier(Card);
        GameplayManager.PlayerMaxAmmoModifier.RemoveModifier(Card);
    }
}

function ActivateShotgunsMoreKick(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerShotgunPelletModifier.AddModifier(1.2f, Card);
        GameplayManager.PlayerShotgunSpreadRecoilModifier.AddModifier(1.25f, Card);
        GameplayManager.PlayerShotgunKickbackModifier.AddModifier(1.25f, Card);
    }
    else
    {
        GameplayManager.PlayerShotgunPelletModifier.RemoveModifier(Card);
        GameplayManager.PlayerShotgunSpreadRecoilModifier.RemoveModifier(Card);
        GameplayManager.PlayerShotgunKickbackModifier.RemoveModifier(Card);
    }
}

function ActivateMoreToPlay(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMaxAmmoModifier.AddModifier(1.15f, Card);
        GameplayManager.PlayerDamageModifier.AddModifier(1.05f, Card);
        GameplayManager.TotalMonstersModifier.AddModifier(1.2f, Card);
    }
    else
    {
        GameplayManager.PlayerMaxAmmoModifier.RemoveModifier(Card);
        GameplayManager.PlayerDamageModifier.RemoveModifier(Card);
        GameplayManager.TotalMonstersModifier.RemoveModifier(Card);
    }
}

function ActivateCollateralDamage(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerExplosiveDamageModifier.AddModifier(1.1f, Card);
        GameplayManager.FriendlyFireModifier.AddModifier(1.05f, Card);
    }
    else
    {
        GameplayManager.PlayerExplosiveDamageModifier.RemoveModifier(Card);
        GameplayManager.FriendlyFireModifier.RemoveModifier(Card);
    }
}

function ActivateHealingAndHurting(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerNonMedicHealPotencyModifier.AddModifier(1.2f, Card);
        GameplayManager.PlayerMedicHealPotencyModifier.AddModifier(1.2f, Card);
        GameplayManager.FriendlyFireModifier.AddModifier(1.05f, Card);
    }
    else
    {
        GameplayManager.PlayerNonMedicHealPotencyModifier.RemoveModifier(Card);
        GameplayManager.PlayerMedicHealPotencyModifier.RemoveModifier(Card);
        GameplayManager.FriendlyFireModifier.RemoveModifier(Card);
    }
}

function ActivateReRoll(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.ResetDecksAndReRollCards(Card);
    }
}

function ActivateDrawOne(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.GrantRandomCard();
    }
}

function ActivateOversizedPipebombs(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateFlag(GameplayManager.OversizedPipebombFlag, bActivate);
}

function ActivateShortHop(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateModifier(GameplayManager.PlayerMovementSpeedModifier, 1.1f, bActivate);
    Card.UpdateModifier(GameplayManager.PlayerJumpModifier, 0.5f, bActivate);
}

function ActivateChargeExchange(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateModifier(GameplayManager.PlayerHealRechargeModifier, 1.25f, bActivate);
    Card.UpdateModifier(GameplayManager.WeldStrengthModifier, 0.5f, bActivate);
}

function ActivateRiskyRegen(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateDelta(GameplayManager.PlayerHealthRegenDelta, 3, bActivate);
    Card.UpdateModifier(GameplayManager.PlayerMaxHealthModifier, 0.9f, bActivate);
}

function ActivateSoulForASoul(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    GameplayManager.RemoveRandomSuperCard();
    GameplayManager.RemoveRandomEvilCard();
}

function ActivateDilutedHeal(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateModifier(GameplayManager.PlayerNonMedicHealPotencyModifier, 0.85f, bActivate);
    Card.UpdateModifier(GameplayManager.PlayerMedicHealPotencyModifier, 0.85f, bActivate);
    Card.UpdateModifier(GameplayManager.PlayerHealRechargeModifier, 1.15f, bActivate);
}

defaultproperties
{
    Begin Object Name=TradeIn Class=TurboCard_ProConStrange
        CardName(0)="Trade In"
        CardDescriptionList(0)="Removes all good"
        CardDescriptionList(1)="cards in exchange"
        CardDescriptionList(2)="for a random"
        CardDescriptionList(3)="super card."
        OnActivateCard=ActivateTradeIn
        CardID="PROCON_TRADEIN"
    End Object
    TradeInCard=TurboCard'TradeIn'
    
    Begin Object Name=SoulForASoul Class=TurboCard_ProConStrange
        CardName(0)="A Soul For"
        CardName(1)="A Soul"
        CardDescriptionList(0)="Removes a random"
        CardDescriptionList(1)="super card and"
        CardDescriptionList(2)="removes a random"
        CardDescriptionList(3)="evil card."
        OnActivateCard=ActivateSoulForASoul
        CardID="PROCON_SOULFORSOUL"
    End Object
    SoulForASoulCard=TurboCard'SoulForASoul'

    Begin Object Name=ExtraMoneyTraderTime Class=TurboCard_ProCon
        CardName(0)="Short Term"
        CardName(1)="Reward"
        CardDescriptionList(0)="All players receive"
        CardDescriptionList(1)="500 extra dosh"
        CardDescriptionList(2)="each wave but"
        CardDescriptionList(3)="trader time is"
        CardDescriptionList(4)="reduced by 15%."
        OnActivateCard=ActivateExtraMoneyTraderTime
        CardID="PROCON_SHORTTERMREW"
    End Object
    DeckCardObjectList(0)=TurboCard'ExtraMoneyTraderTime'

    Begin Object Name=FasterReloadSmallerMag Class=TurboCard_ProCon
        CardName(0)="Sawed Off"
        CardName(1)="Magazines"
        CardDescriptionList(0)="Increases reload"
        CardDescriptionList(1)="speed of all"
        CardDescriptionList(2)="weapons by 15% and"
        CardDescriptionList(3)="reduces magazine"
        CardDescriptionList(4)="size by 20%."
        OnActivateCard=ActivateFasterReloadSmallerMag
        CardID="PROCON_SAWEDOFFMAG"
    End Object
    DeckCardObjectList(1)=TurboCard'FasterReloadSmallerMag'

    Begin Object Name=HandSizeWaveSize Class=TurboCard_ProCon
        CardName(0)="Mo' Cards"
        CardName(1)="Mo' Problems"
        CardDescriptionList(0)="Increases card"
        CardDescriptionList(1)="selection by 1"
        CardDescriptionList(2)="but increases wave"
        CardDescriptionList(3)="size by 25%."
        OnActivateCard=ActivateHandSizeWaveSize
        CardID="PROCON_MOCARDSMOPROB"
    End Object
    DeckCardObjectList(2)=TurboCard'HandSizeWaveSize'

    Begin Object Name=ScrakeDamUpFleshpoundDamDown Class=TurboCard_ProCon
        CardName(0)="Fleshpound++"
        CardName(1)="Scrake--"
        CardDescriptionList(0)="Fleshpounds take"
        CardDescriptionList(1)="15% less damage"
        CardDescriptionList(2)="but Scrakes take"
        CardDescriptionList(3)="10% more damage."
        OnActivateCard=ActivateScrakeDamUpFleshpoundDamDown
        CardID="PROCON_FPPLUSSCMINUS"
    End Object
    DeckCardObjectList(3)=TurboCard'ScrakeDamUpFleshpoundDamDown'

    Begin Object Name=BriskPace Class=TurboCard_ProCon
        CardName(0)="Brisk Pace"
        CardDescriptionList(0)="Reduces wave size"
        CardDescriptionList(1)="by 10% but"
        CardDescriptionList(2)="increases wave"
        CardDescriptionList(3)="speed by 200%."
        OnActivateCard=ActivateBriskPace
        CardID="PROCON_BRISKPACE"
    End Object
    DeckCardObjectList(4)=TurboCard'BriskPace'

    Begin Object Name=Specialization Class=TurboCard_ProCon
        CardName(0)="Specialization"
        CardDescriptionList(0)="Increases on-perk"
        CardDescriptionList(1)="weapon damage by"
        CardDescriptionList(2)="5% but reduces"
        CardDescriptionList(3)="off-perk damage"
        CardDescriptionList(4)="by 15%."
        OnActivateCard=ActivateSpecialization
        CardID="PROCON_SPECIALIZATION"
    End Object
    DeckCardObjectList(5)=TurboCard'Specialization'

    Begin Object Name=PrecisionExplosives Class=TurboCard_ProCon
        CardName(0)="Precision"
        CardName(1)="Explosives"
        CardDescriptionList(0)="Increases explosive"
        CardDescriptionList(1)="damage by 10% but"
        CardDescriptionList(2)="reduces explosive"
        CardDescriptionList(3)="range by 25%."
        OnActivateCard=ActivatePrecisionExplosives
        CardID="PROCON_PRECEXPLOSIVES"
    End Object
    DeckCardObjectList(6)=TurboCard'PrecisionExplosives'

    Begin Object Name=VeryDeepAmmoPockets Class=TurboCard_ProCon
        CardName(0)="Awkwardly Deep"
        CardName(1)="Ammo Pockets"
        CardDescriptionList(0)="Increases max"
        CardDescriptionList(1)="ammo by 10% but"
        CardDescriptionList(2)="reduces reload"
        CardDescriptionList(3)="speed by 15%."
        OnActivateCard=ActivateVeryDeepAmmoPockets
        CardID="PROCON_AWKWARDDEEPAMMO"
    End Object
    DeckCardObjectList(7)=TurboCard'VeryDeepAmmoPockets'

    Begin Object Name=Escalation Class=TurboCard_ProCon
        CardName(0)="Conflict"
        CardName(1)="Escalation"
        CardDescriptionList(0)="Increases damage"
        CardDescriptionList(1)="by players by 5%"
        CardDescriptionList(2)="and damage by"
        CardDescriptionList(3)="zeds by 10%."
        OnActivateCard=ActivateEscalation
        CardID="PROCON_CONFEXCALATION"
    End Object
    DeckCardObjectList(8)=TurboCard'Escalation'

    Begin Object Name=Surplus Class=TurboCard_ProCon
        CardName(0)="Compound"
        CardName(1)="Surplus"
        CardDescriptionList(0)="Increases dosh"
        CardDescriptionList(1)="received from"
        CardDescriptionList(2)="kills by 15% and"
        CardDescriptionList(3)="wave size by 10%."
        OnActivateCard=ActivateSurplus
        CardID="PROCON_COMPSURPLUS"
    End Object
    DeckCardObjectList(9)=TurboCard'Surplus'

    Begin Object Name=DoubleEdgeSword Class=TurboCard_ProCon
        CardName(0)="Double Edged"
        CardName(1)="Sword"
        CardDescriptionList(0)="Increases player"
        CardDescriptionList(1)="damage by 5%"
        CardDescriptionList(2)="and friendly"
        CardDescriptionList(3)="fire damage by 5%."
        OnActivateCard=ActivateDoubleEdgeSword
        CardID="PROCON_DOUBLEEDGESWORD"
    End Object
    DeckCardObjectList(10)=TurboCard'DoubleEdgeSword'

    Begin Object Name=HeavyAmmunition Class=TurboCard_ProCon
        CardName(0)="Heavy"
        CardName(1)="Ammunition"
        CardDescriptionList(0)="Increases player"
        CardDescriptionList(1)="ranged damage by"
        CardDescriptionList(2)="5% but reduces"
        CardDescriptionList(3)="max ammo by 10%."
        OnActivateCard=ActivateHeavyAmmunition
        CardID="PROCON_HEAVYAMMO"
    End Object
    DeckCardObjectList(11)=TurboCard'HeavyAmmunition'

    Begin Object Name=MagazineOverclock Class=TurboCard_ProCon
        CardName(0)="Magazine"
        CardName(1)="Overclock"
        CardDescriptionList(0)="Increases firerate"
        CardDescriptionList(1)="by 15% but reduces"
        CardDescriptionList(2)="reload speed by 10%."
        OnActivateCard=ActivateMagazineOverclock
        CardID="PROCON_MAGOVERCLOCK"
    End Object
    DeckCardObjectList(12)=TurboCard'MagazineOverclock'

    Begin Object Name=PrecisionFire Class=TurboCard_ProCon
        CardName(0)="Precision"
        CardName(1)="Shooting"
        CardDescriptionList(0)="Reduces spread"
        CardDescriptionList(1)="by 30% but reduces"
        CardDescriptionList(2)="firerate by 10%."
        OnActivateCard=ActivatePrecisionFire
        CardID="PROCON_PRECSHOOTING"
    End Object
    DeckCardObjectList(13)=TurboCard'PrecisionFire'

    Begin Object Name=ThinSkinned Class=TurboCard_ProCon
        CardName(0)="Thin Skinned"
        CardDescriptionList(0)="Increases player"
        CardDescriptionList(1)="speed 10% but"
        CardDescriptionList(2)="increases damage"
        CardDescriptionList(3)="taken from"
        CardDescriptionList(4)="zeds by 10%."
        OnActivateCard=ActivateThinSkinned
        CardID="PROCON_THINSKINNED"
    End Object
    DeckCardObjectList(14)=TurboCard'ThinSkinned'

    Begin Object Name=PremiumWeapons Class=TurboCard_ProCon
        CardName(0)="Premium"
        CardName(1)="Weapons"
        CardDescriptionList(0)="Increases weapon"
        CardDescriptionList(1)="firerate, reload"
        CardDescriptionList(2)="and accuracy"
        CardDescriptionList(3)="by 5% but"
        CardDescriptionList(4)="increases trader"
        CardDescriptionList(5)="prices by 15%."
        OnActivateCard=ActivatePremiumWeapons
        CardID="PROCON_PREMIUMWEAPONS"
    End Object
    DeckCardObjectList(15)=TurboCard'PremiumWeapons'

    Begin Object Name=TurtleShell Class=TurboCard_ProCon
        CardName(0)="Turtle Shell"
        CardDescriptionList(0)="Reduces damage"
        CardDescriptionList(1)="to players by"
        CardDescriptionList(2)="10% and player"
        CardDescriptionList(3)="move speed by 5%."
        OnActivateCard=ActivateTurtleShell
        CardID="PROCON_TURTLESHELL"
    End Object
    DeckCardObjectList(16)=TurboCard'TurtleShell'

    Begin Object Name=PaidInBlood Class=TurboCard_ProCon
        CardName(0)="Price Paid"
        CardName(1)="In Blood"
        CardDescriptionList(0)="Reduces player"
        CardDescriptionList(1)="health by 10%"
        CardDescriptionList(2)="and trader"
        CardDescriptionList(3)="prices by 50%."
        OnActivateCard=ActivatePaidInBlood
        CardID="PROCON_PAIDINBLOOD"
    End Object
    DeckCardObjectList(17)=TurboCard'PaidInBlood'
    
    Begin Object Name=DealWithDevil Class=TurboCard_ProConStrange
        CardName(0)="A Deal With"
        CardName(1)="The Devil"
        CardDescriptionList(0)="In exchange for"
        CardDescriptionList(1)="receiving a"
        CardDescriptionList(2)="random Super"
        CardDescriptionList(3)="card, receive"
        CardDescriptionList(4)="a random Evil"
        CardDescriptionList(5)="card as well."
        OnActivateCard=ActivateDealWithDevil
        CardID="PROCON_DEATHWITHDEVIL"
    End Object
    DeckCardObjectList(18)=TurboCard'DealWithDevil'
    
    Begin Object Name=DistractedDriving Class=TurboCard_ProCon
        CardName(0)="Distracted"
        CardName(1)="Driving"
        CardDescriptionList(0)="Stalkers are"
        CardDescriptionList(1)="more distracting"
        CardDescriptionList(2)="and deal 100%"
        CardDescriptionList(3)="more damage."
        OnActivateCard=ActivateDistractedDriving
        CardID="PROCON_DISTDRIVING"
    End Object
    DeckCardObjectList(19)=TurboCard'DistractedDriving'
    
    Begin Object Name=HighSpeedLowDrag Class=TurboCard_ProCon
        CardName(0)="High Speed"
        CardName(1)="Low Drag"
        CardDescriptionList(0)="Decreases max"
        CardDescriptionList(1)="carry capacity"
        CardDescriptionList(2)="by 1. Increases"
        CardDescriptionList(3)="player movement"
        CardDescriptionList(4)="speed by 15%."
        OnActivateCard=ActivateHighSpeedLowDrag
        CardID="PROCON_HIGHSPEEDLOWDRAG"
    End Object
    DeckCardObjectList(20)=TurboCard'HighSpeedLowDrag'
    
    Begin Object Name=UnlicensedPractitioner Class=TurboCard_ProCon
        CardName(0)="Unlicensed"
        CardName(1)="Practitioner"
        CardDescriptionList(0)="Increases heal"
        CardDescriptionList(1)="potency for"
        CardDescriptionList(2)="Field Medics by"
        CardDescriptionList(3)="10% but reduces"
        CardDescriptionList(4)="heal potency"
        CardDescriptionList(5)="for non Field"
        CardDescriptionList(6)="Medics by 25%."
        OnActivateCard=ActivateUnlicensedPractitioner
        CardID="PROCON_UNLICPRACTITIONER"
    End Object
    DeckCardObjectList(21)=TurboCard'UnlicensedPractitioner'
    
    Begin Object Name=RussianRoulette Class=TurboCard_ProCon
        CardName(0)="Russian"
        CardName(1)="Roulette"
        CardDescriptionList(0)="Zeds and players"
        CardDescriptionList(1)="have a 0.1%"
        CardDescriptionList(2)="chance to die"
        CardDescriptionList(3)="instantly when"
        CardDescriptionList(4)="taking damage."
        OnActivateCard=ActivateRussianRoulette
        CardID="PROCON_RUSSIANROULLETTE"
    End Object
    DeckCardObjectList(22)=TurboCard'RussianRoulette'
    
    Begin Object Name=ConcentratedHeal Class=TurboCard_ProCon
        CardName(0)="Concentrated"
        CardName(1)="Healing"
        CardDescriptionList(0)="Increases heal"
        CardDescriptionList(1)="potency by 15%"
        CardDescriptionList(2)="but reduces"
        CardDescriptionList(3)="heal charge"
        CardDescriptionList(4)="rate by 15%."
        OnActivateCard=ActivateConcentratedHeal
        CardID="PROCON_CONCENTRATEHEALING"
    End Object
    DeckCardObjectList(23)=TurboCard'ConcentratedHeal'
    
    Begin Object Name=DroppingBallast Class=TurboCard_ProCon
        CardName(0)="Dropping"
        CardName(1)="Ballast"
        CardDescriptionList(0)="Increases max"
        CardDescriptionList(1)="ammo by 10% but"
        CardDescriptionList(2)="reduces grenade"
        CardDescriptionList(3)="max ammo by 20%."
        OnActivateCard=ActivateDroppingBallast
        CardID="PROCON_DROPBALLAST"
    End Object
    DeckCardObjectList(24)=TurboCard'DroppingBallast'
    
    Begin Object Name=ShotgunsMoreKick Class=TurboCard_ProCon
        CardName(0)="With A Bit"
        CardName(1)="More Kick"
        CardDescriptionList(0)="Increases shotgun"
        CardDescriptionList(1)="pellet count by"
        CardDescriptionList(2)="20% but increases"
        CardDescriptionList(3)="shotgun recoil and"
        CardDescriptionList(4)="kickback by 25%."
        OnActivateCard=ActivateShotgunsMoreKick
        CardID="PROCON_MOREKICK"
    End Object
    DeckCardObjectList(25)=TurboCard'ShotgunsMoreKick'
    
    Begin Object Name=MoreToPlay Class=TurboCard_ProCon
        CardName(0)="More Game"
        CardName(1)="To Play"
        CardDescriptionList(0)="Increases max"
        CardDescriptionList(1)="weapon ammo by"
        CardDescriptionList(2)="15% and damage by"
        CardDescriptionList(3)="5% but wave size is"
        CardDescriptionList(4)="increased by 20%."
        OnActivateCard=ActivateMoreToPlay
        CardID="PROCON_MOREGAMETOPLAY"
    End Object
    DeckCardObjectList(26)=TurboCard'MoreToPlay'
    
    Begin Object Name=CollateralDamage Class=TurboCard_ProCon
        CardName(0)="Collateral"
        CardName(1)="Damage"
        CardDescriptionList(0)="Increases explosive"
        CardDescriptionList(1)="damage by 10% but"
        CardDescriptionList(2)="increases friendly"
        CardDescriptionList(3)="fire damage by 5%."
        OnActivateCard=ActivateCollateralDamage
        CardID="PROCON_COLLATDAMAGE"
    End Object
    DeckCardObjectList(27)=TurboCard'CollateralDamage'
    
    Begin Object Name=MoreHealingAndHurting Class=TurboCard_ProCon
        CardName(0)="More Healing"
        CardName(1)="More Hurting"
        CardDescriptionList(0)="Increases heal"
        CardDescriptionList(1)="potency by 20% but"
        CardDescriptionList(2)="increases friendly"
        CardDescriptionList(3)="fire damage by 5%."
        OnActivateCard=ActivateHealingAndHurting
        CardID="PROCON_HEALINGANDHURTING"
    End Object
    DeckCardObjectList(28)=TurboCard'MoreHealingAndHurting'
    
    Begin Object Name=ReRoll Class=TurboCard_ProConStrange
        CardName(0)="Re-Roll"
        CardDescriptionList(0)="All cards are"
        CardDescriptionList(1)="rerolled and"
        CardDescriptionList(2)="all card decks"
        CardDescriptionList(3)="are reset."
        OnActivateCard=ActivateReRoll
        CardID="PROCON_REROLL"
    End Object
    DeckCardObjectList(29)=TurboCard'ReRoll'
    
    Begin Object Name=DrawOne Class=TurboCard_ProConStrange
        CardName(0)="Draw One"
        CardDescriptionList(0)="Receive a random"
        CardDescriptionList(1)="card from any"
        CardDescriptionList(2)="deck."
        OnActivateCard=ActivateDrawOne
        CardID="PROCON_DRAWONE"
    End Object
    DeckCardObjectList(30)=TurboCard'DrawOne'
    
    Begin Object Name=OversizedPipebombs Class=TurboCard_ProCon
        CardName(0)="Oversized"
        CardName(1)="Pipebombs"
        CardDescriptionList(0)="Increases Pipebomb"
        CardDescriptionList(1)="damage by 50% and"
        CardDescriptionList(2)="radius by 25% but"
        CardDescriptionList(3)="reduces Pipebomb"
        CardDescriptionList(4)="max ammo by 50%."
        OnActivateCard=ActivateOversizedPipebombs
        CardID="PROCON_OVERSIZEPIPE"
    End Object
    DeckCardObjectList(31)=TurboCard'OversizedPipebombs'
    
    Begin Object Name=ShortHop Class=TurboCard_ProCon
        CardName(0)="Short Hop"
        CardDescriptionList(0)="Increases player"
        CardDescriptionList(1)="speed by 10% but"
        CardDescriptionList(2)="reduces jump"
        CardDescriptionList(3)="height by 75%."
        OnActivateCard=ActivateShortHop
        CardID="PROCON_OVERSIZEPIPE"
    End Object
    DeckCardObjectList(32)=TurboCard'ShortHop'
    
    Begin Object Name=ChargeExchange Class=TurboCard_ProCon
        CardName(0)="Charge"
        CardName(1)="Exchange"
        CardDescriptionList(0)="Increases heal"
        CardDescriptionList(1)="recharge speed by"
        CardDescriptionList(2)="25% but reduces"
        CardDescriptionList(3)="weld speed by 50%."
        OnActivateCard=ActivateChargeExchange
        CardID="PROCON_CHARGEEXCHANGE"
    End Object
    DeckCardObjectList(33)=TurboCard'ChargeExchange'
    
    Begin Object Name=RiskyRegen Class=TurboCard_ProCon
        CardName(0)="Risky Regen"
        CardDescriptionList(0)="Increases regen"
        CardDescriptionList(1)="by 3 every 5"
        CardDescriptionList(2)="seconds but"
        CardDescriptionList(3)="reduces max"
        CardDescriptionList(4)="health by 10%."
        OnActivateCard=ActivateRiskyRegen
        CardID="PROCON_RISKYREGEN"
    End Object
    DeckCardObjectList(34)=TurboCard'RiskyRegen'
    
    Begin Object Name=DilutedHeal Class=TurboCard_ProCon
        CardName(0)="Diluted"
        CardName(1)="Healing"
        CardDescriptionList(0)="Reduces heal"
        CardDescriptionList(1)="potency by 15%"
        CardDescriptionList(2)="but increases"
        CardDescriptionList(3)="heal charge"
        CardDescriptionList(4)="rate by 15%."
        OnActivateCard=ActivateDilutedHeal
        CardID="PROCON_DILUTEDHEALING"
    End Object
    DeckCardObjectList(35)=TurboCard'DilutedHeal'
}
