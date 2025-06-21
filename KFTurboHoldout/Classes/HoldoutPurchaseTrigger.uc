//Base class for Holdout purchase triggers.
class HoldoutPurchaseTrigger extends UseTrigger
	hidecategories(Advanced,Force,Karma,LightColor,Lighting,Sound,UseTrigger)
	abstract
	notplaceable;

var(Purchase) Sound PurchaseSound;
var(Purchase) float PurchaseSoundVolume;
var(Purchase) int PurchaseSoundRadius;

var class<TurboLocalMessage> PurchaseMessageClass;
var class<TurboLocalMessage> PurchaseNotificationMessageClass;
var HoldoutHumanPawn TargetPawn;

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
	local HoldoutHumanPawn Pawn;
	
	Pawn = HoldoutHumanPawn(Other);
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
	local HoldoutHumanPawn TouchingPawn;
	if (TargetPawn == None || TargetPawn.Health <= 0)
	{
		return;
	}

	foreach TouchingActors(class'HoldoutHumanPawn', TouchingPawn)
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
	if (PurchaseMessageClass != None)
	{
		PlayerController.ReceiveLocalizedMessage(PurchaseMessageClass, GetPurchasePrice(), PlayerController.PlayerReplicationInfo,, GetBroadcastMessageOptionalObject());
	}
}

simulated function Object GetBroadcastMessageOptionalObject()
{
	return None;
}

simulated function int GetPurchasePrice()
{
	return 0;
}

simulated function string GetMarkerName()
{
	return "";
}

simulated event TriggerEvent(Name EventName, Actor Other, Pawn EventInstigator)
{
	if (Role != ROLE_Authority || EventInstigator.Role != ROLE_Authority || EventInstigator == None || EventInstigator.Role != ROLE_Authority)
	{
		return;
	}

	PerformPurchase(EventInstigator);
}

function PerformPurchase(Pawn EventInstigator)
{
	PlayPurchaseSound(EventInstigator);

	if (PurchaseNotificationMessageClass != None && EventInstigator.PlayerReplicationInfo != None)
	{
		Level.Game.BroadcastLocalizedMessage(PurchaseNotificationMessageClass, GetPurchasePrice(), EventInstigator.PlayerReplicationInfo, None, GetBroadcastMessageOptionalObject());
	}
}

function PlayPurchaseSound(Pawn EventInstigator)
{
	if (PurchaseSound != None)
	{
        PlaySound(PurchaseSound, SLOT_None, PurchaseSoundVolume,, PurchaseSoundRadius);
	}
}

defaultproperties
{
	bAlwaysRelevant=true
	bReplicateMovement=false
	RemoteRole=ROLE_SimulatedProxy
	
	PurchaseSound=Sound'Steamland_SND.SlotMachine_Dosh'
	PurchaseSoundVolume=4.f
	PurchaseSoundRadius=5000
}
