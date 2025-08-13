//Killing Floor Turbo TurboPlayerCustomInfo
//Actor that can contain custom info per-player. May replicate. Registration should be automatically handled via Tick.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerCustomInfo extends ReplicationInfo;

var TurboPlayerReplicationInfo PlayerTPRI;
var bool bRegistered;
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
		if (Controller(Owner) != None)
		{
			PlayerTPRI = TurboPlayerReplicationInfo(Controller(Owner).PlayerReplicationInfo);
		}

		ResolveTimeout = Level.TimeSeconds + 5.f;
	}
	else if (PlayerTPRI == None)
	{
		if (Controller(Owner) != None)
		{
			PlayerTPRI = TurboPlayerReplicationInfo(Controller(Owner).PlayerReplicationInfo);
		}
	}

	Super.PostBeginPlay();
	
	Enable('Tick');
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

	if (bRegistered)
	{
		return;
	}

	if (PlayerTPRI == None)
	{
		if (Controller(Owner) != None)
		{
			PlayerTPRI = TurboPlayerReplicationInfo(Controller(Owner).PlayerReplicationInfo);
		}

		if (PlayerTPRI == None)
		{
			if (Role == ROLE_Authority && ResolveTimeout < Level.TimeSeconds)
			{
				Destroy();
			}

			return;
		}
	}

	bRegistered = true;
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
	bRegistered=false

	RemoteRole=ROLE_None
    NetUpdateFrequency=1.0
    bAlwaysRelevant=false
    bOnlyRelevantToOwner=false

	//Default property replication for these.
    bOnlyDirtyReplication=true
    bSkipActorPropertyReplication=true
}