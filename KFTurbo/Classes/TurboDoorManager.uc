//Killing Floor Turbo TurboDoorManager
//Monitors doors and makes sure any door pairs are not bugged (only one is broken).
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboDoorManager extends Info;

var array<KFUseTrigger> UseTriggerList;
var int TriggerIndex;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    SetTimer(1.f, false);
}

//Defer collection of use triggers to make sure doors had time to link up.
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
}

auto state WatchDoors
{
Begin:
    while (true)
    {
        for (TriggerIndex = 0; TriggerIndex < UseTriggerList.Length; TriggerIndex++)
        {
            CheckUseTrigger(UseTriggerList[TriggerIndex]);
            Sleep(0.05f);
        }

        Sleep(0.05f);
    }
}

final function CheckUseTrigger(KFUseTrigger UseTrigger)
{
    local int DoorIndex;
    local bool bWasSealed;
    local KFDoorMover Door;
    local Mover Follower;

    if (IsPartiallyBroken(UseTrigger))
    {
        for (DoorIndex = 0; DoorIndex < UseTrigger.DoorOwners.Length; DoorIndex++)
        {
            Door = UseTrigger.DoorOwners[DoorIndex];

            if (Door.bDoorIsDead)
            {
                continue;
            }

            Door.GoBang(None, Door.Location, vect(0.f, 0.f, 0.f), None);

            Follower = UseTrigger.DoorOwners[DoorIndex].Follower;
            
            while (Follower != None)
            {
                if (KFDoorMover(Follower) != None)
                {
                    KFDoorMover(Follower).GoBang(None, Follower.Location, vect(0.f, 0.f, 0.f), None);
                }

                Follower = Follower.Follower;
            }
        }

        return;
    }

    if (IsPartiallyOpen(UseTrigger))
    {
        for (DoorIndex = 0; DoorIndex < UseTrigger.DoorOwners.Length; DoorIndex++)
        {
            Door = UseTrigger.DoorOwners[DoorIndex];

            if (Door.bClosed)
            {
                continue;
            }

            //Temporarily unseal door and tell it to close before resealing.
            bWasSealed = Door.bSealed;
            Door.bSealed = false;
            Door.DoClose();
            Door.bSealed = bWasSealed;

            while (Follower != None)
            {
                if (KFDoorMover(Follower) != None)
                {
                    bWasSealed = KFDoorMover(Follower).bSealed;
                    KFDoorMover(Follower).bSealed = false;
                    KFDoorMover(Follower).DoClose();
                    KFDoorMover(Follower).bSealed = bWasSealed;
                }

                Follower = Follower.Follower;
            }
        }

        return;
    }
}

final function bool IsPartiallyBroken(KFUseTrigger UseTrigger)
{
    local int DoorIndex;
    local bool bHasBrokenDoor;
    local bool bHasAliveDoor;
    local Mover Follower;

    bHasBrokenDoor = false;
    bHasAliveDoor = false;

    for (DoorIndex = 0; DoorIndex < UseTrigger.DoorOwners.Length; DoorIndex++)
    {
        if (UseTrigger.DoorOwners[DoorIndex].bDoorIsDead)
        {
            bHasBrokenDoor = true;
        }
        else
        {
            bHasAliveDoor = true;
        }
        
        Follower = UseTrigger.DoorOwners[DoorIndex].Follower;
        while(Follower != None)
        {
            if (KFDoorMover(Follower) != None)
            {
                if (KFDoorMover(Follower).bDoorIsDead)
                {
                    bHasBrokenDoor = true;
                }
                else
                {
                    bHasAliveDoor = true;
                }
            }

            Follower = Follower.Follower;
        }
    }

    return bHasBrokenDoor && bHasAliveDoor;
}

final function bool IsPartiallyOpen(KFUseTrigger UseTrigger)
{
    local int DoorIndex;
    local bool bHasOpenDoor;
    local bool bHasClosedDoor;

    bHasOpenDoor = false;
    bHasClosedDoor = false;

    for (DoorIndex = 0; DoorIndex < UseTrigger.DoorOwners.Length; DoorIndex++)
    {
        if (UseTrigger.DoorOwners[DoorIndex].bClosed)
        {
            bHasClosedDoor = true;
        }
        else
        {
            bHasOpenDoor = true;
        }
    }

    return bHasOpenDoor && bHasClosedDoor;
}

defaultproperties
{
    TriggerIndex = 0
}