//Killing Floor Turbo KFTurboGameType
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboGameType extends KFGameType;

var protected bool bIsHighDifficulty;
var protected bool bStatsAndAchievementsEnabled;
var protected bool bIsTestGameType;

//Used to block ending of a game. Helps with testing.
var protected bool bPreventGameOver;

//Allows a gametype modification to total waves without impacting spawns (eg the game wants to work like a Long game, but with a different number of waves).
var protected int FinalWaveOverride;
var protected bool bHasAttemptedToApplyFinalWaveOverride;
 
//Whatever spawn rate is set as, make sure it gets multiplied by these.
var float GameWaveSpawnRateModifier, MapWaveSpawnRateModifier, AdminSpawnRateModifier;
//Whatever max monsters is set as, make sure it gets multiplied by these.
var float GameMaxMonstersModifier, MapMaxMonstersModifier, AdminMaxMonstersModifier;
//Whatever total monsters is set as, make sure it gets multiplied by this.
var float GameTotalMonstersModifier;
//Whatever trader time is set as, make sure it gets multiplied by this.
var float GameTraderTimeModifier;

//Set to true when the boss has been spawned. Used to prevent duplicate broadcasts of OnBossSpawned event.
var bool bHasSpawnedBoss;

//Event handler stored here so we have an easy way to find it.
var array< TurboEventHandler > EventHandlerList; //List of all event handlers.

var array< TurboPlayerEventHandler > GlobalPlayerEventHandlerList; //Event Handlers added to this will receive events for all players. To refine events to a specific player, use TurboPlayerController::PlayerEventHandlerList
var array< TurboGameplayEventHandler > GameplayEventHandlerList;
var array< TurboHealEventHandler > HealEventHandlerList;
var array< TurboWaveEventHandler > WaveEventHandlerList;
var array< TurboWaveSpawnEventHandler > WaveSpawnEventHandlerList;

var MapConfigurationObject MapConfigurationObject; //MapConfigurationObject associated with the current map.

var protected int FakedPlayerCount; //Faked player count. Used to make wave size larger.
const MAX_FAKED_PLAYERS = 12; //Used to keep faked player count equal to or less than 12.
var protected int ForcedPlayerHealthCount; //Forced player health count. Used to scale up monster health.
const MAX_FORCED_PLAYER_HEALTH = 6; //Used to keep monster health at 6 players or fewer.

var protected bool bZedTimeEnabled; //Allows for zed time to be disabled.

//Events that KFTurboServerMut binds to for bridging communication with ServerPerksMut.
Delegate OnStatsAndAchievementsDisabled();
Delegate LockPerkSelection(bool bLock);

event InitGame(string Options, out string Error)
{
    Super.InitGame(Options, Error);

    bNoLateJoiners = false;
    InitializeMapConfigurationObject();
}

function ProcessServerTravel(string URL, bool bItems)
{
    EventHandlerList.Length = 0;
    GlobalPlayerEventHandlerList.Length = 0;
    GameplayEventHandlerList.Length = 0;
    HealEventHandlerList.Length = 0;
    WaveEventHandlerList.Length = 0;
    WaveSpawnEventHandlerList.Length = 0;
    
    MapConfigurationObject = None;

    OnStatsAndAchievementsDisabled = None;
    LockPerkSelection = None;

    Super.ProcessServerTravel(URL, bItems);
}

function InitializeMapConfigurationObject()
{
    local string MapName;
    local int Index;
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

    log("Loaded MapConfigurationObject for level"@MapName$". Applying modifiers now.", 'KFTurbo');

    log("| Spawn Rate Modifier:"@MapWaveSpawnRateModifier@"| Max Monsters Modifier:"@MapMaxMonstersModifier, 'KFTurbo');

    MapWaveSpawnRateModifier = MapConfigurationObject.WaveSpawnRateMultiplier;
    MapMaxMonstersModifier = MapConfigurationObject.WaveMaxMonstersMultiplier;

    log("| Zombie Volume Respawn Modifier:"@MapConfigurationObject.ZombieVolumeCanRespawnTimeMultiplier@"| Zombie Volume Min Player Distance Modifier:"@MapConfigurationObject.ZombieVolumeMinDistanceToPlayerMultiplier, 'KFTurbo');

    for (Index = ZedSpawnList.Length - 1; Index >= 0; Index--)
    {
        ZedSpawnList[Index].CanRespawnTime *= MapConfigurationObject.ZombieVolumeCanRespawnTimeMultiplier;
        ZedSpawnList[Index].MinDistanceToPlayer *= MapConfigurationObject.ZombieVolumeMinDistanceToPlayerMultiplier;
    }
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
    return Min(NumPlayers + FakedPlayerCount, MAX_FAKED_PLAYERS);
}

