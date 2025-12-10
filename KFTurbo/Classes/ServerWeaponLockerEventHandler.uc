//Killing Floor Turbo ServerWeaponLockerEventHandler
//Used to fix ShopVolume accessed none log warning.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class ServerWeaponLockerEventHandler extends TurboWaveEventHandler;

var WeaponLocker ServerWeaponLocker;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    OnGameStarted = GameStarted;
}

final function WeaponLocker GetOrCreateServerWeaponLocker()
{
    if (ServerWeaponLocker == None)
    {
        ServerWeaponLocker = Spawn(class'ServerWeaponLocker');
    }

    return ServerWeaponLocker;
}

final function GameStarted(KFTurboGameType GameType, int StartingWave)
{
    local int Index;
    local ShopVolume Shop;

    for (Index = GameType.ShopList.Length - 1; Index >= 0; Index--)
    {
        Shop = GameType.ShopList[Index];
        if (Shop == None || Shop.MyTrader != None)
        {
            continue;
        }

        Shop.MyTrader = GetOrCreateServerWeaponLocker();
    }

    if (!class'KFTurboGameType'.static.StaticIsTestGameType(self))
    {
        return;
    }

    foreach AllActors(class'ShopVolume', Shop)
    {
        if (Shop.MyTrader != None)
        {
            continue;
        }
        
        Shop.MyTrader = GetOrCreateServerWeaponLocker();
    }

    LifeSpan = 2.f;
}

defaultproperties
{

}