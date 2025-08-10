class TurboCashPickup extends CashPickup;

var bool bHasLanded;
var float CreationTime;
var float PreventRegrabDelay;

simulated function BeginPlay()
{
	CreationTime = Level.TimeSeconds;

	Super.BeginPlay();
}

simulated function Landed(vector HitNormal)
{
	bHasLanded = true;
	Super.Landed(HitNormal);
}

auto state Pickup
{
	function bool ValidTouch(Actor Other)
	{
		//If not yet landed and also within regarb time.
		if (!bHasLanded && (CreationTime + PreventRegrabDelay) > Level.TimeSeconds)
		{
			if (Owner != None && Owner == Other && Pawn(Other) != None && !class'KFTurboMut'.default.bPreventImmediateCashRegrab)
			{
				return false;
			}
		}

        return Super.ValidTouch(Other);
	}
}

defaultproperties
{
	bHasLanded = false
	PreventRegrabDelay = 0.3f
}