//Player count to use when calculating monster health. Handles forced player monster health. KFTurbo caps this to 6.
final function int GetMonsterHealthPlayerCount()
{
    return Min(Max(GetAlivePlayerCount(), ForcedPlayerHealthCount), MAX_FORCED_PLAYER_HEALTH);
}

function int SetFakedPlayerCount(int NewFakedPlayerCount)
{
    FakedPlayerCount = Min(Max(NewFakedPlayerCount, 0), MAX_FAKED_PLAYERS - 1);
    return FakedPlayerCount;
}

final function int GetFakedPlayerCount()
{
    return FakedPlayerCount;
}

function int SetForcedPlayerHealthCount(int NewForcedPlayerHealthCount)
{
    NewForcedPlayerHealthCount = Clamp(NewForcedPlayerHealthCount, 0, MAX_FORCED_PLAYER_HEALTH);
    ForcedPlayerHealthCount = NewForcedPlayerHealthCount;
    return ForcedPlayerHealthCount;
}

final function int GetForcedPlayerHealthCount()
{
    return ForcedPlayerHealthCount;
}

final function bool SetZedTimeEnabled(bool bNewZedTimeEnabled)
{
    bZedTimeEnabled = bNewZedTimeEnabled;
    return bZedTimeEnabled;
}

function bool IsZedTimeEnabled()
{
    return bZedTimeEnabled;
}

function float SetAdminSpawnRateModifier(float NewAdminSpawnRateModifier)
{
    NewAdminSpawnRateModifier = FClamp(NewAdminSpawnRateModifier, 1.f, 100.f);
    AdminSpawnRateModifier = FMax(NewAdminSpawnRateModifier, 1.f);
    return AdminSpawnRateModifier;
}

function float SetAdminMaxMonstersModifier(float NewAdminMaxMonstersModifier)
{
    NewAdminMaxMonstersModifier = FClamp(NewAdminMaxMonstersModifier, 1.f, 100.f);
    NewAdminMaxMonstersModifier = FMax(NewAdminMaxMonstersModifier, 1.f);
    AdminMaxMonstersModifier = NewAdminMaxMonstersModifier;
    return AdminMaxMonstersModifier;
}

event PlayerController Login(string Portal, string Options, out string Error)
{
    local PlayerController PlayerController;
    local bool bJoinedAsSpectatorOnly;

    PlayerController = Super.Login(Portal, Options, Error);

    if (Level.bLevelChange)
    {
        return PlayerController;
    }

    if (PlayerController == None)
    {
        return None;
    }

    bJoinedAsSpectatorOnly = PlayerController.PlayerReplicationInfo.bOnlySpectator;

    if (!bJoinedAsSpectatorOnly)
    {
        PlayerController.PlayerReplicationInfo.Score = GetPlayerStartingCash();
    }

    if (bJoinedAsSpectatorOnly && bWaveInProgress)
    {
        TurboPlayerController(PlayerController).bWasSpectatingWave = true;
    }

    return PlayerController;
}

function Logout(Controller Exiting)
{
    if (!Level.bLevelChange && TurboPlayerController(Exiting) != None)
    {
        DistributeCash(TurboPlayerController(Exiting));
    }

    Super.Logout(Exiting);
}

