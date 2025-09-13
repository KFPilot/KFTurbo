//Killing Floor Turbo TurboSpectatorActor
//Base class of a visible spectator actor.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboSpectatorActor extends Actor;

var bool bUseMovementBuffer;
var bool bUseMovementBufferRotation;

var bool bTickVisibility;

var float LastSendTime;

var Vector BufferLocation;
var Rotator BufferRotation;

struct MovementStepData
{
    var Vector Location;
    var Rotator Rotation;
    var float Time;

    var Actor AttachParent;
    var Vector RelativeLocation;
};

var MovementStepData MovementStep;
var float LastMovementStepTimeStamp;
var array<MovementStepData> MovementBuffer;
var int MaxMovementBufferSize;
var float LastMovementStepTime;
var Vector MovementBufferVelocity;
var float InterpolationRate;
var float CurrentRoll;
var Actor AttachActor;

var float RandomOffset;
var Vector RandomDirection;
var Rotator CurrentRotation;

var TurboPlayerReplicationInfo OwningPRI;
var TurboPlayerController OwningController;
var bool bIsLocalPlayerSpectatorActor;
var bool bIsVisible;

var globalconfig bool bDebugSpectatorActor;

replication
{
    reliable if (Role == ROLE_Authority)
        OwningPRI;
    reliable if (Role == ROLE_Authority && !bNetOwner)
        bIsVisible;
	reliable if(Role == ROLE_Authority)
        MovementStep;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (!default.bDebugSpectatorActor)
    {
        ConsoleCommand("Suppress KFTurboSpectatorActor");
    }

    if (Role == ROLE_Authority)
    {
        MovementStep.Location = Location;
        MovementStep.Rotation = Rotation;
        OwningPRI = TurboPlayerReplicationInfo(Owner);
        OwningController = TurboPlayerController(OwningPRI.Owner);
    }

    LastMovementStepTime = Level.TimeSeconds;
    RandomOffset = FRand();
    RandomDirection = VRand();
}

auto state AwaitingInitialize
{
    simulated function Tick(float DeltaTime)
    {
        if (Role == ROLE_Authority)
        {
            GotoState('Ready');
            return;
        }

        if (OwningPRI == None)
        {
            return;
        }

        if (Level.NetMode != NM_DedicatedServer && (Level.GetLocalPlayerController() == None || Level.GetLocalPlayerController().PlayerReplicationInfo == None))
        {
            return;
        }

        if (Level.GetLocalPlayerController().PlayerReplicationInfo == OwningPRI)
        {
            log("Spectator Actor for "@OwningPRI.PlayerName@" is the local player's.", 'KFTurboSpectatorActor');
            OwningController = TurboPlayerController(Level.GetLocalPlayerController());
            bIsLocalPlayerSpectatorActor = OwningController != None && OwningController.IsLocalPlayerController();
        }

        GotoState('Ready');
    }

    simulated function PostNetReceive()
    {
        MovementBuffer.Length = 1;
        MovementBuffer[0] = MovementStep;
    }

    simulated function BeginState()
    {
        if (OwningPRI != None)
        {
            log("New Spectator Actor for "@OwningPRI.PlayerName@" is awaiting initialization.", 'KFTurboSpectatorActor');
        }
        else
        {
            log("New Spectator Actor is awaiting initialization.", 'KFTurboSpectatorActor');
        }

        Super.BeginState();
    }
}

state Ready
{
    simulated function BeginState()
    {
        log("Spectator Actor for "@OwningPRI.PlayerName@" has initialized successfully.", 'KFTurboSpectatorActor');
        Super.BeginState();
    }
}

final simulated function bool IsLocalPlayerSpectator()
{
    return bIsLocalPlayerSpectatorActor;
}

simulated function PostNetReceive()
{
    Super.PostNetReceive();

    UpdateMovementStep();
}

simulated function Tick(float DeltaTime)
{
    if (OwningPRI == None)
    {
        if (Role == ROLE_Authority)
        {
            Destroy();
            return;
        }

        GotoState('AwaitingInitialize');
        return;
    }

    Super.Tick(DeltaTime);

    if (Role == ROLE_Authority && OwningController == None)
    {
        Destroy();
        return;
    }

    if (bTickVisibility)
    {
        if (Role == ROLE_Authority || IsLocalPlayerSpectator())
        {
            UpdateVisibility(DeltaTime);
        }
        
        if (Level.NetMode != NM_DedicatedServer)
        {
            TickVisibility(DeltaTime);
        }
    }

    if (bIsVisible && bUseMovementBuffer)
    {
        if (Role == ROLE_Authority || IsLocalPlayerSpectator())
        {
            UpdateMovement(DeltaTime);
        }
        
        CurrentRoll += DeltaTime * 2000.f;
        TickMovementBuffer(DeltaTime);
    }
}

