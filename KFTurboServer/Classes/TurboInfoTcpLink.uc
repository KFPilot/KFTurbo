//Killing Floor Turbo TurboInfoTcpLink
//Responsible for broadcasting game status to a target domain/port.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboInfoTcpLink extends TurboTcpLink
    config(KFTurbo);

var globalconfig bool bCreateInfoLink;
var globalconfig string TargetDomain;
var globalconfig int TargetPort;
var globalconfig string InfoTcpLinkClassOverride;

//Update frequency. This number is multiplied by 5 to get the seconds between updates.
var globalconfig int UpdateFrequency;
var int UpdateCountdown;

var IpAddr ResolvedDomainAddress;

var string CRLF;

//JSON keys
//String
const SERVER_NAME = "serv";
//String (atm reads from KFTurbo's gametype ID system... which is different from UE2's)
const GAME_TYPE = "game";
//String (but is an int).
const DIFFICULTY = "diff";
//String (map file name - fallback if map name is not set)
const MAP_FILE = "mapf";
//String (map level summary title)
const MAP_NAME = "mapn";
//int (the final wave for this game, -1 if there isn't one)
const FINAL_WAVE = "fw";
//String (ID of the current session)
const SESSION_ID = "sid";
//int (-1 match not started, 0 match in progress, 1 game over, 2 game win)
const MATCH_STATE = "ms";
//int (current wave, negative if wave is not active)
const WAVE_STATE = "ws";
//String (encoded as player_count|max_player_count|spec_count)
const PLAYER_COUNT = "pc"; 
//Array of String (SteamID)
const PLAYER_LIST = "pl";
//Array of String (SteamID)
const SPECTATOR_LIST = "sl";

var KFTurboGameType GameType;
var TurboGameReplicationInfo GameReplicationInfo;
var bool bIsShuttingDown;
var int ResolveAttemptCount; //Number of times we've attempted to resolve our endpoint's domain.
var int ConnectAttemptCount; //Number of times we've attempted to connect to our endpoint.

//Cache of JSON data that will not change over the course of the game.
var string PayloadCache;

//Match state JSON data cache.
var string MatchStateCache;
var int LastKnownMatchStateID;

//Wave state JSON data cache.
var string WaveStateCache;
var int LastKnownWaveStateID;

//Player count JSON data cache.
var string PlayerCountCache;
var int LastPlayerCount;
var int LastMaxPlayerCount;
var int LastSpectatorCount;

//Player list JSON data cache.
var string PlayerListCache;

static function bool ShouldBroadcastInfo()
{
    return default.bCreateInfoLink && default.TargetDomain != "" && default.TargetPort >= 0;
}

static function class<TurboInfoTcpLink> GetInfoTcpLinkClass()
{
    local class<TurboInfoTcpLink> TcpLinkClass;
    if (default.InfoTcpLinkClassOverride != "")
    {
        TcpLinkClass = class<TurboInfoTcpLink>(DynamicLoadObject(default.InfoTcpLinkClassOverride, class'class'));
    }

    if (TcpLinkClass == None)
    {
        TcpLinkClass = class'TurboInfoTcpLink';
    }

    return TcpLinkClass;
}

static final function TurboInfoTcpLink FindStatusTcpLink(GameInfo GameInfo)
{
    local KFTurboServerMut TurboServerMut;
    TurboServerMut = class'KFTurboServerMut'.static.FindMutator(GameInfo);

    if (TurboServerMut != None)
    {
        return TurboServerMut.InfoTcpLink;
    }
    
    return None;
}

function PostBeginPlay()
{   
    log("KFTurbo has created a status TCP link!", 'KFTurboInfoTcpLink');

	CRLF = Chr(13) $ Chr(10);

    LinkMode = MODE_Text;
    ReceiveMode = RMODE_Event;

    SetTimer(FRand() + 1.f, false);
}

function Timer()
{
    GameType = KFTurboGameType(Level.Game);
    GameReplicationInfo = TurboGameReplicationInfo(Level.GRI);

    BuildGameStateData();
    GotoState('AttemptResolve');
}

