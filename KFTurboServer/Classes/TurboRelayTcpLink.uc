//Killing Floor Turbo TurboRelayTcpLink
//Responsible for relaying player messages to a target domain/port.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboRelayTcpLink extends TurboTcpLink
    config(KFTurbo);

var globalconfig bool bCreateRelayLink;
var globalconfig string RelayDomain;
var globalconfig int RelayPort;
var globalconfig string RelayTcpLinkClassOverride;

var IpAddr ResolvedDomainAddress;

var string CRLF;

//JSON keys
//String (SteamID)
const STEAM_ID = "id";
//String (player display name)
const PLAYER_NAME = "name";
//String (chat message)
const MESSAGE = "msg";

struct RelayEntry
{
    var string PlayerName;
    var string SteamID;
    var string Message;
};

var array<RelayEntry> MessageBuffer;
var float SendInterval;

static function bool ShouldCreateRelay()
{
    return default.bCreateRelayLink && default.RelayDomain != "" && default.RelayPort >= 0;
}

static function class<TurboRelayTcpLink> GetRelayTcpLinkClass()
{
    local class<TurboRelayTcpLink> TcpLinkClass;
    if (default.RelayTcpLinkClassOverride != "")
    {
        TcpLinkClass = class<TurboRelayTcpLink>(DynamicLoadObject(default.RelayTcpLinkClassOverride, class'class'));
    }

    if (TcpLinkClass == None)
    {
        TcpLinkClass = class'TurboRelayTcpLink';
    }

    return TcpLinkClass;
}

static final function TurboRelayTcpLink FindRelayTcpLink(GameInfo GameInfo)
{
    local KFTurboServerMut TurboServerMut;
    TurboServerMut = class'KFTurboServerMut'.static.FindMutator(GameInfo);

    if (TurboServerMut != None)
    {
        return TurboServerMut.RelayTcpLink;
    }

    return None;
}

function PostBeginPlay()
{
    log("KFTurbo has created a relay TCP link!", 'KFTurboRelayTcpLink');

	CRLF = Chr(13) $ Chr(10);

    LinkMode = MODE_Text;
    ReceiveMode = RMODE_Event;

    GotoState('AttemptResolve');
}

function RelayMessage(PlayerController Sender, string Message)
{
    local RelayEntry Entry;

    Entry.SteamID = Sender.GetPlayerIDHash();
    Entry.PlayerName = Sender.PlayerReplicationInfo.PlayerName;
    Entry.Message = Message;

    MessageBuffer[MessageBuffer.Length] = Entry;
}

function SendNextMessage()
{
    local RelayEntry Entry;

    if (MessageBuffer.Length == 0)
    {
        return;
    }

    Entry = MessageBuffer[0];
    MessageBuffer.Remove(0, 1);

    SendText("{"$StringToJSON(STEAM_ID, Entry.SteamID)$","
        $StringToJSON(PLAYER_NAME, Sanitize(Entry.PlayerName))$","
        $StringToJSON(MESSAGE, Sanitize(Entry.Message))$"}"$CRLF);
}

state AttemptResolve
{
    function BeginState()
    {
        log("Attempting to resolve relay domain.", 'KFTurboRelayTcpLink');
        SetTimer(1.f, false);
    }

    function Timer()
    {
        Resolve(RelayDomain);
    }

    function ResolveFailed()
    {
        SetTimer(10.f, false);
    }

    function Resolved(IpAddr Addr)
    {
        ResolvedDomainAddress = Addr;
        ResolvedDomainAddress.Port = RelayPort;
        GotoState('AttemptConnection');
    }

    function Closed() {}
}

state AttemptConnection
{
    function Opened()
    {
        GotoState('Connected');
    }

    function Closed() {}

Begin:
    log("Attempting to connect to relay.", 'KFTurboRelayTcpLink');
    Sleep(1.f);
    OpenNoSteam(ResolvedDomainAddress);
    Sleep(10.f);
    if (!IsConnected())
    {
        goto 'Begin';
    }
}

state Connected
{
    function Timer()
    {
        SendNextMessage();
    }

    function BeginState()
    {
        SetTimer(SendInterval, true);
    }

    function EndState()
    {
        SetTimer(0.f, false);
    }

    function Closed()
    {
        GotoState('AttemptConnection');
    }
}

defaultproperties
{
    LinkMode=MODE_Text

    bCreateRelayLink=false
    RelayDomain=""
    RelayPort=-1
    RelayTcpLinkClassOverride=""
    SendInterval=0.1
}
