//Killing Floor Turbo W_SeekerSix_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SeekerSix_Weap extends WeaponSeekerSixRocketLauncher;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

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
    FireModeClass(1)=Class'KFTurbo.W_SeekerSix_Fire_Multi'
    PickupClass=Class'KFTurbo.W_SeekerSix_Pickup'
}
