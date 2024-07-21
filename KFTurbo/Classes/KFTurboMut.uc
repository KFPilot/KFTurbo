//Core of the KFTurbo mod. Needed for UI changes (as well as some other functionality).
class KFTurboMut extends Mutator
	config(KFTurbo);

#exec obj load file="..\Animations\KFTurboContent.ukx" package=KFTurbo
#exec obj load file="..\Animations\KFTurboExtra.ukx" package=KFTurbo
#exec obj load file="..\Textures\KFTurboHUD.utx" package=KFTurbo

var TurboCustomZedHandler CustomZedHandler;

var config String RepLinkSettingsClassString;
var class<TurboRepLinkSettings> RepLinkSettingsClass;
var TurboRepLinkSettings RepLinkSettings;

var config bool bDebugClientPerkRepLink;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(Role == ROLE_Authority)
	{
		if (!ClassIsChildOf(Level.Game.PlayerControllerClass, class'TurboPlayerController'))
		{
			Level.Game.PlayerControllerClass = class'TurboPlayerController';
			Level.Game.PlayerControllerClassName = string(class'TurboPlayerController');
		}

		Level.Game.HUDType = GetHUDReplacementClass(Level.Game.HUDType);

		DeathMatch(Level.Game).LoginMenuClass = string(class'TurboInvasionLoginMenu');

		//Every 5 seconds check if our queued spawn has a replaceable zed.
		CustomZedHandler = Spawn(class'TurboCustomZedHandler', self);

		if (bDebugClientPerkRepLink)
		{
			Spawn(class'TurboRepLinkTester', Self);
		}

		if (KFGameType(Level.Game) != None)
		{
			
		}
	}

	//Make sure fonts are added to server packages.
	AddToPackageMap("KFTurboFonts");
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

//Called every time a ServerStStats is made (but we only want to do this once).
function InitializeRepLinkSettings()
{
	if (Role != ROLE_Authority)
	{
		return;
	}

	if (RepLinkSettings != none)
	{
		return;
	}

	log("Attempting setup of RepLinkSettingsClass with"@RepLinkSettingsClassString, 'KFTurbo');
	RepLinkSettingsClass = class<TurboRepLinkSettings>(DynamicLoadObject(RepLinkSettingsClassString, class'Class'));

	if (RepLinkSettingsClass == none)
	{
		RepLinkSettingsClass = class'TurboRepLinkSettings';
	}

	RepLinkSettings = new(self) RepLinkSettingsClass;
	RepLinkSettings.Initialize();
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (KFPlayerReplicationInfo(Other) != None)
	{
		AddTurboPlayerReplicationInfo(KFPlayerReplicationInfo(Other));
	}

	if (KFRandomItemSpawn(Other) != None)
	{
		UpdateRandomItemPickup(KFRandomItemSpawn(Other));
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

function UpdateRandomItemPickup(KFRandomItemSpawn PickupSpawner)
{
	//Randomizer may have set these to none - so try to respect that.
	if (PickupSpawner.PickupClasses[1] == PickupSpawner.default.PickupClasses[1])
	{
		PickupSpawner.PickupClasses[1] = Class'KFTurbo.W_Shotgun_Pickup';
	}

	if (PickupSpawner.PickupClasses[2] == PickupSpawner.default.PickupClasses[2])
	{
		PickupSpawner.PickupClasses[2] = Class'KFTurbo.W_Bullpup_Pickup';
	}

	if (PickupSpawner.PickupClasses[3] == PickupSpawner.default.PickupClasses[3])
	{
		PickupSpawner.PickupClasses[3] = Class'KFTurbo.W_Deagle_Pickup';
	}

	if (PickupSpawner.PickupClasses[4] == PickupSpawner.default.PickupClasses[4])
	{
		PickupSpawner.PickupClasses[4] = Class'KFTurbo.W_LAR_Pickup';
	}

	if (PickupSpawner.PickupClasses[5] == PickupSpawner.default.PickupClasses[5])
	{
		PickupSpawner.PickupClasses[5] = Class'KFTurbo.W_Axe_Pickup';
	}
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