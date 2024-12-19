//Killing Floor Turbo TurboVersionTcpLink
//Checks if there's an update for KFTurbo.
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVersionTcpLink extends TcpLink;

var string TurboDomain;
var string TurboReleaseURL;

var IpAddr TurboAddress;

var string CRLF;

function PostBeginPlay()
{
    log("KFTurbo is preparing to check for a new version!");

	CRLF = Chr(13) $ Chr(10);

    LinkMode = MODE_Text;
    ReceiveMode = RMODE_Event;
    BindPort();
    Resolve(TurboDomain);
}

event Resolved(IpAddr ResolvedAddress)
{
    TurboAddress = ResolvedAddress;
    TurboAddress.Port = 80;

    if (!OpenNoSteam(TurboAddress))
    {
        Close();
        LifeSpan = 1.f;
    }
}

event ResolveFailed()
{
    log("Failed to resolve version domain.");

    if (!OpenNoSteam(TurboAddress))
    {
        Close();
        LifeSpan = 1.f;
    }
}

function Opened()
{
    log("Connection to"@TurboDomain@"opened. Requesting version information.");
	SendText("GET "$TurboReleaseURL$" HTTP/1.1"$CRLF$"Host: "$TurboDomain$CRLF$CRLF$CRLF);
}

event ReceivedText( string Text )
{
    local int Index;
    local array<string> DataList;

    //Check if we're receiving KFTurbo's version data.
    if (InStr(Text, "KFTURBO DATA") == -1)
    {
        return;
    }

    Split(Text, Chr(10), DataList);
    for (Index = 0; Index < DataList.Length; Index++)
    {
        if (InStr(DataList[Index], "Version: ") != -1)
        {
            CheckVersionNumber(Mid(DataList[Index], 9));
            continue;
        }
    }

    Close();
    LifeSpan = 1.f;
}

function CheckVersionNumber(string Version)
{
    local KFTurboMut Mutator;
    Mutator = class'KFTurboMut'.static.FindMutator(Level.Game);

    if (Mutator == None)
    {
        return;
    }

    if (Mutator.CheckIfNewerVersion(Version))
    {
        log("==========================================");
        log("A NEW VERSION OF KFTURBO IS AVAILABLE.");
        log("LOCAL:"@class'KFTurboMut'.static.GetTurboVersionID());
        log("LATEST:"@Version);
        log("==========================================");
    }
    else
    {
        log("KFTurbo version check complete! (Local:"@class'KFTurboMut'.static.GetTurboVersionID()$") (Latest:"@Version$")");
    }
}


defaultproperties
{
    TurboDomain="version.kfturbo.com"
    TurboReleaseURL = "/version.txt"
    LinkMode=MODE_Text
}