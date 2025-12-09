//Common Core CoreKFGameType
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/CommonCore.
class CoreKFGameType extends KFMod.KFGameType
    abstract;

//MapConfigurationObject associated with the current map.
var MapConfigurationObject MapConfigurationObject;

//Whatever spawn rate is set as, make sure it gets multiplied by these.
var float GameWaveSpawnRateModifier, MapWaveSpawnRateModifier, AdminSpawnRateModifier;
//Whatever max monsters is set as, make sure it gets multiplied by these.
var float GameMaxMonstersModifier, MapMaxMonstersModifier, AdminMaxMonstersModifier;
//Whatever total monsters is set as, make sure it gets multiplied by this.
var float GameTotalMonstersModifier;
//Whatever trader time is set as, make sure it gets multiplied by this.
var float GameTraderTimeModifier;

//Faked player count. Used to make wave size larger.
var protected int FakedPlayerCount;
//Forced player health count. Used to scale up monster health.
var protected int ForcedPlayerHealthCount; 
//Allows for zed time to be disabled.
var protected bool bZedTimeEnabled; 

function InitGame(string Options, out string Error)
{
    InitializeMapConfigurationObject();
    
    Super.InitGame(Options, Error);
}

function InitializeMapConfigurationObject()
{
    local string MapName;
    local ZombieVolume ZombieVolume;

    MapName = Locs(GetCurrentMapName(Level));

    MapConfigurationObject = new(None, MapName) class'MapConfigurationObject';

    if (MapConfigurationObject != None && MapConfigurationObject.MapNameRedirect != "")
    {
        MapConfigurationObject = new(None, Locs(MapConfigurationObject.MapNameRedirect)) class'MapConfigurationObject';
    }

    if (MapConfigurationObject == None || MapConfigurationObject.bDisabled)
    {
        return;
    }

    log("Loaded MapConfigurationObject for level"@MapName$". Applying modifiers now...", 'CommonCoreMapConfig');

    log("| Spawn Rate Modifier:"@MapWaveSpawnRateModifier@"| Max Monsters Modifier:"@MapMaxMonstersModifier, 'CommonCoreMapConfig');
    MapWaveSpawnRateModifier = MapConfigurationObject.WaveSpawnRateMultiplier;
    MapMaxMonstersModifier = MapConfigurationObject.WaveMaxMonstersMultiplier;

    log("| Zombie Volume Respawn Modifier:"@MapConfigurationObject.ZombieVolumeCanRespawnTimeMultiplier@"| Zombie Volume Min Player Distance Modifier:"@MapConfigurationObject.ZombieVolumeMinDistanceToPlayerMultiplier, 'CommonCoreMapConfig');
    foreach DynamicActors(class'ZombieVolume', ZombieVolume)
    {
        ZombieVolume.CanRespawnTime *= MapConfigurationObject.ZombieVolumeCanRespawnTimeMultiplier;
        ZombieVolume.MinDistanceToPlayer *= MapConfigurationObject.ZombieVolumeMinDistanceToPlayerMultiplier;
    }
}

function PlayerController Login(string Portal, string Options, out string Error)
{
    local PlayerController PlayerController;

    PlayerController = Super.Login(Portal, Options, Error);

    if (PlayerController == None)
    {
        return None;
    }

    if (PlayerController.PlayerReplicationInfo.bOnlySpectator && bWaveInProgress)
    {
        CorePlayerController(PlayerController).MarkSpectatingWave();
    }

    return PlayerController;
}

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType)
{
    local GameRules GameRules;
    local CoreGameRules CoreGameRules;

    Super.Killed(Killer, Killed, KilledPawn, DamageType);

    GameRules = GameRulesModifiers;

    //Find the first CoreGameRules in the chain and start the event flow.
    while (GameRules != None)
    {
        CoreGameRules = CoreGameRules(GameRules);

        if (CoreGameRules != None)
        {
            break;
        }

        GameRules = GameRules.NextGameRules;
    }

    if (CoreGameRules != None)
    {
        CoreGameRules.Killed(Killer, Killed, KilledPawn, DamageType);
    }
}

state MatchInProgress
{
	function float CalcNextSquadSpawnTime()
	{
		return Super.CalcNextSquadSpawnTime() / (GameWaveSpawnRateModifier * MapWaveSpawnRateModifier * AdminSpawnRateModifier);
	}

	function DoWaveEnd()
	{
		Super.DoWaveEnd();

        if (GameTraderTimeModifier != 1.f)
        {
            WaveCountDown = float(WaveCountDown) * GameTraderTimeModifier;
            KFGameReplicationInfo(GameReplicationInfo).TimeToNextWave = WaveCountDown;
        }

        InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum; //Update wave number sooner.
	}
}

