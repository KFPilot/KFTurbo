//Killing Floor Turbo VinylAugmentReplicationInfo
//Replicated state actor for vinyl augments. Spawned by TurboPlayerCardCustomInfo while its vinyl is
//possessed and registers itself to that custom info via the SparseReplicationInfo pattern.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentReplicationInfo extends KFTurbo.SparseReplicationInfo;

var TurboPlayerCardCustomInfo OwningCardInfo;

static function SparseReplicationInfo Find(Actor InSparseOwningActor)
{
	local TurboPlayerCardCustomInfo CardInfo;

	if (InSparseOwningActor == None)
	{
		return None;
	}

	CardInfo = TurboPlayerCardCustomInfo(InSparseOwningActor);
	if (CardInfo == None)
	{
		Warn("Find: " $ default.Class $ " was subclassed from VinylAugmentReplicationInfo but InSparseOwningActor is not a TurboPlayerCardCustomInfo (was a " $ InSparseOwningActor $ ").");
		return None;
	}

	return CardInfo.GetAugmentInfo(default.Class);
}

protected simulated function bool AttemptRegister()
{
	if (SparseOwningActor == None)
	{
		return false;
	}

	OwningCardInfo = TurboPlayerCardCustomInfo(SparseOwningActor);
	if (OwningCardInfo == None)
	{
		Warn("AttemptRegister: " $ Class $ " was subclassed from VinylAugmentReplicationInfo but SparseOwningActor is not a TurboPlayerCardCustomInfo (was a " $ SparseOwningActor $ ").");
		return false;
	}

	OwningCardInfo.RegisterAugmentInfo(Self);
	return true;
}

protected simulated function Unregister()
{
	Super.Unregister();

	if (OwningCardInfo == None)
	{
		return;
	}

	OwningCardInfo.UnregisterAugmentInfo(Self);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bOnlyRelevantToOwner=true
}
