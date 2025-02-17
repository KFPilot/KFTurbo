//Killing Floor Turbo TurboPlayerStatCollectorBase
//Base class for all player stat collectors. Owning actor must be owning PRI.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerStatCollectorBase extends Info;

var TurboPlayerReplicationInfo PlayerTPRI;
var protected bool bIsCollector;
var class<TurboPlayerStatCollectorBase> PlayerStatReplicatorClass;

replication
{
	reliable if (Role == ROLE_Authority)
		PlayerTPRI;
}

static final function TurboPlayerStatCollectorBase FindStats(TurboPlayerReplicationInfo TPRI)
{
	local int Index;

	if (TPRI == None)
	{
		return None;
	}

	if (default.bIsCollector)
	{
		for (Index = TPRI.StatCollectorList.Length - 1; Index >= 0; Index--)
		{
			if (TPRI.StatCollectorList[Index] == None)
			{
				TPRI.StatCollectorList.Remove(Index, 1);
				continue;
			}

			if (TPRI.StatCollectorList[Index].Class == default.Class)
			{
				return TPRI.StatCollectorList[Index];
			}
		}
	}
	else
	{
		for (Index = TPRI.StatReplicatorList.Length - 1; Index >= 0; Index--)
		{
			if (TPRI.StatReplicatorList[Index] == None)
			{
				TPRI.StatReplicatorList.Remove(Index, 1);
				continue;
			}

			if (TPRI.StatReplicatorList[Index].Class == default.Class)
			{
				return TPRI.StatReplicatorList[Index];
			}
		}
	}

	return None;
}

function PreBeginPlay()
{
	PlayerTPRI = TurboPlayerReplicationInfo(Owner);
	Super.PreBeginPlay();
}

//Intentionally not simulated - we can't resolve Steam IDs this way on the remote (except maybe owning remote?).
function string GetPlayerSteamID()
{
	if (PlayerTPRI == None)
	{
		return "";
	}

	if (PlayerController(PlayerTPRI.Owner) == None)
	{
		return "";
	}

	return PlayerController(PlayerTPRI.Owner).GetPlayerIDHash();
}

function string GetPlayerName()
{
	if (PlayerTPRI == None)
	{
		return "";
	}

	return PlayerTPRI.PlayerName;
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
		return;
	}

	Register();

	if (!bIsCollector && Role == ROLE_Authority)
	{
		SetTimer(15.f, false);
	}

	Disable('Tick');
}

//Tear off this stat actor then destroy it.
function Timer()
{
	if (bTearOff)
	{
		Destroy();
		return;
	}

	bTearOff = true;
	SetTimer(15.f, false);
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
	if (bIsCollector)
	{
		PlayerTPRI.RegisterStatCollector(Self);
	}
	else
	{
		PlayerTPRI.RegisterStatReplicator(Self);
	}
}

simulated function Unregister()
{
	if (bIsCollector)
	{
		PlayerTPRI.UnregisterStatCollector(Self);
	}
	else
	{
		PlayerTPRI.UnregisterStatReplicator(Self);
	}
}

//Called to "finalize" a stat collector by pushing stats to a replicator and then destroying this collector.
final function TurboPlayerStatCollectorBase ReplicateStats()
{
	local TurboPlayerStatCollectorBase Replicator;
	if (Role != ROLE_Authority || !bIsCollector || PlayerStatReplicatorClass == None)
	{
		return None;
	}

	Replicator = Spawn(PlayerStatReplicatorClass, Owner);
	Replicator.PushStats(Self);
	Replicator.ForceNetUpdate();
	Destroy();
}

//API to convert a stat collector into a stat replicator.
function PushStats(TurboPlayerStatCollectorBase Source) {}

defaultproperties
{
	bIsCollector=true

	RemoteRole=ROLE_None
    NetUpdateFrequency=0.100000
}