//Killing Floor Turbo TurboCardDeck_Evil
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardDeck_Evil extends TurboCardDeck;

function ActivateHyperbloats(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.MonsterBloatMovementSpeedModifier.AddModifier(4.f, Card);
    }
    else
    {
        GameplayManager.MonsterBloatMovementSpeedModifier.RemoveModifier(Card);
    }
}

function ActivateBelligerentScrakes(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.MonsterScrakeRageThresholdModifier.AddModifier(1000000.f, Card);
    }
    else
    {
        GameplayManager.MonsterScrakeRageThresholdModifier.RemoveModifier(Card);
    }
}

function ActivateHairtriggerFleshpounds(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.MonsterFleshpoundRageThresholdModifier.AddModifier(0.0000001f, Card);
    }
    else
    {
        GameplayManager.MonsterFleshpoundRageThresholdModifier.RemoveModifier(Card);
    }
}

function ActivateOverclockedHusks(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.MonsterHuskRefireTimeModifier.AddModifier(0.0000001f, Card);
        GameplayManager.HuskAmountBoostFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.MonsterHuskRefireTimeModifier.RemoveModifier(Card);
        GameplayManager.HuskAmountBoostFlag.ClearFlag();
    }
}

function ActivateRecession(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.TraderPriceModifier.AddModifier(2.5f, Card);
    }
    else
    {
        GameplayManager.TraderPriceModifier.RemoveModifier(Card);
    }
}

function ActivateFriendlyFire(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.FriendlyFireModifier.AddModifier(1.1f, Card);
    }
    else
    {
        GameplayManager.FriendlyFireModifier.RemoveModifier(Card);
    }
}

function ActivateSuperSiren(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.MonsterSirenScreamDamageModifier.AddModifier(2.f, Card);
        GameplayManager.MonsterSirenScreamRangeModifier.AddModifier(1.25f, Card);
    }
    else
    {
        GameplayManager.MonsterSirenScreamDamageModifier.RemoveModifier(Card);
        GameplayManager.MonsterSirenScreamRangeModifier.RemoveModifier(Card);
    }
}

function ActivateDisablePerkSwitching(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.LockPerkSelectionFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.LockPerkSelectionFlag.ClearFlag();
    }
}

function ActivateCashSlowsPlayers(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerGreedSlowsFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.PlayerGreedSlowsFlag.ClearFlag();
    }
}

function ActivateSuperSlowPlayers(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMovementSpeedModifier.AddModifier(0.2f, Card);
    }
    else
    {
        GameplayManager.PlayerMovementSpeedModifier.RemoveModifier(Card);
    }
}

function ActivateFreezeTag(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerFreezeTagFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.PlayerFreezeTagFlag.ClearFlag();
    }
}

function ActivateSuddenDeath(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.SuddenDeathFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.SuddenDeathFlag.ClearFlag();
    }
}

function ActivateBleedingPlayers(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.BleedDamageFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.BleedDamageFlag.ClearFlag();
    }
}

function ActivateLightWeightPlayers(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.MonsterMeleeDamageModifier.AddModifier(1.5f, Card);
        GameplayManager.MonsterDamageMomentumModifier.AddModifier(3.f, Card);
    }
    else
    {
        GameplayManager.MonsterMeleeDamageModifier.RemoveModifier(Card);
        GameplayManager.MonsterDamageMomentumModifier.RemoveModifier(Card);
    }
}

function ActivatePoorlyOiledMachine(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerLowHealthSlowsFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.BleedDamageFlag.ClearFlag();
    }
}

function ActivateSlipperyFloor(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerMovementAccelModifier.AddModifier(0.5f, Card);
        GameplayManager.PlayerMovementFrictionModifier.AddModifier(0.05f, Card);
    }
    else
    {
        GameplayManager.PlayerMovementAccelModifier.RemoveModifier(Card);
        GameplayManager.PlayerMovementFrictionModifier.RemoveModifier(Card);
    }
}

function ActivateNoodleArms(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerCarryCapacityDelta.AddDelta(-2, Card);
    }
    else
    {
        GameplayManager.PlayerCarryCapacityDelta.RemoveDelta(Card);
    }
}

function ActivateInPlainSight(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlainSightSpawnFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.PlainSightSpawnFlag.ClearFlag();
    }
}

