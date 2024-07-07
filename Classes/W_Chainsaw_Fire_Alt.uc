class W_Chainsaw_Fire_Alt extends KFMod.ChainsawAltFire;

var() int TotalHitCount;
var int CurrentHitCount;
var bool bAwaitingHitTimer;
var float HitInterval;
var float NextHitTimerPop;

simulated event ModeDoFire()
{
    Super.ModeDoFire();

    CurrentHitCount = 0;
    HitInterval = default.HitInterval / GetFireSpeed();
}

simulated function Timer()
{
    MeleeDamage = float(MeleeDamage) * (1.f / float(TotalHitCount));
    Super.Timer();
    MeleeDamage = default.MeleeDamage;

    CurrentHitCount++;
    if (CurrentHitCount >= TotalHitCount || (Weapon.Instigator.PendingWeapon != None && Weapon.Instigator.PendingWeapon != Weapon))
    {
        Weapon.PlayOwnedSound(FireEndSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,,false);
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
