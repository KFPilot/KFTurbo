//Core of the KFTurbo mod. Needed for server-side only changes.
class KFTurboServerMut extends Mutator;

var TurboRepLinkHandler RepLinkHandler;
var bool bSpawnedRandomizerHelper;

simulated function PostBeginPlay()
{
	local KFTurboRandomizerMut KFTurboRandomizerMutator;
	local ServerPerksMut ServerPerksMutator;
	Super.PostBeginPlay();

	if(Role == ROLE_Authority)
	{
		//Manages the creation of KFPRepLink for players joining.
		RepLinkHandler = Spawn(class'TurboRepLinkHandler', self);
	}

	foreach Level.AllActors( class'KFTurboRandomizerMut', KFTurboRandomizerMutator )
	{
		SpawnRandomizerHelper();
		break;
	}

	//Tell server perks to turn off progression saving if we're disabling them.
	foreach Level.AllActors( class'ServerPerksMut', ServerPerksMutator )
	{
		ServerPerksMutator.bNoSavingProgress = !class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(Self);
		break;
	}
}

function AddMutator(Mutator M)
{
	local KFTurboRandomizerMut KFTurboRandomizerMutator;
	local ServerPerksMut ServerPerksMutator;

	Super.AddMutator(M);

	KFTurboRandomizerMutator = KFTurboRandomizerMut(M);
	
	if (KFTurboRandomizerMutator != None)
	{
		SpawnRandomizerHelper();
	}

	ServerPerksMutator = ServerPerksMut(M);
	
	//Tell server perks to turn off progression saving if we're disabling them.
	if (ServerPerksMutator != None)
	{
		ServerPerksMutator.bNoSavingProgress = !class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(Self);
	}
}

function SpawnRandomizerHelper()
{
	if (bSpawnedRandomizerHelper)
	{
		return;
	}

	bSpawnedRandomizerHelper = true;
	Spawn(class'TurboRandomizetHelper', Self);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (RepLinkHandler != none && ServerStStats(Other) != None)
	{
		RepLinkHandler.OnServerStatsAdded(ServerStStats(Other));
	}

	return true;
}

simulated function String GetHumanReadableName()
{
	return FriendlyName;
}

defaultproperties
{
	bAddToServerPackages=False
	GroupName="KF-KFTurboServer"
	FriendlyName="Killing Floor Turbo Server"
	Description="Mutator for KFTurbo Server."

	bSpawnedRandomizerHelper=false
}