function int CalculateTotalMaxMonsters()
{
    local int NewTotalMaxMonsters;
    local float Modifier;
    NewTotalMaxMonsters = Waves[WaveNum].WaveMaxMonsters;
    Modifier = 1.f;

    if (GameDifficulty >= 7.0)
    {
        Modifier *= 1.7f;
    }
    else if (GameDifficulty >= 5.0)
    {
        Modifier *= 1.5f;
    }
    else if (GameDifficulty >= 4.0)
    {
        Modifier *= 1.3f;
    }
    else if (GameDifficulty >= 2.0)
    {
        Modifier *= 1.f;
    }
    else
    {
        Modifier *= 0.7f;
    }

    switch (GetMaxMonsterPlayerCount())
    {
        case 1:
            Modifier *= 1.f;
            break;
        case 2:
            Modifier *= 2.f;
            break;
        case 3:
            Modifier *= 2.75f;
            break;
        case 4:
            Modifier *= 3.5f;
            break;
        case 5:
            Modifier *= 4.f;
            break;
        case 6:
            Modifier *= 4.5f;
            break;
        default:
            Modifier *= float(GetMaxMonsterPlayerCount()) * 0.8f;
    }

    return float(NewTotalMaxMonsters) * Modifier * GameTotalMonstersModifier;
}

final function int GetAlivePlayerCount()
{
    local Controller C;
    local int PlayerCount;
    PlayerCount = 0;
	for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if (C.bIsPlayer && C.Pawn!=None && C.Pawn.Health > 0)
        {
            PlayerCount++;
        }
    }

    return PlayerCount;
}

//Player count to use when calculating MaxMonsters. Handles faked players.
final function int GetMaxMonsterPlayerCount()
{
    return NumPlayers + GetFakedPlayerCount();
}

function int SetFakedPlayerCount(int NewFakedPlayerCount)
{
    FakedPlayerCount = Max(NewFakedPlayerCount, 0);
    return FakedPlayerCount;
}

final function int GetFakedPlayerCount()
{
    return FakedPlayerCount;
}

//Player count to use when calculating monster health. Handles forced player monster health.
function int GetMonsterHealthPlayerCount()
{
    return Max(GetAlivePlayerCount(), GetForcedPlayerHealthCount());
}

function int SetForcedPlayerHealthCount(int NewForcedPlayerHealthCount)
{
    NewForcedPlayerHealthCount = Max(NewForcedPlayerHealthCount, 0);
    ForcedPlayerHealthCount = NewForcedPlayerHealthCount;
    return ForcedPlayerHealthCount;
}

final function int GetForcedPlayerHealthCount()
{
    return ForcedPlayerHealthCount;
}

function bool SetZedTimeEnabled(bool bNewZedTimeEnabled)
{
    bZedTimeEnabled = bNewZedTimeEnabled;
    return bZedTimeEnabled;
}

final function bool IsZedTimeEnabled()
{
    return bZedTimeEnabled;
}

function DramaticEvent(float BaseZedTimePossibility, optional float DesiredZedTimeDuration)
{
    if (!IsZedTimeEnabled())
    {
        return;
    }

    Super.DramaticEvent(BaseZedTimePossibility, DesiredZedTimeDuration);
}

function SetupWave()
{
	Super.SetupWave();

    MaxMonsters = float(MaxMonsters) * GameMaxMonstersModifier * MapMaxMonstersModifier * AdminMaxMonstersModifier;

    TotalMaxMonsters = CalculateTotalMaxMonsters();
    KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonsters = TotalMaxMonsters;
	
    DoWaveStartForPlayers();
}

function DoWaveStartForPlayers()
{
    local int Index;
    local PlayerReplicationInfo PRI;

	for (Index = Level.GRI.PRIArray.Length - 1; Index >= 0; Index--)
	{
		PRI = Level.GRI.PRIArray[Index];

        if (PRI == None)
        {
            continue;
        }
        
        if (CorePlayerController(PRI.Owner) != None && PRI.bOnlySpectator)
        {
            CorePlayerController(PRI.Owner).MarkSpectatingWave();
        }
    }
}

//We need to properly route this to DamageType::DeathMessage and DamageType::SuicideMessage because CommonCore wants to route localization back to KFMod's damage types.
function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> DamageType)
{
    if (DamageType == None)
    {
        DamageType = class'DamageType';
    }

    if (Killer != None && Other != None && Killer != Other)
    {
        Broadcast(Self, ParseKillMessage(GetNameOf(Killer.Pawn), GetNameOf(Other.Pawn), DamageType.static.DeathMessage(Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo)), 'DeathMessage');
    }
    else if (Other != None)
    {
        Broadcast(Self, ParseKillMessage("Someone", GetNameOf(Other.Pawn), DamageType.static.SuicideMessage(Other.PlayerReplicationInfo)), 'DeathMessage');
    }
}

function string GetNameOf(Pawn Other)
{
    local string NameString;

    if (Other == None)
    {
        return "Someone";
    }

    if (Other.PlayerReplicationInfo != None)
    {
        return Other.PlayerReplicationInfo.PlayerName;
    }

    NameString = Other.MenuName;
    
    if (NameString == "")
    {
        Other.MenuName = string(Other.Class.Name);
        NameString = Other.MenuName;
    }

    if (Monster(Other)!=None && Monster(Other).bBoss)
    {
        return "the"@NameString;
    }
    else if (class'KFInvasionMessage'.Static.ShouldUseAn(NameString))
    {
        return "an"@NameString;
    }
    
    return "a"@NameString;
}

