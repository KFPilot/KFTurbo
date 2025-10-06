//Killing Floor Turbo TurboStatsGameRules
//Responsible for managing stat collectors/replications and broadcasting events related to kills/damage.
//Needs to be at the front of the GameRules list so it can make sure all rules have gone first.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboStatsGameRules extends TurboGameRules
	config(KFTurbo);

//Used during spin up state.
var bool bGeneratingStatCollectors;
var array<TurboHumanPawn> PawnList;
var int PawnListIndex;

//Used during spin down state.
var bool bReplicatingStatCollectors;
var array<TurboPlayerController> ControllerList;
var int ControllerListIndex;

var KFTurboGameType TurboGameType;
var TurboGameReplicationInfo TurboGRI;
var KFTurboMut Mutator;
var TurboPlayerEventHandler PlayerStatsHandler;
var TurboHealEventHandler HealStatsHandler;

//Turns on collector/replicator system.
var globalconfig string WaveStatCollectorClassOverride;
var class<TurboWavePlayerStatCollector> WaveStatCollectorClass;

static final function TurboWavePlayerStatCollector GetPlayerWaveStats(TurboPlayerController Player)
{
    if (Player == None)
    {
        return None;
    }

    return TurboWavePlayerStatCollector(class'TurboWavePlayerStatCollector'.static.FindStats(TurboPlayerReplicationInfo(Player.PlayerReplicationInfo)));
}

function PostBeginPlay()
{
    Super.PostBeginPlay();

    TurboGameType = KFTurboGameType(Level.Game);
    TurboGRI = TurboGameReplicationInfo(Level.GRI);
    Mutator = KFTurboMut(Owner);
    
    PlayerStatsHandler = TurboPlayerEventHandler(class'TurboPlayerEventHandler'.static.CreateHandler(Self));
    PlayerStatsHandler.OnPlayerFire = OnPlayerFire;
    PlayerStatsHandler.OnPlayerMeleeFire = OnPlayerMeleeFire;
    PlayerStatsHandler.OnPlayerFireHit = OnPlayerFireHit;
    PlayerStatsHandler.OnPlayerReload = OnPlayerReload;
    PlayerStatsHandler.OnPlayerDamagedMonster = OnPlayerDamagedMonster;
    PlayerStatsHandler.OnPlayerReceivedDamage = OnPlayerReceivedDamage;
    PlayerStatsHandler.OnPlayerKilledMonster = OnPlayerKilledMonster;
    PlayerStatsHandler.OnPlayerDied = OnPlayerDied;
    
    HealStatsHandler = TurboHealEventHandler(class'TurboHealEventHandler'.static.CreateHandler(Self));
    HealStatsHandler.OnPawnDartHealed = OnPawnDartHealed;
    HealStatsHandler.OnPawnSyringeHealed = IncrementHealStats;
    HealStatsHandler.OnPawnGrenadeHealed = IncrementHealStats;

    if (WaveStatCollectorClassOverride != "")
    {
        WaveStatCollectorClass = class<TurboWavePlayerStatCollector>(DynamicLoadObject(WaveStatCollectorClassOverride, class'class'));
    }

    if (WaveStatCollectorClass == None)
    {
        WaveStatCollectorClass = class'TurboWavePlayerStatCollector';
    }
}

function int NetDamage(int OriginalDamage, int Damage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    Damage = Super.NetDamage(OriginalDamage, Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);

    if (Damage == 0)
    {
        return 0;
    }

    if (InstigatedBy != None && KFMonster(Injured) != None)
    {
        class'TurboPlayerEventHandler'.static.BroadcastPlayerDamagedMonster(InstigatedBy.Controller, KFMonster(Injured), Damage);
    }

    if (Injured != None && Injured.Controller != None && Injured.Controller.bIsPlayer)
    {
        class'TurboPlayerEventHandler'.static.BroadcastPlayerReceivedDamage(Injured.Controller, KFMonster(InstigatedBy), Damage, DamageType);
    }

    return Damage;
}

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType)
{
    Super.Killed(Killer, Killed, KilledPawn, DamageType);

    if (KFMonster(KilledPawn) != None)
    {
        class'TurboPlayerEventHandler'.static.BroadcastPlayerKilledMonster(Killer, KFMonster(KilledPawn), DamageType);
    }

    if (TurboPlayerController(Killed) != None)
    {
        class'TurboPlayerEventHandler'.static.BroadcastPlayerDied(TurboPlayerController(Killed), Killer, DamageType);
    }
}

