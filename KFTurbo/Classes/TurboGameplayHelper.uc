//Killing Floor Turbo TurboGameplayHelper
//Helpful gameplay statics.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGameplayHelper extends Object;

const ASSUMED_PLAYER_COUNT = 6;

static final function array<TurboPlayerController> GetPlayerControllerList(LevelInfo Level, optional bool bIncludeSpectators)
{
    local Controller Controller;
    local TurboPlayerController TurboPlayerController;
    local array<TurboPlayerController> PlayerControllerList;
    local int FoundControllers;

    PlayerControllerList.Length = ASSUMED_PLAYER_COUNT;
    FoundControllers = 0;

    for ( Controller = Level.ControllerList; Controller != None; Controller = Controller.NextController )
    {
        if (!Controller.bIsPlayer)
        {
            continue;
        }

        if (Controller.PlayerReplicationInfo == None || (Controller.PlayerReplicationInfo.bOnlySpectator && !bIncludeSpectators))
        {
            continue;
        }

        TurboPlayerController = TurboPlayerController(Controller);

        if (TurboPlayerController != None)
        {
            if (PlayerControllerList.Length <= FoundControllers)
            {
                PlayerControllerList.Length = FoundControllers + 2; //Allocate in steps of 2.
            }

            PlayerControllerList[FoundControllers] = TurboPlayerController;
            FoundControllers++;
        }
    }

    if (FoundControllers < PlayerControllerList.Length)
    {
        PlayerControllerList.Length = FoundControllers;
    }

    return PlayerControllerList;
}

static final function int GetPlayerControllerCount(LevelInfo Level, optional bool bIncludeSpectators)
{
    local Controller Controller;
    local int FoundControllers;

    FoundControllers = 0;

    for ( Controller = Level.ControllerList; Controller != None; Controller = Controller.NextController )
    {
        if (!Controller.bIsPlayer)
        {
            continue;
        }

        if (Controller.PlayerReplicationInfo == None || (Controller.PlayerReplicationInfo.bOnlySpectator && !bIncludeSpectators))
        {
            continue;
        }

        FoundControllers++;
    }

    return FoundControllers;
}

static final function array<TurboHumanPawn> GetPlayerPawnList(LevelInfo Level)
{
    local Controller Controller;
    local TurboHumanPawn TurboHumanPawn;
    local array<TurboHumanPawn> HumanPawnList;
    local int FoundPawns;

    HumanPawnList.Length = ASSUMED_PLAYER_COUNT;
    FoundPawns = 0;

    for ( Controller = Level.ControllerList; Controller != None; Controller = Controller.NextController )
    {
        if (!Controller.bIsPlayer)
        {
            continue;
        }

        if (Controller.Pawn == None || Controller.Pawn.bDeleteMe || Controller.Pawn.Health <= 0)
        {
            continue;
        }

        TurboHumanPawn = TurboHumanPawn(Controller.Pawn);

        if (TurboHumanPawn != None)
        {
            if (HumanPawnList.Length <= FoundPawns)
            {
                HumanPawnList.Length = FoundPawns + 2; //Allocate in steps of 2.
            }

            HumanPawnList[FoundPawns] = TurboHumanPawn;
            FoundPawns++;
        }
    }

    if (FoundPawns < HumanPawnList.Length)
    {
        HumanPawnList.Length = FoundPawns;
    }

    return HumanPawnList;
}

static final function array<Monster> GetMonsterPawnList(LevelInfo Level, optional class<Monster> FilterClass)
{
    local Controller Controller;
    local Monster MonsterPawn;
    local array<Monster> MonsterPawnList;
    local int FoundPawns;
    local int Index;

    for ( Controller = Level.ControllerList; Controller != None; Controller = Controller.NextController )
    {
        if (Controller.bIsPlayer)
        {
            continue;
        }

        if (Controller.Pawn == None || Controller.Pawn.bDeleteMe || Controller.Pawn.Health <= 0)
        {
            continue;
        }

        MonsterPawn = Monster(Controller.Pawn);

        if (MonsterPawn != None)
        {
            if (MonsterPawnList.Length <= FoundPawns)
            {
                MonsterPawnList.Length = FoundPawns + 4; //Allocate in steps of 4.
            }

            MonsterPawnList[FoundPawns] = MonsterPawn;
            FoundPawns++;
        }
    }

    if (FoundPawns < MonsterPawnList.Length)
    {
        MonsterPawnList.Length = FoundPawns;
    }

    if (FilterClass != None)
    {
        for (Index = MonsterPawnList.Length - 1; Index >= 0; Index--)
        {
            if (MonsterPawnList[Index] == None || !ClassIsChildOf(MonsterPawnList[Index].Class, FilterClass))
            {
                MonsterPawnList.Remove(Index, 1);
            }
        }
    }

    return MonsterPawnList;
}