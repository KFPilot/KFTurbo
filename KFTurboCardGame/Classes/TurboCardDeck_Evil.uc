//Killing Floor Turbo TurboCardDeck_Evil
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardDeck_Evil extends TurboCardDeck;

function ActivateHyperbloats(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyBloatMovementSpeed(4.f);
}

function ActivateBelligerentScrakes(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyScrakeRageThreshold(1000000.f);
}

function ActivateHairtriggerFleshpounds(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyFleshpoundRageThreshold(0.0000001f);
}

function ActivateOverclockedHusks(TurboCardReplicationInfo CGRI)
{
    class'TurboWaveEventHandler'.static.RegisterWaveHandler(CGRI, class'OverclockedHuskWaveEventHandler');
    CGRI.ModifyHuskRefireTime(0.0000001f);
}

function ActivateRecession(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyTraderPriceMultiplier(3.f);
}

function ActivateFriendlyFire(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyFriendlyFireScale(1.15f);
}

function ActivateSuperSiren(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifySirenScreamDamage(3.f);
    CGRI.ModifySirenScreamRangeModifier(2.f);
}

function ActivateDisablePerkSwitching(TurboCardReplicationInfo CGRI)
{
    KFTurboGameType(CGRI.Level.Game).LockPerkSelection(true);
}

function ActivateCashSlowsPlayers(TurboCardReplicationInfo CGRI)
{
    CGRI.EnableMoneySlowsPlayers();
}

function ActivateSuperSlowPlayers(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyPlayerSpeed(0.2f);
}

function ActivateFreezeTag(TurboCardReplicationInfo CGRI)
{
    CGRI.EnableWaveMovementFreeze();
}

function ActivateSuddenDeath(TurboCardReplicationInfo CGRI)
{
    CGRI.EnableSuddenDeath();
    CGRI.ModifyPlayerMaxHealth(0.75f);
}

function ActivateBleedingPlayers(TurboCardReplicationInfo CGRI)
{
    CGRI.EnablePlayerBleeding();
}

function ActivateLightWeightPlayers(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyZombieMeleeDamage(3.f);
    CGRI.ModifyZombieMeleeMomentum(10.f);
}

function ActivatePoorlyOiledMachine(TurboCardReplicationInfo CGRI)
{
    CGRI.EnableMissingHealthStronglySlows();
}

function ActivateSlipperyFloor(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyPlayerAccel(0.5f);
    CGRI.ModifyMovementFriction(0.05f);
}

function ActivateNoodleArms(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyPlayerMaxCarryWeight(-2);
}

function ActivateInPlainSight(TurboCardReplicationInfo CGRI)
{
    CGRI.EnablePlainSightSpawning();
}

function ActivateHandCramps(TurboCardReplicationInfo CGRI)
{
    CGRI.ModifyWeaponReloadRate(0.75f);
}

function ActivateDoorless(TurboCardReplicationInfo CGRI)
{
    class'TurboWaveEventHandler'.static.RegisterWaveHandler(CGRI, class'BlowUpDoorsWaveEventHandler');
    class'BlowUpDoorsWaveEventHandler'.static.OnWaveEnded(KFTurboGameType(CGRI.Level.Game), KFTurboGameType(CGRI.Level.Game).WaveNum);
}

function ActivateSmallerBlind(TurboCardReplicationInfo CGRI)
{
    CGRI.DecreaseSelectionCount();
}

function ActivateBorrowedTime(TurboCardReplicationInfo CGRI)
{
    CGRI.EnableBorrowedTime();
}

function ActivateBankRun(TurboCardReplicationInfo CGRI)
{
    class'TurboWaveEventHandler'.static.RegisterWaveHandler(CGRI, class'BankRunWaveEventHandler');
    class'BankRunWaveEventHandler'.static.OnWaveStarted(KFTurboGameType(CGRI.Level.Game), KFTurboGameType(CGRI.Level.Game).WaveNum);
}

function ActivateNoRestForTheWicked(TurboCardReplicationInfo CGRI)
{
    CGRI.EnableNoRestForTheWicked();
}

function ActivateCurseOfRa(TurboCardReplicationInfo CGRI)
{
    CGRI.EnableCurseOfRa();
}

