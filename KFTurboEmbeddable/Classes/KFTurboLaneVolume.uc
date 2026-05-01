//Killing Floor Turbo KFTurboLaneVolume
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboLaneVolume extends Volume;

var KFTurboLaneManager Manager;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    Disable('Touch');
    Disable('UnTouch');
}

function Initialize(KFTurboLane OwningLane)
{
    Manager = OwningLane.OwningManager;
}

simulated final function bool HasPlayers()
{
    local KFHumanPawn Pawn;
    foreach TouchingActors(class'KFHumanPawn', Pawn)
    {
        if (Pawn.Health > 0)
        {
            return true;
        }
    }

    return false;
}

function TurnOn()
{
    GotoState('EjectPlayers');
}

function TurnOff() {}

state EjectPlayers
{
    function BeginState()
    {
        TeleportOutPlayers();
        Enable('Touch');
        Enable('UnTouch');
    }

    function EndState()
    {
        Disable('Touch');
        Disable('UnTouch');
    }

    function TurnOn() {}
    
    function TurnOff()
    {
        GotoState('');
    }

    function Touch(Actor Other)
    {
        TeleportPlayer(KFHumanPawn(Other));
    }
}

function TeleportPlayer(KFHumanPawn Pawn)
{
	local Vector RandomOffset;

    if (Pawn == None || Pawn.Health <= 0)
    {
        return;
    }

    RandomOffset = VRand() * 32.f;
    RandomOffset.Z = 12.f;
    Pawn.SetLocation(Manager.PlayerStartList[Rand(Manager.PlayerStartList.Length)].Location + RandomOffset);
}

function TeleportOutPlayers()
{
	local int SpawnerIndex;
	local Vector RandomOffset;
	local KFHumanPawn Pawn;

    foreach TouchingActors(class'KFHumanPawn', Pawn)
    {
        if (Pawn.Health <= 0)
        {
            continue;
        }

        RandomOffset = VRand() * 32.f;
        RandomOffset.Z = 12.f;

        Pawn.SetLocation(Manager.PlayerStartList[SpawnerIndex % Manager.PlayerStartList.Length].Location + RandomOffset);
        SpawnerIndex++;
    }
}