function DistributeCash(TurboPlayerController ExitingPlayer)
{
	local int Index;
	local float Score;
	local array<TurboPlayerController> PlayerList;

	PlayerList = class'TurboGameplayHelper'.static.GetPlayerControllerList(Level);
    
    if (PlayerList.Length == 0)
    {
        return;
    }

	Score = ExitingPlayer.PlayerReplicationInfo.Score;
	Score -= float(GetPlayerStartingCash());
	Score = Score / float(PlayerList.Length);

	if (Score < 1.f)
	{
		return;
	}

	for (Index = PlayerList.Length - 1; Index >= 0; Index--)
	{
        if (ExitingPlayer == PlayerList[Index])
        {
            continue;
        }

		PlayerList[Index].PlayerReplicationInfo.Score += Score;
		PlayerList[Index].PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - ((1.f / PlayerList[Index].PlayerReplicationInfo.NetUpdateFrequency) + 1.f);
	}
}

function int GetPlayerStartingCash()
{
    return StartingCash;
}

//Provide full context on something dying to TurboGameRules.
function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType)
{
    local GameRules GameRules;
    local TurboGameRules TurboGameRules;

    Super.Killed(Killer, Killed, KilledPawn, DamageType);

    GameRules = GameRulesModifiers;

    //Find the first TurboGameRules in the chain and start the event flow.
    while (GameRules != None)
    {
        TurboGameRules = TurboGameRules(GameRules);

        if (TurboGameRules != None)
        {
            break;
        }

        GameRules = GameRules.NextGameRules;
    }

    if (TurboGameRules != None)
    {
        TurboGameRules.Killed(Killer, Killed, KilledPawn, DamageType);
    }
}

static function bool IsHighDifficulty()
{
    return default.bIsHighDifficulty;
}

static final function bool StaticIsHighDifficulty( Actor Actor )
{
	local class<KFTurboGameType> GameClass;
	if(Actor == None || Actor.Level == None)
	{
		return false;
	}

	GameClass = class<KFTurboGameType>(Actor.Level.GetGameClass());
	
	if (GameClass == none)
	{
		return false;
	}

	return GameClass.static.IsHighDifficulty();
}

static function bool AreStatsAndAchievementsEnabled()
{
    return default.bStatsAndAchievementsEnabled;
}

static final function bool StaticAreStatsAndAchievementsEnabled( Actor Actor )
{
	local class<KFTurboGameType> GameClass;
	if(Actor == None || Actor.Level == None)
	{
		return false;
	}

	if (KFTurboGameType(Actor.Level.Game) != None)
	{
        //If the class defines by default that stats are not enabled, stick to that!
        if (!class<KFTurboGameType>(Actor.Level.Game.Class).default.bStatsAndAchievementsEnabled)
        {
            return false;
        }

		return KFTurboGameType(Actor.Level.Game).bStatsAndAchievementsEnabled;
	}

	GameClass = class<KFTurboGameType>(Actor.Level.GetGameClass());
	
	if (GameClass == none)
	{
		return false;
	}

	return GameClass.static.AreStatsAndAchievementsEnabled();
}

static final function StaticDisableStatsAndAchievements( Actor Actor )
{
	if(Actor == None || Actor.Level == None)
	{
		return;
	}

	if (KFTurboGameType(Actor.Level.Game) != None)
	{
		KFTurboGameType(Actor.Level.Game).bStatsAndAchievementsEnabled = false;
		KFTurboGameType(Actor.Level.Game).OnStatsAndAchievementsDisabled();
	}
}

static function bool IsTestGameType()
{
    return default.bIsTestGameType;
}

static final function bool StaticIsTestGameType( Actor Actor )
{
	local class<KFTurboGameType> GameClass;
	if(Actor == None || Actor.Level == None)
	{
		return false;
	}

	GameClass = class<KFTurboGameType>(Actor.Level.GetGameClass());
	
	if (GameClass == none)
	{
		return false;
	}

	return GameClass.static.IsTestGameType();
}

final function bool HasAnyTraders()
{
	local int Index;
	local bool bHasAnyTraders;
	bHasAnyTraders = false;

	for(Index = 0; Index < ShopList.Length; Index++)
	{
		if(ShopList[Index].bAlwaysClosed)
		{
			continue;
		}
		
		bHasAnyTraders = true;
		break;		
	}

	return bHasAnyTraders;
}

