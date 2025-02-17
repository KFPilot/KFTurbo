class TestWaveTrigger extends UseTrigger
	hidecategories(Advanced,Force,Karma,LightColor,Lighting,Sound,UseTrigger)
	placeable;

var TestLaneWaveManager LaneManager;
var class<TurboLocalMessage> HintMessageClass;
var TurboHumanPawn TargetPawn;

replication
{
	reliable if (Role == ROLE_Authority)
		LaneManager;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	LaneManager = GetTestLaneWaveManager();
}

simulated function ForceNetUpdate()
{
	NetUpdateTime = FMax(Level.TimeSeconds - (1.f / NetUpdateFrequency), 0.1f);
}

simulated function TestLaneWaveManager GetTestLaneWaveManager()
{
	if (LaneManager != None)
	{
		return LaneManager;
	}

	foreach AllActors(class'TestLaneWaveManager', LaneManager, Tag)
	{
		break;
	}

	ForceNetUpdate();
	return LaneManager;
}

function UsedBy(Pawn User)
{
	if (User.Role != ROLE_Authority || User.Controller == None || !User.Controller.bIsPlayer)
	{
		return;
	}
	
	Super.UsedBy(User);
}

simulated function Touch(Actor Other)
{
	local TurboHumanPawn Pawn;
	
	Pawn = TurboHumanPawn(Other);
	if (Pawn == None || !Pawn.IsLocallyControlled())
	{
		return;
	}

	TargetPawn = Pawn;
	BroadcastMessage(PlayerController(Pawn.Controller));
	SetTimer(0.5f, false);
}

simulated function Timer()
{
	local TurboHumanPawn TouchingPawn;
	if (TargetPawn == None || TargetPawn.Health <= 0)
	{
		return;
	}

	foreach TouchingActors(class'TurboHumanPawn', TouchingPawn)
	{
		if (TouchingPawn == TargetPawn)
		{
			BroadcastMessage(PlayerController(TargetPawn.Controller));
			SetTimer(0.5f, false);
			break;
		}
	}
}

simulated function BroadcastMessage(PlayerController PlayerController)
{
	if (HintMessageClass != None)
	{
		PlayerController.ReceiveLocalizedMessage(HintMessageClass,, PlayerController.PlayerReplicationInfo,,GetTestLaneWaveManager());
	}
}

function TriggerEvent(Name EventName, Actor Other, Pawn EventInstigator)
{
	if (LaneManager == None)
	{
		return;
	}

	if (LaneManager.bIsActive)
	{
		LaneManager.Deactivate();
	}
	else
	{
		LaneManager.Activate(TurboHumanPawn(EventInstigator));
	}
}

defaultproperties
{
	bAlwaysRelevant=true
	bReplicateMovement=false
	RemoteRole=ROLE_SimulatedProxy
	NetUpdateFrequency=0.1f
	
	HintMessageClass=class'TestToggleLaneMessage'
	Texture=Texture'Engine.SubActionTrigger'
}
