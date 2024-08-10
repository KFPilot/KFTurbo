//Core of the KFTurbo mod. Needed for UI changes (as well as some other functionality).
class KFTurboMut extends Mutator
	config(KFTurbo);

#exec obj load file="..\Animations\KFTurboContent.ukx" package=KFTurbo
#exec obj load file="..\Animations\KFTurboExtra.ukx" package=KFTurbo
#exec obj load file="..\Textures\KFTurboHUD.utx" package=KFTurbo

var TurboCustomZedHandler CustomZedHandler;

var config String RepLinkSettingsClassString;

var config bool bDebugClientPerkRepLink;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	//Make sure fonts are added to server packages.
	AddToPackageMap("KFTurboFonts");

	if(Role != ROLE_Authority)
	{
		return;
	}

	if (!ClassIsChildOf(Level.Game.PlayerControllerClass, class'TurboPlayerController'))
	{
		Level.Game.PlayerControllerClass = class'TurboPlayerController';
		Level.Game.PlayerControllerClassName = string(class'TurboPlayerController');
	}

	Level.Game.HUDType = GetHUDReplacementClass(Level.Game.HUDType);

	if (DeathMatch(Level.Game) != None)
	{
		DeathMatch(Level.Game).LoginMenuClass = string(class'TurboInvasionLoginMenu');
	}

	CustomZedHandler = Spawn(class'TurboCustomZedHandler', self);

	if (bDebugClientPerkRepLink)
	{
		Spawn(class'TurboRepLinkTester', Self);
	}
	
	class'TurboEventHandler'.static.RegisterHandler(Self, class'TurboEventHandlerImpl');

	SetupBroadcaster();

	if (TeamGame(Level.Game) != None)
	{
		if (TeamGame(Level.Game).FriendlyFireScale <= 0.f)
		{
			TeamGame(Level.Game).FriendlyFireScale = 0.001f;
		}
	}
}

function SetupBroadcaster()
{
	local TurboBroadcastHandler TurboBroadcastHandler;
	TurboBroadcastHandler = Spawn(class'TurboBroadcastHandler', Self);

	if(Level.Game.BroadcastHandler != None)
	{
		TurboBroadcastHandler.NextBroadcastHandler = Level.Game.BroadcastHandler;
		Level.Game.BroadcastHandler = TurboBroadcastHandler;
	}
	else
	{
		Level.Game.BroadcastHandler = TurboBroadcastHandler;
	}
}

static function string GetHUDReplacementClass(string HUDClassString)
{
	if (HUDClassString ~= string(Class'ServerPerks.SRHUDKillingFloor')
		|| HUDClassString ~= Class'KFGameType'.Default.HUDType
		|| HUDClassString ~= Class'KFStoryGameInfo'.Default.HUDType)
	{
		HUDClassString = string(class'KFTurbo.TurboHUDKillingFloor');
	}

	return HUDClassString;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (KFPlayerReplicationInfo(Other) != None)
	{
		AddTurboPlayerReplicationInfo(KFPlayerReplicationInfo(Other));
	}

	//Looks like tinkering with these directly doesn't work... just replace it.
	if (KFRandomItemSpawn(Other) != None && TurboRandomItemSpawn(Other) == None)
	{
		ReplaceWith(Other, string(class'KFTurbo.TurboRandomItemSpawn'));
		return false;
	}

	return true;
}

function AddTurboPlayerReplicationInfo(KFPlayerReplicationInfo PlayerReplicationInfo)
{
	local TurboPlayerReplicationInfo TurboPRI;
	TurboPRI = Spawn(class'TurboPlayerReplicationInfo', PlayerReplicationInfo.Owner);
	TurboPRI.NextReplicationInfo = PlayerReplicationInfo.CustomReplicationInfo;
	TurboPRI.OwningReplicationInfo = PlayerReplicationInfo;
	PlayerReplicationInfo.CustomReplicationInfo = TurboPRI;
}

function ModifyPlayer(Pawn Other)
{
	Super.ModifyPlayer(Other);

	AddChatWatcher(Other);
}

function AddChatWatcher(Pawn Other)
{
	local ChatWatcher ChatWatcherInv;

	if (!Other.IsHumanControlled())
	{
		return;
	}

	ChatWatcherInv = Spawn(class'ChatWatcher', Other);

	if (ChatWatcherInv == None)
	{
		return;
	}

	Other.AddInventory(ChatWatcherInv);
}

simulated function String GetHumanReadableName()
{
	return FriendlyName;
}

defaultproperties
{
	bDebugClientPerkRepLink=false
	bAddToServerPackages=True
	GroupName="KF-KFTurbo"
	FriendlyName="Killing Floor Turbo"
	Description="Mutator for KFTurbo."
}