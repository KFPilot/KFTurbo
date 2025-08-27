//Killing Floor Turbo TurboPlayerEventHandler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerEventHandler extends TurboEventHandler;

struct MonsterHitData
{
    var KFMonster Monster;
    var class<KFMonster> MonsterClass;
    var bool bIsHeadshot;
    var int DamageDealt;
};

delegate OnPlayerFire(TurboPlayerController Player, WeaponFire FireMode);
delegate OnPlayerMeleeFire(TurboPlayerController Player, KFMeleeFire FireMode);

delegate OnPlayerFireHit(TurboPlayerController Player, WeaponFire FireMode, KFMonster HitMonster, class<KFMonster> MonsterClass, bool bHeadshot, int Damage);

delegate OnPlayerMedicDartFire(TurboPlayerController Player, WeaponFire FireMode);

delegate OnPlayerReload(TurboPlayerController Player, KFWeapon Weapon);

delegate OnPlayerDamagedMonster(TurboPlayerController Player, KFMonster Target, int Damage);
delegate OnPlayerReceivedDamage(TurboPlayerController Player, KFMonster Instigator, int Damage);

delegate OnPlayerKilledMonster(TurboPlayerController Player, KFMonster Target, class<DamageType> DamageType);
delegate OnPlayerDied(TurboPlayerController Player, Controller Killer, class<DamageType> DamageType);

static function TurboEventHandler CreateHandler(Actor Context)
{
    local TurboEventHandler Handler;
    local KFTurboGameType GameType;

    Handler = Super.CreateHandler(Context);

    if (Handler == None)
    {
        return None;
    }

    GameType = KFTurboGameType(Context.Level.Game);
    GameType.GlobalPlayerEventHandlerList[GameType.GlobalPlayerEventHandlerList.Length] = TurboPlayerEventHandler(Handler);
    return Handler;
}

function RemoveEventHandler()
{
    local int Index;
    local KFTurboGameType GameType;
    GameType = KFTurboGameType(Level.Game);

    Super.RemoveEventHandler();

    for (Index = GameType.GlobalPlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        if (GameType.GlobalPlayerEventHandlerList[Index] != self)
        {
            continue;
        }

        GameType.GlobalPlayerEventHandlerList.Remove(Index, 1);
        break;
    }
}

static function TurboEventHandler CreatePlayerHandler(TurboPlayerController Player)
{
    local TurboEventHandler Handler;

    Handler = Super.CreateHandler(Player);

    if (Handler == None)
    {
        return None;
    }

    Player.PlayerEventHandlerList[Player.PlayerEventHandlerList.Length] = TurboPlayerEventHandler(Handler);
    return Handler;
}

//Event broadcasting.
static final function BroadcastPlayerFire(Controller Player, WeaponFire FireMode)
{
    local TurboPlayerController TurboPlayerController;
    local KFTurboGameType GameType;
    local int Index;

    TurboPlayerController = TurboPlayerController(Player);

    if (TurboPlayerController == None || TurboPlayerController.Role != ROLE_Authority)
    {
        return;
    }
    
    GameType = KFTurboGameType(Player.Level.Game);

    if (GameType == None)
    {
        return;
    }

    for (Index = TurboPlayerController.PlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        TurboPlayerController.PlayerEventHandlerList[Index].OnPlayerFire(TurboPlayerController, FireMode);
    }

    for (Index = GameType.GlobalPlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.GlobalPlayerEventHandlerList[Index].OnPlayerFire(TurboPlayerController, FireMode);
    }
}

static final function CollectMonsterHitData(Actor Other, vector HitLocation, vector Direction, out MonsterHitData HitData, optional float HeadshotAdditionalScale)
{
    HitData.Monster = None;
    HitData.MonsterClass = None;
    HitData.bIsHeadshot = false;
    HitData.DamageDealt = 0;
    
    HitData.Monster = KFMonster(Other);
    if (HitData.Monster == None)
    {
        HitData.Monster = KFMonster(Other.Base);
    }

    if (HitData.Monster != None)
    {
        if (HeadshotAdditionalScale == 0.f)
        {
            HeadshotAdditionalScale = 1.f;
        }

        HitData.bIsHeadshot = !HitData.Monster.bDecapitated && HitData.Monster.IsHeadShot(HitLocation, Direction, HeadshotAdditionalScale);
        HitData.DamageDealt = HitData.Monster.Health;
    }
}

