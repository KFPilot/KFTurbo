//Killing Floor Turbo TurboStatsTcpLink
//Sends analytics data to a specified endpoint. All content is deferred over multiple frames.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboStatsTcpLink extends TurboTcpLink
    config(KFTurbo);

var globalconfig bool bBroadcastAnalytics;
var globalconfig string StatsDomain;
var globalconfig int StatsPort;
var globalconfig string StatsTcpLinkClassOverride;

var KFTurboMut Mutator;
var KFTurboGameType GameType;
var IpAddr StatsAddress;


var string CRLF;

var array<string> DeferredDataList;
var float LastDataSendTime;

var int MaxRetryCount;
var bool bIsFlushing;
var bool bFlushPending;

//JSON data that does not change over the course of a game.
//Cached to reduce the amount of string manipulation needed to produce payloads.
var string VersionIDJson; 
var string SessionIDJson;
var string GameStartPayloadCache;
var string GameEndPayloadCache;
var string WaveStartPayloadCache;
var string WaveEndPayloadCache;
var string WaveStatsPayloadCache;

var const bool bVerboseLogging;

static function bool ShouldBroadcastAnalytics()
{
    return default.bBroadcastAnalytics && default.StatsDomain != "" && default.StatsPort >= 0;
}

static function class<TurboStatsTcpLink> GetStatsTcpLinkClass()
{
    local class<TurboStatsTcpLink> TcpLinkClass;
    if (default.StatsTcpLinkClassOverride != "")
    {
        TcpLinkClass = class<TurboStatsTcpLink>(DynamicLoadObject(default.StatsTcpLinkClassOverride, class'class'));
    }

    if (TcpLinkClass == None)
    {
        TcpLinkClass = class'TurboStatsTcpLink';
    }

    return TcpLinkClass;
}

static final function TurboStatsTcpLink FindStatsTcpLink(GameInfo GameInfo)
{
    local KFTurboMut TurboMut;
    TurboMut = class'KFTurboMut'.static.FindMutator(GameInfo);
    return TurboMut.StatsTcpLink;
}

function PostBeginPlay()
{
    log("KFTurbo has created a stats TCP link!", 'KFTurboStatsTcp');
    Mutator = KFTurboMut(Owner);
    GameType = KFTurboGameType(Level.Game);

	CRLF = Chr(13) $ Chr(10);

    LinkMode = MODE_Text;
    ReceiveMode = RMODE_Event;
}

function OnGameStart()
{
    SetTimer(FRand() + 1.f, false);
}

function Timer()
{
    //Precache the static parts of the payloads.
    VersionIDJson = StringToJSON("version", Mutator.GetTurboVersionID());
    SessionIDJson = StringToJSON("session", Mutator.GetSessionID());

    GameStartPayloadCache = "{" $ StringToJSON("type", "gamebegin") $ ","$ SessionIDJson $ "," $ VersionIDJson
        $ "," $ StringToJSON("map", Left(string(Level), InStr(string(Level), ".")))
        $ "," $ StringToJSON("time", Mutator.GetSessionStartTime()) $ ",";

    GameEndPayloadCache = "{" $ StringToJSON("type", "gameend") $ "," $ SessionIDJson $ ",";
    WaveStartPayloadCache = "{" $ StringToJSON("type", "wavestart") $ "," $ SessionIDJson $ ",";
    WaveEndPayloadCache = "{" $ StringToJSON("type", "waveend") $ "," $ SessionIDJson $ ",";
    WaveStatsPayloadCache = "{" $ StringToJSON("type", "wavestats") $ "," $ SessionIDJson $ ",";

    GotoState('AttemptResolve');
}


state AttemptResolve
{
    function BeginState()
    {
        log("Attempting to resolve target domain.", 'KFTurboStatsTcp');
        SetTimer(1.f, false);
    }

    function Timer()
    {
        BindPort();
        Resolve(StatsDomain);
    }
    
    function ResolveFailed()
    {
        SetTimer(10.f, false);
    }

    function Resolved(IpAddr Addr)
    {
        //Put first payload in now.
        DeferredDataList[0] = BuildGameStartPayload();

        StatsAddress = Addr;
        StatsAddress.Port = StatsPort;
        GotoState('AttemptConnection');
    }
}

state AttemptConnection
{
    function Opened()
    {
        GotoState('Connected');
    }
    
Begin:
    log("Attempting to connect to resolved address.", 'KFTurboStatsTcp');
    Sleep(1.f);
    OpenNoSteam(StatsAddress);
    Sleep(10.f);
    if (!IsConnected())
    {
        goto 'Begin';
    }
}

state Connected
{
    function BeginState()
    {
        SetTimer(1.f, true);
    }

    function EndState()
    {
        SetTimer(0.f, false);
    }

    function Closed()
    {
        GotoState('AttemptConnection');
    }

    function Timer()
    {
        if (LastDataSendTime + 5.f < Level.TimeSeconds && DeferredDataList.Length == 0)
        {
            LastDataSendTime = Level.TimeSeconds;
            SendText("keepalive"$CRLF);
        }
    }
    
    function FlushData()
    {
        bIsFlushing = true;
        GotoState('FlushAllData');
    }

Begin:
    if (bFlushPending)
    {
        GotoState('FlushAllData');
    }
    else
    {
        log("Now sending payloads.", 'KFTurboInfoTcpLink');
        while(true)
        {
            Sleep(0.2f);
            SendNextPayload();
        }
    }
}