defaultproperties
{
    Begin Object Name=Hyperbloats Class=TurboCard_Evil
        CardName(0)="Hyperbloats"
        CardDescriptionList(0)="Increases Bloat"
        CardDescriptionList(1)="speed by 300%."
        OnActivateCard=ActivateHyperbloats
    End Object
    DeckCardObjectList(0)=TurboCard'Hyperbloats'

    Begin Object Name=BelligerentScrakes Class=TurboCard_Evil
        CardName(0)="Belligerent"
        CardName(1)="Scrakes"
        CardDescriptionList(0)="All Scrakes"
        CardDescriptionList(1)="spawn raged."
        OnActivateCard=ActivateBelligerentScrakes
    End Object
    DeckCardObjectList(1)=TurboCard'BelligerentScrakes'

    Begin Object Name=HairtriggerFleshpounds Class=TurboCard_Evil
        CardName(0)="Hair-Trigger"
        CardName(1)="Fleshpounds"
        CardDescriptionList(0)="Fleshpounds rage"
        CardDescriptionList(1)="when receiving"
        CardDescriptionList(2)="any damage."
        OnActivateCard=ActivateHairtriggerFleshpounds
    End Object
    DeckCardObjectList(2)=TurboCard'HairtriggerFleshpounds'

    Begin Object Name=OverclockedHusks Class=TurboCard_Evil
        CardName(0)="Overclocked"
        CardName(1)="Husks"
        CardDescriptionList(0)="Husk Fireball"
        CardDescriptionList(1)="refire time"
        CardDescriptionList(2)="reduced by 90%."
        OnActivateCard=ActivateOverclockedHusks
    End Object
    DeckCardObjectList(3)=TurboCard'OverclockedHusks'

    Begin Object Name=Recession Class=TurboCard_Evil
        CardName(0)="Complete"
        CardName(1)="Recession"
        CardDescriptionList(0)="All prices in"
        CardDescriptionList(1)="trader cost"
        CardDescriptionList(2)="200% more."
        OnActivateCard=ActivateRecession
    End Object
    DeckCardObjectList(4)=TurboCard'Recession'

    Begin Object Name=FriendlyFire Class=TurboCard_Evil
        CardName(0)="Friendly"
        CardName(1)="Fire"
        CardDescriptionList(0)="Increases damage"
        CardDescriptionList(1)="to allies by 15%."
        OnActivateCard=ActivateFriendlyFire
    End Object
    DeckCardObjectList(5)=TurboCard'FriendlyFire'

    Begin Object Name=SuperSiren Class=TurboCard_Evil
        CardName(0)="Super Sirens"
        CardDescriptionList(0)="Increases Siren"
        CardDescriptionList(1)="scream damage by"
        CardDescriptionList(2)="200% and scream"
        CardDescriptionList(3)="range by 100%."
        //TODO: Normal sirens are blowing up explosives with screams - not good.
        OnActivateCard=ActivateSuperSiren
    End Object
    DeckCardObjectList(6)=TurboCard'SuperSiren'
    
    Begin Object Name=DisablePerkSwitching Class=TurboCard_Evil
        CardName(0)="Locked In"
        CardDescriptionList(0)="All players are"
        CardDescriptionList(1)="locked to their"
        CardDescriptionList(2)="current perk."
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
        OnActivateCard=ActivateCashSlowsPlayers
    End Object
    DeckCardObjectList(8)=TurboCard'CashSlowsPlayers'
    
    Begin Object Name=SlipperyFloor Class=TurboCard_Evil
        CardName(0)="Slip'n'Slide"
        CardDescriptionList(0)="Players are"
        CardDescriptionList(1)="now very"
        CardDescriptionList(2)="slippery."
        OnActivateCard=ActivateSlipperyFloor
    End Object
    DeckCardObjectList(9)=TurboCard'SlipperyFloor'
    
    Begin Object Name=FreezeTag Class=TurboCard_Evil
        CardName(0)="Freeze Tag"
        CardDescriptionList(0)="During the"
        CardDescriptionList(1)="wave players"
        CardDescriptionList(2)="cannot move."
        OnActivateCard=ActivateFreezeTag
    End Object
    DeckCardObjectList(10)=TurboCard'FreezeTag'
    
    Begin Object Name=SuddenDeath Class=TurboCard_Evil
        CardName(0)="Sudden Death"
        CardDescriptionList(0)="Reduces player"
        CardDescriptionList(1)="health by 25%."
        CardDescriptionList(2)="If any player"
        CardDescriptionList(3)="dies, the"
        CardDescriptionList(4)="squad dies."
        OnActivateCard=ActivateSuddenDeath
    End Object
    DeckCardObjectList(11)=TurboCard'SuddenDeath'
    
    Begin Object Name=BleedingPlayers Class=TurboCard_Evil
        CardName(0)="Clotting"
        CardName(1)="Issues"
        CardDescriptionList(0)="Players lose"
        CardDescriptionList(1)="5 health every"
        CardDescriptionList(2)="5 seconds."
        OnActivateCard=ActivateBleedingPlayers
    End Object
    DeckCardObjectList(12)=TurboCard'BleedingPlayers'
    
    Begin Object Name=LightWeightPlayers Class=TurboCard_Evil
        CardName(0)="Lethal"
        CardName(1)="Specimens"
        CardDescriptionList(0)="Zeds deal"
        CardDescriptionList(1)="200% more damage"
        CardDescriptionList(2)="and knockback is"
        CardDescriptionList(3)="increased by 900%."
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
        OnActivateCard=ActivatePoorlyOiledMachine
    End Object
    DeckCardObjectList(14)=TurboCard'PoorlyOiledMachine'
    
    Begin Object Name=NoodleArms Class=TurboCard_Evil
        CardName(0)="Noodle Arms"
        CardDescriptionList(0)="Reduces max"
        CardDescriptionList(1)="carry weight"
        CardDescriptionList(2)="by 2 for all"
        CardDescriptionList(3)="players."
        OnActivateCard=ActivateNoodleArms
    End Object
    DeckCardObjectList(15)=TurboCard'NoodleArms'
    
    Begin Object Name=InPlainSight Class=TurboCard_Evil
        CardName(0)="In Plain Sight"
        CardDescriptionList(0)="Allows spawns"
        CardDescriptionList(1)="to occur in"
        CardDescriptionList(2)="sight of"
        CardDescriptionList(3)="players."
        OnActivateCard=ActivateInPlainSight
    End Object
    DeckCardObjectList(16)=TurboCard'InPlainSight'
    
    Begin Object Name=HandCramps Class=TurboCard_Evil
        CardName(0)="Hand Cramps"
        CardDescriptionList(0)="Reduces reload"
        CardDescriptionList(1)="speed for all"
        CardDescriptionList(2)="players by 25%."
        OnActivateCard=ActivateHandCramps
    End Object
    DeckCardObjectList(17)=TurboCard'HandCramps'
    
    Begin Object Name=Doorless Class=TurboCard_Evil
        CardName(0)="Doorless"
        CardDescriptionList(0)="Removes all"
        CardDescriptionList(1)="doors."
        OnActivateCard=ActivateDoorless
    End Object
    DeckCardObjectList(18)=TurboCard'Doorless'
    
    Begin Object Name=SmallerBlind Class=TurboCard_Evil
        CardName(0)="Smaller Blind"
        CardDescriptionList(0)="Reduces card"
        CardDescriptionList(1)="selection by 1."
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
        CardDescriptionList(5)="runs outs."
        OnActivateCard=ActivateBorrowedTime
    End Object
    DeckCardObjectList(20)=TurboCard'BorrowedTime'
    
    Begin Object Name=BankRun Class=TurboCard_Evil
        CardName(0)="Bank Run"
        CardDescriptionList(0)="Players lose all"
        CardDescriptionList(1)="dosh at the end"
        CardDescriptionList(2)="of trader time."
        OnActivateCard=ActivateBankRun
    End Object
    DeckCardObjectList(21)=TurboCard'BankRun'
    
    Begin Object Name=NoRestForTheWicked Class=TurboCard_Evil
        CardName(0)="No Rest For"
        CardName(1)="The Wicked"
        CardDescriptionList(0)="Players take"
        CardDescriptionList(1)="damage when"
        CardDescriptionList(2)="standing still."
        OnActivateCard=ActivateNoRestForTheWicked
    End Object
    DeckCardObjectList(22)=TurboCard'NoRestForTheWicked'
    
    Begin Object Name=CurseOfRa Class=TurboCard_Evil_Ra
        OnActivateCard=ActivateCurseOfRa
    End Object
    DeckCardObjectList(23)=TurboCard'CurseOfRa'

    //Strong Winds.
}