static final function FinalizeMonsterHitData(out MonsterHitData HitData)
{
    if (HitData.Monster != None)
    {
        HitData.DamageDealt -= HitData.Monster.Health;
    }
}

static final function BroadcastPlayerFireHit(Controller Player, WeaponFire FireMode, MonsterHitData HitData)
{
    local TurboPlayerController TurboPlayerController;
    local KFTurboGameType GameType;
    local int Index;

    TurboPlayerController = TurboPlayerController(Player);

    if (TurboPlayerController == None || TurboPlayerController.Role != ROLE_Authority)
    {
        return;
    }
    
    GameType = KFTurboGameType(Player.Level.Game);

    if (GameType == None)
    {
        return;
    }

    FinalizeMonsterHitData(HitData);

    for (Index = TurboPlayerController.PlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        TurboPlayerController.PlayerEventHandlerList[Index].OnPlayerFireHit(TurboPlayerController, FireMode, HitData.Monster, HitData.MonsterClass, HitData.bIsHeadshot, HitData.DamageDealt);
    }

    for (Index = GameType.GlobalPlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.GlobalPlayerEventHandlerList[Index].OnPlayerFireHit(TurboPlayerController, FireMode, HitData.Monster, HitData.MonsterClass, HitData.bIsHeadshot, HitData.DamageDealt);
    }
}

static final function BroadcastPlayerMeleeFire(Controller Player, KFMeleeFire FireMode)
{
    local TurboPlayerController TurboPlayerController;
    local KFTurboGameType GameType;
    local int Index;

    TurboPlayerController = TurboPlayerController(Player);

    if (TurboPlayerController == None || TurboPlayerController.Role != ROLE_Authority)
    {
        return;
    }
    
    GameType = KFTurboGameType(Player.Level.Game);

    if (GameType == None)
    {
        return;
    }

    for (Index = TurboPlayerController.PlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        TurboPlayerController.PlayerEventHandlerList[Index].OnPlayerMeleeFire(TurboPlayerController, FireMode);
    }

    for (Index = GameType.GlobalPlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.GlobalPlayerEventHandlerList[Index].OnPlayerMeleeFire(TurboPlayerController, FireMode);
    }
    
    BroadcastPlayerFire(Player, FireMode);
}

static final function BroadcastPlayerMedicDartFire(Controller Player, WeaponFire FireMode)
{
    local TurboPlayerController TurboPlayerController;
    local KFTurboGameType GameType;
    local int Index;

    TurboPlayerController = TurboPlayerController(Player);

    if (TurboPlayerController == None || TurboPlayerController.Role != ROLE_Authority)
    {
        return;
    }
    
    GameType = KFTurboGameType(Player.Level.Game);

    if (GameType == None)
    {
        return;
    }

    for (Index = TurboPlayerController.PlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        TurboPlayerController.PlayerEventHandlerList[Index].OnPlayerMedicDartFire(TurboPlayerController, FireMode);
    }

    for (Index = GameType.GlobalPlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.GlobalPlayerEventHandlerList[Index].OnPlayerMedicDartFire(TurboPlayerController, FireMode);
    }
}

static final function BroadcastPlayerReload(Controller Player, KFWeapon Weapon)
{
    local TurboPlayerController TurboPlayerController;
    local KFTurboGameType GameType;
    local int Index;

    TurboPlayerController = TurboPlayerController(Player);

    if (TurboPlayerController == None || TurboPlayerController.Role != ROLE_Authority)
    {
        return;
    }
    
    GameType = KFTurboGameType(Player.Level.Game);

    if (GameType == None)
    {
        return;
    }

    for (Index = TurboPlayerController.PlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        TurboPlayerController.PlayerEventHandlerList[Index].OnPlayerReload(TurboPlayerController, Weapon);
    }

    for (Index = GameType.GlobalPlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.GlobalPlayerEventHandlerList[Index].OnPlayerReload(TurboPlayerController, Weapon);
    }
}