function ActivateHandCramps(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerReloadRateModifier.AddModifier(0.75f, Card);
    }
    else
    {
        GameplayManager.PlayerReloadRateModifier.RemoveModifier(Card);
    }
}

function ActivateDoorless(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.ExplodeDoorFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.ExplodeDoorFlag.ClearFlag();
    }
}

function ActivateSmallerBlind(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.CardSelectionCountDelta.AddDelta(-1, Card);
    }
    else
    {
        GameplayManager.CardSelectionCountDelta.RemoveDelta(Card);
    }
}

function ActivateBorrowedTime(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.BorrowedTimeFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.BorrowedTimeFlag.ClearFlag();
    }
}

function ActivateBankRun(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.BankRunFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.BankRunFlag.ClearFlag();
    }
}

function ActivateNoRestForTheWicked(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.NoRestForTheWickedFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.NoRestForTheWickedFlag.ClearFlag();
    }
}

function ActivateCurseOfRa(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.CurseOfRaFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.CurseOfRaFlag.ClearFlag();
    }
}

function ActivateGarbageDay(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerNonEliteDamageModifier.AddModifier(0.66f, Card);
    }
    else
    {
        GameplayManager.PlayerNonEliteDamageModifier.RemoveModifier(Card);
    }
}

function ActivateNoJunkies(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.NoSyringeFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.NoSyringeFlag.ClearFlag();
    }
}

function ActivateMarkedForDeath(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.MarkedForDeathFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.MarkedForDeathFlag.ClearFlag();
    }
}

function ActivateRestrictedExplosives(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.PlayerExplosiveRadiusModifier.AddModifier(0.5f, Card);
    }
    else
    {
        GameplayManager.PlayerExplosiveRadiusModifier.RemoveModifier(Card);
    }
}

function ActivateOopsAllScrakes(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.ScrakeMonsterReplacementFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.ScrakeMonsterReplacementFlag.ClearFlag();
    }
}

function ActivateMixedSignals(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.RandomTraderChangeFlag.SetFlag(Card);
    }
    else
    {
        GameplayManager.RandomTraderChangeFlag.ClearFlag();
    }
}

function ActivateHighThroughput(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.MaxMonstersModifier.AddModifier(1.4f, Card);
        GameplayManager.WaveSpeedModifier.AddModifier(1.15f, Card);
    }
    else
    {
        GameplayManager.MaxMonstersModifier.RemoveModifier(Card);
        GameplayManager.WaveSpeedModifier.RemoveModifier(Card);
    }
}

function ActivateNakedSnake(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateFlag(GameplayManager.NoArmorFlag, bActivate);
}

function ActivateThisIsMyRifle(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateFlag(GameplayManager.NoDropOrSellItemsFlag, bActivate);
}

function ActivateSacrificialCard(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    if (bActivate)
    {
        GameplayManager.RemoveRandomSuperCard();
    }
}

function ActivateUnfortunateUpgrade(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateFlag(GameplayManager.MonsterUpgradeFlag, bActivate);
}

function ActivateDoubleTime(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateModifier(GameplayManager.TraderTimeModifier, 0.5f, bActivate);
}

function ActivateBadBlood(TurboCardGameplayManager GameplayManager, TurboCard Card, bool bActivate)
{
    Card.UpdateModifier(GameplayManager.PlayerMaxHealthModifier, 0.8f, bActivate);
}

