//Killing Floor Turbo TurboCardGameplayManagerBase
//Handles all modifications, deltas and flags that Card Game is applying.
//Responsible for setting these values elsewhere/spinning up actors to handle the actual gameplay changes.
//Also has a bunch of convenience functions to help debloat TurboCardGameplayManager.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardGameplayManagerBase extends Engine.Info;

var KFTurboCardGameMut CardGaneMutator;
var KFTurboGameType TurboGameType;
var TurboCardReplicationInfo CardReplicationInfo;
var TurboCardGameModifierRepLink CardGameModifier;
var TurboCardClientModifierRepLink CardClientModifier;
var CardGameRules CardGameRules;

var array<CardModifierStack> CardModifierList;
var array<CardDeltaStack> CardDeltaList;
var array<CardFlag> CardFlagList;

struct DeEvolutionMonsterReplacement
{
    var class<KFMonster> TargetParentClass;
    var class<KFMonster> ReplacementClass;
};

var array<DeEvolutionMonsterReplacement> WeakReplacementList; //List of KFMonster parent classes, their replacement, and individual chance to be applied.

struct UpgradeMonsterReplacement
{
    var array <class<KFMonster> > ReplacementClassList;
};

var array<UpgradeMonsterReplacement> UpgradeReplacementList;

function PostBeginPlay()
{
    local CardDeltaStack CardDelta;
    local CardModifierStack CardStack;
    local CardFlag CardFlag;
    local int Count;

    Super.PostBeginPlay();

    TurboGameType = KFTurboGameType(Level.Game);
    CardGaneMutator = KFTurboCardGameMut(Owner);

    if (CardGaneMutator == None)
    {
        return;
    }

    CardReplicationInfo = CardGaneMutator.TurboCardReplicationInfo;
    CardGameModifier = CardGaneMutator.TurboCardGameModifier;
    CardClientModifier = CardGaneMutator.TurboCardClientModifier;
    CardGameRules = CardGaneMutator.CardGameRules;

    log("Collecting all modifiers, deltas and flags...", 'KFTurboCardGame');
    StopWatch(false);
    Count = 0;
    CardModifierList.Length = 80;
    foreach AllObjects(class'CardModifierStack', CardStack)
    {
        //This filters out CDO instances.
        if (CardStack.Outer == None || CardStack.Outer.IsA('Class'))
        {
            continue;
        }

        CardModifierList[Count] = CardStack;
        Count++;
    }
    CardModifierList.Length = Count;

    Count = 0;
    CardDeltaList.Length = 80;
    foreach AllObjects(class'CardDeltaStack', CardDelta)
    {
        if (CardDelta.Outer == None || CardDelta.Outer.IsA('Class'))
        {
            continue;
        }

        CardDeltaList[Count] = CardDelta;
        Count++;
    }
    CardDeltaList.Length = Count;
    
    Count = 0;
    CardFlagList.Length = 80;
    foreach AllObjects(class'CardFlag', CardFlag)
    {
        if (CardFlag.Outer == None || CardFlag.Outer.IsA('Class'))
        {
            continue;
        }

        CardFlagList[Count] = CardFlag;
        Count++;
    }
    CardFlagList.Length = Count;
    StopWatch(true);
    log("... collection of"@CardModifierList.Length@"modifiers,"@CardDeltaList.Length@"deltas and"@CardFlagList.Length@"flags complete!", 'KFTurboCardGame');
}

function ModifyPlayer(Pawn Pawn)
{
    
}

function OnWaveStart(int StartedWave)
{
    switch (StartedWave)
    {
        case 0:
            ModifyWaveSize(0.2f);
            GrantExtraWaveReward(200);
            break;
        case 1:
            ModifyWaveSize(0.25f);
            GrantExtraWaveReward(150);
            break;
        case 2:
            ModifyWaveSize(0.3f);
            GrantExtraWaveReward(100);
            break;
        case 3:
            ModifyWaveSize(0.4f);
            GrantExtraWaveReward(50);
            break;
        case 4:
            ModifyWaveSize(0.5f);
            break;
        case 5:
            ModifyWaveSize(0.6f);
            break;
        case 6:
            ModifyWaveSize(0.7f);
            break;
        case 7:
            ModifyWaveSize(0.8f);
            break;
        case 8:
            ModifyWaveSize(0.9f);
            break;
    }

}