static final function BroadcastPlayerDamagedMonster(Controller Player, KFMonster Target, int Damage)
{
    local TurboPlayerController TurboPlayerController;
    local KFTurboGameType GameType;
    local int Index;

    TurboPlayerController = TurboPlayerController(Player);

    if (TurboPlayerController == None || TurboPlayerController.Role != ROLE_Authority)
    {
        return;
    }
    
    GameType = KFTurboGameType(Player.Level.Game);

    if (GameType == None)
    {
        return;
    }

    for (Index = TurboPlayerController.PlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        TurboPlayerController.PlayerEventHandlerList[Index].OnPlayerDamagedMonster(TurboPlayerController, Target, Damage);
    }

    for (Index = GameType.GlobalPlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.GlobalPlayerEventHandlerList[Index].OnPlayerDamagedMonster(TurboPlayerController, Target, Damage);
    }
}

static final function BroadcastPlayerReceivedDamage(Controller Player, KFMonster Instigator, int Damage)
{
    local TurboPlayerController TurboPlayerController;
    local KFTurboGameType GameType;
    local int Index;

    TurboPlayerController = TurboPlayerController(Player);

    if (TurboPlayerController == None || TurboPlayerController.Role != ROLE_Authority)
    {
        return;
    }
    
    GameType = KFTurboGameType(Player.Level.Game);

    if (GameType == None)
    {
        return;
    }

    for (Index = TurboPlayerController.PlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        TurboPlayerController.PlayerEventHandlerList[Index].OnPlayerReceivedDamage(TurboPlayerController, Instigator, Damage);
    }

    for (Index = GameType.GlobalPlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.GlobalPlayerEventHandlerList[Index].OnPlayerReceivedDamage(TurboPlayerController, Instigator, Damage);
    }
}

static final function BroadcastPlayerKilledMonster(Controller Player, KFMonster Target, class<DamageType> DamageType)
{
    local TurboPlayerController TurboPlayerController;
    local KFTurboGameType GameType;
    local int Index;

    TurboPlayerController = TurboPlayerController(Player);

    if (TurboPlayerController == None || TurboPlayerController.Role != ROLE_Authority)
    {
        return;
    }
    
    GameType = KFTurboGameType(Player.Level.Game);

    if (GameType == None)
    {
        return;
    }

    TurboPlayerController = TurboPlayerController(Player);

    if (TurboPlayerController == None || TurboPlayerController.Role != ROLE_Authority)
    {
        return;
    }

    for (Index = TurboPlayerController.PlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        TurboPlayerController.PlayerEventHandlerList[Index].OnPlayerKilledMonster(TurboPlayerController, Target, DamageType);
    }

    for (Index = GameType.GlobalPlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.GlobalPlayerEventHandlerList[Index].OnPlayerKilledMonster(TurboPlayerController, Target, DamageType);
    }
}

static final function BroadcastPlayerDied(TurboPlayerController Player, Controller Killer, class<DamageType> DamageType)
{
    local KFTurboGameType GameType;
    local int Index;

    if (Player.Role != ROLE_Authority)
    {
        return;
    }

    GameType = KFTurboGameType(Player.Level.Game);

    if (GameType == None)
    {
        return;
    }

    for (Index = Player.PlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        Player.PlayerEventHandlerList[Index].OnPlayerDied(Player, Killer, DamageType);
    }

    for (Index = GameType.GlobalPlayerEventHandlerList.Length - 1; Index >= 0; Index--)
    {
        GameType.GlobalPlayerEventHandlerList[Index].OnPlayerDied(Player, Killer, DamageType);
    }
}