simulated function bool ShouldUpdateMovementStep()
{
    if (Level.TimeSeconds < LastSendTime + 0.1f)
    {
        return false;
    }

    if (Level.TimeSeconds < (LastSendTime + 1.f) && VSizeSquared(BufferLocation - MovementStep.Location) < 25.f && (Vector(BufferRotation) Dot Vector(MovementStep.Rotation)) > 0.9f)
    {
        return false;
    }

    return true;
}

simulated function UpdateMovement(float DeltaTime)
{
    local Vector AttachOffset;
    if (OwningController.ViewTarget == None || OwningController.ViewTarget == OwningController)
    {
        BufferLocation = OwningController.Location;
        BufferRotation = OwningController.Rotation;
    }
    else
    {
        BufferLocation = OwningController.ViewTarget.Location;
        BufferRotation = OwningController.Rotation;
        AttachOffset = (vect(0.f, 0.f, 2.f) * OwningController.ViewTarget.default.CollisionHeight * Lerp(RandomOffset, 0.95f, 1.05f)) + (RandomDirection * 5.f);
    }

    if (ShouldUpdateMovementStep())
    {
        MovementStep.Location = BufferLocation;
        MovementStep.Rotation = BufferRotation;
        LastSendTime = Level.TimeSeconds + (FRand() * 0.1f);

        if (OwningController.ViewTarget == None || OwningController.ViewTarget == OwningController)
        {
            MovementStep.AttachParent = None;
        }
        else
        {
            MovementStep.AttachParent = OwningController.ViewTarget;
        }

        if (MovementStep.AttachParent != None)
        {
            MovementStep.Location += AttachOffset;
            MovementStep.RelativeLocation = AttachOffset;
        }
    }
}

simulated function AttachToActor(Actor Other)
{
    if (AttachActor == Other)
    {
        return;
    }

    SetBase(None);
    AttachActor = None;

    if (Other != None)
    {
        Log("Attaching to: "$Other, 'KFTurboSpectatorActor');
        AttachActor = Other;
        SetBase(Other);
    }
}

simulated function DetachFromActor()
{
    AttachToActor(None);
}

simulated function UpdateVisibility(float DeltaTime)
{
    local bool bPreviousIsVisible;
    if (IsLocalPlayerSpectator())
    {
        bIsVisible = OwningController.Pawn == None && OwningController.ViewTarget != None && OwningController.ViewTarget != OwningController;
        return;
    }

    bPreviousIsVisible = bIsVisible;
    bIsVisible = OwningController.Pawn == None;

    if (bPreviousIsVisible != bIsVisible)
    {
        return;
    }
    
    if (!bIsVisible)
    {
        NetUpdateFrequency = 1.f;
    }
    else
    {
        NetUpdateFrequency = default.NetUpdateFrequency;
    }
}

simulated function TickVisibility(float DeltaTime)
{
    if (bHidden == !bIsVisible)
    {
        return;
    }

    if (bIsVisible && MovementBuffer.Length == 0)
    {
        return;
    }

    bHidden = !bIsVisible;

    if (!bHidden)
    {
        SetLocation(MovementBuffer[0].Location);
        SetRotation(MovementBuffer[0].Rotation);
    }
}

simulated function bool ShouldAddStep()
{
    return true;
}

simulated function UpdateMovementStep()
{
    if (!ShouldAddStep())
    {
        LastMovementStepTime = Level.TimeSeconds;
        return;
    }

    MovementBuffer.Insert(0, 1);
    MovementBuffer[0] = MovementStep;
    MovementBuffer.Length = Min(MovementBuffer.Length, MaxMovementBufferSize);

    if (LastMovementStepTime <= 0.f)
    {
        MovementBuffer[0].Time = 0.5f;
    }
    else
    {
        MovementBuffer[0].Time = FMax(Level.TimeSeconds - LastMovementStepTime, 0.25f);
    }

    LastMovementStepTime = Level.TimeSeconds;
}

