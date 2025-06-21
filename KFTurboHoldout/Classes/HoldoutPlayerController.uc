//Killing Floor Turbo HoldoutPlayerController
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class HoldoutPlayerController extends TurboPlayerController;

var FadeColor ShortLivedPickupOverlay;

replication
{
	reliable if( Role == ROLE_Authority )
		ClientMarkPickupShortLived;
}

simulated function ClientSetHUD(class<HUD> newHUDClass, class<Scoreboard> newScoringClass )
{
	if (class<HoldoutHUDKillingFloor>(newHUDClass) == None)
	{
		Super.ClientSetHUD(class'HoldoutHUDKillingFloor', newScoringClass);
	}

	Super.ClientSetHUD(newHUDClass, newScoringClass);
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

simulated function ClientMarkPickupShortLived(WeaponPickup Pickup)
{
	if (Pickup == None)
	{
		return;
	}

	Pickup.UV2Texture = ShortLivedPickupOverlay;
}

defaultproperties
{
	PawnClass=Class'KFTurboHoldout.HoldoutHumanPawn'
	ShortLivedPickupOverlay=FadeColor'KFTurboHoldout.Effects.ShortLivedPickupOverlay'
}