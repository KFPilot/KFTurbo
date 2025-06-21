//Killing Floor Turbo KFTurboLaneUseTrigger
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboLaneUseTrigger extends UseTrigger;

var float UseCooldown;
var float LastUseTime;

var float MessageCooldown;
var float NextMessageTime;

var array<KFTurboLaneUseTrigger> LaneTriggerList;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Level.NetMode == NM_DedicatedServer)
	{
		return;
	}

	SetTimer(0.1f, false);
}

simulated function Timer()
{
	local KFTurboLaneUseTrigger Trigger;
	local int Index;

	if (LaneTriggerList.Length != 0)
	{
		return;
	}

	foreach AllActors(class'KFTurboLaneUseTrigger', Trigger)
	{
		LaneTriggerList[LaneTriggerList.Length] = Trigger;
	}

	//Push list to all other triggers.
	for (Index = LaneTriggerList.Length - 1; Index >= 0; Index--)
	{
		LaneTriggerList[Index].LaneTriggerList = LaneTriggerList;
	}
}

function UsedBy(Pawn Pawn)
{
	if (Level.TimeSeconds < (LastUseTime + UseCooldown) || KFHumanPawn(Pawn) == None)
	{
		return;
	}
	
	LastUseTime = Level.TimeSeconds;
	
	Super.UsedBy(Pawn);
}

simulated function Touch(Actor Other)
{
	local Pawn Pawn;
	local PlayerController PlayerController;

	if (Level.NetMode == NM_DedicatedServer)
	{
		return;
	}

	if (Level.TimeSeconds < (NextMessageTime))
	{
		return;
	}
	
	Pawn = KFHumanPawn(Other);
	if (Pawn == None || Pawn.Health <= 0 || !Pawn.IsLocallyControlled())
	{
		return;
	}

	PlayerController = PlayerController(Pawn.Controller);

	if (PlayerController == None)
	{
		return;
	}

	SetNextMessageTime(Level.TimeSeconds + MessageCooldown);

	PlayerController.ReceiveLocalizedMessage(class'KFTurboLaneTriggerMessage');
}

simulated function SetNextMessageTime(float InNextMessageTime)
{
	local int Index;
	NextMessageTime = InNextMessageTime;

	for (Index = LaneTriggerList.Length - 1; Index >= 0; Index--)
	{
		LaneTriggerList[Index].NextMessageTime = NextMessageTime;
	}
}

defaultproperties
{
    UseCooldown=1.f
	MessageCooldown=120.f
	bAlwaysRelevant=true
	bSkipActorPropertyReplication=true
	bReplicateMovement=false
	RemoteRole=ROLE_SimulatedProxy
}
