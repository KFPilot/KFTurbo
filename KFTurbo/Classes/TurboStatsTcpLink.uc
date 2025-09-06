//Killing Floor Turbo TurboStatsTcpLink
//Sends analytics data to a specified endpoint. All content is deferred over multiple frames.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboStatsTcpLink extends TcpLink
    config(KFTurbo);

var globalconfig bool bBroadcastAnalytics;
var globalconfig string StatsDomain;
var globalconfig int StatsPort;
var globalconfig string StatsTcpLinkClassOverride;

var KFTurboMut Mutator;
var IpAddr StatsAddress;

var string CRLF;

var array<string> DeferredDataList;
var int DeferredDataIndex;

var int MaxRetryCount;

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

	CRLF = Chr(13) $ Chr(10);

    LinkMode = MODE_Text;
    ReceiveMode = RMODE_Event;
}

function OnGameStart()
{
    BindPort();
    Resolve(StatsDomain);
}

event Resolved(IpAddr ResolvedAddress)
{
    log("Resolved stats domain"@StatsDomain$".", 'KFTurboStatsTcp');
    StatsAddress = ResolvedAddress;
    StatsAddress.Port = StatsPort;

    if (!OpenNoSteam(StatsAddress))
    {
        log("OpenNoSteam failed for stats domain"@StatsDomain$"!", 'KFTurboStatsTcp');
        Close();
        LifeSpan = 1.f;
    }
}

event ResolveFailed()
{
    log("Failed to resolve stats domain.", 'KFTurboStatsTcp');

    Close();
    LifeSpan = 1.f;
}

function Opened()
{
    log("Connection to stats domain"@StatsDomain@"opened. Sending game start payload.", 'KFTurboStatsTcp');

    DeferredDataList.Insert(0, 1);
    DeferredDataList[0] = BuildGameStartPayload(); //Make sure this is the first thing we send out.
    GotoState('ConnectionReady');
}

function SendData(string Data)
{
    if (DeferredDataList.Length > 50)
    {
        log("WARNING: Stats data buffer has exceeded 50 entries! Removing oldest entry before adding a new one.", 'KFTurboStatsTcp');
        DeferredDataList.Remove(0, 1);
    }
    else if (DeferredDataList.Length > 10)
    {
        log("WARNING: Stats data buffer has exceeded 10 entries. The tcp link is falling behind for an unknown reason.", 'KFTurboStatsTcp');
    }

    DeferredDataList[DeferredDataList.Length] = Data;
}

function FlushData() {}

state ConnectionReady
{
    function BeginState()
    {
        SetTimer(9.f, true);
    }

    function EndState()
    {
        SetTimer(0.f, false);
    }

    function Timer()
    {
        SendData("keepalive");
    }

    function FlushData()
    {
        GotoState('FlushAllData');
    }

Begin:
    while (true)
    {
        Sleep(0.15f);

        if (DeferredDataList.Length == 0)
        {
            continue;
        }

        SendText(DeferredDataList[0]);
        DeferredDataList.Remove(0, 1);
    }
}

function Closed()
{
    log("Connection to stats domain"@StatsDomain@"was closed.", 'KFTurboStatsTcp');
    GotoState('ConnectionClosed');
}

//Will attempt to re-establish the connection to the stats server.
state ConnectionClosed
{
Begin:
    if (MaxRetryCount <= 0)
    {
        log("Connection to stats domain"@StatsDomain@"failed"@default.MaxRetryCount@"times. Stopping reconnection attempts.", 'KFTurboStatsTcp');
        GotoState('ConnectionFailed');
        stop;
    }

    MaxRetryCount--;

    Sleep(1.f);
    Close();
    Sleep(1.f);
    BindPort();
    Resolve(StatsDomain);
}

