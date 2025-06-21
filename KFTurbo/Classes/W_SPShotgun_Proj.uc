//Killing Floor Turbo W_SPShotgun_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SPShotgun_Proj extends W_BaseShotgunBullet;

function PreBeginPlay()
{
    local W_SPShotgun_Fire WeaponFire;
    WeaponFire = W_SPShotgun_Fire(GetWeaponFire());

    if (WeaponFire != None)
    {
        FireModeHitRegisterCount = WeaponFire.FireEffectCount;
    }

    Super.PreBeginPlay();
}

function NotifyProjectileRegisterHit(TurboPlayerEventHandler.MonsterHitData HitData)
{
    local W_SPShotgun_Fire WeaponFire;
    WeaponFire = W_SPShotgun_Fire(GetWeaponFire());

    if (WeaponFire == None)
    {
        return;
    }

    RegisterHit(WeaponFire.HitRegistryList, HitData);
}

defaultproperties
{
	PenDamageReduction=0.750000
	MomentumTransfer=60000.000000
	DrawScale=1.500000

	Damage=25.000000
	MyDamageType=Class'KFMod.DamTypeSPShotgun'
}