defaultproperties
{
    Begin Object Name=Hyperbloats Class=TurboCard_Evil
        CardName(0)="Hyperbloats"
        CardDescriptionList(0)="Increases Bloat"
        CardDescriptionList(1)="speed by 300%."
        CardID="EVIL_HYPBLOAT"
        OnActivateCard=ActivateHyperbloats
    End Object
    DeckCardObjectList(0)=TurboCard'Hyperbloats'

    Begin Object Name=BelligerentScrakes Class=TurboCard_Evil
        CardName(0)="Belligerent"
        CardName(1)="Scrakes"
        CardDescriptionList(0)="All Scrakes"
        CardDescriptionList(1)="spawn raged."
        CardID="EVIL_BELLIGSC"
        OnActivateCard=ActivateBelligerentScrakes
    End Object
    DeckCardObjectList(1)=TurboCard'BelligerentScrakes'

    Begin Object Name=HairtriggerFleshpounds Class=TurboCard_Evil
        CardName(0)="Hair-Trigger"
        CardName(1)="Fleshpounds"
        CardDescriptionList(0)="Fleshpounds rage"
        CardDescriptionList(1)="when receiving"
        CardDescriptionList(2)="any damage."
        CardID="EVIL_HAIRTRIGFP"
        OnActivateCard=ActivateHairtriggerFleshpounds
    End Object
    DeckCardObjectList(2)=TurboCard'HairtriggerFleshpounds'

    Begin Object Name=OverclockedHusks Class=TurboCard_Evil
        CardName(0)="Overclocked"
        CardName(1)="Husks"
        CardDescriptionList(0)="Husk Fireball"
        CardDescriptionList(1)="refire time"
        CardDescriptionList(2)="reduced by 99%."
        CardID="EVIL_OVERCLOCKHUSK"
        OnActivateCard=ActivateOverclockedHusks
    End Object
    DeckCardObjectList(3)=TurboCard'OverclockedHusks'

    Begin Object Name=Recession Class=TurboCard_Evil
        CardName(0)="Complete"
        CardName(1)="Recession"
        CardDescriptionList(0)="All prices in"
        CardDescriptionList(1)="trader cost"
        CardDescriptionList(2)="150% more."
        CardID="EVIL_COMPLETEREC"
        OnActivateCard=ActivateRecession
    End Object
    DeckCardObjectList(4)=TurboCard'Recession'

    Begin Object Name=FriendlyFire Class=TurboCard_Evil
        CardName(0)="Friendly"
        CardName(1)="Fire"
        CardDescriptionList(0)="Increases damage"
        CardDescriptionList(1)="to allies by 10%."
        CardID="EVIL_FRIENDLYFIRE"
        OnActivateCard=ActivateFriendlyFire
    End Object
    DeckCardObjectList(5)=TurboCard'FriendlyFire'

    Begin Object Name=SuperSiren Class=TurboCard_Evil
        CardName(0)="Super Sirens"
        CardDescriptionList(0)="Increases Siren"
        CardDescriptionList(1)="scream damage by"
        CardDescriptionList(2)="100% and scream"
        CardDescriptionList(3)="range by 25%."
        CardID="EVIL_SUPERSIREN"
        OnActivateCard=ActivateSuperSiren
    End Object
    DeckCardObjectList(6)=TurboCard'SuperSiren'
    
    Begin Object Name=DisablePerkSwitching Class=TurboCard_Evil
        CardName(0)="Locked In"
        CardDescriptionList(0)="All players are"
        CardDescriptionList(1)="locked to their"
        CardDescriptionList(2)="current perk."
        CardID="EVIL_NOPERKSWITCH"
        OnActivateCard=ActivateDisablePerkSwitching
    End Object
    DeckCardObjectList(7)=TurboCard'DisablePerkSwitching'
    
    Begin Object Name=CashSlowsPlayers Class=TurboCard_Evil
        CardName(0)="Greed Begets"
        CardName(1)="Slow Speed"
        CardDescriptionList(0)="The more money"
        CardDescriptionList(1)="a player holds,"
        CardDescriptionList(2)="the slower"
        CardDescriptionList(3)="they become."
        CardID="EVIL_GREEDBEGETSLOW"
        OnActivateCard=ActivateCashSlowsPlayers
    End Object
    DeckCardObjectList(8)=TurboCard'CashSlowsPlayers'
    
    Begin Object Name=SlipperyFloor Class=TurboCard_Evil
        CardName(0)="Slip'n'Slide"
        CardDescriptionList(0)="Players and"
        CardDescriptionList(1)="zeds are now"
        CardDescriptionList(2)="very slippery."
        CardID="EVIL_SLIPPERY"
        OnActivateCard=ActivateSlipperyFloor
    End Object
    DeckCardObjectList(9)=TurboCard'SlipperyFloor'
    
    Begin Object Name=FreezeTag Class=TurboCard_Evil
        CardName(0)="Freeze Tag"
        CardDescriptionList(0)="During the"
        CardDescriptionList(1)="wave players"
        CardDescriptionList(2)="cannot move"
        CardDescriptionList(3)="unless they"
        CardDescriptionList(4)="hold a melee"
        CardDescriptionList(5)="weapon."
        CardID="EVIL_FREEZETAG"
        OnActivateCard=ActivateFreezeTag
    End Object
    DeckCardObjectList(10)=TurboCard'FreezeTag'
    
    Begin Object Name=SuddenDeath Class=TurboCard_Evil
        CardName(0)="Sudden Death"
        CardDescriptionList(0)="If any player"
        CardDescriptionList(1)="dies, the"
        CardDescriptionList(2)="squad dies."
        CardID="EVIL_SUDDENDEATH"
        OnActivateCard=ActivateSuddenDeath
    End Object
    DeckCardObjectList(11)=TurboCard'SuddenDeath'
    
    Begin Object Name=BleedingPlayers Class=TurboCard_Evil
        CardName(0)="Clotting"
        CardName(1)="Issues"
        CardDescriptionList(0)="After receiving"
        CardDescriptionList(1)="melee damage,"
        CardDescriptionList(2)="players lose"
        CardDescriptionList(3)="2 health every"
        CardDescriptionList(4)="second for"
        CardDescriptionList(5)="5 seconds."
        CardID="EVIL_BLEEDING"
        OnActivateCard=ActivateBleedingPlayers
    End Object
    DeckCardObjectList(12)=TurboCard'BleedingPlayers'
    
    Begin Object Name=LightWeightPlayers Class=TurboCard_Evil
        CardName(0)="Lethal"
        CardName(1)="Specimens"
        CardDescriptionList(0)="Zeds deal 50%"
        CardDescriptionList(1)="more melee damage"
        CardDescriptionList(2)="and knockback is"
        CardDescriptionList(3)="increased by 200%."
        CardID="EVIL_LETHALSPEC"
        OnActivateCard=ActivateLightWeightPlayers
    End Object
    DeckCardObjectList(13)=TurboCard'LightWeightPlayers'
    
    Begin Object Name=PoorlyOiledMachine Class=TurboCard_Evil
        CardName(0)="Poorly Oiled"
        CardName(1)="Machine"
        CardDescriptionList(0)="Players at"
        CardDescriptionList(1)="less than 75%"
        CardDescriptionList(2)="max health move"
        CardDescriptionList(3)="at 75% speed."
        CardID="EVIL_POORLYOILED"
        OnActivateCard=ActivatePoorlyOiledMachine
    End Object
    DeckCardObjectList(14)=TurboCard'PoorlyOiledMachine'
    
    Begin Object Name=NoodleArms Class=TurboCard_Evil
        CardName(0)="Noodle Arms"
        CardDescriptionList(0)="Reduces max"
        CardDescriptionList(1)="carry weight"
        CardDescriptionList(2)="by 2 for all"
        CardDescriptionList(3)="players."
        CardID="EVIL_NOODLEARMS"
        OnActivateCard=ActivateNoodleArms
    End Object
    DeckCardObjectList(15)=TurboCard'NoodleArms'
    
    Begin Object Name=InPlainSight Class=TurboCard_Evil
        CardName(0)="In Plain Sight"
        CardDescriptionList(0)="Allows spawns"
        CardDescriptionList(1)="to occur in"
        CardDescriptionList(2)="sight of"
        CardDescriptionList(3)="players."
        CardID="EVIL_PLAINSIGHT"
        OnActivateCard=ActivateInPlainSight
    End Object
    DeckCardObjectList(16)=TurboCard'InPlainSight'
    
    Begin Object Name=HandCramps Class=TurboCard_Evil
        CardName(0)="Hand Cramps"
        CardDescriptionList(0)="Reduces reload"
        CardDescriptionList(1)="speed for all"
        CardDescriptionList(2)="players by 25%."
        CardID="EVIL_HANDCRAMPS"
        OnActivateCard=ActivateHandCramps
    End Object
    DeckCardObjectList(17)=TurboCard'HandCramps'
    
    Begin Object Name=Doorless Class=TurboCard_Evil
        CardName(0)="Doorless"
        CardDescriptionList(0)="Removes all"
        CardDescriptionList(1)="doors."
        CardID="EVIL_DOORLESS"
        OnActivateCard=ActivateDoorless
    End Object
    DeckCardObjectList(18)=TurboCard'Doorless'
    
    Begin Object Name=SmallerBlind Class=TurboCard_Evil
        CardName(0)="Smaller Blind"
        CardDescriptionList(0)="Reduces card"
        CardDescriptionList(1)="selection by 1."
        CardID="EVIL_SMALLBLIND"
        OnActivateCard=ActivateSmallerBlind
    End Object
    DeckCardObjectList(19)=TurboCard'SmallerBlind'
    
    Begin Object Name=BorrowedTime Class=TurboCard_Evil
        CardName(0)="On Borrowed"
        CardName(1)="Time"
        CardDescriptionList(0)="Waves now have"
        CardDescriptionList(1)="a time limit"
        CardDescriptionList(2)="based on wave"
        CardDescriptionList(3)="size. All players"
        CardDescriptionList(4)="die when time"
        CardDescriptionList(5)="runs out."
        CardID="EVIL_BORROWEDTIME"
        OnActivateCard=ActivateBorrowedTime
    End Object
    DeckCardObjectList(20)=TurboCard'BorrowedTime'
    
    Begin Object Name=BankRun Class=TurboCard_Evil
        CardName(0)="Bank Run"
        CardDescriptionList(0)="Players lose half"
        CardDescriptionList(1)="of their dosh"
        CardDescriptionList(2)="at the end of"
        CardDescriptionList(3)="trader time."
        CardID="EVIL_BANKRUN"
        OnActivateCard=ActivateBankRun
    End Object
    DeckCardObjectList(21)=TurboCard'BankRun'
    
    Begin Object Name=NoRestForTheWicked Class=TurboCard_Evil
        CardName(0)="No Rest For"
        CardName(1)="The Wicked"
        CardDescriptionList(0)="Players take"
        CardDescriptionList(1)="damage when"
        CardDescriptionList(2)="standing still."
        CardID="EVIL_NOREST"
        OnActivateCard=ActivateNoRestForTheWicked
    End Object
    DeckCardObjectList(22)=TurboCard'NoRestForTheWicked'
    
    Begin Object Name=CurseOfRa Class=TurboCard_Evil_Ra
        OnActivateCard=ActivateCurseOfRa
        CardID="EVIL_CURSEOFRA"
    End Object
    DeckCardObjectList(23)=TurboCard'CurseOfRa'
    
    Begin Object Name=GarbageDay Class=TurboCard_Evil
        CardName(0)="Garbage Day"
        CardDescriptionList(0)="Trash zeds have"
        CardDescriptionList(1)="50% more health."
        CardID="EVIL_GARBAGEDAY"
        OnActivateCard=ActivateGarbageDay
    End Object
    DeckCardObjectList(24)=TurboCard'GarbageDay'
    
    Begin Object Name=NoJunkies Class=TurboCard_Evil
        CardName(0)="No Junkies"
        CardDescriptionList(0)="Syringes are"
        CardDescriptionList(1)="removed from"
        CardDescriptionList(2)="all players."
        CardID="EVIL_NOJUNKIES"
        OnActivateCard=ActivateNoJunkies
    End Object
    DeckCardObjectList(25)=TurboCard'NoJunkies'
    
    Begin Object Name=MarkedForDeath Class=TurboCard_Evil
        CardName(0)="Marked For"
        CardName(1)="Death"
        CardDescriptionList(0)="Each wave a"
        CardDescriptionList(1)="random player is"
        CardDescriptionList(2)="chosen and takes"
        CardDescriptionList(3)="200% more damage"
        CardDescriptionList(4)="for a wave."
        CardID="EVIL_MARKEDDEATH"
        OnActivateCard=ActivateMarkedForDeath
    End Object
    DeckCardObjectList(26)=TurboCard'MarkedForDeath'
    
    Begin Object Name=RestrictedExplosives Class=TurboCard_Evil
        CardName(0)="Restricted"
        CardName(1)="Explosives"
        CardDescriptionList(0)="Reduces explosive"
        CardDescriptionList(1)="range by 50%."
        CardID="EVIL_RESTEXPLOSIVES"
        OnActivateCard=ActivateRestrictedExplosives
    End Object
    DeckCardObjectList(27)=TurboCard'RestrictedExplosives'
    
    Begin Object Name=OopsAllScrakes Class=TurboCard_Evil
        CardName(0)="Oops!"
        CardName(1)="All Scrakes!"
        CardDescriptionList(0)="All zeds have a"
        CardDescriptionList(1)="5% chance to be"
        CardDescriptionList(2)="replaced with"
        CardDescriptionList(3)="a Scrake instead."
        CardID="EVIL_OOPSALLSC"
        OnActivateCard=ActivateOopsAllScrakes
    End Object
    DeckCardObjectList(28)=TurboCard'OopsAllScrakes'
    
    Begin Object Name=MixedSignals Class=TurboCard_Evil
        CardName(0)="Mixed Signals"
        CardDescriptionList(0)="Next trader"
        CardDescriptionList(1)="location randomly"
        CardDescriptionList(2)="changes throughout"
        CardDescriptionList(3)="the wave."
        CardID="EVIL_MIXEDSIGNALS"
        OnActivateCard=ActivateMixedSignals
    End Object
    DeckCardObjectList(29)=TurboCard'MixedSignals'
    
    Begin Object Name=HighThroughput Class=TurboCard_Evil
        CardName(0)="High"
        CardName(1)="Throughput"
        CardDescriptionList(0)="Increases maximum"
        CardDescriptionList(1)="alive zeds at"
        CardDescriptionList(2)="once by 40%."
        CardID="EVIL_HITHROUGHPUT"
        OnActivateCard=ActivateHighThroughput
    End Object
    DeckCardObjectList(30)=TurboCard'HighThroughput'
    
    Begin Object Name=NakedSnake Class=TurboCard_Evil
        CardName(0)="Naked"
        CardName(1)="Snake"
        CardDescriptionList(0)="Players cannot"
        CardDescriptionList(1)="buy armor at"
        CardDescriptionList(2)="the trader."
        CardID="EVIL_NAKEDSNAKE"
        OnActivateCard=ActivateNakedSnake
    End Object
    DeckCardObjectList(31)=TurboCard'NakedSnake'
    
    Begin Object Name=ThisIsMyRifle Class=TurboCard_Evil
        CardName(0)="This Is"
        CardName(1)="My Rifle"
        CardDescriptionList(0)="Players cannot"
        CardDescriptionList(1)="drop or sell"
        CardDescriptionList(2)="their weapons."
        CardID="EVIL_MYRIFLE"
        OnActivateCard=ActivateThisIsMyRifle
    End Object
    DeckCardObjectList(32)=TurboCard'ThisIsMyRifle'
    
    Begin Object Name=SacrificialCard Class=TurboCard_Evil
        CardName(0)="Sacrificial"
        CardName(1)="Card"
        CardDescriptionList(0)="Removes a random"
        CardDescriptionList(1)="Super card."
        CardID="EVIL_SACRIFICIAL"
        OnActivateCard=ActivateSacrificialCard
    End Object
    DeckCardObjectList(33)=TurboCard'SacrificialCard'
    
    Begin Object Name=UnfortunateUpgrade Class=TurboCard_Evil
        CardName(0)="Unfortunate"
        CardName(1)="Upgrade"
        CardDescriptionList(0)="Non-elites have"
        CardDescriptionList(1)="a 5% chance to be"
        CardDescriptionList(2)="replaced with a"
        CardDescriptionList(3)="special zed."
        CardDescriptionList(4)="Special zeds have"
        CardDescriptionList(5)="a 5% chance to be"
        CardDescriptionList(6)="replaced with an."
        CardDescriptionList(7)="elite zed."
        CardID="EVIL_UNFORTUPGRADE"
        OnActivateCard=ActivateUnfortunateUpgrade
    End Object
    DeckCardObjectList(34)=TurboCard'UnfortunateUpgrade'
    
    Begin Object Name=DoubleTime Class=TurboCard_Evil
        CardName(0)="Double"
        CardName(1)="Time It"
        CardDescriptionList(0)="Reduces trader"
        CardDescriptionList(1)="time by 50%."
        CardID="EVIL_DOUBLETIME"
        OnActivateCard=ActivateDoubleTime
    End Object
    DeckCardObjectList(35)=TurboCard'DoubleTime'
    
    Begin Object Name=BadBlood Class=TurboCard_Evil
        CardName(0)="Bad Blood"
        CardDescriptionList(0)="Decreases max"
        CardDescriptionList(1)="health for all"
        CardDescriptionList(2)="players by 20%."
        CardID="EVIL_BADBLOOD"
        OnActivateCard=ActivateBadBlood
    End Object
    DeckCardObjectList(36)=TurboCard'BadBlood'
}