final function ModifyWaveSize(float Multiplier)
{
    TurboGameType.TotalMaxMonsters = Max(float(TurboGameType.TotalMaxMonsters) * Multiplier, 10);
    KFGameReplicationInfo(TurboGameType.GameReplicationInfo).MaxMonsters = TurboGameType.TotalMaxMonsters;
}

final function GrantExtraWaveReward(int RewardAmount)
{
    local Controller Controller;
    local TeamInfo Team;
    local int NumPlayers;

    NumPlayers = 0;
    for (Controller = Level.ControllerList; Controller != none; Controller = Controller.NextController )
	{
        if (!Controller.bIsPlayer || Controller.Pawn == None)
        {
            continue;
        }

        NumPlayers++;
		
        if (Team == None && Controller.PlayerReplicationInfo != None && Controller.PlayerReplicationInfo.Team != None)
		{
			Team = Controller.PlayerReplicationInfo.Team;
		}
	}
    
    if (Team == None || NumPlayers == 0)
    {
        return;
    }

    Team.Score += int(float(RewardAmount) * (1.f + (float(NumPlayers - 1) * 0.75f)));
}

function OnWaveEnd(int EndedWave)
{
    CardGameRules.MarkedForDeathPawn = None;
}

function OnNextSpawnSquadGenerated(out array < class<KFMonster> > NextSpawnSquad)
{

}

final function AttemptUpgradeMonster(out class<KFMonster> Monster)
{
    local PawnHelper.EMonsterTier MonsterTier;
    MonsterTier = class'PawnHelper'.static.GetMonsterTier(Monster);

    if (MonsterTier == Elite)
    {
        return;
    }

    Monster = UpgradeReplacementList[int(MonsterTier)].ReplacementClassList[Rand(UpgradeReplacementList[int(MonsterTier)].ReplacementClassList.Length)];
}

final function AttemptReplaceWeakMonster(out class<KFMonster> Monster)
{
    local int ReplacementIndex;
    for (ReplacementIndex = 0; ReplacementIndex < WeakReplacementList.Length; ReplacementIndex++)
    {
        if (ClassIsChildOf(Monster, WeakReplacementList[ReplacementIndex].TargetParentClass))
        {
            Monster = WeakReplacementList[ReplacementIndex].ReplacementClass;
            return;
        }
    }
}

final function PotentiallyDoubleHuskSpawn(out array < class<KFMonster> > NextSpawnSquad)
{
    local int Index;
    local int HuskCount;
    HuskCount = 0;

    for (Index = NextSpawnSquad.Length - 1; Index >= 0; Index--)
    {
        if (class<P_Husk>(NextSpawnSquad[Index]) != None)
        {
            HuskCount++;
        }
    }

    while (HuskCount > 0)
    {
        HuskCount--;

        if (FRand() < 0.5f)
        {
            NextSpawnSquad.Length = NextSpawnSquad.Length + 1;
            NextSpawnSquad[NextSpawnSquad.Length - 1] = class'P_Husk_STA';
        }
    }
}

function GrantAllPlayersDosh(int Amount)
{   
	local Controller Controller;

    for ( Controller = TurboGameType.Level.ControllerList; Controller != None; Controller = Controller.NextController )
    {
        if (Controller.Pawn != None && Controller.Pawn.Health > 0 && PlayerController(Controller) != None)
        {
            Controller.PlayerReplicationInfo.Score += Amount;

            if(PlayerController(Controller) != none)
            {
                PlayerController(Controller).ClientPlaySound(class'CashPickup'.default.PickupSound);
                PlayerController(Controller).ReceiveLocalizedMessage(class 'Msg_CashReward', Amount);
            }
        }
    }
}