//Game ended. Get all this data out asap.
state FlushAllData
{
    function OnGameStart() {}
    function Opened() {}

    function Closed()
    {
        if (DeferredDataList.Length != 0)
        {
            log("WARNING: Connection to stats domain was closed before buffer was finished sending! ", 'KFTurboStatsTcp');
        }

        GotoState('ConnectionFailed');
    }

Begin:
    while (true)
    {
        Sleep(0.1f);

        if (DeferredDataList.Length == 0)
        {
            break;
        }

		if (Level.bLevelChange)
        {
			Level.NextSwitchCountdown = FMax(Level.NextSwitchCountdown, 1.f);
        }

        SendText(DeferredDataList[0]);
        DeferredDataList.Remove(0, 1);
    }

    Sleep(0.1f);
    Close();
}

//Either we were unable to connect after retrying a few times or the connection was closed for an unknown reason while trying to flush data.
state ConnectionFailed
{
    function OnGameStart() {}
    function Resolved(IpAddr ResolvedAddress) {}
    function Opened() { Close(); }
    function Closed() {}
}

/*
Data payload for a game starting looks like the following;

{
    "type": "gamebegin",
    "version": "5.2.2",
    "session": "<session ID>",
    "gametype" : "turbo"
}

type - refers to the type of payload this is.
version - The KFTurbo version currently running.
session - The session ID for this game."
gametype - The type of game being played. Can be "turbo", "turbocardgame", "turborandomizer", "turboplus".
*/

final function string BuildGameStartPayload()
{
    local string Payload;

    Payload = "{%qtype%q:%qgamebegin%q,";
    Payload $= "%qversion%q:%q"$Mutator.GetTurboVersionID()$"%q,";
    Payload $= "%qsession%q:%q"$Mutator.GetSessionID()$"%q,";
    Payload $= "%qgametype%q:%q"$Mutator.GetGameType()$"%q}";
    
    Payload = Repl(Payload, "%q", Chr(34));
    return Payload;
}

/*
Data payload for a game ending looks like the following;

{
    "type": "gameend",
    "version": "5.2.2",
    "session": "<session ID>",
    "wavenum" : 3,
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
    SendData(BuildGameEndPayload(Level.Game.GetCurrentWaveNum(), GetResultName(Result)));
    FlushData();
}

final function string BuildGameEndPayload(int WaveNum, string Result)
{
    local string Payload;

    Payload = "{%qtype%q:%qgameend%q,";
    Payload $= "%qversion%q:%q"$Mutator.GetTurboVersionID()$"%q,";
    Payload $= "%qsession%q:%q"$Mutator.GetSessionID()$"%q,";
    Payload $= "%qwavenum%q:"$WaveNum$",";
    Payload $= "%qresult%q:%q"$Result$"%q}";
    
    Payload = Repl(Payload, "%q", Chr(34));
    return Payload;
}

/*
Data payload for a wave starting looks like the following;

{
    "type": "wavestart",
    "version": "5.2.2",
    "session": "<session ID>",
    "wavenum" : 2,
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
    local string Payload;

    Payload = "{%qtype%q:%qwavestart%q,";
    Payload $= "%qversion%q:%q"$Mutator.GetTurboVersionID()$"%q,";
    Payload $= "%qsession%q:%q"$Mutator.GetSessionID()$"%q,";
    Payload $= "%qwavenum%q:"$WaveNum$",";
    Payload $= "%qplayerlist%q:["$GetPlayerList()$"]}";
    
    Payload = Repl(Payload, "%q", Chr(34));
    return Payload;
}

/*
Data payload for a wave ending looks like the following;

{
    "type": "waveend",
    "version": "5.2.2",
    "session": "<session ID>",
    "wavenum" : 2
}

type - refers to the type of payload this is.
version - The KFTurbo version currently running.
session - The session ID for this game."
wavenum - The wave that started.
*/

function SendWaveEnd()
{
    SendData(BuildWaveEndPayload(Level.Game.GetCurrentWaveNum() - 1));
}

