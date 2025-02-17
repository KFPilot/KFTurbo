//Killing Floor Turbo PlayerNoRestForTheWickedActor
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PlayerNoRestForTheWickedActor extends Engine.Info;

struct PlayerMovementCache
{
    var float NextDamageTime;
    var PlayerController Player;
};

var array<PlayerMovementCache> PlayerMovementList;

function ResetPlayerMovementCache(out PlayerMovementCache Cache)
{
    Cache.NextDamageTime = Level.TimeSeconds + 5.f;
}

function TickPlayerMovementCache(PlayerController PlayerController)
{
    local int Index;
    local bool bFoundPlayer;

    for (Index = PlayerMovementList.Length - 1; Index >= 0; Index--)
    {
        if (PlayerMovementList[Index].Player == None)
        {
            PlayerMovementList.Remove(Index, 1);
            continue;
        }

        if (PlayerController != PlayerMovementList[Index].Player)
        {
            continue;
        }

        bFoundPlayer = true;

        if (PlayerController.Pawn == None || PlayerController.Pawn.bDeleteMe || PlayerController.Pawn.Health <= 0)
        {
            ResetPlayerMovementCache(PlayerMovementList[Index]);
            break;
        }

        if (VSize(PlayerController.Pawn.Velocity) > 10.f)
        {
            ResetPlayerMovementCache(PlayerMovementList[Index]);
            break;
        }

        if (PlayerMovementList[Index].NextDamageTime > Level.TimeSeconds)
        {
            break;
        }

        PlayerController.Pawn.TakeDamage(10, None, PlayerController.Pawn.Location, vect(0, 0, 0), class'NoRestForTheWicked_DT');
        PlayerMovementList[Index].NextDamageTime = Level.TimeSeconds + 1.f;
        break;
    }

    if (!bFoundPlayer)
    {
        PlayerMovementList.Length = PlayerMovementList.Length + 1;
        PlayerMovementList[PlayerMovementList.Length - 1].Player = PlayerController;
        ResetPlayerMovementCache(PlayerMovementList[PlayerMovementList.Length - 1]);
    }
}

function Tick(float DeltaTime)
{
    local Controller C;
    local int Index;
    if (!KFGameType(Level.Game).bWaveInProgress)
    {
        for (Index = PlayerMovementList.Length - 1; Index >= 0; Index--)
        {
            ResetPlayerMovementCache(PlayerMovementList[Index]);
        }
        return;
    }

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if (PlayerController(C) == None)
        {
            continue;
        }

        TickPlayerMovementCache(PlayerController(C));
    }
}

defaultproperties
{

}