function bool SetFinalWaveOverride(int NewOverride)
{
    if (bHasAttemptedToApplyFinalWaveOverride)
    {
        log("Error!!! Attempted to set final wave override but wave setup was already performed.", 'KFTurbo');
        return false;
    }

    FinalWaveOverride = NewOverride;
    MonsterCollection.default.SpecialSquads.Length = 0;
    PrepareSpecialSquads();
    return true;
}

function PrepareSpecialSquads()
{
    Super.PrepareSpecialSquads();

    if (FinalWaveOverride != -1)
    {
        FinalWave = FinalWaveOverride;
    }

    bHasAttemptedToApplyFinalWaveOverride = true;
}

function BuildNextSquad()
{
	Super.BuildNextSquad();

	class'TurboWaveSpawnEventHandler'.static.BroadcastNextSpawnSquadGenerated(Self, NextSpawnSquad);
}

function bool AddBoss()
{
    if (Super.AddBoss())
    {
        if (!bHasSpawnedBoss)
        {
            bHasSpawnedBoss = true;
	        class'TurboWaveSpawnEventHandler'.static.BroadcasBossSpawned(Self);
        }
        return true;
    }

    return false;
}

function bool AddSquad()
{
    local int LastIndex;

    //Some special game modes (such as Card Game and Holdout) use more than 10 waves. Rather than adding special squads to the game types, we'll just reappend the last entry.
    if (KFGameLength != GL_Custom && !bUsedSpecialSquad && MonsterCollection.default.SpecialSquads.Length <= WaveNum)
    {
        LastIndex = MonsterCollection.default.SpecialSquads.Length - 1;
        if (LastIndex >= 0)
        {
            MonsterCollection.default.SpecialSquads[WaveNum] = MonsterCollection.default.SpecialSquads[LastIndex];
        }

        LastIndex = SpecialSquads.Length - 1;
        if (LastIndex >= 0)
        {
            SpecialSquads[WaveNum] = SpecialSquads[LastIndex];
        }
    }

    return Super.AddSquad();
}


function AddSpecialSquad()
{
	Super.AddSpecialSquad();

	class'TurboWaveSpawnEventHandler'.static.BroadcastNextSpawnSquadGenerated(Self, NextSpawnSquad);
}

function AddSpecialPatriarchSquad()
{
    if( FinalSquads.Length == 0 )
    {
        AddSpecialPatriarchSquadFromCollection();
    }
    else
    {
        AddSpecialPatriarchSquadFromGameType();
    }

    if (NextSpawnSquad.Length > 0)
    {
	    class'TurboWaveSpawnEventHandler'.static.BroadcastNextSpawnSquadGenerated(Self, NextSpawnSquad);
    }
}

function AddBossBuddySquad()
{
    local int TotalZeds, NumSpawned, TotalZedsValue;
    local int Index;
    local int TempMaxMonsters;
    local int TotalSpawned;
    local int SpawnDiff;

    if (NumPlayers == 1)
    {
        TotalZeds = 8;
    }
    else if (NumPlayers <= 3)
    {
        TotalZeds = 12;
    }
    else if (NumPlayers <= 5)
    {
        TotalZeds = 14;
    }
    else if (NumPlayers >= 6)
    {
        TotalZeds = 16;
    }
	
	class'TurboWaveSpawnEventHandler'.static.BroadcastAddBossBuddySquad(Self, TotalZeds);

    for (Index = 0; Index < 10; Index++)
    {
        if (TotalSpawned >= TotalZeds)
        {
            FinalSquadNum++;
            return;
        }

        NumSpawned = 0;
        NextSpawnSquad.Length = 0;
        AddSpecialPatriarchSquad();

        LastZVol = FindSpawningVolume();
        if (LastZVol != None)
		{
			LastSpawningVolume = LastZVol;
		}

        if (LastZVol == None)
        {
            LastZVol = FindSpawningVolume();
            if (LastZVol != None)
			{
                LastSpawningVolume = LastZVol;
			}

            if (LastZVol == None)
            {
                log("Error!!! Couldn't find a place for the Patriarch squad after 2 tries!!!");
            }
        }

        if ((NextSpawnSquad.Length + TotalSpawned) > TotalZeds)
        {
            SpawnDiff = (NextSpawnSquad.Length + TotalSpawned) - TotalZeds;

            if (NextSpawnSquad.Length > SpawnDiff)
            {
                NextSpawnSquad.Remove(0, SpawnDiff);
            }
            else
            {
                FinalSquadNum++;
                return;
            }

            if (NextSpawnSquad.Length == 0)
            {
                FinalSquadNum++;
                return;
            }
        }

        TempMaxMonsters = 999;
        if (LastZVol.SpawnInHere(NextSpawnSquad, , NumSpawned, TempMaxMonsters, 999, TotalZedsValue))
        {
            NumMonsters += NumSpawned;
            WaveMonsters += NumSpawned;
            TotalSpawned += NumSpawned;

            NextSpawnSquad.Remove(0, NumSpawned);
        }
    }

    FinalSquadNum++;
}

