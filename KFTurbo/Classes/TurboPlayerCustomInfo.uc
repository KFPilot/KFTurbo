//Killing Floor Turbo TurboPlayerCustomInfo
//Actor that can contain custom info per-player. May replicate. Registration should be automatically handled via Tick.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerCustomInfo extends ReplicationInfo;

var TurboPlayerReplicationInfo PlayerTPRI;
var float ResolveTimeout;

replication
{
	reliable if (Role == ROLE_Authority)
		PlayerTPRI;
}

static final function TurboPlayerCustomInfo FindCustomInfo(TurboPlayerReplicationInfo TPRI)
{
	local int Index;

	if (TPRI == None || TPRI.bOnlySpectator)
	{
		return None;
	}

	for (Index = TPRI.PlayerCustomInfoList.Length - 1; Index >= 0; Index--)
	{
		if (TPRI.PlayerCustomInfoList[Index] == None)
		{
			TPRI.PlayerCustomInfoList.Remove(Index, 1);
			continue;
		}

		if (TPRI.PlayerCustomInfoList[Index].Class == default.Class)
		{
			return TPRI.PlayerCustomInfoList[Index];
		}
	}

	return None;
}

simulated function PostBeginPlay()
{
	if (Role == ROLE_Authority)
	{
		PlayerTPRI = TurboPlayerReplicationInfo(Controller(Owner).PlayerReplicationInfo);
		ResolveTimeout = Level.TimeSeconds + 5.f;
	}
	
	Super.PostBeginPlay();
}

simulated function Destroyed()
{
	if (!Level.bLevelChange)
	{
		Unregister();
	}
	
	Super.Destroyed();
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (PlayerTPRI == None)
	{
		if (Role == ROLE_Authority && ResolveTimeout < Level.TimeSeconds)
		{
			Destroy();
		}

		return;
	}

	Register();

	Disable('Tick');
}

simulated function TornOff()
{
	Super.TornOff();

	if (PlayerTPRI == None)
	{
		LifeSpan = 1.f;
	}
}

function ForceNetUpdate()
{
    NetUpdateTime = Max(Level.TimeSeconds - ((1.f / NetUpdateFrequency) + 1.f), 0.1f);
}

simulated function Register()
{
	PlayerTPRI.RegisterCustomInfo(Self);
}

simulated function Unregister()
{
	PlayerTPRI.UnregisterCustomInfo(Self);
}

defaultproperties
{
	RemoteRole=ROLE_None
    NetUpdateFrequency=0.100000
    bAlwaysRelevant=false
    bOnlyRelevantToOwner=false

	//Default property replication for these.
    bOnlyDirtyReplication=true
    bSkipActorPropertyReplication=true
}