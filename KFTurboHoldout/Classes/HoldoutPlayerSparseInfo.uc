//Killing Floor Turbo HoldoutPlayerSparseInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class HoldoutPlayerSparseInfo extends SparsePlayerReplicationInfo;

var protected bool bReady;

var protected float ReadyUpAttemptTime;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		bReady;
	reliable if (Role < ROLE_Authority)
		ServerReadyUp;
}


simulated function bool IsReady()
{
	return bReady || (Level.TimeSeconds - ReadyUpAttemptTime) < 2.f;
}

//Called by the client to ready up.
//Sets ReadyUpAttemptTime to de-bounce the state of "I sent the RPC to ready up but my local state of bReady is not updated".
simulated function ReadyUp()
{
	if (IsReady())
	{
		return;
	}

	ReadyUpAttemptTime = Level.TimeSeconds;
	ServerReadyUp();
}

function ServerReadyUp()
{
	SetReady(true);
}

function SetReady(bool bNewReady)
{
	if (bReady == bNewReady)
	{
		return;
	}
	
	bReady = bNewReady;
	ForceNetUpdate();
}

static final function HoldoutPlayerSparseInfo GetHoldoutInfo(PlayerReplicationInfo PRI)
{
	return HoldoutPlayerSparseInfo(Find(PRI));
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true

	bReady=true
	ReadyUpAttemptTime=-10.f
}