function SetupWave()
{
	Super.SetupWave();

    MaxMonsters = float(MaxMonsters) * GameMaxMonstersModifier * MapMaxMonstersModifier * AdminMaxMonstersModifier;

    TotalMaxMonsters = CalculateTotalMaxMonster();
    KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonsters = TotalMaxMonsters;
	
    DoWaveStartForPlayers();

    class'KFTurboMut'.static.FindMutator(Self).OnWaveStart();
	class'TurboWaveEventHandler'.static.BroadcastWaveStarted(Self, WaveNum);
}

function int CalculateTotalMaxMonster()
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

//Function needs to be declared outside of state scope if it wants to be called outside of the state's scope...
function SelectShop() {}

function ClearEndGame(){}

function ShowPathTo(PlayerController P, int TeamNum)
{
    local ShopVolume CurrentShop;
    CurrentShop = KFGameReplicationInfo(GameReplicationInfo).CurrentShop;

    if (CurrentShop == None)
    {
        return;
    }

    //In KF's original code, it was calling InitTeleports for each player controller. 
    if (!CurrentShop.bTelsInit)
    {
        CurrentShop.InitTeleports();
    }

    if (CurrentShop.TelList.Length == 0)
    {
        return;
    }

    if (CurrentShop.TelList[0] != None && P.FindPathToward(CurrentShop.TelList[0], false) != None)
    {
        Spawn(GetTraderPathClass(), P,, P.Pawn.Location);
    }
}

function class<Actor> GetTraderPathClass()
{
    return class'KFMod.RedWhisp';
}

state MatchInProgress
{
    function BeginState()
    {
        local KFTurboMut KFTurboMut;

        Super.BeginState();

        KFTurboMut = class'KFTurboMut'.static.FindMutator(Self);
        if (KFTurboMut != None)
        {
            if (KFTurboMut.HasVersionUpdate())
            {
                BroadcastLocalized(Level.GRI, class'TurboVersionLocalMessage');
            }

            if (MapConfigurationObject != None && MapConfigurationObject.bSkipInitialMonsterWander)
            {
                KFTurboMut.bSkipInitialMonsterWander = true;
            }
        }

        NotifyTurboMutatorGameStart();
		class'TurboWaveEventHandler'.static.BroadcastGameStarted(Self, WaveNum);
    }

	//Don't do these things if there are no traders (KFTurbo+ or Randomizer).
    function SelectShop()
    {
		if (!HasAnyTraders())
		{
			return;
		}

		Super.SelectShop();
    }

    function OpenShops()
    {
        if (WaveCountDown == 31 && WaveNum % 4 == 0)
        {
            BroadcastLocalizedMessage(class'TurboEndTraderVoteMessage', 0);
        }

		if (!HasAnyTraders())
		{
			return;
		}

		Super.OpenShops();
    }

    function CloseShops()
    {
        local Controller C;
        Super.CloseShops();

        for (C = Level.ControllerList; C != None; C = C.NextController)
        {
            if (TurboPlayerController(C) != None)
            {
                TurboPlayerController(C).bShopping = false;
            }
        }
    }

	function float CalcNextSquadSpawnTime()
	{
		return Super.CalcNextSquadSpawnTime() / (GameWaveSpawnRateModifier * MapWaveSpawnRateModifier * AdminSpawnRateModifier);
	}
	
	function StartWaveBoss()
	{
		Super.StartWaveBoss();
        class'KFTurboMut'.static.FindMutator(Self).OnWaveStart();
		class'TurboWaveEventHandler'.static.BroadcastWaveStarted(Self, WaveNum);
	}

    function ClearEndGame()
    {
        local bool bPlayerAlive;
        local Controller C;

        if (!IsPreventGameOverEnabled())
        {
            return;
        }

        bPlayerAlive = false;

        for ( C=Level.ControllerList; C!=None; C=C.NextController )
        {
            if ( (C.PlayerReplicationInfo != None) && C.bIsPlayer && !C.PlayerReplicationInfo.bOutOfLives && !C.PlayerReplicationInfo.bOnlySpectator )
            {
                bPlayerAlive = true;
                break;
            }
        }

        if (!bPlayerAlive)
        {
            DoWaveEnd();
        }
    }
	
	function DoWaveEnd()
	{
		Super.DoWaveEnd();

        if (GameTraderTimeModifier != 1.f)
        {
            WaveCountDown = float(WaveCountDown) * GameTraderTimeModifier;
            KFGameReplicationInfo(GameReplicationInfo).TimeToNextWave = WaveCountDown;
        }

        InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;
        class'KFTurboMut'.static.FindMutator(Self).OnWaveEnd();
		class'TurboWaveEventHandler'.static.BroadcastWaveEnded(Self, WaveNum - 1);
	}
}

