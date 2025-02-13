//Killing Floor Turbo W_BoomStick_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_BoomStick_Proj extends W_BaseShotgunBullet;

function PreBeginPlay()
{
    local W_BoomStick_Fire_Alt WeaponFire;
    WeaponFire = W_BoomStick_Fire_Alt(GetWeaponFire());

    if (WeaponFire != None)
    {
        FireModeHitRegisterCount = WeaponFire.FireEffectCount;
    }

    Super.PreBeginPlay();
}

function NotifyProjectileRegisterHit(TurboPlayerEventHandler.MonsterHitData HitData)
{
    local W_BoomStick_Fire_Alt WeaponFire;
    WeaponFire = W_BoomStick_Fire_Alt(GetWeaponFire());

    if (WeaponFire == None)
    {
        return;
    }

    RegisterHit(WeaponFire.HitRegistryList, HitData);
}

defaultproperties
{
    PenDamageReduction=0.650000
    MomentumTransfer=60000.000000
    
    Damage=50.000000
    MyDamageType=Class'W_BoomStick_DT'
}
