//Killing Floor Turbo ExplodeDoorsActor
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class ExplodeDoorsActor extends Engine.Info;

var array<KFUseTrigger> UseTriggerList;
var int TriggerIndex;

var KFGameType GameType;
var bool bExplodePending;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    GameType = KFGameType(Level.Game);
    SetTimer(1.f, false);
}

function Timer()
{
    local KFUseTrigger UserTrigger;

    foreach DynamicActors(class'KFUseTrigger', UserTrigger)
    {
        if (UserTrigger == None || UserTrigger.DoorOwners.Length == 0)
        {
            continue;
        }

        UseTriggerList[UseTriggerList.Length] = UserTrigger;
    }
    
    GotoState('WaitingToExplodeDoors');
}

function ExplodeDoors()
{
    bExplodePending = true;
}

state ExplodingDoors
{
    function ExplodeDoors() {}

Begin:
    bExplodePending = false;
    TriggerIndex = 0;
    Sleep(1.f);
    while(TriggerIndex < UseTriggerList.Length)
    {
        Explode(UseTriggerList[TriggerIndex]);
        TriggerIndex++;
        Sleep(0.1f);
    }
    
    GotoState('WaitingToExplodeDoors');
}

final function Explode(KFUseTrigger UseTrigger)
{
    local int Index;
    local Mover Follower;
    
    for (Index = UseTrigger.DoorOwners.Length - 1; Index >= 0; Index--)
    {
        if (UseTrigger.DoorOwners[Index] == None || UseTrigger.DoorOwners[Index].bDoorIsDead)
        {
            continue;
        }

        UseTrigger.DoorOwners[Index].GoBang(None, vect(0, 0, 0), vect(0, 0, 0), class'DamageType');

        Follower = UseTrigger.DoorOwners[Index].Follower;
        while (Follower != None)
        {
            if (KFDoorMover(Follower) != None && !KFDoorMover(Follower).bDoorIsDead)
            {
                KFDoorMover(Follower).GoBang(None, vect(0, 0, 0), vect(0, 0, 0), class'DamageType');
            }

            Follower = Follower.Follower;
        }
    }
}

state WaitingToExplodeDoors
{
    function BeginState()
    {
        if (bExplodePending)
        {
            SetTimer(0.1f, false);
        }
    }

    function Timer()
    {
        ExplodeDoors();
    }

    function ExplodeDoors()
    {
        GotoState('ExplodingDoors');
    }
}

defaultproperties
{

}