function bool IsPreventGameOverEnabled()
{
    return bPreventGameOver;
}

function PreventGameOver()
{
    bPreventGameOver = true;
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
    local bool bGameIsOver, bResult;

    if (WaveNum <= FinalWave && bPreventGameOver)
    {
        return false;
    }

    bGameIsOver = KFGameReplicationInfo(GameReplicationInfo).EndGameType != 0;

    bResult = Super.CheckEndGame(Winner, Reason);

    if (!bGameIsOver && KFGameReplicationInfo(GameReplicationInfo).EndGameType != 0)
    {
		class'TurboWaveEventHandler'.static.BroadcastGameEnded(Self, KFGameReplicationInfo(GameReplicationInfo).EndGameType);
    }

    return bResult;
}

function DoWaveStartForPlayers()
{
    local int Index;
    local TurboPlayerReplicationInfo TPRI;

	for (Index = Level.GRI.PRIArray.Length - 1; Index >= 0; Index--)
	{
		TPRI = TurboPlayerReplicationInfo(Level.GRI.PRIArray[Index]);

        if (TPRI == None)
        {
            continue;
        }
        
        if (TurboPlayerController(TPRI.Owner) != None)
        {
            TurboPlayerController(TPRI.Owner).bWasSpectatingWave = TPRI.bOnlySpectator;
        }
    }
}

function NotifyTurboMutatorGameStart()
{
    local KFTurboMut TurboMut;
    TurboMut = class'KFTurboMut'.static.FindMutator(Self);
    TurboMut.OnGameStart();
}

function DramaticEvent(float BaseZedTimePossibility, optional float DesiredZedTimeDuration)
{
    if (!IsZedTimeEnabled())
    {
        return;
    }

    Super.DramaticEvent(BaseZedTimePossibility, DesiredZedTimeDuration);
}

