//Killing Floor Turbo TurboGameReplicationInfo
//KFTurbo's GRI. Hooks up CustomTurboModifier, CustomTurboClientModifier, and voting systems.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameReplicationInfo extends KFGameReplicationInfo
    dependson(TurboGameVoteBase);

var class<TurboServerTimeActor> ServerTimeActorClass;
var TurboServerTimeActor ServerTimeActor;

var TurboGameModifierReplicationLink CustomTurboModifier;
var TurboClientModifierReplicationLink CustomTurboClientModifier;

var TurboGameVoteBase VoteInstance; //Current active vote.
var array< class<TurboGameVoteBase> > VoteClassList; //List of all valid votes a player can initiate. Does not replicate.
delegate OnVoteInstanceStateChanged(TurboGameVoteBase VoteInstance, TurboGameVoteBase.EVotingState NewState);
delegate OnVoteInstanceTallyChanged(TurboGameVoteBase VoteInstance, int NewYesVoteCount, int NewNoVoteCount);

replication
{
    reliable if(Role == ROLE_Authority)
        CustomTurboModifier, CustomTurboClientModifier;
}

simulated function PostBeginPlay()
{
    if (Role == ROLE_Authority && ServerTimeActor == None)
    {
        if (ServerTimeActorClass == None)
        {
            ServerTimeActorClass = class'TurboServerTimeActor';
        }

        ServerTimeActor = Spawn(ServerTimeActorClass, Self);
    }

    Super.PostBeginPlay();
}

function PlayerVote(TurboPlayerReplicationInfo Voter, string VoteString)
{
    local int Index;
    local class<TurboGameVoteBase> VoteClass;
    local TurboGameVoteBase NewVoteInstance;
    local string VoteID, VoteValue;

    if (VoteInstance != None)
    {
        VoteInstance.PlayerVote(Voter, VoteString);
        return;
    }

    if (VoteString == "" || VoteString == "YES" || VoteString == "NO")
    {
        return;
    }

    if (Divide(VoteString, " ", VoteID, VoteValue))
    {
        VoteID = Caps(VoteID);
    }
    else
    {
        VoteID = Caps(VoteString);
    }

    for (Index = VoteClassList.Length - 1; Index >= 0; Index--)
    {
        if (VoteClassList[Index].static.GetVoteID() != VoteID)
        {
            continue;
        }

        VoteClass = VoteClassList[Index];
        break;
    }

    if (VoteClass == None || !VoteClass.static.CanInitiateVote(Self, Voter, VoteString))
    {
        return;
    }

    NewVoteInstance = Spawn(VoteClass, Self);

    if (NewVoteInstance != None)
    {
        NewVoteInstance.InitiateVote(Voter, VoteString);

        //Votes can instantly complete in some circumstances.
        if (NewVoteInstance != None && NewVoteInstance.GetVoteState() < Expired)
        {
            RegisterVoteInstance(NewVoteInstance);
        }
    }
}

function RevokePlayerVote(TurboPlayerReplicationInfo Voter)
{
    if (Voter == None || VoteInstance == None)
    {
        return;
    }

    VoteInstance.RevokePlayerVote(Voter);
}

function PlayerVoteComplete(TurboGameVoteBase CompletedVoteInstance, TurboGameVoteBase.EVotingState VoteState)
{
    local TurboPlayerController PlayerController;

    if (VoteState == Failed && CompletedVoteInstance != None && CompletedVoteInstance.GetVoteInitiator() != None)
    {
        PlayerController = TurboPlayerController(CompletedVoteInstance.GetVoteInitiator().Owner);

        if (PlayerController != None)
        {
            PlayerController.NextStartVoteTime = Level.TimeSeconds + CompletedVoteInstance.GetPlayerStartVoteCooldown(PlayerController);
        }
    }

    if (CompletedVoteInstance == VoteInstance)
    {
        VoteInstance = None;
    }
}

//Passthrough delegates for UI.
simulated function RegisterVoteInstance(TurboGameVoteBase NewVoteInstance)
{
    VoteInstance = NewVoteInstance;
    VoteInstance.OnVoteStateChanged = OnVoteInstanceStateUpdate;
    VoteInstance.OnVoteTallyChanged = OnVoteInstanceTallyUpdate;
}

