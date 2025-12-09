//Common Core SparseReplicationInfo
//Allows for out of order lists of replication infos associated with some actor. By default SparseReplicationInfo will use its owner.
//This fixes the issue where using LRIs on something like a PRI can break if some LRIs are bOnlyRelevantToOwner and others are bAlwaysRelevant.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/CommonCore.
class SparseReplicationInfo extends Engine.ReplicationInfo;

//Replicated pointer to actor we are in the sparse actor list of.
var Actor SparseOwningActor;

//If true, will disable tick once this sparse replication info has successfully registered.
var bool bStopTickAfterRegister;
//If true, will destroy this sparse replication info when it is torn off.
var bool bDestroyAfterTearOff;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority) //Can't be net initial. Seems to cause trouble when received out of order.
		SparseOwningActor;
}

static function SparseReplicationInfo Find(Actor InSparseOwningActor)
{
    Warn("Find: " $ default.Class $ " was subclassed directly from SparseReplicationInfo and did not override Find!");
    return None;
}

simulated function PreBeginPlay()
{
    if (Owner != None)
    {
        SparseOwningActor = Owner;
    }

    Super.PreBeginPlay();
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role == ROLE_Authority && !AttemptRegister())
    {
        GotoState('AwaitingRegister');
    }
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if (SparseOwningActor != None && AttemptRegister())
    {
        OnRegister();
        return;
    }

    GotoState('AwaitingRegister');
}

state AwaitingRegister
{
    simulated function BeginState()
    {
        Enable('Tick');
    }

    simulated function EndState()
    {
	    Disable('Tick');
    }

    simulated function Tick(float DeltaTime)
    {
        if (AttemptRegister())
        {
            OnRegister();
            GotoState('');
        }
    }
}

//Return true if this sparse replication info has successfully registered.
protected simulated function bool AttemptRegister()
{
    return false;
}

//Called by Destroyed(). Should remove this actor from its sparse replication info list.
private simulated function Unregister()
{
    if (!SparseOwningActor.bDeleteMe)
    {
        OnUnregister();
    }
}

//USE THESE FUNCTIONS TO DO THINGS ONCE REGISTERED/UNREGISTERED
protected simulated function OnRegister()
{

}

protected simulated function OnUnregister()
{

}

//By default SRIs should be destroyed if their owner is. Override this to manage SRI lifetimes.
simulated function OnOwnerDestroyed()
{
    Destroy();
}

simulated function Destroyed()
{
	if (!Level.bLevelChange)
	{
		Unregister();
	}
	
	Super.Destroyed();
}

simulated function TornOff()
{
	Super.TornOff();

	if (bDestroyAfterTearOff)
	{
		LifeSpan = 1.f;
	}
}

//Helper function to force this actor to replicate.
function ForceNetUpdate()
{
    NetUpdateTime = Max(Level.TimeSeconds - ((1.f / NetUpdateFrequency) + 1.f), 0.1f);
}

defaultproperties
{
    bStopTickAfterRegister=true
    bDestroyAfterTearOff=true

	RemoteRole=ROLE_None
    NetUpdateFrequency=0.1
    bAlwaysRelevant=false
    bOnlyRelevantToOwner=false

	//Default property replication for these.
    bOnlyDirtyReplication=true
    bSkipActorPropertyReplication=true   
}