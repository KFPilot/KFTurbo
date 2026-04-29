//Killing Floor Turbo TurboRepLinkFix
//Fixes up LRIs that get broken due to replication quirks
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboRepLinkFix extends Info;

var int FailureCount;
var const int MaxFailureCount;

var PlayerController OwningPlayer;
var LinkedReplicationInfo TestLRI;

var const bool bDebug;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	OwningPlayer = PlayerController(Owner);
	InitialState = 'ValidateClientPerkRepLink';
}

state ValidateLRI
{
	simulated function BeginState()
	{
		FailureCount = 0;
	}

	simulated function bool AttemptValidate() { return false; }

	simulated function OnValidate() {}

Begin:
	while (true)
	{
		Sleep(1.f);
		if (AttemptValidate())
		{
			OnValidate();
			break;
		}

		FailureCount++;

		if (FailureCount > MaxFailureCount)
		{
			OwningPlayer.ClientMessage("FAILED TO VALIDATE LRI IN TIME.");
			OwningPlayer.ConsoleCommand("DISCONNECT");
			break;
		}
	}
}

//Returns true if the provided LRI is present in the provided PlayerController's LRI list.
static final function bool HasLRI(PlayerController PlayerController, LinkedReplicationInfo TargetLRI)
{
	local LinkedReplicationInfo LRI;

	if (PlayerController == None || PlayerController.PlayerReplicationInfo == None)
	{
		return false;
	}

	for (LRI = PlayerController.PlayerReplicationInfo.CustomReplicationInfo; LRI != None; LRI = LRI.NextReplicationInfo)
	{
		if (LRI == TargetLRI)
		{
			return true;
		}
	}

	return false;
}

//Put our LRI into the front of the list. Hopefully putting the LRI in the front of the list reduces chance we ended up messing with someone else in the list.
static final function ForceEmplaceLRI(PlayerReplicationInfo PRI, LinkedReplicationInfo LRI)
{
	local LinkedReplicationInfo NextLRI;

	NextLRI = PRI.CustomReplicationInfo;
	while (NextLRI != None)
	{
		if (NextLRI == LRI)
		{
			return;
		}

		NextLRI = NextLRI.NextReplicationInfo;
	}

	NextLRI = PRI.CustomReplicationInfo;
	PRI.CustomReplicationInfo = LRI;
	LRI.NextReplicationInfo = NextLRI;
}

state ValidateClientPerkRepLink extends ValidateLRI
{
	simulated function BeginState()
	{
		Global.BeginState();

		if (bDebug)
		{
			log("Starting ValidateClientPerkRepLink");
		}
	}

	simulated function bool AttemptValidate()
	{
		local ClientPerkRepLink CPRL;
    	
		foreach DynamicActors(class'ClientPerkRepLink', CPRL) { break; }

		if (CPRL == None)
		{
			FailureCount--;
			return false;
		}

		if (HasLRI(OwningPlayer, CPRL))
		{
			return true;
		}

		if (FailureCount == (MaxFailureCount / 2))
		{
			if (bDebug)
			{
				log("Starting ValidateClientPerkRepLink Hit failure limit. Attempting emplace.");
			}
			ForceEmplaceLRI(OwningPlayer.PlayerReplicationInfo, CPRL);
		}

		return false;
	}
	
	simulated function OnValidate()
	{
		if (bDebug)
		{
			log("ValidateClientPerkRepLink Validated CPRL.");
		}
		GotoState('ValidateTurboRepLink');
	}
}

state ValidateTurboRepLink extends ValidateLRI
{
	simulated function BeginState()
	{
		Global.BeginState();

		if (bDebug)
		{
			log("Starting ValidateTurboRepLink");
		}
	}

	simulated function bool AttemptValidate()
	{
		local TurboRepLink TRL;

    	foreach DynamicActors(class'TurboRepLink', TRL) { break; }

		if (TRL == None)
		{
			FailureCount--;
			return false;
		}

		if (HasLRI(OwningPlayer, TRL))
		{
			return true;
		}

		if (FailureCount == (MaxFailureCount / 2))
		{
			if (bDebug)
			{
				log("Starting ValidateTurboRepLink Hit failure limit. Attempting emplace.");
			}

			ForceEmplaceLRI(OwningPlayer.PlayerReplicationInfo, TRL);
			TRL.OnSetupComplete();
		}

		return false;
	}
	
	simulated function OnValidate()
	{
		if (bDebug)
		{
			log("ValidateTurboRepLink Validated TRL.");
		}

		GotoState('ValidationComplete');
	}
}

state ValidationComplete
{
	simulated function BeginState()
	{
		LifeSpan = 0.1f;
	}
}
 
defaultproperties
{
	MaxFailureCount=20

	bDebug=false
}