function BuildGameStateData()
{
    local KFTurboMut Mutator;
    Mutator = class'KFTurboMut'.static.FindMutator(Level.Game);

    PayloadCache = "{%runtime%,"$StringToJSON(SERVER_NAME, Sanitize(class'GUIComponent'.static.StripColorCodes(Level.GRI.ServerName)))$","
        $StringToJSON(GAME_TYPE, Mutator.GetGameType())$","
        $StringToJSON(DIFFICULTY, int(Round(Level.Game.GameDifficulty)))$","
        $StringToJSON(MAP_FILE, Left(string(Level), InStr(string(Level), ".")))$","
        $StringToJSON(MAP_NAME, Level.Title)$","
        $DataToJSON(FINAL_WAVE, Level.Game.GetFinalWaveNum())$","
        $StringToJSON(SESSION_ID, Mutator.GetSessionID())$"}";

    UpdateMatchStateJSON(true);
    UpdateWaveStateJSON(true);
    UpdatePlayerCountJSON();

    //Don't bother updating player list now. We don't cache its outcome.
}

state AttemptResolve
{
    function BeginState()
    {
        ResolveAttemptCount = 0;
        log("Status Tcp Link attempting to resolve target domain.", 'KFTurboInfoTcpLink');
        SetTimer(1.f, false);
    }

    function Timer()
    {
        BindPort();
        Resolve(TargetDomain);
    }
    
    function ResolveFailed()
    {
        ResolveAttemptCount++;
        SetTimer(10.f * float(ResolveAttemptCount), false);
    }

    function Resolved(IpAddr Addr)
    {
        ResolvedDomainAddress = Addr;
        ResolvedDomainAddress.Port = TargetPort;
        GotoState('AttemptConnection');
    }

    function Closed() {}
}

state AttemptConnection
{
    function BeginState()
    {
        ConnectAttemptCount = 0;
        log("Status Tcp Link attempting to connect to resolved address.", 'KFTurboInfoTcpLink');
    }

    function Opened()
    {
        GotoState('Heartbeat');
    }

    function Closed() {}
    
Begin:
    Sleep(1.f);
    OpenNoSteam(ResolvedDomainAddress);

    ConnectAttemptCount++;
    Sleep(30.f * float(ConnectAttemptCount));
    
    if (!IsConnected())
    {
        goto 'Begin';
    }
}

state Heartbeat
{
    function EndState()
    {
        SetTimer(0.f, false);
    }

    function Closed()
    {
        log("Status Tcp Link connection was closed. Going back to AttemptResolve in 30 seconds.", 'KFTurboInfoTcpLink');
        SetTimer(30.f, false);
    }

    function Timer()
    {
        Close();
        GotoState('AttemptResolve');
    }

Begin:
    log("Status Tcp Link now heartbeating status.", 'KFTurboInfoTcpLink');
    UpdateCountdown = 1;
    while(true)
    {
        if (UpdateCountdown > 0)
        {
            Sleep(5.f + FRand());
            SendText("keepalive"$CRLF);
            UpdateCountdown--;
            continue;
        }

        UpdateCountdown = UpdateFrequency;
        Sleep(0.1f);
        UpdateMatchStateJSON();
        Sleep(0.1f);
        UpdateWaveStateJSON();
        Sleep(0.1f);
        UpdatePlayerCountJSON();
        Sleep(0.1f);
        UpdatePlayerListJSON();
        Sleep(0.1f);
        SendStatus();
    }
}

state Shutdown
{
Begin:
    log("Status Tcp Link now sending final shutdown status.", 'KFTurboInfoTcpLink');
    Level.NextSwitchCountdown = FMax(Level.NextSwitchCountdown, 1.f);
    Sleep(0.1f);
    UpdateMatchStateJSON();
    Sleep(0.1f);
    UpdateWaveStateJSON();
    Sleep(0.1f);
    UpdatePlayerCountJSON();
    Sleep(0.1f);
    UpdatePlayerListJSON();
    Sleep(0.1f);
    SendStatus();
}

function SendStatus()
{
    SendText(Repl(PayloadCache, "%runtime%", MatchStateCache$","$WaveStateCache$","$PlayerCountCache$","$PlayerListCache)$CRLF);
}

function NotifyLevelTravel()
{
    if (!IsConnected())
    {
        return;
    }

    bIsShuttingDown = true;
    GotoState('Shutdown');
}

function UpdateMatchStateJSON(optional bool bForce)
{
    local int NewMatchStateID;
    if (GameType == None || GameReplicationInfo == None)
    {
        return;
    }

    if (!GameReplicationInfo.bMatchHasBegun)
    {
        NewMatchStateID = -1;
    }
    else
    {
        if (!GameType.IsTestGameType())
        {
            NewMatchStateID = GameReplicationInfo.EndGameType;
        }
        else
        {
            if (GameType.NumPlayers > 0)
            {
                NewMatchStateID = 0;
            }
            else
            {
                NewMatchStateID = 3;
            }
        }
    }

    if (bIsShuttingDown && NewMatchStateID == 0)
    {
        NewMatchStateID = 3;
    }

    if (!bForce && NewMatchStateID == LastKnownMatchStateID)
    {
        return;
    }

    LastKnownMatchStateID = NewMatchStateID;
    MatchStateCache = DataToJSON(MATCH_STATE, NewMatchStateID);
}

