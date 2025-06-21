//Killing Floor Turbo HoldoutDoor
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class HoldoutDoor extends Mover
	placeable;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (OpenedSound != None && OpeningSound == None)
	{
		OpeningSound = OpenedSound;
		OpenedSound = None;
	}
}

function DoOpen()
{
	bOpening = true;
	bDelaying = false;
	InterpolateTo( 1, MoveTime );
	MakeNoise(1.0);
	PlaySound( OpeningSound, SLOT_None, SoundVolume / 128.0, false, SoundRadius, SoundPitch / 64.0);
	AmbientSound = MoveAmbientSound;
	TriggerEvent(OpeningEvent, Self, Instigator);
	if ( Follower != None )
		Follower.DoOpen();
}

state() TriggerToggle
{
	//Only allow opening from triggers.
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		if (KeyNum != 0 && KeyNum >= PrevKeyNum)
		{
			return;
		}

		Super.Trigger(Other, EventInstigator);
	}
}

defaultproperties
{
	InitialState="TriggerToggle"
    MoverEncroachType=ME_IgnoreWhenEncroach
	bNoAIRelevance=true
	bPathColliding=false

	SoundVolume=255
	SoundRadius=200
}