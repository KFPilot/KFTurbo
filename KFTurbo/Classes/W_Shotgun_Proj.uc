//Killing Floor Turbo W_Shotgun_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Shotgun_Proj extends W_BaseShotgunBullet;

function PreBeginPlay()
{
    local W_Shotgun_Fire WeaponFire;
    WeaponFire = W_Shotgun_Fire(GetWeaponFire());

    if (WeaponFire != None)
    {
        FireModeHitRegisterCount = WeaponFire.FireEffectCount;
    }

    Super.PreBeginPlay();
}

function NotifyProjectileRegisterHit(TurboPlayerEventHandler.MonsterHitData HitData)
{
    local W_Shotgun_Fire WeaponFire;
    WeaponFire = W_Shotgun_Fire(GetWeaponFire());

    if (WeaponFire == None)
    {
        return;
    }

    RegisterHit(WeaponFire.HitRegistryList, HitData);
}

defaultproperties
{
     Damage=31.000000
}