function GrantAllPlayersArmor()
{
	local Controller Controller;

    for ( Controller = TurboGameType.Level.ControllerList; Controller != None; Controller = Controller.NextController )
    {
        if (Controller.Pawn != None && Controller.Pawn.Health > 0 && PlayerController(Controller) != None && Controller.Pawn.ShieldStrength < 100.f)
        {
            PlayerController(Controller).ClientPlaySound(Sound'KF_InventorySnd.Vest_Pickup');
            Controller.Pawn.ShieldStrength = 100.f;
        }
    }
}

function GrantRandomSuperCard()
{
    CardReplicationInfo.ActivateRandomSuperCard();
}

function GrantRandomEvilCard()
{
    CardReplicationInfo.ActivateRandomEvilCard();
}

function GrantRandomCard()
{
    CardReplicationInfo.ActivateRandomCard();
}

function RemoveRandomSuperCard()
{
    CardReplicationInfo.DeactivateRandomSuperCard();
}

function RemoveRandomEvilCard()
{
    CardReplicationInfo.DeactivateRandomEvilCard();
}

function ResetDecksAndReRollCards(optional TurboCard TopCard)
{
    CardReplicationInfo.ResetDecksAndReRollCards(TopCard);
}

function DeactivateAllGoodCards()
{
    CardReplicationInfo.DeactivateAllGoodCards();
}

function MultiplyPlayerCash(float Multiplier)
{
	local Controller Controller;

    for (Controller = TurboGameType.Level.ControllerList; Controller != None; Controller = Controller.NextController)
    {
        if (Controller.Pawn != None && PlayerController(Controller) != None && Controller.PlayerReplicationInfo != None)
        {
            Controller.PlayerReplicationInfo.Score = int(Controller.PlayerReplicationInfo.Score * Multiplier);
        }
    }
}

function MarkPlayerForDeath()
{
    local TurboHumanPawn HumanPawn;
    local array<TurboHumanPawn> HumanPawnList;

    HumanPawnList = class'TurboGameplayHelper'.static.GetPlayerPawnList(Level);

    if (HumanPawnList.Length == 0)
    {
        return;
    }

    HumanPawn = HumanPawnList[Rand(HumanPawnList.Length)];

    if (HumanPawn == None || HumanPawn.bDeleteMe || HumanPawn.Health <= 0 || KFWeapon(HumanPawn.Weapon) == None)
    {
        return;
    }

    CardGameRules.MarkedForDeathPawn = HumanPawn;
    TurboGameType.Level.BroadcastLocalizedMessage(class'MarkedForDeathLocalMessage', 0, HumanPawn.PlayerReplicationInfo);
}

defaultproperties
{
    WeakReplacementList(0)=(TargetParentClass=class'P_Clot',ReplacementClass=class'P_Clot_Weak')
    WeakReplacementList(1)=(TargetParentClass=class'P_Gorefast',ReplacementClass=class'P_Gorefast_Weak')
    WeakReplacementList(2)=(TargetParentClass=class'P_Crawler',ReplacementClass=class'P_Crawler_Weak')
    WeakReplacementList(3)=(TargetParentClass=class'P_Stalker',ReplacementClass=class'P_Stalker_Weak')
    WeakReplacementList(4)=(TargetParentClass=class'P_Bloat',ReplacementClass=class'P_Bloat_Weak')
    WeakReplacementList(5)=(TargetParentClass=class'P_Husk',ReplacementClass=class'P_Husk_Weak')
    WeakReplacementList(6)=(TargetParentClass=class'P_Siren',ReplacementClass=class'P_Siren_Weak')
    WeakReplacementList(7)=(TargetParentClass=class'P_Scrake',ReplacementClass=class'P_Scrake_Weak')
    WeakReplacementList(8)=(TargetParentClass=class'P_Fleshpound',ReplacementClass=class'P_Fleshpound_Weak')

    UpgradeReplacementList(0)=(ReplacementClassList=(class'P_Bloat_STA',class'P_Husk_STA',class'P_Siren_STA'))
    UpgradeReplacementList(1)=(ReplacementClassList=(class'P_Scrake_STA',class'P_Fleshpound_STA'))
}