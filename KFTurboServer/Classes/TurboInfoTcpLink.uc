//Killing Floor Turbo TurboInfoTcpLink
//Creates a connection and awaits specific requests for info about the current game.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboInfoTcpLink extends TcpLink
    config(KFTurbo);

var globalconfig bool bCreateInfoLink;
var globalconfig int InfoPort;
var globalconfig string InfoTcpLinkClassOverride;

var string CRLF;

const GAME_INFO = "GAMEINFO";
const PLAYER_INFO = "PLAYERINFO";
const WAVE_INFO = "WAVEINFO";
var array<string> PendingCommandList;
var float NextNotReadyTime;


static function bool ShouldBroadcastInfo()
{
    return default.bCreateInfoLink && default.InfoPort >= 0;
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
    log("KFTurbo has created a stats TCP link!", 'KFTurbo');

	CRLF = Chr(13) $ Chr(10);

    LinkMode = MODE_Text;
    ReceiveMode = RMODE_Event;
}

auto state SetupConnection
{
    function ReceivedText(string Text)
    {
        if (NextNotReadyTime >= Level.TimeSeconds)
        {
            return;
        }

        NextNotReadyTime = Level.TimeSeconds + 1.f;
        SendText("{\"type\":\"not_ready\"}");
    }

Begin:
    Sleep(5.f);
    StartConnection();
}

function StartConnection()
{
    BindPort(InfoPort);
    Listen();
    GotoState('AwaitingCommands');
}

state ConnectionReady
{
    function ReceivedText(string Text)
    {
        ProcessCommand(Text);
    }
}

state AwaitingCommands extends ConnectionReady
{
    function ProcessCommand(string Text)
    {
        Global.ProcessCommand(Text);

        if (PendingCommandList.Length != 0)
        {
            GotoState('ProcessCommands');
        }
    }
}

state ProcessCommands extends ConnectionReady
{
Begin:
    while (PendingCommandList.Length != 0)
    {
        Sleep(0.25f);

        if (PendingCommandList.Length == 0)
        {
            continue;
        }
        
        HandlePendingCommand();
    }

    GotoState('AwaitingCommands');
}

function ProcessCommand(string Text)
{
    Text = Caps(Text);
    switch (Text)
    {
        case GAME_INFO:
        case WAVE_INFO:
        case PLAYER_INFO:
            break;
        default:
            return;
    }

    PendingCommandList.Length = PendingCommandList.Length + 1;
    PendingCommandList[PendingCommandList.Length - 1] = Text;
}

function HandlePendingCommand()
{
    local string PendingCommand;
    PendingCommand = PendingCommandList[0];
    PendingCommandList.Remove(0, 1);

    switch (PendingCommand)
    {
        case GAME_INFO:
            BroadcastGameInfo();
            break;
        case WAVE_INFO:
            BroadcastWaveInfo();
            break;
        case PLAYER_INFO:
            BroadcastPlayerInfo();
            break;
    }

    if (PendingCommandList.Length == 0)
    {
        GotoState('AwaitingCommands');
    }
}

function BroadcastGameInfo()
{
    local string Payload;
    Payload = "{\"type\":\"game_info\",";
    Payload $= GenerateGameJSON(Level.Game)$"}";
    SendText(Payload);
}

static final function string GenerateGameJSON(GameInfo GameInfo)
{
    local string Data;
    local KFTurboMut Mutator;
    Mutator = class'KFTurboMut'.static.FindMutator(GameInfo);
    Data = "\"mode\":\""$Mutator.GetGameType()$"\",";
    Data $= "\"session\":\""$Mutator.GetSessionID()$"\",";
    Data $= "\"wave\":\""$GameInfo.GetCurrentWaveNum()$"\"";

    return Data;
}

function BroadcastWaveInfo()
{
    local string Payload;
    Payload = "{\"type\":\"wave_info\",";
    Payload $= GenerateWaveJSON(Level.Game)$"}";
    SendText(Payload);
}

static final function string GenerateWaveJSON(GameInfo GameInfo)
{
    local string Data;
    local KFTurboGameType TurboGameType;
    TurboGameType = KFTurboGameType(GameInfo);
    Data = "\"remaining\":\""$TurboGameType.TotalMaxMonsters$"\"";

    return Data;
}

function BroadcastPlayerInfo()
{
    local string Payload;
    Payload = "{\"type\":\"player_info\", \"players\":[";
    Payload $= GeneratePlayerJSON(Level.Game)$"]}";
    SendText(Payload);
}

static final function string GeneratePlayerJSON(GameInfo GameInfo)
{
    local string Data;
    local int Index;
    local array<TurboPlayerController> PlayerList;
    local TurboPlayerController Player;
	PlayerList = class'TurboGameplayHelper'.static.GetPlayerControllerList(GameInfo.Level, true);

    for (Index = 0; Index < PlayerList.Length; Index++)
    {
        if (Index != 0)
        {
            Data $= ",";
        }

        Player = PlayerList[Index];

        if (Player.PlayerReplicationInfo.bOnlySpectator)
        {
            Data $= "{\"id\":\""$Player.GetPlayerIDHash()$"\",\"name\":\""$Player.PlayerReplicationInfo.PlayerName$"\",\"spectator\":\"true\"}";
            continue;
        }

        Data $= "{\"id\":\""$Player.GetPlayerIDHash()$"\",\"name\":\""$Player.PlayerReplicationInfo.PlayerName$"\",\"spectator\":\"false\"}";
    }

    return Data;
}

defaultproperties
{
    LinkMode=MODE_Text

    bCreateInfoLink=false
    InfoPort=-1;
    InfoTcpLinkClassOverride=""
}