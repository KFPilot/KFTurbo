//Killing Floor Turbo KFTurboServerMut
//Server-only mutator. Needed for interactions with server-only code in ServerPerksMut.
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboServerMut extends Mutator;

var TurboRepLinkHandler RepLinkHandler;

simulated function PostBeginPlay()
{
	local ServerPerksMut ServerPerksMutator;
	Super.PostBeginPlay();

	if(Role == ROLE_Authority)
	{
		//Manages the creation of KFPRepLink for players joining.
		RepLinkHandler = Spawn(class'TurboRepLinkHandler', self);
	}

	//Tell server perks to turn off progression saving if we're disabling them.
	foreach Level.AllActors( class'ServerPerksMut', ServerPerksMutator )
	{
		ServerPerksMutator.bNoSavingProgress = !class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(Self);
		ServerPerksMutator.bAllowAlwaysPerkChanges = ServerPerksMutator.bAllowAlwaysPerkChanges || class'KFTurboGameType'.static.StaticIsTestGameType(Self);
		
		if (!ServerPerksMutator.bEnabledEmoIcons)
		{
			ForceEnableEmotes(ServerPerksMutator);
		}
		break;
	}

	//Listen for disabling stats/achievements/perk selection.
	if (KFTurboGameType(Level.Game) != None)
	{
		KFTurboGameType(Level.Game).OnStatsAndAchievementsDisabled = OnStatsAndAchievementsDisabled;
		KFTurboGameType(Level.Game).LockPerkSelection = LockPerkSelection;
	}
}

//ServerPerks likes to not do this - try to force it!
function ForceEnableEmotes(ServerPerksMut ServerPerksMutator)
{
	local int i, j;
	local Texture T;

	j = 0;
	for( i=0; i<ServerPerksMutator.SmileyTags.Length; ++i )
	{
		if( ServerPerksMutator.SmileyTags[i].IconTexture=="" || ServerPerksMutator.SmileyTags[i].IconTag=="" )
			continue;
		T = Texture(DynamicLoadObject(ServerPerksMutator.SmileyTags[i].IconTexture,class'Texture',true));
		if( T==None )
			continue;
		ServerPerksMutator.ImplementPackage(T);
		ServerPerksMutator.SmileyMsgs.Length = j+1;
		ServerPerksMutator.SmileyMsgs[j].SmileyTex = T;
		if( ServerPerksMutator.SmileyTags[i].bCaseInsensitive )
			ServerPerksMutator.SmileyMsgs[j].SmileyTag = Caps(ServerPerksMutator.SmileyTags[i].IconTag);
		else ServerPerksMutator.SmileyMsgs[j].SmileyTag = ServerPerksMutator.SmileyTags[i].IconTag;
		ServerPerksMutator.SmileyMsgs[j].bInCAPS = ServerPerksMutator.SmileyTags[i].bCaseInsensitive;
		++j;
	}

	ServerPerksMutator.bEnabledEmoIcons = (j!=0);
}

function AddMutator(Mutator M)
{
	local ServerPerksMut ServerPerksMutator;

	Super.AddMutator(M);

	ServerPerksMutator = ServerPerksMut(M);
	
	//Tell server perks to turn off progression saving if we're disabling them.
	if (ServerPerksMutator != None)
	{
		ServerPerksMutator.bNoSavingProgress = !class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(Self);
		ServerPerksMutator.bAllowAlwaysPerkChanges = ServerPerksMutator.bAllowAlwaysPerkChanges || class'KFTurboGameType'.static.StaticIsTestGameType(Self);

		if (!ServerPerksMutator.bEnabledEmoIcons)
		{
			ForceEnableEmotes(ServerPerksMutator);
		}
	}
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (RepLinkHandler != none && ServerStStats(Other) != None)
	{
		RepLinkHandler.OnServerStatsAdded(ServerStStats(Other));
	}

	return true;
}

function OnStatsAndAchievementsDisabled()
{	
	local ServerPerksMut ServerPerksMut;

	foreach Level.AllActors( class'ServerPerksMut', ServerPerksMut )
		break;

	if (ServerPerksMut == None)
	{
		return;
	}

	ServerPerksMut.bNoSavingProgress = true;
}

function LockPerkSelection(bool bLock)
{	
	local ServerPerksMut ServerPerksMut;

	foreach Level.AllActors( class'ServerPerksMut', ServerPerksMut )
		break;

	if (ServerPerksMut == None)
	{
		return;
	}

	ServerPerksMut.bNoPerkChanges = bLock;
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
}