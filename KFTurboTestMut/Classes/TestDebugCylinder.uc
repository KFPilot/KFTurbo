class TestDebugCylinder extends Actor;

var Pawn PawnOwner;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    PawnOwner = Pawn(Owner);
}

function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    if (PawnOwner == None || PawnOwner.Health <= 0)
    {
        Destroy();
    }
}

defaultproperties
{
    DrawType=DT_StaticMesh
    bAcceptsProjectors=false
    bUnlit=true
    StaticMesh=StaticMesh'KFTurboTestMut.DebugCylinder'
    Skins(0)=Material'KFTurboTestMut.Debug.Collision_FB'

    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
    bBlockProjectiles=false
    bBlockZeroExtentTraces=false
    bBlockNonZeroExtentTraces=false
    bBlockHitPointTraces=false

}