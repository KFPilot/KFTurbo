//Killing Floor Turbo PlayerNoRestForTheWickedActor
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PlayerNoRestForTheWickedActor extends Engine.Info;

struct PlayerMovementCache
{
    var float NextDamageTime;
    var bool bWasTakingDamage;
    var PlayerController Player;
};

var array<PlayerMovementCache> PlayerMovementList;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    SetTimer(0.125f, true);
}

function Timer()
{
    local Controller C;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if (!C.bIsPlayer || C.Pawn == None || PlayerController(C) == None)
        {
            continue;
        }

        AddUnique(PlayerController(C));
    }
}

final function AddUnique(PlayerController PlayerController)
{
    local int Index;
    for (Index = PlayerMovementList.Length - 1; Index >= 0; Index--)
    {
        if (PlayerController == PlayerMovementList[Index].Player)
        {
            return;
        }
    }
    
    PlayerMovementList.Length = PlayerMovementList.Length + 1;
    PlayerMovementList[PlayerMovementList.Length - 1].Player = PlayerController;
    ResetPlayerMovementCache(PlayerMovementList[PlayerMovementList.Length - 1]);
}

function ResetPlayerMovementCache(out PlayerMovementCache Cache)
{
    Cache.NextDamageTime = Level.TimeSeconds + 5.f;

    if (Cache.bWasTakingDamage)
    {
        Cache.bWasTakingDamage = false;
        UpdatePlayer(Cache.Player, false);
    }
}

function Tick(float DeltaTime)
{
    local int Index;
 
    if (!KFGameType(Level.Game).bWaveInProgress)
    {
        for (Index = PlayerMovementList.Length - 1; Index >= 0; Index--)
        {
            ResetPlayerMovementCache(PlayerMovementList[Index]);
        }
        return;
    }

    TickPlayerMovementCache();
}

function TickPlayerMovementCache()
{
    local int Index;
    local PlayerController PlayerController;

    for (Index = PlayerMovementList.Length - 1; Index >= 0; Index--)
    {
        if (PlayerMovementList[Index].Player == None)
        {
            PlayerMovementList.Remove(Index, 1);
            continue;
        }

        PlayerController = PlayerMovementList[Index].Player;

        if (PlayerController.Pawn == None || PlayerController.Pawn.bDeleteMe || PlayerController.Pawn.Health <= 0)
        {
            ResetPlayerMovementCache(PlayerMovementList[Index]);
            continue;
        }

        if (VSize(PlayerController.Pawn.Velocity) > 10.f)
        {
            ResetPlayerMovementCache(PlayerMovementList[Index]);
            continue;
        }

        if (PlayerMovementList[Index].NextDamageTime > Level.TimeSeconds)
        {
            continue;
        }

        if (!PlayerMovementList[Index].bWasTakingDamage)
        {
            PlayerMovementList[Index].bWasTakingDamage = true;
            UpdatePlayer(PlayerController, true);
        }

        PlayerController.Pawn.TakeDamage(10, None, PlayerController.Pawn.Location, vect(0, 0, 0), class'NoRestForTheWicked_DT');
        PlayerMovementList[Index].NextDamageTime = Level.TimeSeconds + 1.f;
    }
}

function UpdatePlayer(PlayerController Player, bool bTakingDamage)
{
    local TurboPlayerCardCustomInfo CardCustomInfo;
    CardCustomInfo = TurboPlayerCardCustomInfo(class'TurboPlayerCardCustomInfo'.static.FindCustomInfo(TurboPlayerReplicationInfo(Player.PlayerReplicationInfo)));

    if (CardCustomInfo == None)
    {
        return;
    }

    CardCustomInfo.SetNoRestForTheWickedActive(bTakingDamage);
}

defaultproperties
{

}