simulated function TickMovementBuffer(float DeltaTime)
{
    local int Index;
    local MovementStepData NextStep;
    local Vector StartingLocation, Displacement;

    local Quat CurrentQuat, TemporaryQuat;
    local Vector X, Y, Z;

    if (MovementBuffer.Length == 0)
    {
        return;
    }

    for (Index = MovementBuffer.Length - 1; Index >= 0; Index--)
    {
        MovementBuffer[Index].Time -= (DeltaTime);
        NextStep = MovementBuffer[Index];

        if (NextStep.Time > 0.f)
        {
            break;
        }
        
        MovementBuffer[Index].Time = 0.f;

        if (MovementBuffer.Length != 1)
        {
            MovementBuffer.Remove(Index, 1);
        }
    }
    
    AttachToActor(NextStep.AttachParent);

    GetAxes(NextStep.Rotation, X, Y, Z);
    CurrentQuat = QuatFromRotator(NextStep.Rotation);
    TemporaryQuat = QuatFromAxisAngle(Z, -90.f);
    CurrentQuat = QuatProduct(CurrentQuat, TemporaryQuat);
    SetRotation(RLerp(CurrentRotation, QuatToRotator(CurrentQuat), DeltaTime * InterpolationRate * 0.25f));
    CurrentRotation = Rotation;

    if (NextStep.AttachParent != None)
    {
        SetRelativeLocation(NextStep.RelativeLocation);
        return;
    }

    StartingLocation = Location;
    Displacement = (NextStep.Location - Location);
    
    MovementBufferVelocity.X = Lerp(DeltaTime * InterpolationRate, MovementBufferVelocity.X, Displacement.X);
    MovementBufferVelocity.Y = Lerp(DeltaTime * InterpolationRate, MovementBufferVelocity.Y, Displacement.Y);
    MovementBufferVelocity.Z = Lerp(DeltaTime * InterpolationRate, MovementBufferVelocity.Z, Displacement.Z);
    SetLocation(Location + (MovementBufferVelocity * DeltaTime * (InterpolationRate * 0.5f)));
    if (VSizeSquared(Location) < 2.f || (Normal(Location - NextStep.Location) dot Normal(StartingLocation - NextStep.Location)) <= 0.f)
    {
        SetLocation(NextStep.Location);
    }
}

static final function Quat QuatFromAxisAngle(Vector Axis, float Degrees)
{
    local Quat Q;
    local float HalfAngleRad, S;

    HalfAngleRad = Degrees * 0.5 * Pi / 180.0;
    S = Sin(HalfAngleRad);

    Q.X = Axis.X * S;
    Q.Y = Axis.Y * S;
    Q.Z = Axis.Z * S;
    Q.W = Cos(HalfAngleRad);

    return Q;
}

static final function Rotator RLerp(Rotator A, Rotator B, float Alpha)
{
    local Rotator Result;
    local int Delta;

    Delta = B.Pitch - A.Pitch;
    if (Delta > 32768)
        Delta -= 65536;
    else if (Delta < -32768)
        Delta += 65536;
    Result.Pitch = A.Pitch + int(Delta * Alpha);

    Delta = B.Yaw - A.Yaw;
    if (Delta > 32768)
        Delta -= 65536;
    else if (Delta < -32768)
        Delta += 65536;
    Result.Yaw = A.Yaw + int(Delta * Alpha);

    Delta = B.Roll - A.Roll;
    if (Delta > 32768)
        Delta -= 65536;
    else if (Delta < -32768)
        Delta += 65536;
    Result.Roll = A.Roll + int(Delta * Alpha);

    return Result;
}

defaultproperties
{
    bUseMovementBuffer=True
    bUseMovementBufferRotation=True
    MaxMovementBufferSize = 5
    LastMovementStepTime=-1.f
    InterpolationRate=10.f

    bTickVisibility=True
    bIsVisible=False

    bDebugSpectatorActor=False

    DrawType=DT_None
    bHidden=True //Default bHidden is True to let us warm up before showing the actor.
    
    Physics=PHYS_None
    
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=True
    bOnlyRelevantToOwner=False
    bSkipActorPropertyReplication=True
    bReplicateMovement=False
    NetUpdateFrequency=8.0
    bNetNotify=True
    
    CollisionRadius=1.0
    CollisionHeight=1.0
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockKarma=false
    bBlockZeroExtentTraces=false
    bBlockNonZeroExtentTraces=false
}