//Killing Floor Turbo TurboCardDrawnActor
//Client-only actor rendered onto the HUD via Canvas.DrawActor.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardDrawnActor extends Actor;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if (Level.NetMode != NM_DedicatedServer)
	{
		SetDrawType(EDrawType.DT_StaticMesh);
	}
}

defaultproperties
{
	bHidden=true
	bUnlit=true
	Physics=PHYS_None
	RemoteRole=ROLE_None
	bCollideActors=false
	bBlockActors=false
	bCollideWorld=false
}