function UpdateWaveStateJSON(optional bool bForce)
{
    local int NewWaveStateID;
    if (GameType == None)
    {
        return;
    }

    if (GameType.bWaitingToStartMatch)
    {
        NewWaveStateID = 0;
    }
    else
    {
        NewWaveStateID = Min(GameType.GetCurrentWaveNum(), GameType.GetFinalWaveNum() + 1);

        if (!GameType.bWaveInProgress)
        {
            NewWaveStateID = NewWaveStateID  * -1; //Make negative if during trader time.
        }
    }

    if (!bForce && NewWaveStateID == LastKnownWaveStateID)
    {
        return;
    }

    LastKnownWaveStateID = NewWaveStateID;
    WaveStateCache = DataToJSON(WAVE_STATE, NewWaveStateID);
}

function UpdatePlayerCountJSON()
{
    if (LastPlayerCount == Level.Game.NumPlayers
        && LastMaxPlayerCount == Level.Game.MaxPlayers
        && LastSpectatorCount == Level.Game.NumSpectators)
    {
        return;
    }
    
    LastPlayerCount = Level.Game.NumPlayers;
    LastMaxPlayerCount = Level.Game.MaxPlayers;
    LastSpectatorCount = Level.Game.NumSpectators;
    

    if (bIsShuttingDown)
    {
        LastPlayerCount = 0;
        LastSpectatorCount = 0;
    }

    PlayerCountCache = StringToJSON(PLAYER_COUNT, LastPlayerCount$"|"$LastMaxPlayerCount$"|"$LastSpectatorCount);
}

function UpdatePlayerListJSON()
{
    PlayerListCache = GeneratePlayerJSON();
}

final function string GeneratePlayerJSON()
{
    local int Index;
    local array<TurboPlayerController> PlayerControllerList;
    local array<string> PlayerList, SpectatorList;
    local TurboPlayerController Player;

	PlayerControllerList = class'TurboGameplayHelper'.static.GetPlayerControllerList(Level, true);

    if (bIsShuttingDown)
    {
        return StringArrayToJSON(PLAYER_LIST, PlayerList) $ "," $ StringArrayToJSON(SPECTATOR_LIST, SpectatorList);
    }

    for (Index = 0; Index < PlayerControllerList.Length; Index++)
    {
        Player = PlayerControllerList[Index];

        if (Player.PlayerReplicationInfo == None)
        {
            continue;
        }

        if (Player.PlayerReplicationInfo.bOnlySpectator)
        {
            SpectatorList[SpectatorList.Length] = Player.GetPlayerIDHash();
        }
        else
        {
            PlayerList[PlayerList.Length] = Player.GetPlayerIDHash()$"|"$GetPerkID(TurboPlayerReplicationInfo(Player.PlayerReplicationInfo));
        }
    }

    return StringArrayToJSON(PLAYER_LIST, PlayerList) $ "," $ StringArrayToJSON(SPECTATOR_LIST, SpectatorList);
}


static final function string GetPerkID(TurboPlayerReplicationInfo TPRI)
{
    if (TPRI == None || TPRI.ClientVeteranSkill == None)
    {
        return "NONE";
    }

    switch(TPRI.ClientVeteranSkill)
    {
        case class'KFTurbo.V_FieldMedic':
            return "MED";
        case class'KFTurbo.V_SupportSpec':
            return "SUP";
        case class'KFTurbo.V_Sharpshooter':
            return "SHA";
        case class'KFTurbo.V_Commando':
            return "COM";
        case class'KFTurbo.V_Berserker':
            return "BER";
        case class'KFTurbo.V_Firebug':
            return "FIR";
        case class'KFTurbo.V_Demolitions':
            return "DEM";
    }

    return "INV";
}

defaultproperties
{
    LinkMode=MODE_Text

    LastKnownMatchStateID=-100000000
    LastKnownWaveStateID=-1
    LastPlayerCount=-1
    LastMaxPlayerCount=-1
    LastSpectatorCount=-1

    bCreateInfoLink=false
    TargetDomain=""
    TargetPort=-1
    InfoTcpLinkClassOverride=""
    UpdateFrequency=2
}