final function OnPlayerFire(TurboPlayerController Player, WeaponFire FireMode)
{
    local TurboWavePlayerStatCollector WavePlayerStatCollector;
    WavePlayerStatCollector = GetPlayerWaveStats(Player);

    if (WavePlayerStatCollector == None)
    {
        return;
    }

    if (W_Frag_Fire(FireMode) != None)
    {
        return;
    }

    WavePlayerStatCollector.IncrementShotsFired();
}

final function OnPlayerFireHit(TurboPlayerController Player, WeaponFire FireMode, KFMonster HitMonster, class<KFMonster> MonsterClass, bool bHeadshot, int Damage)
{
    local TurboWavePlayerStatCollector WavePlayerStatCollector;
    WavePlayerStatCollector = GetPlayerWaveStats(Player);

    if (WavePlayerStatCollector == None)
    {
        return;
    }

    WavePlayerStatCollector.IncrementShotsHit(bHeadShot);
}

final function OnPlayerMeleeFire(TurboPlayerController Player, CoreMeleeWeaponFire FireMode)
{
    local TurboWavePlayerStatCollector WavePlayerStatCollector;
    WavePlayerStatCollector = GetPlayerWaveStats(Player);

    if (WavePlayerStatCollector == None)
    {
        return;
    }

    WavePlayerStatCollector.IncrementMeleeSwings();
}

final function OnPlayerReload(TurboPlayerController Player, KFWeapon Weapon)
{
    local TurboWavePlayerStatCollector WavePlayerStatCollector;
    WavePlayerStatCollector = GetPlayerWaveStats(Player);
    
    if (WavePlayerStatCollector == None)
    {
        return;
    }

    WavePlayerStatCollector.IncrementReloads();
}

final function OnPlayerDamagedMonster(TurboPlayerController Player, KFMonster Target, int Damage)
{
    local TurboWavePlayerStatCollector WavePlayerStatCollector;
    WavePlayerStatCollector = GetPlayerWaveStats(Player);

    if (WavePlayerStatCollector == None)
    {
        return;
    }

    WavePlayerStatCollector.IncrementDamageDone(Damage, Target.Class);
}

final function OnPlayerKilledMonster(TurboPlayerController Player, KFMonster Target, class<DamageType> DamageType)
{
    local TurboWavePlayerStatCollector WavePlayerStatCollector;
    WavePlayerStatCollector = GetPlayerWaveStats(Player);

    if (WavePlayerStatCollector == None)
    {
        return;
    }

    WavePlayerStatCollector.IncrementKills(Target.Class);
}

final function OnPlayerReceivedDamage(TurboPlayerController Player, KFMonster Instigator, int Damage, class<DamageType> DamageType)
{
    local TurboWavePlayerStatCollector WavePlayerStatCollector;
    WavePlayerStatCollector = GetPlayerWaveStats(Player);

    if (WavePlayerStatCollector == None)
    {
        return;
    }

    WavePlayerStatCollector.IncrementDamageTaken(Damage);
}

final function OnPlayerDied(TurboPlayerController Player, Controller Killer, class<DamageType> DamageType)
{
    local TurboWavePlayerStatCollector WavePlayerStatCollector;
    WavePlayerStatCollector = GetPlayerWaveStats(Player);

    if (WavePlayerStatCollector == None)
    {
        return;
    }

    WavePlayerStatCollector.OnDied(Killer, DamageType);
}

final function OnPawnDartHealed(Pawn Instigator, Pawn Target, int HealingAmount, HealingProjectile HealDart)
{
    IncrementHealStats(Instigator, Target, HealingAmount);
}

final function IncrementHealStats(Pawn Instigator, Pawn Target, int HealingAmount)
{
    local TurboWavePlayerStatCollector StatCollector;
    
    if (HealingAmount <= 0)
    {
        return;
    }

    if (Instigator == None || Instigator == Target)
    {
        return;
    }

    StatCollector = GetPlayerWaveStats(TurboPlayerController(Instigator.Controller));

    if (StatCollector == None)
    {
        return;
    }

    StatCollector.IncrementHealthHealed(HealingAmount);
}

