//Killing Floor Turbo HoldoutDoorPathNode
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class HoldoutDoorPathNode extends Door
	placeable;

function MoverOpened()
{
	bBlocked = false;
	bDoorOpen = true;
}

function MoverClosed()
{
	bBlocked = true;
	bDoorOpen = false;
}

defaultproperties
{
	bInitiallyClosed = true
	bBlockedWhenClosed = true
	bBlockable = true
}