//Killing Floor Turbo W_Benelli_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Benelli_Proj extends W_BaseShotgunBullet;

function PreBeginPlay()
{
    local W_Benelli_Fire WeaponFire;
    WeaponFire = W_Benelli_Fire(GetWeaponFire());

    if (WeaponFire != None)
    {
        FireModeHitRegisterCount = WeaponFire.FireEffectCount;
    }

    Super.PreBeginPlay();
}

function NotifyProjectileRegisterHit(TurboPlayerEventHandler.MonsterHitData HitData)
{
    local W_Benelli_Fire WeaponFire;
    WeaponFire = W_Benelli_Fire(GetWeaponFire());

    if (WeaponFire == None)
    {
        return;
    }

    RegisterHit(WeaponFire.HitRegistryList, HitData);
}

defaultproperties
{
    PenDamageReduction=0.750000
    MyDamageType=Class'DamageTypeBenelli'
}