//Game ended. Get all this data out asap.
state FlushAllData
{
    function Closed()
    {
        log("WARNING: Connection was closed before data was able to be flushed!", 'KFTurboStatsTcp');
        GotoState('FlushComplete');
    }

Begin:
    log("Attempting to flush all pending data.", 'KFTurboStatsTcp');
    while (true)
    {
        Sleep(0.1f);

        if (DeferredDataList.Length == 0)
        {
            break;
        }

		if (Level.bLevelChange)
        {
			Level.NextSwitchCountdown = FMax(Level.NextSwitchCountdown, 2.f);
        }

        SendText(DeferredDataList[0]$CRLF);
        DeferredDataList.Remove(0, 1);
    }

    Sleep(0.1f);
    log("Flush complete!", 'KFTurboStatsTcp');
    GotoState('FlushComplete');
}

state FlushComplete
{
    
}

function SendData(string Data)
{
    if (bIsFlushing)
    {
        log("WARNING: SendData was called while flushing stats!", 'KFTurboStatsTcp');
        return;
    }

    if (DeferredDataList.Length > 50)
    {
        log("WARNING: Stats data buffer has exceeded 50 entries! Removing oldest entry before adding a new one.", 'KFTurboStatsTcp');
        DeferredDataList.Remove(0, 1);
    }
    else if (DeferredDataList.Length > 10)
    {
        log("WARNING: Stats data buffer has exceeded 10 entries. The tcp link is falling behind for an unknown reason.", 'KFTurboStatsTcp');
    }

    if (bVerboseLogging) { log("= CACHING NEW PAYLOAD"@Data, 'TurboStatsTcpLink'); }
    DeferredDataList[DeferredDataList.Length] = Data;
}

function SendNextPayload()
{
    if (DeferredDataList.Length == 0)
    {
        return;
    }

    if (bVerboseLogging) { log("= SENDING NEXT PAYLOAD"@DeferredDataList[0], 'TurboStatsTcpLink'); }
    LastDataSendTime = Level.TimeSeconds;
    SendText(DeferredDataList[0]$CRLF);
    DeferredDataList.Remove(0, 1);
}

function FlushData()
{
    bFlushPending = true;
}

/*
Data payload for a game starting looks like the following;

{
    "type": "gamebegin",
    "map" : "<.rom file>",
    "time" : "<Date/Time in MYSQL format>",
    "version": "5.2.2",
    "session": "<session ID>",
    "gametype" : "turbo",
    "diff" : "7"
}

type - refers to the type of payload this is.
map - The rom file that is being played.
time - The MYSQL time the game started.
version - The KFTurbo version currently running.
session - The session ID for this game.
gametype - The type of game being played. Can be "turbo", "turbocardgame", "turborandomizer", "turboplus".
diff - The game difficulty. Uses KF difficulty values (7 for Hell on Earth, 5 for Suicidal, etc.).
*/

final function string BuildGameStartPayload()
{
    return GameStartPayloadCache $ StringToJSON("gametype", Mutator.GetGameType()) $ "," $ StringToJSON("diff", int(Round(GameType.GetDifficulty()))) $ "}";
}

/*
Data payload for a game ending looks like the following;

{
    "type": "gameend",
    "version": "5.2.2",
    "session": "<session ID>",
    "wavenum" : "3",
    "result" : "won"
}

type - refers to the type of payload this is.
version - The KFTurbo version currently running.
session - The session ID for this game."
wavenum - The wave this game ended on.
result - The result of the game. Can be "won", "lost", "aborted". Aborted refers to a map vote that occurred without a game end state being reached.
*/

function SendGameEnd(int Result)
{
    if (bVerboseLogging) { log("======== SENDING GAME END"@BuildGameEndPayload(Level.Game.GetCurrentWaveNum(), GetResultName(Result)), 'TurboStatsTcpLink'); }

    SendData(BuildGameEndPayload(Level.Game.GetCurrentWaveNum(), GetResultName(Result)));

    FlushData();
}

final function string BuildGameEndPayload(int WaveNum, string Result)
{
    return GameEndPayloadCache $ StringToJSON("wavenum", WaveNum) $ "," $ StringToJSON("result", Result) $ "}";
}

/*
Data payload for a wave starting looks like the following;

{
    "type": "wavestart",
    "version": "5.2.2",
    "session": "<session ID>",
    "wavenum" : "2",
    "playerlist" : ["<steam ID 1>","<steam ID 2>", "<steam ID 3>", ...]
}

type - refers to the type of payload this is.
version - The KFTurbo version currently running.
session - The session ID for this game."
wavenum - The wave that started.
playerlist - The Steam IDs of the players in the game at the wave start.
*/