function GetPlayerControllerList(out array<PlayerController> ControllerArray)
{
    ControllerArray = GetPlayerList(false);
}

function array<CorePlayerController> GetPlayerList(optional bool bIncludeSpectators)
{
    local Controller Controller;
    local CorePlayerController CorePlayerController;
    local array<CorePlayerController> PlayerControllerList;
    local int FoundControllers;

    PlayerControllerList.Length = 6;
    FoundControllers = 0;

    for ( Controller = Level.ControllerList; Controller != None; Controller = Controller.NextController )
    {
        if (!Controller.bIsPlayer)
        {
            continue;
        }

        if (Controller.PlayerReplicationInfo == None || (Controller.PlayerReplicationInfo.bOnlySpectator && !bIncludeSpectators))
        {
            continue;
        }

        CorePlayerController = CorePlayerController(Controller);

        if (CorePlayerController != None)
        {
            if (PlayerControllerList.Length <= FoundControllers)
            {
                PlayerControllerList.Length = FoundControllers + 2; //Allocate in steps of 2.
            }

            PlayerControllerList[FoundControllers] = CorePlayerController;
            FoundControllers++;
        }
    }

    if (FoundControllers < PlayerControllerList.Length)
    {
        PlayerControllerList.Length = FoundControllers;
    }

    return PlayerControllerList;
}

function int GetPlayerCount(optional bool bIncludeSpectators)
{
    local Controller Controller;
    local int FoundControllers;

    FoundControllers = 0;

    for ( Controller = Level.ControllerList; Controller != None; Controller = Controller.NextController )
    {
        if (!Controller.bIsPlayer)
        {
            continue;
        }

        if (Controller.PlayerReplicationInfo == None || (Controller.PlayerReplicationInfo.bOnlySpectator && !bIncludeSpectators))
        {
            continue;
        }

        FoundControllers++;
    }

    return FoundControllers;
}

function array<TurboHumanPawn> GetPlayerPawnList()
{
    local Controller Controller;
    local TurboHumanPawn CoreHumanPawn;
    local array<TurboHumanPawn> HumanPawnList;
    local int FoundPawns;

    HumanPawnList.Length = 6;
    FoundPawns = 0;

    for ( Controller = Level.ControllerList; Controller != None; Controller = Controller.NextController )
    {
        if (!Controller.bIsPlayer)
        {
            continue;
        }

        if (Controller.Pawn == None || Controller.Pawn.bDeleteMe || Controller.Pawn.Health <= 0)
        {
            continue;
        }

        CoreHumanPawn = TurboHumanPawn(Controller.Pawn);

        if (CoreHumanPawn != None)
        {
            if (HumanPawnList.Length <= FoundPawns)
            {
                HumanPawnList.Length = FoundPawns + 2; //Allocate in steps of 2.
            }

            HumanPawnList[FoundPawns] = CoreHumanPawn;
            FoundPawns++;
        }
    }

    if (FoundPawns < HumanPawnList.Length)
    {
        HumanPawnList.Length = FoundPawns;
    }

    return HumanPawnList;
}

final function array<Monster> GetMonsterPawnList(optional class<Monster> FilterClass)
{
    local Controller Controller;
    local Monster MonsterPawn;
    local array<Monster> MonsterPawnList;
    local int FoundPawns;
    local int Index;

    for ( Controller = Level.ControllerList; Controller != None; Controller = Controller.NextController )
    {
        if (Controller.bIsPlayer)
        {
            continue;
        }

        if (Controller.Pawn == None || Controller.Pawn.bDeleteMe || Controller.Pawn.Health <= 0)
        {
            continue;
        }

        MonsterPawn = Monster(Controller.Pawn);

        if (MonsterPawn != None)
        {
            if (MonsterPawnList.Length <= FoundPawns)
            {
                MonsterPawnList.Length = FoundPawns + 4; //Allocate in steps of 4.
            }

            MonsterPawnList[FoundPawns] = MonsterPawn;
            FoundPawns++;
        }
    }

    if (FoundPawns < MonsterPawnList.Length)
    {
        MonsterPawnList.Length = FoundPawns;
    }

    if (FilterClass != None)
    {
        for (Index = MonsterPawnList.Length - 1; Index >= 0; Index--)
        {
            if (MonsterPawnList[Index] == None || !ClassIsChildOf(MonsterPawnList[Index].Class, FilterClass))
            {
                MonsterPawnList.Remove(Index, 1);
            }
        }
    }

    return MonsterPawnList;
}

defaultproperties
{
    GameWaveSpawnRateModifier=1.f
    MapWaveSpawnRateModifier=1.f
    AdminSpawnRateModifier=1.f

    GameMaxMonstersModifier=1.f
    MapMaxMonstersModifier=1.f
    AdminMaxMonstersModifier=1.f

    GameTotalMonstersModifier=1.f

    GameTraderTimeModifier=1.f
}