//Does initial kick-off.
function Tick(float DeltaTime)
{
    if (class'KFTurboGameType'.static.StaticIsTestGameType(Self))
    {
        Disable('Tick');
        return;
    }

    if (TurboGRI == None)
    {
        TurboGRI = TurboGameReplicationInfo(Level.GRI);
        
        if (TurboGRI == None)
        {
            return;
        }
    }
    
    if (!TurboGameType.bWaveInProgress)
    {
        return;
    }

    GotoState('WaveStart');
}

state WaveStart
{
    function Tick(float DeltaTime)
    {
        if (bGeneratingStatCollectors)
        {
            return;
        }
        
        if (TurboGRI.EndGameType != 0)
        {
            GotoState('GameEnd');
            return;
        }

        if (TurboGameType.bWaveInProgress)
        {
            return;
        }

        GotoState('WaveEnd');
    }

Begin:
    bGeneratingStatCollectors = true;
    PawnList = class'TurboGameplayHelper'.static.GetPlayerPawnList(Level);
    for (PawnListIndex = 0; PawnListIndex < PawnList.Length; PawnListIndex++)
    {
        Sleep(0.1f);
        CreateStatCollector(PawnList[PawnListIndex]);
    }
    bGeneratingStatCollectors = false;
}

state WaveEnd
{
    function Tick(float DeltaTime)
    {
        if (bReplicatingStatCollectors)
        {
            return;
        }

        if (TurboGRI.EndGameType != 0)
        {
            GotoState('GameEnd');
            return;
        }

        if (!TurboGameType.bWaveInProgress)
        {
            return;
        }

        GotoState('WaveStart');
    }

Begin:
    bReplicatingStatCollectors = true;
    ControllerList = class'TurboGameplayHelper'.static.GetPlayerControllerList(Level);
    for (ControllerListIndex = 0; ControllerListIndex < ControllerList.Length; ControllerListIndex++)
    {
        Sleep(0.1f);
        ReplicateStatCollector(ControllerList[ControllerListIndex]);
    }
    bReplicatingStatCollectors = false;
}

//Game ends. We do a last attempt to replicate stat collectors, wave end event (if we didn't manage to complete the wave), and then finally a game end event.
state GameEnd
{
    function Tick(float DeltaTime) {} //No more ticking. This is our last state.

Begin:
    bReplicatingStatCollectors = true;
    ControllerList = class'TurboGameplayHelper'.static.GetPlayerControllerList(Level);
    for (ControllerListIndex = 0; ControllerListIndex < ControllerList.Length; ControllerListIndex++)
    {
        Sleep(0.1f);
        ReplicateStatCollector(ControllerList[ControllerListIndex]);
    }
    bReplicatingStatCollectors = false;

    if (TurboGameType.bWaveInProgress)
    {
        Sleep(0.1f);
        SendWaveEnd();
    }

    Sleep(0.1f);
    SendEndGameStats();
}

function CreateStatCollector(TurboHumanPawn Pawn)
{
    if (Pawn == None || Pawn.Health <= 0 || Pawn.PlayerReplicationInfo == None || Pawn.PlayerReplicationInfo.bOnlySpectator || Pawn.PlayerReplicationInfo.bBot)
    {
        return;
    }

    Spawn(WaveStatCollectorClass, Pawn.PlayerReplicationInfo);
}

function ReplicateStatCollector(TurboPlayerController Controller)
{
    local TurboPlayerStatCollectorBase StatsCollector;
    StatsCollector = class'TurboWavePlayerStatCollector'.static.FindStats(TurboPlayerReplicationInfo(Controller.PlayerReplicationInfo));

    if (StatsCollector == None)
    {
        return;
    }
    
    if (Mutator != None && Mutator.StatsTcpLink != None)
    {
        Mutator.StatsTcpLink.SendWaveStats(TurboWavePlayerStatCollector(StatsCollector));
    }

    StatsCollector.ReplicateStats();
}

function SendWaveEnd()
{
    if (Mutator != None && Mutator.StatsTcpLink != None)
    {
        Mutator.StatsTcpLink.SendWaveEnd();
    }
}

function SendEndGameStats()
{
    if (Mutator != None && Mutator.StatsTcpLink != None)
    {
        Mutator.StatsTcpLink.SendGameEnd(TurboGRI.EndGameType);
    }
}

defaultproperties
{
    
}