final function string BuildWaveEndPayload(int WaveNum)
{
    local string Payload;

    Payload = "{%qtype%q:%qwaveend%q,";
    Payload $= "%qversion%q:%q"$Mutator.GetTurboVersionID()$"%q,";
    Payload $= "%qsession%q:%q"$Mutator.GetSessionID()$"%q,";
    Payload $= "%qwavenum%q:"$WaveNum$"}";
    
    Payload = Repl(Payload, "%q", Chr(34));
    return Payload;
}

/*
Data payload for a player's wave stats looks like the following;

{
    "type": "wavestats",
    "version": "5.2.2",
    "session": "<session ID>",
    "wavenum" : 8,
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

    SendData(BuildWaveStatsPayload(Stats));
}

final function string BuildWaveStatsPayload(TurboWavePlayerStatCollector Stats)
{
    local string Payload;

    Payload = "{%qtype%q:%qwavestats%q,";
    Payload $= "%qversion%q:%q"$Mutator.GetTurboVersionID()$"%q,";
    Payload $= "%qsession%q:%q"$Mutator.GetSessionID()$"%q,";
    Payload $= "%qwavenum%q:"$Stats.Wave$",";
    Payload $= "%qplayer%q:%q"$Stats.PlayerID$"%q,";
    Payload $= "%qplayername%q:%q"$Stats.GetPlayerName()$"%q,";
    Payload $= "%qperk%q:%q"$GetPerkID(Stats.PlayerTPRI)$"%q,";
    Payload $= "%qstats%q:{"$BuildStatsMap(Stats)$"},";
    Payload $= "%qdied%q:"$Locs(string(Stats.Deaths > 0))$"}";
    
    Payload = Repl(Payload, "%q", Chr(34));
    return Payload;
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

    return "NONE";
}

static final function string BuildStatsMap(TurboWavePlayerStatCollector Stats)
{
    local string StatMap;
    StatMap = "";
    StatMap $= AppendStat("Kills", Stats.Kills);
    StatMap $= AppendStat("KillsFP", Stats.KillsFleshpound);
    StatMap $= AppendStat("KillsSC", Stats.KillsScrake);
    
    StatMap $= AppendStat("Damage", Stats.DamageDone);
    StatMap $= AppendStat("DamageFP", Stats.DamageDoneFleshpound);
    StatMap $= AppendStat("DamageSC", Stats.DamageDoneScrake);
    
    StatMap $= AppendStat("ShotsFired", Stats.ShotsFired);
    StatMap $= AppendStat("MeleeSwings", Stats.MeleeSwings);
    StatMap $= AppendStat("ShotsHit", Stats.ShotsHit);
    StatMap $= AppendStat("ShotsHeadshot", Stats.ShotsHeadshot);

    StatMap $= AppendStat("Reloads", Stats.Reloads);

    StatMap $= AppendStat("Heals", Stats.HealingDone);

    //Remove starting comma.
    if (StatMap != "" && Left(StatMap, 1) == ",")
    {
        StatMap = Mid(StatMap, 1);
    }

    return StatMap;
}

static final function string AppendStat(string StatName, int StatAmount)
{
    if (StatAmount <= 0)
    {
        return "";
    }

    return ",%q"$StatName$"%q:"$StatAmount;
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

final function string GetPlayerList()
{
    local Controller C;
    local string PlayerList;
    PlayerList = "";

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if (!C.bIsPlayer || C.PlayerReplicationInfo == None || C.PlayerReplicationInfo.bOnlySpectator || PlayerController(C) == None)
        {
            continue;
        }

        PlayerList $= ",%q"$PlayerController(C).GetPlayerIDHash()$"%q";
    }

    if (PlayerList != "" && Left(PlayerList, 1) == ",")
    {
        PlayerList = Mid(PlayerList, 1);
    }

    return PlayerList;
}

defaultproperties
{
    LinkMode=MODE_Text

    bBroadcastAnalytics=false
    StatsDomain="";
    StatsPort=-1;
    StatsTcpLinkClassOverride=""

    MaxRetryCount=5
}