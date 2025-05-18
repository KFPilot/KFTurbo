//Killing Floor Turbo TurboPlayerCardEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerCardEventHandler extends TurboPlayerEventHandler;

var bool bTossGrenadeBuff;
var bool bPlayerHeadshotsIncreaseHeadshotDamage;

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
    OnPlayerFireHit = PlayerFireHit;
}

final function PlayerFire(TurboPlayerController Player, WeaponFire FireMode)
{
    if (bTossGrenadeBuff && W_Frag_Fire(FireMode) != None)
    {
        FindCardCustomInfo(Player).PlayerThrewGrenade(); 
    }
}

final function PlayerFireHit(TurboPlayerController Player, WeaponFire FireMode, KFMonster HitMonster, class<KFMonster> MonsterClass, bool bHeadshot, int Damage)
{
    if (bHeadshot && bPlayerHeadshotsIncreaseHeadshotDamage)
    {
        FindCardCustomInfo(Player).PlayerScoredHeadshot(); 
    }
}

defaultproperties
{
    bTossGrenadeBuff=false
    bPlayerHeadshotsIncreaseHeadshotDamage=false
}