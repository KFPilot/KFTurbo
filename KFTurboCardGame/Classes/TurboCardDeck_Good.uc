//Killing Floor Turbo TurboCardDeck_Good
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardDeck_Good extends TurboCardDeck;

function ActivateBonusCashKill(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.CashBonusModifier.AddModifier(1.1f, Card);
    }
    else
    {
        GameplayManager.CashBonusModifier.RemoveModifier(Card);
    }
}

function ActivateFirerateIncrease(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerFireRateModifier.AddModifier(1.05f, Card);
    }
    else
    {
        GameplayManager.PlayerFireRateModifier.RemoveModifier(Card);
    }
}

function ActivateExplosiveDamage(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerExplosiveDamageModifier.AddModifier(1.05f, Card);
    }
    else
    {
        GameplayManager.PlayerExplosiveDamageModifier.RemoveModifier(Card);
    }
}

function ActivateExplosiveRange(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerExplosiveRadiusModifier.AddModifier(1.1f, Card);
    }
    else
    {
        GameplayManager.PlayerExplosiveRadiusModifier.RemoveModifier(Card);
    }
}

function ActivateFreeArmor(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.FreeArmorFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.FreeArmorFlag.ClearFlag();
    }
}

function ActivateIncreaseSelectableCards(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.CardSelectionCountDelta.AddDelta(1, Card);
    }
    else
    {
        GameplayManager.CardSelectionCountDelta.RemoveDelta(Card);
    }
}

function ActivateMaxAmmo(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMaxAmmoModifier.AddModifier(1.1f, Card);
    }
    else
    {
        GameplayManager.PlayerMaxAmmoModifier.RemoveModifier(Card);
    }
}

function ActivateReloadSpeed(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerReloadRateModifier.AddModifier(1.05f, Card);
    }
    else
    {
        GameplayManager.PlayerReloadRateModifier.RemoveModifier(Card);
    }
}

function ActivateSlomoDamageBonus(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerSlomoDamageModifier.AddModifier(1.1f, Card);
    }
    else
    {
        GameplayManager.PlayerSlomoDamageModifier.RemoveModifier(Card);
    }
}

function ActivateThorns(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerThornsModifier.AddModifier(2.f, Card);
    }
    else
    {
        GameplayManager.PlayerThornsModifier.RemoveModifier(Card);
    }
}

function ActivateTraderDiscount(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.TraderPriceModifier.AddModifier(0.9f, Card);
    }
    else
    {
        GameplayManager.TraderPriceModifier.RemoveModifier(Card);
    }
}

function ActivateTraderGrenadeDiscount(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.TraderGrenadePriceModifier.AddModifier(0.7f, Card);
    }
    else
    {
        GameplayManager.TraderGrenadePriceModifier.RemoveModifier(Card);
    }
}

function ActivateTrashHeadshotDamage(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerNonEliteHeadshotDamageModifier.AddModifier(1.1f, Card);
    }
    else
    {
        GameplayManager.PlayerNonEliteHeadshotDamageModifier.RemoveModifier(Card);
    }
}

function ActivateFastAmmoRespawn(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.AmmoPickupRespawnModifier.AddModifier(0.333f, Card);
    }
    else
    {
        GameplayManager.AmmoPickupRespawnModifier.RemoveModifier(Card);
    }
}

function ActivateMagazineAmmoIncrease(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMagazineAmmoModifier.AddModifier(1.05f, Card);
    }
    else
    {
        GameplayManager.PlayerMagazineAmmoModifier.RemoveModifier(Card);
    }
}

function ActivateSpreadAndRecoilDecrease(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerSpreadRecoilModifier.AddModifier(0.9f, Card);
    }
    else
    {
        GameplayManager.PlayerSpreadRecoilModifier.RemoveModifier(Card);
    }
}

function ActivateMonsterDamageDecrease(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.MonsterMeleeDamageModifier.AddModifier(0.95f, Card);
    }
    else
    {
        GameplayManager.MonsterMeleeDamageModifier.RemoveModifier(Card);
    }
}

