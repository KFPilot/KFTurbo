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
    GameType = KFTurboGameType(Level.Game);
    GameReplicationInfo = TurboGameReplicationInfo(Level.GRI);
    
    log("KFTurbo has created a status TCP link!", 'KFTurboInfoTcpLink');

	CRLF = Chr(13) $ Chr(10);

    LinkMode = MODE_Text;
    ReceiveMode = RMODE_Event;

    SetTimer(1.f, false);
}

function Timer()
{
    BuildGameStateData();
    GotoState('AttemptResolve');
}

function BuildGameStateData()
{
    PayloadCache = "{%runtime%,"$StringToJSON(SERVER_NAME, Sanitize(class'GUIComponent'.static.StripColorCodes(Level.GRI.ServerName)))$","
        $StringToJSON(GAME_TYPE, class'KFTurboMut'.static.FindMutator(Level.Game).GetGameType())$","
        $StringToJSON(DIFFICULTY, int(Round(Level.Game.GameDifficulty)))$","
        $StringToJSON(MAP_FILE, Left(string(Level), InStr(string(Level), ".")))$","
        $StringToJSON(MAP_NAME, Level.Title)$","
        $DataToJSON(FINAL_WAVE, Level.Game.GetFinalWaveNum())$"}";

    UpdateMatchStateJSON();
    UpdateWaveStateJSON();
    UpdatePlayerCountJSON();

    //Don't bother updating player list now. We don't cache its outcome.
}

state AttemptResolve
{
    function BeginState()
    {
        log("Attempting to resolve target domain.", 'KFTurboInfoTcpLink');
        SetTimer(1.f, false);
    }

    function Timer()
    {
        BindPort();
        Resolve(TargetDomain);
    }
    
    function ResolveFailed()
    {
        SetTimer(10.f, false);
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
    function Opened()
    {
        GotoState('Heartbeat');
    }

    function Closed() {}
    
Begin:
    log("Attempting to connect to resolved address.", 'KFTurboInfoTcpLink');
    Sleep(1.f);
    OpenNoSteam(ResolvedDomainAddress);
    Sleep(10.f);
    if (!IsConnected())
    {
        goto 'Begin';
    }
}

state Heartbeat
{
    function Closed()
    {
        GotoState('AttemptConnection');
    }

Begin:
    log("Now heartbeating status.", 'KFTurboInfoTcpLink');
    while(true)
    {
        Sleep(5.f);
        SendText("keepalive"$CRLF);
        Sleep(1.f);
        UpdateMatchStateJSON();
        Sleep(1.f);
        UpdateWaveStateJSON();
        Sleep(1.f);
        UpdatePlayerCountJSON();
        Sleep(1.f);
        UpdatePlayerListJSON();
        Sleep(1.f);
        SendStatus();
    }
}

function SendStatus()
{
    SendText(Repl(PayloadCache, "%runtime%", MatchStateCache$","$WaveStateCache$","$PlayerCountCache$","$PlayerListCache)$CRLF);
}

function UpdateMatchStateJSON()
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
        NewMatchStateID = GameReplicationInfo.EndGameType;
    }


    if (NewMatchStateID == LastKnownMatchStateID)
    {
        return;
    }

    LastKnownMatchStateID = NewMatchStateID;
    MatchStateCache = DataToJSON(MATCH_STATE, NewMatchStateID);
}

function UpdateWaveStateJSON()
{
    local int NewWaveStateID;
    if (GameType == None)
    {
        return;
    }

    if (GameType.bWaitingToStartMatch)
    {
        NewWaveStateID = -1;
    }
    else
    {
        NewWaveStateID = GameType.GetCurrentWaveNum();

        if (!GameType.bWaveInProgress)
        {
            NewWaveStateID = NewWaveStateID | (1 << 31); //write to last bit
        }
    }


    if (NewWaveStateID == LastKnownWaveStateID)
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
            PlayerList[PlayerList.Length] = Player.GetPlayerIDHash();
        }
    }

    return StringArrayToJSON(PLAYER_LIST, PlayerList) $ "," $ StringArrayToJSON(SPECTATOR_LIST, SpectatorList);
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
}