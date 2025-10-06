//Killing Floor Turbo W_Chainsaw_Fire_Alt
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Chainsaw_Fire_Alt extends WeaponChainsawAltFire;

var() int TotalHitCount;
var int CurrentHitCount;
var bool bAwaitingHitTimer;
var float HitInterval;
var float NextHitTimerPop;

var int HitRegisterCount;
var int LastHitRegisterCount;

function DoFireEffect()
{
    class'WeaponHelper'.static.OnMeleeFire(self);
    Super.DoFireEffect();
}

simulated event ModeDoFire()
{
    Super.ModeDoFire();

    CurrentHitCount = 0;
    HitInterval = default.HitInterval / GetFireSpeed();
    HitRegisterCount++;
}

simulated function Timer()
{
    MeleeDamage = float(MeleeDamage) * (1.f / float(TotalHitCount));

    if (class'MeleeHelper'.static.PerformMeleeSwing(KFWeapon(Weapon), Self, HitRegisterCount == LastHitRegisterCount))
    {
        LastHitRegisterCount = HitRegisterCount;
    }

    Weapon.PlayOwnedSound(FireEndSound, SLOT_Interact, TransientSoundVolume,, TransientSoundRadius,, false);
    
    MeleeDamage = default.MeleeDamage;

    CurrentHitCount++;
    if (CurrentHitCount >= TotalHitCount || (Weapon.Instigator.PendingWeapon != None && Weapon.Instigator.PendingWeapon != Weapon))
    {
        Weapon.PlayOwnedSound(FireEndSound, SLOT_Interact, TransientSoundVolume,, TransientSoundRadius,, false);
        return;
    }

    bAwaitingHitTimer = true;
    NextHitTimerPop = Level.TimeSeconds + HitInterval;
}

simulated function ModeTick(float DeltaTime)
{
    Super.ModeTick(DeltaTime);

    if (bAwaitingHitTimer && NextHitTimerPop > Level.TimeSeconds)
    {
        bAwaitingHitTimer = false;
        Timer();
    }
}

defaultproperties
{
    TotalHitCount = 3
    CurrentHitCount = 0
    HitInterval = 0.15f
    bAwaitingHitTimer = false
    NextHitTimerPop = 0.f

    MeleeDamage = 540
    DamagedelayMin=0.50
    DamagedelayMax=0.50

    MeleeHitVolume = 0.25f
}