simulated function OnVoteInstanceStateUpdate(TurboGameVoteBase VoteInstance, TurboGameVoteBase.EVotingState NewState)
{
    OnVoteInstanceStateChanged(VoteInstance, NewState);
}

simulated function OnVoteInstanceTallyUpdate(TurboGameVoteBase VoteInstance, int NewYesVoteCount, int NewNoVoteCount)
{
    OnVoteInstanceTallyChanged(VoteInstance, NewYesVoteCount, NewNoVoteCount);
}

//Reminder that if you override these simulated functions, they must return the same value on the client and server.
simulated function float GetFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetFireRateMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetBerserkerFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetBerserkerFireRateMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetFirebugFireRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetFirebugFireRateMultiplier(KFPRI, Other); } return 1.f; }

simulated function float GetReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetReloadRateMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetCommandoReloadRateMultiplier(KFPlayerReplicationInfo KFPRI, Weapon Other) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetCommandoReloadRateMultiplier(KFPRI, Other); } return 1.f; }

simulated function float GetMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetMagazineAmmoMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetCommandoMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetCommandoMagazineAmmoMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetMedicMagazineAmmoMultiplier(KFPlayerReplicationInfo KFPRI, KFWeapon Other) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetMedicMagazineAmmoMultiplier(KFPRI, Other); } return 1.f; }

simulated function float GetMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetMaxAmmoMultiplier(KFPRI, AmmoType); } return 1.f; }
simulated function float GetCommandoMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetCommandoMaxAmmoMultiplier(KFPRI, AmmoType); } return 1.f; }
simulated function float GetMedicMaxAmmoMultiplier(KFPlayerReplicationInfo KFPRI, class<Ammunition> AmmoType) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetMedicMaxAmmoMultiplier(KFPRI, AmmoType); } return 1.f; }

simulated function float GetWeaponPenetrationMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetWeaponPenetrationMultiplier(KFPRI, Other); } return 1.f; }
simulated function float GetWeaponSpreadRecoilMultiplier(KFPlayerReplicationInfo KFPRI, WeaponFire Other) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetWeaponSpreadRecoilMultiplier(KFPRI, Other); } return 1.f; }

simulated function GetTraderCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item, out float Multiplier) { if (CustomTurboModifier != None) { CustomTurboModifier.GetTraderCostMultiplier(KFPRI, Item, Multiplier); } }
simulated function float GetTraderGrenadeCostMultiplier(KFPlayerReplicationInfo KFPRI, class<Pickup> Item) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetTraderGrenadeCostMultiplier(KFPRI, Item); } return 1.f; }

simulated function float GetPlayerMovementSpeedMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetPlayerMovementSpeedMultiplier(KFPRI, KFGRI); } return 1.f; }
simulated function float GetPlayerMovementAccelMultiplier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetPlayerMovementAccelMultiplier(KFPRI, KFGRI); } return 1.f; }
simulated function float GetPlayerMaxHealthMultiplier(Pawn Pawn) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetPlayerMaxHealthMultiplier(Pawn); } return 1.f; }

simulated function float GetHealRechargeMultiplier(KFPlayerReplicationInfo KFPRI) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetHealRechargeMultiplier(KFPRI); } return 1.f; }

//Functions from here onward are not simulated - no need to replicate the outcome.
function GetPlayerCarryWeightModifier(KFPlayerReplicationInfo KFPRI, out int OutCarryWeightModifier) { if (CustomTurboModifier != None) { CustomTurboModifier.GetPlayerCarryWeightModifier(KFPRI, OutCarryWeightModifier); } }
function GetPlayerZedExtensionModifier(KFPlayerReplicationInfo KFPRI, out int OutZedExtensions) { if (CustomTurboModifier != None) { CustomTurboModifier.GetPlayerZedExtensionModifier(KFPRI, OutZedExtensions); } }
function float GetHeadshotDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetHeadshotDamageMultiplier(KFPRI, Pawn, DamageType); } return 1.f; }
function float GetHealPotencyMultiplier(KFPlayerReplicationInfo KFPRI) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetHealPotencyMultiplier(KFPRI); } return 1.f; }
function float GetWeldSpeedModifier(KFPlayerReplicationInfo KFPRI) { if (CustomTurboModifier != None) { return CustomTurboModifier.GetWeldSpeedModifier(KFPRI); } return 1.f; }
function GetBodyArmorDamageModifier(KFPlayerReplicationInfo KFPRI, out float Multiplier) { if (CustomTurboModifier != None) { CustomTurboModifier.GetBodyArmorDamageModifier(KFPRI, Multiplier); } }

