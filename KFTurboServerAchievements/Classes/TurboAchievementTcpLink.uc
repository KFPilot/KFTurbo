//Killing Floor Turbo TurboAchievementTcpLink
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievementTcpLink extends TcpLink;

var globalconfig bool bRemoteDatabase;
var globalconfig string AchievementsDomain;
var globalconfig int AchievementsPort;
var globalconfig string AchievementsTcpLinkClassOverride;

var IpAddr StatsAddress;

var string CRLF;

var array<string> DeferredDataList;
var int DeferredDataIndex;

var int MaxRetryCount;

static function bool ShouldUseRemoteDatabase()
{
    return default.bRemoteDatabase && default.AchievementsDomain != "" && default.AchievementsPort >= 0;
}

static function class<TurboAchievementTcpLink> GetStatsTcpLinkClass()
{
    local class<TurboAchievementTcpLink> TcpLinkClass;
    if (default.AchievementsTcpLinkClassOverride != "")
    {
        TcpLinkClass = class<TurboAchievementTcpLink>(DynamicLoadObject(default.AchievementsTcpLinkClassOverride, class'class'));
    }

    if (TcpLinkClass == None)
    {
        TcpLinkClass = class'TurboAchievementTcpLink';
    }

    return TcpLinkClass;
}

static final function TurboAchievementTcpLink FindStatsTcpLink(GameInfo GameInfo)
{
    local KFTurboAchievementMut TurboMut;
    TurboMut = class'KFTurboAchievementMut'.static.FindMutator(GameInfo);
    return TurboMut.AchievementTcpLink;
}

function PostBeginPlay()
{
    log("KFTurboAchievements has created an achievement TCP link!", 'KFTurboAchievements');

	CRLF = Chr(13) $ Chr(10);

    LinkMode = MODE_Text;
    ReceiveMode = RMODE_Event;
}

defaultproperties
{
    LinkMode=MODE_Text

    bRemoteDatabase=false
    AchievementsDomain="";
    AchievementsPort=-1;
    AchievementsTcpLinkClassOverride=""

    MaxRetryCount=5
}
