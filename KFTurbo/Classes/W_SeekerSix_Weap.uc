class W_SeekerSix_Weap extends SeekerSixRocketLauncher;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local W_SeekerSix_Proj Rocket;
    local W_SeekerSix_Seeking_Proj SeekingRocket;

    bBreakLock = true;

    if (bLockedOn && SeekTarget != None)
    {
        SeekingRocket = Spawn(class'W_SeekerSix_Seeking_Proj',,, Start, Dir);
        SeekingRocket.Seeking = SeekTarget;
        return SeekingRocket;
    }
    else
    {
        Rocket = Spawn(class'W_SeekerSix_Proj',,, Start, Dir);
        return Rocket;
    }
}

defaultproperties
{
     ReloadRate=3.350000

     Weight=8.000000
     FireModeClass(0)=Class'KFTurbo.W_SeekerSix_Fire'
     PickupClass=Class'KFTurbo.W_SeekerSix_Pickup'
}