function OnWeaponFire(WeaponFire WeaponFire)
{
    if (CustomTurboModifier != None)
    {
        CustomTurboModifier.OnWeaponFire(WeaponFire);
    }
}

function OnShotgunFire(KFShotgunFire ShotgunFire)
{
    if (CustomTurboModifier != None)
    {
        CustomTurboModifier.OnShotgunFire(ShotgunFire);
    }
}

function OnMeleeFire(KFMeleeFire MeleeFire)
{
    if (CustomTurboModifier != None)
    {
        CustomTurboModifier.OnMeleeFire(MeleeFire);
    }
}

function OnMedicDartFire(WeaponFire WeaponFire)
{
    if (CustomTurboModifier != None)
    {
        CustomTurboModifier.OnMedicDartFire(WeaponFire);
    }
}

//Helpers TurboGameModifierReplicationLinks can call to propagate updates for multiplier changes.
function NotifyPlayerMovementSpeedChanged()
{
    local Controller Controller;
    for ( Controller = Level.ControllerList; Controller != None; Controller = Controller.NextController )
    {
        if (Controller.Pawn != None && Controller.Pawn.Health > 0 && PlayerController(Controller) != None)
        {
            Controller.Pawn.ModifyVelocity(0.f, Controller.Pawn.Velocity);
            Controller.Pawn.AccelRate = FMax(0.f, Controller.Pawn.default.AccelRate * GetPlayerMovementAccelMultiplier(KFPlayerReplicationInfo(Controller.PlayerReplicationInfo), Self));
        }
    }
}

function NotifyPlayerMaxHealthChanged()
{
    local Controller Controller;
    for ( Controller = Level.ControllerList; Controller != None; Controller = Controller.NextController )
    {
        if (Controller.Pawn != None && Controller.Pawn.Health > 0 && PlayerController(Controller) != None)
        {
            Controller.Pawn.HealthMax = FMax(Round(Controller.Pawn.default.HealthMax * GetPlayerMaxHealthMultiplier(Controller.Pawn)), 1.f);
            Controller.Pawn.Health = Min(Controller.Pawn.Health, Controller.Pawn.HealthMax);
        }
    }
}

function NotifyPlayerCarryWeightChanged()
{
    local Controller Controller;
    for ( Controller = Level.ControllerList; Controller != None; Controller = Controller.NextController )
    {
        if (Controller.Pawn != None && Controller.Pawn.Health > 0 && KFHumanPawn(Controller.Pawn) != None)
        {
            KFHumanPawn(Controller.Pawn).VeterancyChanged();
        }
    }
}

//Client-side modification.
simulated function ModifyMonster(KFMonster Monster) { if (CustomTurboClientModifier != None) { CustomTurboClientModifier.ModifyMonster(Monster); } }
simulated function OnWeaponChange(KFWeapon CurrentWeapon, KFWeapon PendingWeapon) { if (CustomTurboClientModifier != None) { CustomTurboClientModifier.OnWeaponChange(CurrentWeapon, PendingWeapon); } }

//Make NetUpdateTime want to update now.
simulated function ForceNetUpdate()
{
    NetUpdateTime = Max(Level.TimeSeconds - ((1.f / NetUpdateFrequency) + 1.f), 0.1f);
}

defaultproperties
{
    VoteClassList(0)=class'TurboGameVoteEndTrader'
    VoteClassList(1)=class'TurboGameVoteSpawnRate'
    VoteClassList(2)=class'TurboGameVoteMaxMonsters'
    VoteClassList(3)=class'TurboGameVoteFakedPlayers'
    VoteClassList(4)=class'TurboGameVotePlayerHealth'
    VoteClassList(5)=class'TurboGameVoteMonsterSkipWander'
    VoteClassList(6)=class'TurboGameVoteDisableZedTime'
    VoteClassList(7)=class'TurboGameVoteMaxPlayers'
}