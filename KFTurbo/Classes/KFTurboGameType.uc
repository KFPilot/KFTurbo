//Killing Floor Turbo KFTurboGameType
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboGameType extends KFGameType;

var protected bool bIsHighDifficulty;
var protected bool bStatsAndAchievementsEnabled;
var protected bool bIsTestGameType;

//Allows a gametype modification to total waves without impacting spawns (eg the game wants to work like a Long game, but with a different number of waves).
var protected int FinalWaveOverride;
var protected bool bHasAttemptedToApplyFinalWaveOverride;
 
//Whatever spawn rate is set as, make sure it gets multiplied by this.
var float WaveSpawnRateModifier;

//Set to true when the boss has been spawned. Used to prevent duplicate broadcasts of OnBossSpawned event.
var bool bHasSpawnedBoss;

//Event handler stored here so we have an easy way to find it.
//TODO: Slowly split these up into relevant categories so that a listener doesn't bloat the list of active handlers just to get one event it wants.
var array< class<TurboEventHandler> > EventHandlerList;
var array< class<TurboHealEventHandler> > HealEventHandlerList;
var array< class<TurboWaveEventHandler> > WaveEventHandlerList;

//Events that KFTurboServerMut binds to for bridging communication with ServerPerksMut.
Delegate OnStatsAndAchievementsDisabled();
Delegate LockPerkSelection(bool bLock);
 
//Provide full context on something dying to TurboGameRules.
function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType)
{
    local GameRules NextGameRules;
    Super.Killed(Killer, Killed, KilledPawn, DamageType);

    for (NextGameRules = GameRulesModifiers; NextGameRules != None; NextGameRules = NextGameRules.NextGameRules)
    {
        if (TurboGameRules(NextGameRules) != None)
        {
            TurboGameRules(NextGameRules).Killed(Killer, Killed, KilledPawn, DamageType);
        }
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

simulated function bool SetFinalWaveOverride(int NewOverride)
{
    if (bHasAttemptedToApplyFinalWaveOverride)
    {
        return false;
    }

    FinalWaveOverride = NewOverride;
    return true;
}

simulated function PrepareSpecialSquads()
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

	class'TurboWaveEventHandler'.static.BroadcastNextSpawnSquadGenerated(Self, NextSpawnSquad);
}

function bool AddBoss()
{
    if (Super.AddBoss())
    {
        if (!bHasSpawnedBoss)
        {
            bHasSpawnedBoss = true;
	        class'TurboWaveEventHandler'.static.BroadcasBossSpawned(Self);
        }
        return true;
    }

    return false;
}

function AddSpecialSquad()
{
	Super.AddSpecialSquad();

	class'TurboWaveEventHandler'.static.BroadcastNextSpawnSquadGenerated(Self, NextSpawnSquad);
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
	    class'TurboWaveEventHandler'.static.BroadcastNextSpawnSquadGenerated(Self, NextSpawnSquad);
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
	
	class'TurboWaveEventHandler'.static.BroadcastAddBossBuddySquad(Self, TotalZeds);

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
	
    ClearTraderEndVotes();
	class'TurboWaveEventHandler'.static.BroadcastWaveStarted(Self, WaveNum);
}

state MatchInProgress
{
    function BeginState()
    {
        Super.BeginState();

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
		return Super.CalcNextSquadSpawnTime() / WaveSpawnRateModifier;
	}
	
	function StartWaveBoss()
	{
		Super.StartWaveBoss();
		class'TurboWaveEventHandler'.static.BroadcastWaveStarted(Self, WaveNum);
	}
	
	function DoWaveEnd()
	{
		Super.DoWaveEnd();
		class'TurboWaveEventHandler'.static.BroadcastWaveEnded(Self, WaveNum - 1);
	}
}

//Check if enough people have voted to end the trader and end it.
function AttemptTraderEnd(TurboPlayerController VoteInstigator)
{
    local int Index, NumVoters, NumVotes;
    local TurboPlayerReplicationInfo TPRI;
    local float VotePercent;
    
    if (bWaveInProgress || WaveCountDown <= 10)
	{
		return;
	}

    if (StaticIsTestGameType(Self))
    {
        return;
    }

    NumVoters = 0;
    NumVotes = 0;

	for (Index = Level.GRI.PRIArray.Length - 1; Index >= 0; Index--)
	{
		TPRI = TurboPlayerReplicationInfo(Level.GRI.PRIArray[Index]);

        if (TPRI == None)
        {
            continue;
        }

        NumVoters++;
        
        if (TPRI.bVotedForTraderEnd)
        {
            NumVotes++;
        }
    }

    if (NumVoters == 0)
    {
        return;
    }

    VotePercent = float(NumVotes) / float(NumVoters);

    if (VotePercent < 0.51f)
    {
        //This means someone instigated a vote.
        if (NumVoters == 1)
        {
            BroadcastLocalizedMessage(class'TurboEndTraderVoteMessage',,VoteInstigator.PlayerReplicationInfo);
        }
        return;
    }

	WaveCountDown = Min(WaveCountDown, 10);
    TurboGameReplicationInfo(GameReplicationInfo).TimeToNextWave = WaveCountDown;
}

function ClearTraderEndVotes()
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

        TPRI.ClearTraderEndVote();
    }
}

defaultproperties
{
    bIsHighDifficulty=false
    bStatsAndAchievementsEnabled=true
	bIsTestGameType=false

    FinalWaveOverride=-1
    bHasAttemptedToApplyFinalWaveOverride=false

	WaveSpawnRateModifier=1.f
    bHasSpawnedBoss=false

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
	
    GameName="Killing Floor Turbo Game Type"
    Description="KF Turbo version of default Killing Floor Game Type."
    ScreenShotName="KFTurbo.Generic.KFTurbo_FB"

	ScoreBoardType="KFTurbo.TurboHUDScoreboard"
}