function SendWaveStart()
{
    SendData(BuildWaveStartPayload(Level.Game.GetCurrentWaveNum()));
}

final function string BuildWaveStartPayload(int WaveNum)
{
    return WaveStartPayloadCache $ StringToJSON("wavenum", WaveNum) $ "," $ GeneratePlayerJSON() $ "}";
}

/*
Data payload for a wave ending looks like the following;

{
    "type": "waveend",
    "version": "5.2.2",
    "session": "<session ID>",
    "wavenum" : "2"
}

type - refers to the type of payload this is.
version - The KFTurbo version currently running.
session - The session ID for this game."
wavenum - The wave that started.
*/

function SendWaveEnd(bool bWin)
{
    if (bWin)
    {
        SendData(BuildWaveEndPayload(Level.Game.GetCurrentWaveNum() - 1));
    }
    else
    {
        SendData(BuildWaveEndPayload(Level.Game.GetCurrentWaveNum()));
    }
}

final function string BuildWaveEndPayload(int WaveNum)
{
    return WaveEndPayloadCache $ StringToJSON("wavenum", WaveNum) $ "}";
}

/*
Data payload for a player's wave stats looks like the following;

{
    "type": "wavestats",
    "version": "5.2.2",
    "session": "<session ID>",
    "wavenum" : "8",
    "player" : "<steam ID>",
    "playername" : "Player Name",
    "perk" : "<perk name>",
    "stats" :
        {
         "Kills"  : 2,
         "Damage" : 1000
        },
    "died" : false
}

type - refers to the type of payload this is.
version - The KFTurbo version currently running.
session - The session ID for this game.
wavenum - The wave this vote data came from during the game.
player - the steam ID of the player this payload is for.
playername - the username of the player this payload is for.
perk - the perk this player was during the wave.
stats - A map of tracked non-zero stats accrued during the wave.
    Map key list: Kills, KillsFP, KillsSC, Damage, DamageFP, DamageSC, ShotsFired, MeleeSwings, ShotsHit, ShotsHeadshot, Reloads, Heals, DamageTaken.
died - Whether or not the player died this wave.
*/

function SendWaveStats(TurboWavePlayerStatCollector Stats)
{

    if (Stats == None)
    {
        return;
    }

    if (bVerboseLogging) { log("======== SENDING WAVE STATS"@BuildWaveStatsPayload(Stats), 'TurboStatsTcpLink'); }
    SendData(BuildWaveStatsPayload(Stats));
}

final function string BuildWaveStatsPayload(TurboWavePlayerStatCollector Stats)
{
    return WaveStatsPayloadCache
        $ StringToJSON("wavenum", Stats.Wave) $ ","
        $ StringToJSON("player", Stats.PlayerID) $ ","
        $ StringToJSON("playername", Sanitize(Stats.GetPlayerName())) $ ","
        $ StringToJSON("perk", GetPerkID(Stats.PlayerTPRI)) $ ","
        $ DataToJSON("stats", BuildStatsMap(Stats)) $ ","
        $ DataToJSON("died", Eval(Stats.Deaths > 0, "true", "false")) $ "}";
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

static final function string BuildStatsMap(TurboWavePlayerStatCollector Stats)
{
    return "{" $ DataToJSON("Kills", Stats.Kills)
        $ "," $ DataToJSON("KillsFP", Stats.KillsFleshpound)
        $ "," $ DataToJSON("KillsSC", Stats.KillsScrake)
        $ "," $ DataToJSON("Damage", Stats.DamageDone)
        $ "," $ DataToJSON("DamageFP", Stats.DamageDoneFleshpound)
        $ "," $ DataToJSON("DamageSC", Stats.DamageDoneScrake)
        $ "," $ DataToJSON("ShotsFired", Stats.ShotsFired)
        $ "," $ DataToJSON("MeleeSwings", Stats.MeleeSwings)
        $ "," $ DataToJSON("ShotsHit", Stats.ShotsHit)
        $ "," $ DataToJSON("ShotsHeadshot", Stats.ShotsHeadshot)
        $ "," $ DataToJSON("Reloads", Stats.Reloads)
        $ "," $ DataToJSON("Heals", Stats.HealingDone) $ "}";
}

static final function string GetResultName(int GameResult)
{
    switch(GameResult)
    {
        case 2:
            return "won";
        case 1:
            return "lost";
    }

    return "aborted";
}


final function string GeneratePlayerJSON()
{
    local int Index;
    local array<TurboPlayerController> PlayerControllerList;
    local array<string> PlayerList;

	PlayerControllerList = class'TurboGameplayHelper'.static.GetPlayerControllerList(Level, false);

    for (Index = 0; Index < PlayerControllerList.Length; Index++)
    {
        PlayerList[PlayerList.Length] = PlayerControllerList[Index].GetPlayerIDHash();
    }

    return StringArrayToJSON("playerlist", PlayerList);
}

defaultproperties
{
    LinkMode=MODE_Text

    bBroadcastAnalytics=false
    StatsDomain="";
    StatsPort=-1;
    StatsTcpLinkClassOverride=""

    MaxRetryCount=10

    bVerboseLogging=false
}