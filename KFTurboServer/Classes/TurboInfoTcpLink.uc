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
const SERVER_NAME = "serv";
const GAME_TYPE = "game";
const DIFFICULTY = "diff";
const MAP_FILE = "mapf";
const MAP_NAME = "mapn";
const MATCH_STATE = "ms";
const PLAYER_COUNT = "pc";
const PLAYER_LIST = "pl";
const SPECTATOR_LIST = "sl";

var KFTurboGameType GameType;
var TurboGameReplicationInfo GameReplicationInfo;

//Cache of JSON data that will not change over the course of the game.
var string PayloadCache;

//Match count JSON data cache.
var string MatchStateCache;
var int LastKnownMatchStateID; //Used to determine if we need to update MatchStateCache.

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

static final function TurboInfoTcpLink FindStatsTcpLink(GameInfo GameInfo)
{
    local KFTurboServerMut TurboServerMut;
    TurboServerMut = class'KFTurboServerMut'.static.FindMutator(GameInfo);
    return TurboServerMut.InfoTcpLink;
}

function PostBeginPlay()
{
    GameType = KFTurboGameType(Level.Game);
    GameReplicationInfo = TurboGameReplicationInfo(Level.GRI);
    
    log("KFTurbo has created an status TCP link!", 'KFTurboInfoTcpLink');

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
    PayloadCache = "{"$StringToJSON(SERVER_NAME, Sanitize(class'GUIComponent'.static.StripColorCodes(Level.GRI.ServerName)))$","
        $StringToJSON(GAME_TYPE, class'KFTurboMut'.static.FindMutator(Level.Game).GetGameType())$","
        $StringToJSON(DIFFICULTY, int(Round(Level.Game.GameDifficulty)))$","
        $StringToJSON(MAP_FILE, Left(string(Level), InStr(string(Level), ".")))$","
        $StringToJSON(MAP_NAME, Level.Title)$",%runtime%}";

    UpdateMatchStateJSON();
    UpdatePlayerCountJSON();
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
        Resolve(TargetDomain);
    }
    
    function ResolveFailed()
    {
        SetTimer(1.f, false);
    }

    function Resolved(IpAddr Addr)
    {
        ResolvedDomainAddress = Addr;
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
        Sleep(2.f);
        SendText("keepalive");
        Sleep(1.f);
        UpdateMatchStateJSON();
        Sleep(1.f);
        UpdatePlayerCountJSON();
        UpdatePlayerListJSON();
        Sleep(1.f);
        SendStatus();
    }
}

function SendStatus()
{
    SendText(Repl(PayloadCache, "%runtime%", MatchStateCache$","$PlayerCountCache$","$PlayerListCache)$CRLF);
}

function UpdateMatchStateJSON()
{
    local int NewMatchStateID;
    if (GameType == None)
    {
        return;
    }

    if (GameType.bWaitingToStartMatch)
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

    bCreateInfoLink=false
    TargetDomain=""
    TargetPort=-1
    InfoTcpLinkClassOverride=""
}