function ActivateMoveSpeedIncrease(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMovementSpeedModifier.AddModifier(1.05f, Card);
    }
    else
    {
        GameplayManager.PlayerMovementSpeedModifier.RemoveModifier(Card);
    }
}

function ActivateSlowerWave(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.WaveSpeedModifier.AddModifier(0.95f, Card);
    }
    else
    {
        GameplayManager.WaveSpeedModifier.RemoveModifier(Card);
    }
}

function ActivateShorterWave(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.TotalMonstersModifier.AddModifier(0.95f, Card);
    }
    else
    {
        GameplayManager.TotalMonstersModifier.RemoveModifier(Card);
    }
}

function ActivateDauntless(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerLowHealthDamageModifier.AddModifier(1.1f, Card);
    }
    else
    {
        GameplayManager.PlayerLowHealthDamageModifier.RemoveModifier(Card);
    }
}

function ActivateRangedResistance(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.MonsterRangedDamageModifier.AddModifier(0.9f, Card);
    }
    else
    {
        GameplayManager.MonsterRangedDamageModifier.RemoveModifier(Card);
    }
}

function ActivateBetterArmor(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerArmorStrengthModifier.AddModifier(0.9f, Card);
    }
    else
    {
        GameplayManager.PlayerArmorStrengthModifier.RemoveModifier(Card);
    }
}

function ActivateMyLegsAreOkay(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerFallDamageModifier.AddModifier(0.f, Card);
    }
    else
    {
        GameplayManager.PlayerFallDamageModifier.RemoveModifier(Card);
    }
}

function ActivateHealthy(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMaxHealthModifier.AddModifier(1.05f, Card);
    }
    else
    {
        GameplayManager.PlayerMaxHealthModifier.RemoveModifier(Card);
    }
}

function ActivateBetterMedicine(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerNonMedicHealPotencyModifier.AddModifier(1.05f, Card);
        GameplayManager.PlayerMedicHealPotencyModifier.AddModifier(1.05f, Card);
    }
    else
    {
        GameplayManager.PlayerNonMedicHealPotencyModifier.RemoveModifier(Card);
        GameplayManager.PlayerMedicHealPotencyModifier.RemoveModifier(Card);
    }
}

function ActivateFamiliarTerritory(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerOnPerkDamageModifier.AddModifier(1.05f, Card);
    }
    else
    {
        GameplayManager.PlayerOnPerkDamageModifier.RemoveModifier(Card);
    }
}

function ActivateUnfamiliarTerritory(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerOffPerkDamageModifier.AddModifier(1.05f, Card);
    }
    else
    {
        GameplayManager.PlayerOffPerkDamageModifier.RemoveModifier(Card);
    }
}

function ActivateMoreSlomo(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerZedTimeExtensionDelta.AddDelta(4, Card);
    }
    else
    {
        GameplayManager.PlayerZedTimeExtensionDelta.RemoveDelta(Card);
    }
}

function ActivateExtraGrenade(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerGrenadeMaxAmmoModifier.AddModifier(1.2f, Card);
    }
    else
    {
        GameplayManager.PlayerGrenadeMaxAmmoModifier.RemoveModifier(Card);
    }
}

function ActivateFasterMedical(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerHealRechargeModifier.AddModifier(1.05f, Card);
    }
    else
    {
        GameplayManager.PlayerHealRechargeModifier.RemoveModifier(Card);
    }
}

function ActivateWalkItOff(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateDelta(GameplayManager.PlayerHealthRegenDelta, 1, bActivate);
}

function ActivateAdvancedWelding(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateModifier(GameplayManager.WeldStrengthModifier, 1.5f, bActivate);
}

function ActivateLargerQuanityOfLowQuality(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateDelta(GameplayManager.GoodCardSelectionCountDelta, 1, bActivate);
}

function ActivateBroaderGamble(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateDelta(GameplayManager.ProConCardSelectionCountDelta, 1, bActivate);
}

function ActivateElDiabloSlayer(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateModifier(GameplayManager.PlayerBossDamageModifier, 1.05f, bActivate);
}

