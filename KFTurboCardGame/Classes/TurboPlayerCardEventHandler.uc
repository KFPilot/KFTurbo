//Killing Floor Turbo TurboPlayerCardEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerCardEventHandler extends TurboPlayerEventHandler;

var bool bTossGrenadeBuff;

static function TurboPlayerCardCustomInfo FindCardCustomInfo(TurboPlayerController Player)
{
    if (Player == None)
    {
        return None;
    }

    return TurboPlayerCardCustomInfo(class'TurboPlayerCardCustomInfo'.static.FindCustomInfo(TurboPlayerReplicationInfo(Player.PlayerReplicationInfo)));
}

function PostBeginPlay()
{
    Super.PostBeginPlay();

    OnPlayerFire = PlayerFire;
}

final function PlayerFire(TurboPlayerController Player, WeaponFire FireMode)
{
    if (bTossGrenadeBuff && W_Frag_Fire(FireMode) != None)
    {
        FindCardCustomInfo(Player).PlayerThrewGrenade(); 
    }
}

defaultproperties
{
    bTossGrenadeBuff=false
}