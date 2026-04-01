//Killing Floor Turbo HoldoutPlayerController
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class HoldoutPlayerController extends TurboPlayerController;

var HoldoutInteraction HoldoutInteraction;

simulated function InitInputSystem()
{
	Super.InitInputSystem();

	if (!Level.bLevelChange)
	{
		SetupHoldoutInteraction();
	}
}

simulated function SetupHoldoutInteraction()
{
	if (HoldoutInteraction != None || Player == None)
	{
		return;
	}

	HoldoutInteraction = HoldoutInteraction(Player.InteractionMaster.AddInteraction("KFTurboHoldout.HoldoutInteraction", Player));
}

function AttemptMarkActor(vector Start, vector End, Actor TargetActor, class<TurboMarkerType> DataClassOverride, int DataOverride, TurboPlayerMarkReplicationInfo.EMarkColor Color)
{
	local HoldoutPurchaseTrigger FoundPurchaseTrigger;

	if ((TargetActor == None || TargetActor.bWorldGeometry || Mover(TargetActor) != None) && (Player != None))
	{
		foreach CollidingActors(class'HoldoutPurchaseTrigger', FoundPurchaseTrigger, 80.f, End)
			break;

		if (FoundPurchaseTrigger != None)
		{
			Super.AttemptMarkActor(Start, End, FoundPurchaseTrigger, class'HoldoutPurchaseMarkerType', DataOverride, Color);
			return;
		}
	}

	Super.AttemptMarkActor(Start, End, TargetActor, DataClassOverride, DataOverride, Color);
}

defaultproperties
{
	PawnClass=Class'KFTurboHoldout.HoldoutHumanPawn'

	HUDBaseClass=class'HoldoutHUDKillingFloor'
}