defaultproperties
{
    Begin Object Name=BonusCashKill Class=TurboCard_Good
        CardName(0)="Reward Inflation"
        CardDescriptionList(0)="All players receive"
        CardDescriptionList(1)="10% extra cash"
        CardDescriptionList(2)="from kills."
        CardID="GOOD_REWARDINF"
        OnActivateCard=ActivateBonusCashKill
    End Object
    DeckCardObjectList(0)=TurboCard'BonusCashKill'

    Begin Object Name=FirerateIncrease Class=TurboCard_Good
        CardName(0)="Trigger Finger"
        CardDescriptionList(0)="Increases"
        CardDescriptionList(1)="firerate of all"
        CardDescriptionList(2)="weapons by 5%."
        CardID="GOOD_TRIGGERFING"
        OnActivateCard=ActivateFirerateIncrease
    End Object
    DeckCardObjectList(1)=TurboCard'FirerateIncrease'

    Begin Object Name=ExplosiveDamage Class=TurboCard_Good
        CardName(0)="Higher"
        CardName(1)="Explosives"
        CardDescriptionList(0)="Explosives deal"
        CardDescriptionList(1)="5% more damage."
        CardID="GOOD_HIGHEXPLOSIVES"
        OnActivateCard=ActivateExplosiveDamage
    End Object
    DeckCardObjectList(2)=TurboCard'ExplosiveDamage'

    Begin Object Name=ExplosiveRange Class=TurboCard_Good
        CardName(0)="Wider Explosives"
        CardDescriptionList(0)="Explosives have"
        CardDescriptionList(1)="10% larger range."
        CardID="GOOD_WIDEEXPLOSIVES"
        OnActivateCard=ActivateExplosiveRange
    End Object
    DeckCardObjectList(3)=TurboCard'ExplosiveRange'

    Begin Object Name=FreeArmor Class=TurboCard_Good
        CardName(0)="Free Armor"
        CardDescriptionList(0)="All players"
        CardDescriptionList(1)="receive free"
        CardDescriptionList(2)="armor each wave."
        CardID="GOOD_FREEARMOR"
        OnActivateCard=ActivateFreeArmor
    End Object
    DeckCardObjectList(4)=TurboCard'FreeArmor'

    Begin Object Name=MaxAmmo Class=TurboCard_Good
        CardName(0)="Deeper Bullet"
        CardName(1)="Pockets"
        CardDescriptionList(0)="Increase max"
        CardDescriptionList(1)="ammo for all"
        CardDescriptionList(2)="weapons by 10%."
        CardID="GOOD_DEEPERBULLET"
        OnActivateCard=ActivateMaxAmmo
    End Object
    DeckCardObjectList(5)=TurboCard'MaxAmmo'

    Begin Object Name=ReloadSpeed Class=TurboCard_Good
        CardName(0)="Basic Hand"
        CardName(1)="Stretches"
        CardDescriptionList(0)="Increases reload"
        CardDescriptionList(1)="speed of all"
        CardDescriptionList(2)="weapons by 5%."
        CardID="GOOD_BASICSTRETCHES"
        OnActivateCard=ActivateReloadSpeed
    End Object
    DeckCardObjectList(6)=TurboCard'ReloadSpeed'

    Begin Object Name=SlomoDamageBonus Class=TurboCard_Good
        CardName(0)="Slow Motion"
        CardName(1)="Expertise"
        CardDescriptionList(0)="Deal 10% more"
        CardDescriptionList(1)="damage during"
        CardDescriptionList(2)="zed time."
        CardID="GOOD_SLOMOEXPERT"
        OnActivateCard=ActivateSlomoDamageBonus
    End Object
    DeckCardObjectList(7)=TurboCard'SlomoDamageBonus'

    Begin Object Name=Thorns Class=TurboCard_Good
        CardName(0)="Thorns"
        CardDescriptionList(0)="Reflect 100% of"
        CardDescriptionList(1)="received damage"
        CardDescriptionList(2)="back onto zeds."
        CardID="GOOD_THORNS"
        OnActivateCard=ActivateThorns
    End Object
    DeckCardObjectList(8)=TurboCard'Thorns'

    Begin Object Name=TraderDiscount Class=TurboCard_Good
        CardName(0)="Slight Discount"
        CardDescriptionList(0)="All ammo and"
        CardDescriptionList(1)="weapons receive"
        CardDescriptionList(2)="a 10% discount."
        CardID="GOOD_SLIGHTDISC"
        OnActivateCard=ActivateTraderDiscount
    End Object
    DeckCardObjectList(9)=TurboCard'TraderDiscount'

    Begin Object Name=TraderGrenadeDiscount Class=TurboCard_Good
        CardName(0)="Grenade"
        CardName(1)="Clearance"
        CardDescriptionList(0)="Grenades receive"
        CardDescriptionList(1)="a 30% discount"
        CardDescriptionList(2)="at the trader."
        CardID="GOOD_GRENCLEARANCE"
        OnActivateCard=ActivateTraderGrenadeDiscount
    End Object
    DeckCardObjectList(10)=TurboCard'TraderGrenadeDiscount'

    Begin Object Name=TrashHeadshotDamage Class=TurboCard_Good
        CardName(0)="Trash Heads"
        CardDescriptionList(0)="Increases headshot"
        CardDescriptionList(1)="damage on non-elite"
        CardDescriptionList(2)="zeds by 10%."
        CardID="GOOD_TRASHHEADS"
        OnActivateCard=ActivateTrashHeadshotDamage
    End Object
    DeckCardObjectList(11)=TurboCard'TrashHeadshotDamage'

    Begin Object Name=FastAmmoRespawn Class=TurboCard_Good
        CardName(0)="Fast Ammo"
        CardName(1)="Respawn"
        CardDescriptionList(0)="Ammo pickups"
        CardDescriptionList(1)="respawn 200%"
        CardDescriptionList(2)="faster."
        CardID="GOOD_FASTAMMORESP"
        OnActivateCard=ActivateFastAmmoRespawn
    End Object
    DeckCardObjectList(12)=TurboCard'FastAmmoRespawn'

    Begin Object Name=MagazineAmmoIncrease Class=TurboCard_Good
        CardName(0)="Stuffed"
        CardName(1)="Magazine"
        CardDescriptionList(0)="Increases weapon"
        CardDescriptionList(1)="magazine size by 5%."
        CardID="GOOD_STUFFEDMAG"
        OnActivateCard=ActivateMagazineAmmoIncrease
    End Object
    DeckCardObjectList(13)=TurboCard'MagazineAmmoIncrease'

    Begin Object Name=SpreadAndRecoilDecrease Class=TurboCard_Good
        CardName(0)="Improved"
        CardName(1)="Focus"
        CardDescriptionList(0)="Decreases weapon"
        CardDescriptionList(1)="spread and"
        CardDescriptionList(2)="recoil by 10%."
        CardID="GOOD_STUFFEDMAG"
        OnActivateCard=ActivateSpreadAndRecoilDecrease
    End Object
    DeckCardObjectList(14)=TurboCard'SpreadAndRecoilDecrease'

    Begin Object Name=MonsterDamageDecrease Class=TurboCard_Good
        CardName(0)="Thicker Skin"
        CardDescriptionList(0)="Decreases melee"
        CardDescriptionList(1)="damage taken from"
        CardDescriptionList(2)="monsters by 5%."
        CardID="GOOD_THICKSKIN"
        OnActivateCard=ActivateMonsterDamageDecrease
    End Object
    DeckCardObjectList(15)=TurboCard'MonsterDamageDecrease'

    Begin Object Name=MoveSpeedIncrease Class=TurboCard_Good
        CardName(0)="Cardio Enjoyer"
        CardDescriptionList(0)="Increases player"
        CardDescriptionList(1)="move speed by 5%."
        CardID="GOOD_CARDIOENJOY"
        OnActivateCard=ActivateMoveSpeedIncrease
    End Object
    DeckCardObjectList(16)=TurboCard'MoveSpeedIncrease'

    Begin Object Name=SlowerWave Class=TurboCard_Good
        CardName(0)="Relaxed Pace"
        CardDescriptionList(0)="Decreases wave"
        CardDescriptionList(1)="spawn rate by 5%."
        CardID="GOOD_SLOWERWAVE"
        OnActivateCard=ActivateSlowerWave
    End Object
    DeckCardObjectList(17)=TurboCard'SlowerWave'

    Begin Object Name=ShorterWave Class=TurboCard_Good
        CardName(0)="Skimmed Waves"
        CardDescriptionList(0)="Decreases wave"
        CardDescriptionList(1)="size by 5%."
        CardID="GOOD_SHORTERWAVE"
        OnActivateCard=ActivateShorterWave
    End Object
    DeckCardObjectList(18)=TurboCard'ShorterWave'

    Begin Object Name=Dauntless Class=TurboCard_Good
        CardName(0)="Dauntless"
        CardDescriptionList(0)="When below 75%"
        CardDescriptionList(1)="health players"
        CardDescriptionList(2)="deal 10% more"
        CardDescriptionList(3)="damage."
        CardID="GOOD_DAUNTLESS"
        OnActivateCard=ActivateDauntless
    End Object
    DeckCardObjectList(19)=TurboCard'Dauntless'

    Begin Object Name=RangedResistance Class=TurboCard_Good
        CardName(0)="Ranged"
        CardName(1)="Resistance"
        CardDescriptionList(0)="Decreases damage"
        CardDescriptionList(1)="taken by ranged"
        CardDescriptionList(2)="zed attacks by 10%."
        CardID="GOOD_DAUNTLESS"
        OnActivateCard=ActivateRangedResistance
    End Object
    DeckCardObjectList(20)=TurboCard'RangedResistance'

    Begin Object Name=BetterArmor Class=TurboCard_Good
        CardName(0)="Tier 4 Plates"
        CardDescriptionList(0)="Increases armor"
        CardDescriptionList(1)="damage reduction"
        CardDescriptionList(2)="by 10%."
        CardID="GOOD_TIER4PLATES"
        OnActivateCard=ActivateBetterArmor
    End Object
    DeckCardObjectList(21)=TurboCard'BetterArmor'

    Begin Object Name=MyLegsAreOkay Class=TurboCard_Good
        CardName(0)="My Legs"
        CardName(1)="Are Okay"
        CardDescriptionList(0)="Players no longer"
        CardDescriptionList(1)="take fall damage."
        CardID="GOOD_MYLEGSAREOK"
        OnActivateCard=ActivateMyLegsAreOkay
    End Object
    DeckCardObjectList(22)=TurboCard'MyLegsAreOkay'

    Begin Object Name=Healthy Class=TurboCard_Good
        CardName(0)="Healthy"
        CardDescriptionList(0)="Increases player"
        CardDescriptionList(1)="health by 5%."
        CardID="GOOD_HEALTHY"
        OnActivateCard=ActivateHealthy
    End Object
    DeckCardObjectList(23)=TurboCard'Healthy'

    Begin Object Name=BetterMedicine Class=TurboCard_Good
        CardName(0)="Better Medicine"
        CardDescriptionList(0)="Increases heal"
        CardDescriptionList(1)="potency by 5%."
        CardID="GOOD_BETTERMEDICINE"
        OnActivateCard=ActivateBetterMedicine
    End Object
    DeckCardObjectList(24)=TurboCard'BetterMedicine'

    Begin Object Name=FamiliarTerritory Class=TurboCard_Good
        CardName(0)="Familiar"
        CardName(1)="Territory"
        CardDescriptionList(0)="Increases on-perk"
        CardDescriptionList(1)="damage by 5%."
        CardID="GOOD_FAMILIARTER"
        OnActivateCard=ActivateFamiliarTerritory
    End Object
    DeckCardObjectList(25)=TurboCard'FamiliarTerritory'

    Begin Object Name=UnfamiliarTerritory Class=TurboCard_Good
        CardName(0)="Unfamiliar"
        CardName(1)="Territory"
        CardDescriptionList(0)="Increases off-perk"
        CardDescriptionList(1)="damage by 5%."
        CardID="GOOD_UNFAMILIARTER"
        OnActivateCard=ActivateUnfamiliarTerritory
    End Object
    DeckCardObjectList(26)=TurboCard'UnfamiliarTerritory'

    Begin Object Name=MoreSlomo Class=TurboCard_Good
        CardName(0)="Extended Cut"
        CardDescriptionList(0)="Increases player"
        CardDescriptionList(1)="max zed time"
        CardDescriptionList(2)="extensions by 4."
        CardID="GOOD_EXTENDEDCUT"
        OnActivateCard=ActivateMoreSlomo
    End Object
    DeckCardObjectList(27)=TurboCard'MoreSlomo'

    Begin Object Name=ExtraGrenade Class=TurboCard_Good
        CardName(0)="He Who Casts"
        CardName(1)="The First Stone"
        CardDescriptionList(0)="Increases grenade"
        CardDescriptionList(1)="max ammo by 20%."
        CardID="GOOD_CASTFIRSTSTONE"
        OnActivateCard=ActivateExtraGrenade
    End Object
    DeckCardObjectList(28)=TurboCard'ExtraGrenade'

    Begin Object Name=FasterMedical Class=TurboCard_Good
        CardName(0)="Faster Medical"
        CardName(1)="Delivery"
        CardDescriptionList(0)="Increases medic"
        CardDescriptionList(1)="gun and syringe"
        CardDescriptionList(2)="recharge rate"
        CardDescriptionList(3)="by 5%."
        CardID="GOOD_FASTERMED"
        OnActivateCard=ActivateFasterMedical
    End Object
    DeckCardObjectList(29)=TurboCard'FasterMedical'

    Begin Object Name=WalkItOff Class=TurboCard_Good
        CardName(0)="Walk It Off"
        CardDescriptionList(0)="Increases health"
        CardDescriptionList(1)="regen by 1 every"
        CardDescriptionList(2)="5 seconds."
        CardID="GOOD_WALKITOFF"
        OnActivateCard=ActivateWalkItOff
    End Object
    DeckCardObjectList(30)=TurboCard'WalkItOff'

    Begin Object Name=AdvancedWelding Class=TurboCard_Good
        CardName(0)="Advanced"
        CardName(1)="Welding"
        CardDescriptionList(0)="Increases weld"
        CardDescriptionList(1)="speed by 50%."
        CardID="GOOD_ADVWELD"
        OnActivateCard=ActivateAdvancedWelding
    End Object
    DeckCardObjectList(31)=TurboCard'AdvancedWelding'

    Begin Object Name=LargerQuanityOfLowQuality Class=TurboCard_Good
        CardName(0)="Large Quantity"
        CardName(1)="Low Quality"
        CardDescriptionList(0)="Increases good"
        CardDescriptionList(1)="card selection"
        CardDescriptionList(2)="by 1."
        CardID="GOOD_LARGEQUANLOWQUAL"
        OnActivateCard=ActivateLargerQuanityOfLowQuality
    End Object
    DeckCardObjectList(32)=TurboCard'LargerQuanityOfLowQuality'

    Begin Object Name=BroaderGamble Class=TurboCard_Good
        CardName(0)="Broader Gamble"
        CardDescriptionList(0)="Increases pro/con"
        CardDescriptionList(1)="card selection"
        CardDescriptionList(2)="by 1."
        CardID="GOOD_BROADGAMBLE"
        OnActivateCard=ActivateBroaderGamble
    End Object
    DeckCardObjectList(33)=TurboCard'BroaderGamble'

    Begin Object Name=ElDiabloSlayer Class=TurboCard_Good
        CardName(0)="Slayer Of"
        CardName(1)="El Diablo"
        CardDescriptionList(0)="Increases damage"
        CardDescriptionList(1)="dealt to the"
        CardDescriptionList(2)="Patriarch by 5%."
        CardID="GOOD_DIABLOSLAYER"
        OnActivateCard=ActivateElDiabloSlayer
    End Object
    DeckCardObjectList(34)=TurboCard'ElDiabloSlayer'
}