defaultproperties
{
    bIsHighDifficulty=false
    bStatsAndAchievementsEnabled=true
	bIsTestGameType=false

    FinalWaveOverride=-1
    bHasAttemptedToApplyFinalWaveOverride=false

	GameWaveSpawnRateModifier=1.f
    MapWaveSpawnRateModifier=1.f
    AdminSpawnRateModifier=1.f

    GameMaxMonstersModifier=1.f
    MapMaxMonstersModifier=1.f
    AdminMaxMonstersModifier=1.f

    GameTotalMonstersModifier=1.f
    GameTraderTimeModifier=1.f
    bHasSpawnedBoss=false

    FakedPlayerCount=0
    ForcedPlayerHealthCount=0
    bZedTimeEnabled=true

    MonsterClasses(0)=(MClassName="KFTurbo.P_Clot_STA",Mid="A")
    MonsterClasses(1)=(MClassName="KFTurbo.P_Crawler_STA",Mid="B")
    MonsterClasses(2)=(MClassName="KFTurbo.P_GoreFast_STA",Mid="C")
    MonsterClasses(3)=(MClassName="KFTurbo.P_Stalker_STA",Mid="D")
    MonsterClasses(4)=(MClassName="KFTurbo.P_Scrake_STA",Mid="E")
    MonsterClasses(5)=(MClassName="KFTurbo.P_Fleshpound_STA",Mid="F")
    MonsterClasses(6)=(MClassName="KFTurbo.P_Bloat_STA",Mid="G")
    MonsterClasses(7)=(MClassName="KFTurbo.P_Siren_STA",Mid="H")
    MonsterClasses(8)=(MClassName="KFTurbo.P_Husk_STA",Mid="I")

    MonsterCollection=Class'KFTurbo.MC_DEF'
    SpecialEventMonsterCollections(0)=Class'KFTurbo.MC_DEF'
    SpecialEventMonsterCollections(1)=Class'KFTurbo.MC_SUM'
    SpecialEventMonsterCollections(2)=Class'KFTurbo.MC_HAL'
    SpecialEventMonsterCollections(3)=Class'KFTurbo.MC_XMA'

	GameReplicationInfoClass=Class'KFTurbo.TurboGameReplicationInfo'
	
    MapPrefix="KF"
    BeaconName="KF"
    Acronym="KF"
    
    GameName="Killing Floor Turbo Game Type"
    Description="KF Turbo version of the regular Killing Floor Game Type."
    ScreenShotName="KFTurbo.Generic.KFTurbo_FB"

    HUDType="KFTurbo.TurboHUDKillingFloor"
	ScoreBoardType="KFTurbo.TurboHUDScoreboard"

    Waves(0)=(WaveMask=196611,WaveMaxMonsters=20,WaveDuration=255,WaveDifficulty=0.100000)
    Waves(1)=(WaveMask=19662621,WaveMaxMonsters=32,WaveDuration=255,WaveDifficulty=0.100000)
    Waves(2)=(WaveMask=39337661,WaveMaxMonsters=35,WaveDuration=255,WaveDifficulty=0.200000)
    Waves(3)=(WaveMask=73378265,WaveMaxMonsters=42,WaveDuration=255,WaveDifficulty=0.300000)
    Waves(4)=(WaveMask=20713149,WaveMaxMonsters=35,WaveDuration=255,WaveDifficulty=0.200000)
    Waves(5)=(WaveMask=39337661,WaveMaxMonsters=35,WaveDuration=255,WaveDifficulty=0.200000)
    Waves(6)=(WaveMask=39337661,WaveMaxMonsters=35,WaveDuration=255,WaveDifficulty=0.200000)
    Waves(7)=(WaveMask=41839087,WaveMaxMonsters=40,WaveDuration=255,WaveDifficulty=0.300000)
    Waves(8)=(WaveMask=41839087,WaveMaxMonsters=40,WaveDuration=255,WaveDifficulty=0.300000)
    Waves(9)=(WaveMask=39840217,WaveMaxMonsters=45,WaveDuration=255,WaveDifficulty=0.300000)
    Waves(10)=(WaveMask=65026687,WaveMaxMonsters=45,WaveDuration=255,WaveDifficulty=0.300000)
    Waves(11)=(WaveMask=63750079,WaveMaxMonsters=45,WaveDuration=255,WaveDifficulty=0.300000)
    Waves(12)=(WaveMask=64810679,WaveMaxMonsters=50,WaveDuration=255,WaveDifficulty=0.300000)
    Waves(13)=(WaveMask=62578607,WaveMaxMonsters=50,WaveDuration=255,WaveDifficulty=0.300000)
    Waves(14)=(WaveMask=100663295,WaveMaxMonsters=50,WaveDuration=255,WaveDifficulty=0.300000)
    Waves(15)=(WaveMask=125892608,WaveMaxMonsters=50,WaveDuration=255,WaveDifficulty=0.300000)
}
