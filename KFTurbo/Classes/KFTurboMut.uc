//Killing Floor Turbo KFTurboMut
//Core of the KFTurbo mod.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboMut extends Mutator
	config(KFTurbo);

#exec obj load file="..\Textures\KFTurboWeaponSkins.utx" package=KFTurbo
#exec obj load file="..\Textures\KFTurboCharacters.utx" package=KFTurbo

#exec obj load file="..\Textures\KFTurboVet.utx" package=KFTurbo
#exec obj load file="..\Textures\KFTurboHUD.utx" package=KFTurbo

#exec obj load file="..\Animations\KFTurboContent.ukx" package=KFTurbo
#exec obj load file="..\Animations\KFTurboExtra.ukx" package=KFTurbo

var TurboStatsGameRules StatsGameRules;
var TurboStatsTcpLink StatsTcpLink;
var TurboCustomZedHandler CustomZedHandler;
var TurboDoorManager DoorManager;

//TODO: Remove this once KFTurboServerAchievements is done.
//This is really hacky. We have a better implementation coming in via KFTurboServerAchievements that will handle this properly
//For now we need somewhere to store these and this is probably the best place to do so.
var TurboHealEventHandler AchievementHealEventHandler;
var TurboGameplayEventHandler AchievementGameplayEventHandler;

var globalconfig bool bDebugClientPerkRepLink;

var globalconfig bool bCheckLatestTurboVersion;
var private string TurboVersion;
var private bool bHasVersionUpdate;

var protected string SessionID;
var protected string GameStartTime;
var protected string GameType;

var globalconfig bool bRequireAdminForDifficultyCommands;
var globalconfig bool bAutoRestartEmptyIdleServer; //Server will restart after 1 hour of being empty and idle.
var globalconfig bool bPreventImmediateCashRegrab; //Prevents annoyance where player's tossed cash can accidentally be picked up by tosser immediately.

var bool bSkipInitialMonsterWander;

delegate SetPerkSwitchEnabled(bool bEnable);

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	//Make sure fonts are added to server packages.
	AddToPackageMap("KFTurboFonts");
	AddToPackageMap("KFTurboWeaponSkins");
	AddToPackageMap("KFTurboFontsJP");
	AddToPackageMap("KFTurboFontsCY");

	if(Role != ROLE_Authority)
	{
		return;
	}

	if (!ClassIsChildOf(Level.Game.PlayerControllerClass, class'TurboPlayerController'))
	{
		Level.Game.PlayerControllerClass = class'TurboPlayerController';
		Level.Game.PlayerControllerClassName = string(class'TurboPlayerController');
	}

	Level.Game.HUDType = GetHUDReplacementClass(Level.Game.HUDType);

	if (DeathMatch(Level.Game) != None)
	{
		DeathMatch(Level.Game).LoginMenuClass = string(class'TurboInvasionLoginMenu');
	}

	CustomZedHandler = Spawn(class'TurboCustomZedHandler', self);
	DoorManager = Spawn(class'TurboDoorManager', self);

	if (bDebugClientPerkRepLink)
	{
		Spawn(class'TurboRepLinkTester', Self);
	}

	if (bAutoRestartEmptyIdleServer && Level.NetMode == NM_DedicatedServer)
	{
		Spawn(class'TurboIdleServerHandler',  Self);
	}

	SetupBroadcaster();
	StatsGameRules = SetupTurboStatsGameRules();
	StatsTcpLink = SetupStatTcpLink();

	if (TeamGame(Level.Game) != None)
	{
		if (TeamGame(Level.Game).FriendlyFireScale <= 0.f)
		{
			TeamGame(Level.Game).FriendlyFireScale = 0.001f;
		}
	}

	if (bCheckLatestTurboVersion)
	{
		Spawn(class'TurboVersionTcpLink', Self);
	}
	
	class'TurboHealRewardEventHandler'.static.CreateHandler(Self);
}

function SetupBroadcaster()
{
	local TurboBroadcastHandler TurboBroadcastHandler;
	TurboBroadcastHandler = Spawn(class'TurboBroadcastHandler', Self);

	if(Level.Game.BroadcastHandler != None)
	{
		TurboBroadcastHandler.NextBroadcastHandler = Level.Game.BroadcastHandler;
		Level.Game.BroadcastHandler = TurboBroadcastHandler;
	}
	else
	{
		Level.Game.BroadcastHandler = TurboBroadcastHandler;
	}
}

