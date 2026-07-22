//Killing Floor Turbo TurboPlayerCardEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerCardEventHandler extends TurboPlayerEventHandler;

var bool bTossGrenadeBuff;

var protected bool bNotifyCardCustomInfoOnHeadshot;
var protected bool bRackEmUpEnabled;
var protected bool bPrecisionChainEnabled;

var float PrecisionChainChance;
var protected PrecisionChainManager PrecisionChainActor;

var float PlayerKillsReloadMagazineChance;

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
    OnPlayerKilledMonster = PlayerKilledMonster;
}

final function SetRackEmUpEnabled(bool bEnabled)
{
    bRackEmUpEnabled = bEnabled;
    UpdateNotify();
}

final function SetPrecisionChainEnabled(bool bEnabled)
{
    bPrecisionChainEnabled = bEnabled;

    if (bEnabled && PrecisionChainActor == None)
    {
        PrecisionChainActor = Spawn(class'PrecisionChainManager', Self);
    }

    UpdateNotify();
}

final function UpdateNotify()
{
    bNotifyCardCustomInfoOnHeadshot = bRackEmUpEnabled || bPrecisionChainEnabled;
}

final function PlayerFire(TurboPlayerController Player, WeaponFire FireMode)
{
    local TurboPlayerCardCustomInfo PlayerCardCustomInfo;
    PlayerCardCustomInfo = FindCardCustomInfo(Player);

    if (PlayerCardCustomInfo == None)
    {
        return;
    }

    PlayerCardCustomInfo.PlayerFire(Player, FireMode);

    if (bTossGrenadeBuff && W_Frag_Fire(FireMode) != None)
    {
        PlayerCardCustomInfo.PlayerThrewGrenade();
    }
}

final function PlayerFireHit(TurboPlayerController Player, WeaponFire FireMode, KFMonster HitMonster, class<KFMonster> MonsterClass, bool bHeadshot, int BaseDamage, int Damage, class<DamageType> DamageType)
{
    local TurboPlayerCardCustomInfo CardCustomInfo;

    //Do not consider precision chain headshots as player headshots.
    if (bPrecisionChainEnabled && PrecisionChainActor.bProcessingChainList)
    {
        return;
    }

    if (bHeadShot && bNotifyCardCustomInfoOnHeadshot)
    {
        CardCustomInfo = FindCardCustomInfo(Player);
    }

    if (bHeadshot && CardCustomInfo != None)
    {
        if (bRackEmUpEnabled)
        {
            CardCustomInfo.IncrementRackEmUp();
        }

        if (bPrecisionChainEnabled && CardCustomInfo.AttemptPrecisionChain() && FRand() < PrecisionChainChance)
        {
            PrecisionChainActor.NotifyPrecisionChain(HitMonster, HitMonster.Location, TurboPlayerReplicationInfo(Player.PlayerReplicationInfo), BaseDamage, DamageType);
        }
    }
}

final function PlayerKilledMonster(TurboPlayerController Player, KFMonster Target, class<DamageType> DamageType)
{
    if (PlayerKillsReloadMagazineChance != 0.f && Player.Pawn != None && Player.Pawn.Health > 0)
    {
        if (FRand() < PlayerKillsReloadMagazineChance)
        {
            ReloadWeapon(Player.Pawn);
        }
    }
}

final function ReloadWeapon(Pawn PlayerPawn)
{
    local KFWeapon Weapon;
    Weapon = KFWeapon(PlayerPawn.Weapon);

    if (Weapon == None || Weapon.default.MagCapacity <= 2)
    {
        return;
    }

    Weapon.AddReloadedAmmo();
}

defaultproperties
{
    bTossGrenadeBuff=false

    bNotifyCardCustomInfoOnHeadshot=false
    bRackEmUpEnabled=false
    bPrecisionChainEnabled=false
    PrecisionChainChance=0.f

    PlayerKillsReloadMagazineChance = 0.f;
}
