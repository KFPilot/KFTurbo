//Killing Floor Turbo PlayerGrenadePrinterActor
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PlayerGrenadePrinterActor extends Engine.Info;

var float GrantInterval;
var float TimeUntilNextGrant;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    TimeUntilNextGrant = GrantInterval;
    SetTimer(1.f, true);
}

function Timer()
{
    local array<TurboHumanPawn> PawnList;
    local int Index;
    local Weapon FragWeapon;

    //Don't count down or grant grenades outside of a wave.
    if (KFGameType(Level.Game) == None || !KFGameType(Level.Game).bWaveInProgress)
    {
        TimeUntilNextGrant = GrantInterval;
        return;
    }

    TimeUntilNextGrant -= 1.f;

    if (TimeUntilNextGrant > 0.f)
    {
        return;
    }

    TimeUntilNextGrant = GrantInterval;

    PawnList = class'TurboGameplayHelper'.static.GetPlayerPawnList(Level);

    for (Index = PawnList.Length - 1; Index >= 0; Index--)
    {
        FragWeapon = Weapon(PawnList[Index].FindInventoryType(class'Frag'));

        if (FragWeapon != None)
        {
            FragWeapon.AddAmmo(1, 0);
        }
    }
}

defaultproperties
{
    GrantInterval=30.f
}