//Wants to be at the front of the list.
function TurboStatsGameRules SetupTurboStatsGameRules()
{
	local TurboStatsGameRules TSGR;
	local GameRules GameRules;
	TSGR = Spawn(class'TurboStatsGameRules', Self);

	GameRules = Level.Game.GameRulesModifiers;
	Level.Game.GameRulesModifiers = TSGR;
	TSGR.NextGameRules = GameRules;
	return TSGR;
}

function TurboStatsTcpLink SetupStatTcpLink()
{
	local class<TurboStatsTcpLink> TcpLinkClass;
	if (!class'TurboStatsTcpLink'.static.ShouldBroadcastAnalytics())
	{
		return None;
	}

	TcpLinkClass = class'TurboStatsTcpLink'.static.GetStatsTcpLinkClass();

	if (TcpLinkClass == None)
	{
		return None;
	}

	return Spawn(TcpLinkClass, Self);
}

static function string GetHUDReplacementClass(string HUDClassString)
{
	local class<HUD> HUDClass;
	HUDClass = class<HUD>(DynamicLoadObject(HUDClassString, class'class'));

	if (class<TurboHUDKillingFloor>(HUDClass) == None)
	{
		return string(class'KFTurbo.TurboHUDKillingFloor');
	}

	return HUDClassString;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Level.bLevelChange)
	{
		return true;
	}

	if (KFPlayerReplicationInfo(Other) != None)
	{
		AddTurboPlayerMarkReplicationInfo(KFPlayerReplicationInfo(Other));
	}
	//Looks like tinkering with these directly doesn't work... just replace it.
	else if (KFRandomItemSpawn(Other) != None && TurboRandomItemSpawn(Other) == None)
	{
		ReplaceWith(Other, string(class'KFTurbo.TurboRandomItemSpawn'));
		return false;
	}
	else if (Controller(Other) != None && MessagingSpectator(Other) == None)
	{
		if (Controller(Other).PlayerReplicationInfoClass != None && class<TurboPlayerReplicationInfo>(Controller(Other).PlayerReplicationInfoClass) == None)
		{
			Controller(Other).PlayerReplicationInfoClass = Class'TurboPlayerReplicationInfo';
		}

		if (bSkipInitialMonsterWander && KFMonsterController(Other) != None)
		{
			KFMonsterController(Other).PathFindState = 2;
		}
	}
	else if (WeaponAttachment(Other) != None)
	{
		Other.NetPriority = FMax(Other.NetPriority, 1.5f);
	}
 
	return true;
}

function AddTurboPlayerMarkReplicationInfo(KFPlayerReplicationInfo PlayerReplicationInfo)
{
	local TurboPlayerMarkReplicationInfo TurboPRI;

	if (MessagingSpectator(PlayerReplicationInfo.Owner) != None)
	{
		return;
	}

	TurboPRI = Spawn(class'TurboPlayerMarkReplicationInfo', PlayerReplicationInfo.Owner);
	TurboPRI.NextReplicationInfo = PlayerReplicationInfo.CustomReplicationInfo;
	TurboPRI.OwningReplicationInfo = PlayerReplicationInfo;
	PlayerReplicationInfo.CustomReplicationInfo = TurboPRI;
}

function ModifyPlayer(Pawn Other)
{
	Super.ModifyPlayer(Other);

	if (TurboHumanPawn(Other) == None || !Other.IsHumanControlled())
	{
		return;
	}

	ApplyHealthModification(Other);
	ApplySpeedModification(Other);
}

function ApplyHealthModification(Pawn Pawn)
{
	local float HealthMultiplier;
	if (TurboGameReplicationInfo(Level.GRI) == None)
	{
		return;
	}
	
	HealthMultiplier = TurboGameReplicationInfo(Level.GRI).GetPlayerMaxHealthMultiplier(Pawn);

	Pawn.HealthMax = Round(Pawn.HealthMax * HealthMultiplier);
	Pawn.Health = Round(Pawn.Health * HealthMultiplier);
	
	Pawn.HealthMax = FMax(Pawn.HealthMax, 1.f);
	Pawn.Health = FMax(Pawn.Health, 1.f);
}

