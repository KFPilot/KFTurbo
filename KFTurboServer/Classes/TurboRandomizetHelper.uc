class TurboRandomizetHelper extends Info;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (KFTurboGameType(Level.Game) != None)
	{
		KFTurboGameType(Level.Game).OnStatsAndAchievementsDisabled = OnStatsAndAchievementsDisabled;
	}
}

function Tick(float DeltaTime)
{
	local ServerPerksMut ServerPerksMut;

	foreach Level.AllActors( class'ServerPerksMut', ServerPerksMut )
		break;

	if (ServerPerksMut == None)
	{
		return;
	}

	ServerPerksMut.bNoPerkChanges = true;
	Disable('Tick');
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