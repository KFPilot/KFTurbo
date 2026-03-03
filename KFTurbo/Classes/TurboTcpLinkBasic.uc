//Killing Floor Turbo TurboTcpLinkBasic
//Basic implementation of a single connection TcpLink. Handles domain resolving, connecting, reconnecting and keep alive.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTcpLinkBasic extends TurboTcpLink
    abstract;

//Should be used to terminate any payload so recipient knows when payloads start and end.
const CRLF = "\r\n";
//Used by keep alive timer if enabled. Sent as the packet to keep the connection up.
const KeepAliveData = "keepalive\r\n";

var config bool bShouldCreateLink;
var config string TargetDomain;
var config int TargetPort;
var config string TcpLinkClassOverride;

//How long to wait before trying to resolve domain again after a failure.
var int DomainResolveRetryInterval;
//How long to wait before considering the current Open/OpenNoSteam attempt is a failure and to try again.
var int ConnectionAttemptTimeout;
//Whether to use Open or OpenNoSteam when opening a connection.
var bool bUseNoSteam;
//If true, timer will be used in Connected state to send keepalive$CRLF to keep the connection open.
var bool bUseTimerForKeepAlive;
//If bUseTimerForKeepAlive is true, KeepAliveInterval will be used as the frequency to send keep alive packet.
var int KeepAliveInterval;

var IpAddr TargetAddress;

static function bool ShouldCreateLink()
{
    return default.bShouldCreateLink && default.TargetDomain != "" && default.TargetPort >= 0;
}

static function class<TurboTcpLinkBasic> GetTcpLinkClass()
{
    local class<TurboTcpLinkBasic> TcpLinkClass;
    if (default.TcpLinkClassOverride != "")
    {
        TcpLinkClass = class<TurboTcpLinkBasic>(DynamicLoadObject(default.TcpLinkClassOverride, class'class'));
    }

    if (TcpLinkClass == None)
    {
        TcpLinkClass = default.Class;
    }

    return TcpLinkClass;
}


function PostBeginPlay()
{
    Super.PostBeginPlay();

    LinkMode = MODE_Text;
    ReceiveMode = RMODE_Event;
}

function StartConnection()
{
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
        Resolve(TargetDomain);
    }
    
    function ResolveFailed()
    {
        SetTimer(DomainResolveRetryInterval, false);
    }

    function Resolved(IpAddr Addr)
    {
        TargetAddress = Addr;
        TargetAddress.Port = TargetPort;
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

    if (bUseNoSteam)
    {
        OpenNoSteam(TargetAddress);
    }
    else
    {
        Open(TargetAddress);
    }

    Sleep(ConnectionAttemptTimeout);
    if (!IsConnected())
    {
        goto 'Begin';
    }
}

state Connected
{
    function BeginState()
    {
        if (bUseTimerForKeepAlive)
        {
            SetTimer(KeepAliveInterval, true);
        }
    }

    function EndState()
    {
        if (bUseTimerForKeepAlive)
        {
            SetTimer(0.f, false);
        }
    }

    function Closed()
    {
        GotoState('AttemptConnection');
    }

    function Timer()
    {
        if (bUseTimerForKeepAlive)
        {
            SendText(KeepAliveData);
        }
    }
}

defaultproperties
{
    LinkMode=MODE_Text

    bShouldCreateLink=false
    TargetDomain="";
    TargetPort=-1;
    TcpLinkClassOverride=""

    DomainResolveRetryInterval=5
    ConnectionAttemptTimeout=10
    bUseNoSteam=true

    bUseTimerForKeepAlive=true
    KeepAliveInterval=5
}