function ApplySpeedModification(Pawn Pawn)
{
	if (TurboGameReplicationInfo(Level.GRI) == None)
	{
		return;
	}
	
	Pawn.AccelRate = Pawn.default.AccelRate * FMax(0.f, TurboGameReplicationInfo(Level.GRI).GetPlayerMovementAccelMultiplier(KFPlayerReplicationInfo(Pawn.PlayerReplicationInfo), TurboGameReplicationInfo(Level.GRI)));
}

static final function KFTurboMut FindMutator(GameInfo GameInfo)
{
    local KFTurboMut TurboMut;
    local Mutator Mutator;

	if (GameInfo == None)
	{
		return None;
	}

    for ( Mutator = GameInfo.BaseMutator; Mutator != None; Mutator = Mutator.NextMutator )
    {
        TurboMut = KFTurboMut(Mutator);

        if (TurboMut == None)
        {
            continue;
        }

		return TurboMut;
    }

	return None;
}

static final function string GetTurboVersionID()
{
	return default.TurboVersion;
}

final function bool CheckIfNewerVersion(string LatestVersion)
{
	local array<string> CurrentVersionList, LatestVersionList;
	Split(default.TurboVersion, ".", CurrentVersionList);
	Split(LatestVersion, ".", LatestVersionList);

	if (int(CurrentVersionList[0]) < int(LatestVersionList[0]))
	{
		bHasVersionUpdate = true;
		return true;
	}

	if (int(CurrentVersionList[1]) < int(LatestVersionList[1]))
	{
		bHasVersionUpdate = true;
		return true;
	}

	return false;
}

final function bool HasVersionUpdate()
{
	return bHasVersionUpdate;
}

simulated function String GetHumanReadableName()
{
	return FriendlyName;
}

final function string GetSessionID()
{
    if (SessionID == "")
	{
		GameStartTime = FullTimeDate();
		SessionID = GenerateSessionID();
	}

	return SessionID;
}

//Taken from GameStats.uc
// Date/Time in MYSQL format
function String FullTimeDate()
{
	return Level.Year$"-"$Level.Month$"-"$Level.Day$" "$Level.Hour$":"$Level.Minute$":"$Level.Second;
}

//By default session IDs are Y-M-D H:M:S|<map_file_name_without_ext>
function string GenerateSessionID()
{
	return GameStartTime $ "|" $ Left(string(Level), InStr(string(Level), "."));
}

function SetGameType(Object Context, string InGameType)
{
	if (Context == None)
	{
		return;
	}

	GameType = InGameType;
	log("Turbo GameType set to"@GameType@"by"@Context$".",'KFTurbo');
}

final function string GetGameType()
{
	return GameType;
}

function OnGameStart()
{
	GetSessionID();

	if (StatsTcpLink != None)
	{
		StatsTcpLink.OnGameStart();
	}
}

function OnWaveStart()
{
	if (StatsTcpLink != None)
	{
		StatsTcpLink.SendWaveStart();
	}
}

function OnWaveEnd()
{
	if (StatsTcpLink != None)
	{
		StatsTcpLink.SendWaveEnd();
	}
}

function ServerTraveling(string URL, bool bItems)
{
	Super.ServerTraveling(URL, bItems);
	
	SetPerkSwitchEnabled = None;

	if (StatsTcpLink == None)
	{
		return;
	}

	if (KFGameReplicationInfo(Level.GRI) == None || KFGameReplicationInfo(Level.GRI).EndGameType != 0)
	{
		StatsTcpLink.Close();
		StatsTcpLink.Destroy();
		return;
	}

	StatsTcpLink.SendGameEnd(-1);
}

defaultproperties
{
	bAddToServerPackages=True
	GroupName="KF-KFTurbo"
	FriendlyName="Killing Floor Turbo"
	Description="Mutator for KFTurbo."

	bDebugClientPerkRepLink=false

	bCheckLatestTurboVersion=true
	TurboVersion="6.5.4"
	bHasVersionUpdate=false

	bRequireAdminForDifficultyCommands=true

	GameType="turbo"

	bSkipInitialMonsterWander=false

	bAutoRestartEmptyIdleServer=false

	bPreventImmediateCashRegrab=false
}